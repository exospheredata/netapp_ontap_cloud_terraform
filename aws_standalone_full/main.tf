provider "aws" {
  profile   = "${var.aws_profile}"
  region    = "${var.region}"
}

/*
Create a new AWS VPC
*/
resource "aws_vpc" "lab" {
  cidr_block       = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags {
    Name = "VPC for ONTAP Cloud",
    "Owned By" =  "${var.owner_name}",
    "Deployed Using" = "Terraform",
    "Designed by" = "www.exospheredata.com"
  }
}

resource "aws_subnet" "lab" {
  vpc_id     = "${aws_vpc.lab.id}"
  cidr_block = "${cidrsubnet(var.vpc_cidr, 8, 1)}"

  tags {
    Name = "Subnet for Infrastructure",
    "Owned By" =  "${var.owner_name}",
    "Deployed Using" = "Terraform",
    "Designed by" = "www.exospheredata.com"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = "${aws_subnet.lab.id}"
  route_table_id = "${aws_vpc.lab.default_route_table_id}"
  depends_on = [
    "aws_subnet.lab"
  ]
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.lab.id}"
  depends_on = [
    "aws_vpc.lab"
  ]

  tags {
    Name = "IGW for ONTAP Cloud VPC",
    "Owned By" =  "${var.owner_name}",
    "Deployed Using" = "Terraform",
    "Designed by" = "www.exospheredata.com"
  }
}

resource "aws_route" "igw" {
  route_table_id          = "${aws_vpc.lab.default_route_table_id}"
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = "${aws_internet_gateway.gw.id}"
}

/*
Create a new IAM Role that can be assigned to the OnCommand Cloud Manager
EC2 instance and provide access controls to the connected AWS account.
*/
resource "aws_iam_role" "occm_ec2_role" {
  name                = "occm_instance_profile_${replace(lower(var.owner_name)," ","_")}"
  description         = "Grants access to services required by NetApp's OnCommand Cloud Manager"
  assume_role_policy  = "${file("${path.module}/files/occm-ec2-role.json")}"
}

/*
EC2 Instance Profile based on the provided role
*/
resource "aws_iam_instance_profile" "occm_instance_profile" {
  name        = "occm_instance_profile_${replace(lower(var.owner_name)," ","_")}"
  role        = "${aws_iam_role.occm_ec2_role.id}"
  depends_on  = [
    "aws_iam_role.occm_ec2_role"
  ]
}

/*
Default policy document for privileges requireed by OnCommand Cloud Manager
*/
resource "aws_iam_role_policy" "occm_role_policy" {
  name        = "occm_instance_profile_${replace(lower(var.owner_name)," ","_")}"
  role        = "${aws_iam_role.occm_ec2_role.id}"
  depends_on  = [
    "aws_iam_role.occm_ec2_role"
  ]

  policy = "${file("${path.module}/files/occm-role-policy.json")}"
}

/*
New Security group granting Web access and SSH access to the OnCommand Cloud Manager host.  Also,
allow all outgoing traffic.
*/
resource "aws_security_group" "occm_access" {
  name                = "occm_access_${replace(lower(var.owner_name)," ","_")}"
  description         = "Allow all inbound traffic on ports 80, 443, and 22."
  vpc_id              = "${aws_subnet.lab.vpc_id}"
  depends_on = [
    "aws_route.igw"
    ]

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
    "Deployed Using" = "Terraform",
    "Designed by" = "www.exospheredata.com"
  }

}

