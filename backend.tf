terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"      # Update this to your bucket
    key            = "iac-w-ansible-terraform/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "my-terraform-locks"             # Update or remove if not using DynamoDB locks
    encrypt        = true
  }
}
