# Terraform Template for ONTAP Cloud for AWS standalone instance with OnCommand Cloud Manager
### _Manages the deployment of NetApp OnCommand Cloud Manager and ONTAP Cloud_

This Terraform template will deploy a NetApp OnCommand Cloud Manager environment into the chosen AWS region and location.  As part of the process, a new ONTAP Cloud system will be deployed with a 1TB aggregate using an ONTAP Cloud Explore system.  The solution leverages the [ONTAP Cloud CHEF Cookbook](github.com/exospheredata/netapp_ontap_cloud) to provision and configure the environment.

_Note: On `terraform destroy`, the associated ONTAP Cloud system deployed will be destroyed and removed from your cloud account_

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Requirements](#requirements)
  - [ONTAP Cloud charges and AWS fees](#ontap-cloud-charges-and-aws-fees)
  - [NetApp and Amazon Marketplace registration](#netapp-and-amazon-marketplace-registration)
  - [Tools and versions](#tools-and-versions)
  - [Resources](#resources)
  - [Variables](#variables)
    - [AWS Variables](#aws-variables)
    - [OnCommand Cloud Manager Variables](#oncommand-cloud-manager-variables)
    - [ONTAP Cloud for AWS](#ontap-cloud-for-aws)
  - [Terraform Configuration Files](#terraform-configuration-files)
    - [Files](#files)
    - [Scripts](#scripts)
    - [Templates](#templates)
    - [Default Variable Values](#default-variable-values)
  - [CHEF Solo integration](#chef-solo-integration)
    - [Run_Lists and Attributes](#run_lists-and-attributes)
- [Usage](#usage)
  - [Before you begin](#before-you-begin)
  - [Re-running the provisioning effort and changes](#re-running-the-provisioning-effort-and-changes)
- [Contribute](#contribute)
- [License & Authors](#license-&-authors)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Requirements

### ONTAP Cloud charges and AWS fees
This Terraform template will deploy cloud instances and resources into your Amazon Web Services (AWS) account.  Usage of this template will likely lead to cloud charges as resources are consumed.  The template will deploy a NetApp OnCommand Cloud Manager instance and a single ONTAP Cloud for AWS instance into the same VPC/Subnet.  Usage of this template in your organization is done so with the explicit understanding that you will be responsible for these charges.

### NetApp and Amazon Marketplace registration
Prior running this template, you will need to ensure that your AWS account has subscribed to the official ONTAP Cloud for AWS and OnCommand Cloud Manager images:
* Visit the [official page for OnCommand Cloud Manager in the AWS Marketplace](https://aws.amazon.com/marketplace/pp/B018REK8QG]) for more information.
* Visit the [official page for ONTAP Cloud in the AWS Marketplace](https://aws.amazon.com/marketplace/pp/B011KEZ734]) for more information.

### Tools and versions

- OnCommand Cloud Manager 3.2.0+
- Chef Solo 12.5+
- Terraform v0.9.2+

### Resources
This Terraform will create the following resources:
- AWS Identity Access Management (IAM) Policy
- AWS Identity Access Management (IAM) Profile
- AWS Elastic Cloud Compute (EC2) IAM Role
- AWS Virtual Private Cloud (VPC) Security Group
- AWS EC2 Instance using OnCommand Cloud Manager marketplace image
- NetApp ONTAP Cloud for AWS instance with 1TB of storage

### Variables
_NOTE: properties in bold are required_

#### AWS Variables
| Variable | Description |
| ------------- |-------------|
| **`aws_profile`** | Identifies the AWS Shared Credentials File profile name.  More information found [in the official AWS documentation](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html).|
| **`key_name`** | Existing AWS KeyPair name.  Must match the KeyPair referenced in `key_file_path`.|
| **`key_file_path`** | Local file path to the SSH key selected as the `aws_keyname`.|
| **`region:`** | AWS region to which the systems will be deployed.|
| **`subnet_id`** | AWS Subnet to which the systems will be deployed.  Must exist in your region.|

#### OnCommand Cloud Manager Variables
| Variable | Description |
| ------------- |-------------|
| **`occm_email`**| The email address to register as the Cloud Admin for the new OnCommand Cloud Manager server.|
| **`occm_password`**| OnCommand Cloud Manager Admin password.|
| **`company_name`**| Your company name to which the OnCommand Cloud manager system will be registered.|
| `occm_amis`| This is a reference variable and does not need to be set.  List of the OnCommand Cloud Manager AMIs per region.|

#### ONTAP Cloud for AWS
| Variable | Description |
| ------------- |-------------|
| **`ontap_name`**| New ONTAP Cloud Name.|
| **`ontap_password`**| New ONTAP Cloud password for Admin.|
| `ontap_size`| Size of the Aggregate: Pick One - 100GB, 500GB, 1TB, 2TB, 4TB, 8TB.  Default = '1TB'.|
| `ontap_instance`| AWS Instance type for ONTAP Cloud instance.  Note: must be a supported size for the selected license type".  Default = 'm4.xlarge'.|
| `license_type`| ONTAP Cloud license type.  Supported values are ['cot-explore-paygo', 'cot-standard-paygo', 'cot-premium-paygo']. Default value is 'cot-explore-paygo'|

### Terraform Configuration Files

```
├── aws_standalone/
│   ├── files
│   ├── scripts
│   │   ├── check_server_health.sh
│   │   ├── bootstrap.sh
│   ├── templates
│   │   ├── create_ontap.json.tpl
│   │   ├── destroy_ontap.json.tpl
│   │   ├── data_bags
│   │   │   ├── occm
│   │   │   │   ├── admin_credentials.json.tpl
│   │   │   │   ├── ontap_credentials.json.tpl
│   ├── terraform.tfvars
```

#### Files
---
- `files/occm-ec2-role.json`: Default role model for IAM EC2 Role used by OnCommand Cloud manager
- `files/occm-role-policy.json`: Creates a new IAM policy used by OnCommand Cloud Manager's IAM EC2 Role and sets valid permissions for the system.
- `files/solo.rb`: Configures CHEF Solo defaults for bootstrapping purposes.

#### Scripts
---
- `scripts/check_server_health.sh`: Forces Terraform to wait for the OnCommand Cloud Manager system services to be fully up prior to provisioning.  This solves a race condition where SSH responds faster than the services have time to complete first-boot.
- `scripts/bootstrap.sh`: Executes the installation of Git, downloads the Chef Client, Clones the CHEF cookbooks, and triggers the CHEF Solo command to self-bootstrap.

#### Templates
---
- `templates/create_ontap.json.tpl`: Configures the CHEF run_list for the process of setting up OnCommand Cloud Manager and deploying ONTAP Cloud for AWS.  This file is automatically configured during execution based on supplied variables.
- `templates/destroy_ontap.json.tpl`: Configures the CHEF run_list for the process of destroying the ONTAP Cloud for AWS system.  This file is automatically configured during execution based on supplied variables.
- `data_bags/occm/admin_credentials.json.tpl`: Template for the CHEF Data_bag to setup and access the OnCommand Cloud Manager system.
- `data_bags/occm/ontap_credentials.json.tpl`: Template for the CHEF Data_bag to configure the credetials for the newly deployed ONTAP Cloud for AWS system.

#### Default Variable Values
---
Create a new file called `terraform.tfvars` to include the variable name and the value to which to assign.  This file can be used to preserve the values of the Terraform variables but is explicitly not included in source code control as per the included .gitignore file.

```
aws_profile = "exosphere"
key_name = "terraform"
key_file_path = "~/Downloads/terraform.pem"

region = "us-east-1"
subnet_id = "subnet-7ce3f846"

occm_email = "admin@test.lab"
occm_password = "Netapp123"
company_name = "exospheredata"

ontap_name = "demolab"
ontap_password = "Netapp123"
```

### CHEF Solo integration
This Terraform template requires the use of the [ONTAP Cloud CHEF Cookbook](github.com/exospheredata/netapp_ontap_cloud) from Exosphere Data, LLC.  This cookbook is loaded automatically to the OnCommand server.

#### Run_Lists and Attributes
Once the OnCommand Cloud Manager has booted and passed the server_health tests, the remote provisioners will transfer the files and start the bootstap process.  The current list of supported node attributes can be found at the [ONTAP Cloud CHEF Cookbook](github.com/exospheredata/netapp_ontap_cloud) repository.  The values for these can be added or removed in the `create_ontap.json.tpl` file in the templates directory.

## Usage
### Before you begin
Verify your meet these requirements
- [Terraform v0.9.2+](https://www.terraform.io/downloads.html) installed on your local machine
- You have an active and valid AWS account with an Identity and Access Management user credentials. More information found [in the official AWS documentation](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html).
- You have registered for access to the OnCommand Cloud Manager and ONTAP Cloud AMI
    - Simply go to each of the below links and register
    - [OnCommand Cloud Manager](https://aws.amazon.com/marketplace/pp/B018REK8QG)
    - [ONTAP Cloud for AWS](https://aws.amazon.com/marketplace/pp/B011KEZ734)


### Re-running the provisioning effort and changes
Since the ONTAP Cloud system can be added or removed outside of this infrastructure, the provisioner for this resource was moved to use the null_resource method and outside of the instance creation.  This means that if you need to re-run the configuration, you will only need to `taint` the resource as such:
```
terraform taint null_resource.ontap_cloud
```

The above command will force the system to run the provisioner once again.  The process will idempodently execute the run_list provided in the `create_ontap.json.tpl` under recipes.

## Contribute
 - Fork it
 - Create your feature branch (git checkout -b my-new-feature)
 - Commit your changes (git commit -am 'Add some feature')
 - Push to the branch (git push origin my-new-feature)
 - Create new Pull Request

## License & Authors

**Author:** Jeremy Goodrum ([jeremy@exospheredata.com](mailto:jeremy@exospheredata.com))

**Copyright:** 2017 Exosphere Data, LLC

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