/*
Launch a new AWS Marketplace instance of Netapp's OnCommand Cloud Manager and assign the newly
created EC2 Instance Profile.
*/
resource "aws_instance" "OCCM" {
  depends_on = [
    "aws_iam_role_policy.occm_role_policy",
    "aws_iam_role.occm_ec2_role",
    "aws_security_group.occm_access"
  ]
  ami                         = "${lookup(var.occm_amis, var.region)}"
  instance_type               = "t2.medium"
  subnet_id                   = "${aws_subnet.lab.id}"
  vpc_security_group_ids      = ["${aws_security_group.occm_access.id}"]
  key_name                    = "${var.key_name}"
  associate_public_ip_address = "true"
  iam_instance_profile        = "${aws_iam_instance_profile.occm_instance_profile.id}"
  tags {
    Name = "OnCommand Cloud Manager",
    "Owned By" =  "${var.owner_name}",
    "Deployed Using" = "Terraform",
    "Provisioned Using" = "CHEF",
    "Designed by" = "www.exospheredata.com"
  }

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
      "mkdir -p /tmp/"
    ]
  }
  provisioner "file" {
    source      = "${path.module}/scripts/check_server_health.sh"
    destination = "/tmp/check_server_health.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/check_server_health.sh",
      "/tmp/check_server_health.sh",
      "echo The Instance is ready to be provisioned"
    ]
  }
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
  /*
  ===========
  These steps will only be run when the terraform destroy command is sent
  ===========

  The following will only run on a destroy of the environment and needs to be run
  to properly destroy the ONTAP Cloud instance.
  */
  provisioner "remote-exec" {
    when = "destroy"
    inline = [
      "rm -rf /tmp/chef",
      "rm -rf /tmp/cookbooks.tar.gz",
      "mkdir -p /tmp/chef/data_bags/occm",
      "mkdir -p /tmp/ontap_cloud_cookbooks"
    ]
  }

  /*
  Create archive of the cookbooks and dependencies. Upon creation, upload the file to the server and then remove the local copy.

  the path_root variable tells the system to look at the top level of the modules and not in the module path.
  */
  provisioner "file" {
    when = "destroy"
    source      = "${path.module}/files/Berksfile"
    destination = "/tmp/ontap_cloud_cookbooks/Berksfile"
  }

  /*
  Send all interpolated files to the remote server
  */
  provisioner "file" {
    when = "destroy"
    source      = "${path.module}/files/solo.rb"
    destination = "/tmp/chef/solo.rb"
  }
  provisioner "file" {
    when = "destroy"
    content     = "${data.template_file.destroy_ontap.rendered}"
    destination = "/tmp/chef/dna.json"
  }
  provisioner "file" {
    when = "destroy"
    source      = "${path.module}/scripts/bootstrap.sh"
    destination = "/tmp/chef/bootstrap.sh"
  }

  /*
  Setup the CHEF Data bags
  */
  provisioner "file" {
    when = "destroy"
    content     = "${data.template_file.admin_credentials.rendered}"
    destination = "/tmp/chef/data_bags/occm/admin_credentials.json"
  }

  /*
  Execute Bootstrap script to apply CHEF configuration and setup.
  */
  provisioner "remote-exec" {
    when = "destroy"
    inline = [
      "chmod +x /tmp/chef/bootstrap.sh",
      "sudo /tmp/chef/bootstrap.sh",
    ]
  }
}

/*
Deploy ONTAP Cloud system and configuration via CHEF
*/
resource "null_resource" "ontap_cloud" {
  triggers {
    occm_id = "${aws_instance.OCCM.id}",
    converge = "${var.converge}"
  }
  depends_on = [
    "aws_iam_role_policy.occm_role_policy",
    "aws_iam_role.occm_ec2_role",
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

  /*
  ===========
  These steps will only be run when the terraform apply command is sent
  ===========

  */
  provisioner "remote-exec" {
    inline = [
      "rm -rf /tmp/chef",
      "rm -rf /tmp/ontap_cloud_cookbooks",
      "mkdir -p /tmp/chef/data_bags/occm",
      "mkdir -p /tmp/ontap_cloud_cookbooks"
    ]
  }

  /*
  Send all interpolated files to the remote server
  */
  provisioner "file" {
    source      = "${path.module}/files/Berksfile"
    destination = "/tmp/ontap_cloud_cookbooks/Berksfile"
  }
  provisioner "file" {
    source      = "${path.module}/files/solo.rb"
    destination = "/tmp/chef/solo.rb"
  }
  provisioner "file" {
    content     = "${data.template_file.create_ontap.rendered}"
    destination = "/tmp/chef/dna.json"
  }
  provisioner "file" {
    source      = "${path.module}/scripts/bootstrap.sh"
    destination = "/tmp/chef/bootstrap.sh"
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

  /*
  Execute Bootstrap script to apply CHEF configuration and setup.
  */
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/chef/bootstrap.sh",
      "sudo /tmp/chef/bootstrap.sh",
    ]
  }
}
