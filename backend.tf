# This is a partial backend configuration.
# The 'key' attribute will be provided via the command line during initialization.
#
# For DEV environment:
# terraform init -backend-config="key=dev/terraform.tfstate"
#
# For PROD environment:
# terraform init -backend-config="key=prod/terraform.tfstate"

terraform {
  backend "s3" {
    bucket         = "mapapp-terraform-state-storage" # Please replace with your unique bucket name
    region         = "us-east-1"
    dynamodb_table = "mapapp-terraform-state-lock"
    encrypt        = true
  }
}