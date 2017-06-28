# aws_standalone Terraform CHANGELOG

This file is used to list changes made in each version of the aws_standalone Terraform.


## v1.5.0

- aws_standalone
  - ADD: Berksfile for cookbook resolution
  - UPDATE: Files::occm-role-policy to include updated IAM requirements for OCCM 3.3.0
  - UPDATE: Script::bootstrap.sh to install the ChefDK client and use the Berksfile to package the cookbooks and dependencies.
  - UPDATE: Templates::create_ontap.json.tpl to include variable to set the ontap_write_speed
  - UPDATE: Main.tf to streamline resource idempotence and deployment
  - UPDATE: Output.tf variable outputs
  - UPDATE: templates.tf to include changes in setting the write_speed
  - UPDATE: variables.tf formatting and defaults.

- aws_standalone_full
  ADD: Berksfile for cookbook resolution
  UPDATE: Files::occm-role-policy to include updated IAM requirements for OCCM 3.3.0
  UPDATE: Script::bootstrap.sh to install the ChefDK client and use the Berksfile to package the cookbooks and dependencies.
  UPDATE: Templates::create_ontap.json.tpl to include variable to set the ontap_write_speed
  UPDATE: Main.tf to streamline resource idempotence and deployment
  UPDATE: Output.tf variable outputs
  UPDATE: templates.tf to include changes in setting the write_speed
  UPDATE: variables.tf formatting and defaults.

## v1.0.0

- Initial release with support for deployment and setup of OnCommand Cloud Manager and the creation and deletion of ONTAP Cloud for AWS systems
