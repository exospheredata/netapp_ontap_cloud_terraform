variable "aws_profile" {
  description = "The aws credentials file profile name."
}

variable "key_name" {
  description = "Existing AWS KeyPair name.  Must match the KeyPair referenced in key_file_path"
}

variable "key_file_path" {
  description = "Location of the local private key file for the EC2 instance."
}

variable "region" {
  description = "AWS region to which the systems will be deployed."
}

variable "occm_email" {
  description = "Email address (username) for OnCommand Cloud Manager instance"
}

variable "occm_password" {
  description = "Administrative password for OnCommand Cloud Manager instance"
}

variable "company_name" {
  description = "Your company name to which the OnCommand Cloud manager system will be registered"
}

variable "occm_amis" {
  type = "map"
  description = "List of the OnCommand Cloud Manager AMIs per region."
  default = {
    "ap-south-1"     = "ami-08443567"
    "eu-west-2"      = "ami-6f73660b"
    "eu-west-1"      = "ami-8dd7f2eb"
    "ap-northeast-2" = "ami-1e61b070"
    "ap-northeast-1" = "ami-21abeb46"
    "sa-east-1"      = "ami-b0c3a7dc"
    "ca-central-1"   = "ami-f8b8059c"
    "ap-southeast-1" = "ami-432e9a20"
    "ap-southeast-2" = "ami-d8aaacbb"
    "eu-central-1"   = "ami-b7c20ad8"
    "us-east-1"      = "ami-6c65a27a"
    "us-east-2"      = "ami-4811342d"
    "us-west-1"      = "ami-e63a6686"
    "us-west-2"      = "ami-68e96c08"
  }
}

variable "ontap_name" {
  description = "New ONTAP Cloud Name"
}

variable "ontap_password" {
  description = "New ONTAP Cloud password for Admin"
}

variable "ontap_size" {
  description = "Size of the Aggregate: Pick One - 100GB, 500GB, 1TB, 2TB, 4TB, 8TB"
  default = "1TB"
}

variable "ontap_instance" {
  description = "AWS Instance type for ONTAP Cloud instance. If not set, the default is 'm4.xlarge'.  Note: must be a supported size for the selected license type"
  default = "m4.xlarge"
}

variable "license_type" {
  description = "ONTAP Cloud license type.  Supported values are [cot-explore-paygo, cot-standard-paygo, cot-premium-paygo]. Default value is cot-explore-paygo"
  default = "cot-explore-paygo"
}
