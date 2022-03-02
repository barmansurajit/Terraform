# Generic Input Variables
# Business Division
variable "business_divsion" {
  type    = string
  default = "hr"
}
# Environment Variable
variable "environment" {
  type    = string
  default = "dev"
}

# Azure Resource Group Name 
variable "resource_group_name" {
  type    = string
  default = "rg-default"
}

# Azure Resources Location
variable "resource_group_location" {
  type    = string
  default = "centralus"
}