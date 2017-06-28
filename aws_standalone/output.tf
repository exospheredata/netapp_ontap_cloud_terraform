/*
Output Variables
*/
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
