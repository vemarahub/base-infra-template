terraform {
  required_version = ">= 0.13.0, < 2.0.0"
  required_providers {
    # tflint-ignore: terraform_required_providers
    aws = ">= 3.0, < 6.0"
  }
}
