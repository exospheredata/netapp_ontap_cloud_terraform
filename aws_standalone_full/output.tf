/*
Output Variables
*/
output "CloudManager-Public-Url" {
  value = "https://${aws_instance.OCCM.0.public_ip}/occmui/"
}
output "CloudManager-Private-Url" {
  value = "https://${aws_instance.OCCM.0.private_ip}/occmui/"
}
