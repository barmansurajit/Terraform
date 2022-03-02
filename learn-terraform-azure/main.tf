terraform {
  # Required providers and their versions
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }
  # Required Terraform version
  required_version = ">= 1.1.0"
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}