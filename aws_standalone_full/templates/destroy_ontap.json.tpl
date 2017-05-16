{
  "ontap_cloud": {
    "ontap": {
      "standalone": {
        "name": "${ontap_name}"
      }
    }
  },
  "run_list": [
    "recipe[netapp_ontap_cloud::ontap_cloud_aws_standalone_delete]"
  ]
}
