variable "name" {
  type = string
  default = "rg-default"
}

variable "location" {
  type = string
  default = "eastus2"
}

variable "tags" {
  type = map
  default = {
    owner = "IT"
    environment = "dev"
  }
}