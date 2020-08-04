# Terraform Version Pinning
terraform {
  required_version = ">= 0.12"
  required_providers {
    azurerm = {
      version = "~> 2.1.0"
    }
    bigip = {
      version = ">= 1.3.0"
    }
  }
}