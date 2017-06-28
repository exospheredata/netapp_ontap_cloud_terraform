{
  "occm": {
    "company_name":"${company_name}"
  },
  "ontap_cloud": {
    "ontap": {
      "standalone": {
        "name": "${ontap_name}",
        "size": "${ontap_size}",
        "instance_type": "${ontap_instance}",
        "license_type": "${license_type}",
        "write_speed": "${write_speed}"
      }
    },
    "aws": {
      "vpc_id" : "${vpc_id}",
      "region" : "${region}",
      "subnet_id" : "${subnet_id}"
    }
  },
  "run_list": [
    "recipe[netapp_ontap_cloud::ontap_cloud_aws_standalone]"
  ]
}
