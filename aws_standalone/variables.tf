/*
Mandatory Variables
*/
variable "owner_name" {
  description = "Your Username to identify your infrastructure"
}

variable "key_name" {
  description = "Existing AWS KeyPair name.  Must match the KeyPair referenced in key_file_path"
}

variable "key_file_path" {
  description = "Location of the local private key file for the EC2 instance."
}

variable "converge" {
  description = "When set to 'true', the configuration resources will all re-apply to their hosts."
  default     = "false"
}
/*
AWS specific
*/
variable "aws_profile" {
  description = "The aws credentials file profile name."
  default     = "default"
}

variable "region" {
  description = "AWS region to which the systems will be deployed."
  default     = "us-east-1"
}

variable "subnet_id" {
  description = "AWS Subnet to which the systems will be deployed.  Must exist in your region."
}

/*
OnCommand Cloud Manager specific
*/
variable "occm_email" {
  description = "Email address (username) for OnCommand Cloud Manager instance"
  default     = "netapp@peritus.lab"
}

variable "occm_password" {
  description = "Administrative password for OnCommand Cloud Manager instance"
  default     = "peritus"
}

variable "company_name" {
  description = "Your company name to which the OnCommand Cloud manager system will be registered"
  default     = "Peritus Lab"
}

variable "occm_amis" {
  type = "map"
  description = "List of the OnCommand Cloud Manager AMIs per region."
  default = {
    "ap-south-1"     = "ami-c2bdc2ad"
    "eu-west-2"      = "ami-fba8bf9f"
    "eu-west-1"      = "ami-bf9986d9"
    "ap-northeast-2" = "ami-2e8d5240"
    "ap-northeast-1" = "ami-8e979ee9"
    "sa-east-1"      = "ami-982843f4"
    "ca-central-1"   = "ami-38e9565c"
    "ap-southeast-1" = "ami-b89c1edb"
    "ap-southeast-2" = "ami-cb3322a8"
    "eu-central-1"   = "ami-975bfff8"
    "us-east-1"      = "ami-392c0a2f"
    "us-east-2"      = "ami-98a98ffd"
    "us-west-1"      = "ami-379ebc57"
    "us-west-2"      = "ami-0258537b"
  }
}

/*
ONTAP Cloud specific
*/
variable "ontap_name" {
  description = "New ONTAP Cloud Name"
  default     = "demolab"
}

variable "ontap_password" {
  description = "New ONTAP Cloud password for Admin"
  default     = "netapp123"
}

variable "ontap_size" {
  description = "Size of the Aggregate: Pick One - 100GB, 500GB, 1TB, 2TB, 4TB, 8TB"
  default     = "500GB"
}

variable "ontap_instance" {
  description = "AWS Instance type for ONTAP Cloud instance. If not set, the default is 'm4.xlarge'.  Note: must be a supported size for the selected license type"
  default     = "m4.xlarge"
}

variable "license_type" {
  description = "ONTAP Cloud license type.  Supported values are [cot-explore-paygo, cot-standard-paygo, cot-premium-paygo]. Default value is cot-explore-paygo"
  default     = "cot-explore-paygo"
}

variable "ontap_write_speed" {
  description = "Sets the ONTAP Cloud write speed.  'Normal' is standard with high consistency guarantee, while 'high' will increase write performance at the risk of potential data loss in the event of a failure."
  default = "normal"
}
