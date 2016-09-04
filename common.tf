# General

variable "aws_region" {
  type = "string"
}

variable "aws_profile" {
  type = "string"
}

# AWS Credentials
provider "aws" {
  profile = "${var.aws_profile}"
  region  = "${var.aws_region}"
}

variable "aws_accounts" {
  type = "map"

  default = {
    development = ""
    testing     = ""
    staging     = ""
    production  = ""

    master     = ""

    #3RD parties, i.e.
    datadog = "464622532012"
  }
}

variable "environment" {
  type = "string"
}

# S3 Buckets
variable "terraform_state_bucket" {
  type = "string"

  default = "my_company-terraform-state"
}
