variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group" {
  type = string
}

variable "tags" {
  type = map
}

variable "vnet_address_space" {
  type = list(string)
}

variable "web_subnet_name" {
  type = string
}

variable "web_subnet_address" {
  type = list(string)
}

variable "app_subnet_name" {
  type = string
}

variable "app_subnet_address" {
  type = list(string)
}

variable "db_subnet_name" {
  type = string
}

variable "db_subnet_address" {
  type = list(string)
}

variable "bastion_subnet_name" {
  type = string
}

variable "bastion_subnet_address" {
  type = list(string)
}