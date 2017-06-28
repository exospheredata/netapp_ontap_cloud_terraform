/*
Output Variables
*/
output "aws_lab_vpc_id" {
  value = "${aws_vpc.lab.id}"
}

output "aws_lab_subnet_id" {
  value = "${aws_subnet.lab.id}"
}

output "cloudmanager_public_url" {
  value = "https://${aws_instance.OCCM.0.public_ip}/occmui/"
}

output "cloudmanager_public_ip" {
  value = "${aws_instance.OCCM.0.public_ip}"
}


output "cloudmanager_private_url" {
  value = "https://${aws_instance.OCCM.0.private_ip}/occmui/"
}

output "cloudmanager_private_ip" {
  value = "${aws_instance.OCCM.0.private_ip}"
}
