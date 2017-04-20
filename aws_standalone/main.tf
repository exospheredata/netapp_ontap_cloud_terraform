provider "aws" {
  profile   = "${var.aws_profile}"
  region    = "${var.region}"
}

/*
Create a new IAM Role that can be assigned to the OnCommand Cloud Manager
EC2 instance and provide access controls to the connected AWS account.
*/
resource "aws_iam_role" "occm_ec2_role" {
  name = "occm_ec2_role"
  description = "Grants access to services required by NetApp's OnCommand Cloud Manager"
  assume_role_policy = "${file("files/occm-ec2-role.json")}"
}

/*
EC2 Instance Profile based on the provided role
*/
resource "aws_iam_instance_profile" "occm_instance_profile" {
  name = "occm_instance_profile"
  role = "${aws_iam_role.occm_ec2_role.id}"
  depends_on = [
    "aws_iam_role.occm_ec2_role"
  ]
}

/*
Default policy document for privileges requireed by OnCommand Cloud Manager
*/
resource "aws_iam_role_policy" "role_policy" {
  name        = "occm_instance_role_policy"
  role        = "${aws_iam_role.occm_ec2_role.id}"
  depends_on = [
    "aws_iam_role.occm_ec2_role"
  ]

  policy = "${file("files/occm-role-policy.json")}"
}

/*
New Security group granting Web access and SSH access to the OnCommand Cloud Manager host.  Also,
allow all outgoing traffic.
*/
resource "aws_security_group" "occm_access" {
  name        = "occm_access"
  description = "Allow all inbound traffic on ports 80, 443, and 22."
  vpc_id = "${data.aws_subnet.selected.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "OnCommand Cloud Manager Access",
    Created_By = "Terraform"
  }

}

/*
Launch a new AWS Marketplace instance of Netapp's OnCommand Cloud Manager and assign the newly
created EC2 Instance Profile.
*/
resource "aws_instance" "OCCM" {
  ami           							= "${lookup(var.occm_amis, var.region)}"
  instance_type 							= "t2.medium"
  subnet_id										= "${data.aws_subnet.selected.id}"
  vpc_security_group_ids 			= ["${aws_security_group.occm_access.id}"]
  key_name										= "${var.key_name}"
  associate_public_ip_address = "true"
  iam_instance_profile = "${aws_iam_instance_profile.occm_instance_profile.id}"
  tags {
    Name = "OnCommand Cloud Manager",
    "Deployed Using" = "Terraform",
    "Provisioned Using" = "CHEF",
    "Designed by" = "www.exospheredata.com",
    "Deployed on" = "${timestamp()}"
  }
  depends_on = [
    "aws_iam_role_policy.role_policy",
    "aws_iam_role.occm_ec2_role",
    "aws_iam_role_policy.role_policy",
    "aws_security_group.occm_access"
  ]

  /*
  Establish a connection to the OnCommand Cloud Manager system using
  ssh and the private key file provided.
  */
  connection {
    host = "${aws_instance.OCCM.0.public_ip}"
    type = "ssh"
    user = "ec2-user"
    private_key = "${file("${var.key_file_path}")}"
  }

  /*
  This provisioner set will ensure that we are able to connect to OnCommand Cloud Manager url
  before the rest of the provisioning occurs.  This fixes a bug where the OCCM server responds
  to SSH long before the service is online.
  */
  provisioner "remote-exec" {
      inline = [
        "mkdir -p /tmp"
      ]
  }
  provisioner "file" {
    source      = "./scripts/check_server_health.sh"
    destination = "/tmp/check_server_health.sh"
  }
  provisioner "remote-exec" {
      inline = [
        "chmod +x /tmp/check_server_health.sh",
        "/tmp/check_server_health.sh",
        "echo The Instance is ready to be provisioned"
      ]
  }
}

resource "null_resource" "ontap_cloud" {
  depends_on = [
    "aws_iam_role_policy.role_policy",
    "aws_iam_role.occm_ec2_role",
    "aws_iam_role_policy.role_policy",
    "aws_instance.OCCM"
  ]

  /*
  Establish a connection to the OnCommand Cloud Manager system using ssh and the private
  key file provided.

  The deployment process of an ONTAP Cloud system can take upwards of 25+ minutes depending
  on the state of the AWS Region.  We are setting a 60 minute timeout on this connection
  due to this potential length.
  */
  connection {
    host = "${aws_instance.OCCM.0.public_ip}"
    type = "ssh"
    user = "ec2-user" # OCCM Default username in AWS EC2 instances
    private_key = "${file("${var.key_file_path}")}"
    timeout = "60m"
  }

  provisioner "remote-exec" {
      inline = [
        "rm -rf /tmp/chef",
        "mkdir -p /tmp/chef/data_bags/occm"
      ]
  }
  provisioner "file" {
    source      = "./files/solo.rb"
    destination = "/tmp/chef/solo.rb"
  }
  provisioner "file" {
    source      = "./scripts/bootstrap.sh"
    destination = "/tmp/chef/bootstrap.sh"
  }
  provisioner "file" {
    content     = "${data.template_file.create_ontap.rendered}"
    destination = "/tmp/chef/dna.json"
  }

  /*
  Setup the CHEF Data bags
  */
  provisioner "file" {
    content     = "${data.template_file.admin_credentials.rendered}"
    destination = "/tmp/chef/data_bags/occm/admin_credentials.json"
  }
  provisioner "file" {
    content     = "${data.template_file.ontap_credentials.rendered}"
    destination = "/tmp/chef/data_bags/occm/${var.ontap_name}.json"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/chef/bootstrap.sh",
      "sudo /tmp/chef/bootstrap.sh",
    ]
  }

  /*
  The following will only run on a destroy of the environment and needs to be run
  to properly destroy the ONTAP Cloud instance.
  */
  provisioner "remote-exec" {
    when = "destroy"
    inline = [
      "rm -rf /tmp/chef",
      "mkdir -p /tmp/chef/data_bags/occm"
    ]
  }
  /*
  Setup the CHEF Data bags
  */
  provisioner "file" {
    when = "destroy"
    content     = "${data.template_file.admin_credentials.rendered}"
    destination = "/tmp/chef/data_bags/occm/admin_credentials.json"
  }
  provisioner "file" {
    when = "destroy"
    source      = "./files/solo.rb"
    destination = "/tmp/chef/solo.rb"
  }
  provisioner "file" {
    when = "destroy"
    source      = "./scripts/bootstrap.sh"
    destination = "/tmp/chef/bootstrap.sh"
  }
  provisioner "file" {
    when = "destroy"
    content     = "${data.template_file.destroy_ontap.rendered}"
    destination = "/tmp/chef/dna.json"
  }
  provisioner "remote-exec" {
    when = "destroy"
    inline = [
      "chmod +x /tmp/chef/bootstrap.sh",
      "sudo /tmp/chef/bootstrap.sh",
    ]
  }
}
