
data "template_file" "admin_credentials" {
  template = "${file("templates/data_bags/occm/admin_credentials.json.tpl")}"
  vars {
    occm_email = "${var.occm_email}"
    occm_password = "${var.occm_password}"
  }
}

data "template_file" "ontap_credentials" {
  template = "${file("templates/data_bags/occm/ontap_credentials.json.tpl")}"
  vars {
    ontap_name = "${var.ontap_name}"
    svm_password = "${var.ontap_password}"
  }
}

data "template_file" "create_ontap" {
  template = "${file("templates/create_ontap.json.tpl")}"
  vars {
    company_name = "${var.company_name}"
    ontap_name = "${var.ontap_name}"
    ontap_size = "${var.ontap_size}"
    ontap_instance = "${var.ontap_instance}"
    license_type = "${var.license_type}"
    vpc_id = "${aws_subnet.occm.vpc_id}"
    region = "${var.region}"
    subnet_id = "${aws_subnet.occm.id}"
  }
}

data "template_file" "destroy_ontap" {
  template = "${file("templates/destroy_ontap.json.tpl")}"
  vars {
    ontap_name = "${var.ontap_name}"
  }
}
