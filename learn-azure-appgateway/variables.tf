variable "resource_group_name" {
  default = "rg-ag-iis-poc"
}
variable "resouce_location" {
  default = "East US"
}
variable "vnet_name" {
  default = "web-vnet-iis"
}
variable "web_subnet" {
  default = "web-subnet-iis"
}
variable "ag_subnet" {
  default = "ag-subnet-iis"
}
variable "web_nsg" {
  default = "web-nsg-iis"
}
variable "ag_nsg" {
  default = "ag-nsg-iis"
}
variable "vm_public_ip" {
  default = "vm-publicip-iis"
}
variable "ag_public_ip" {
  default = "ag-publicip-iis"
}
variable "network_interface_name" {
  default = "web-nic-iis"
}
variable "vm_name" {
  type    = list(string)
  default = ["win-vm-1", "win-vm-2"]
}
variable "iis_server" {
  default = "iis-server"
}
variable "app_gateway" {
  default = "ag-iis"
}
variable "ag_ip_config" {
  default = "ag-ip-config-iis"
}
variable "ag_frontend_port" {
  default = "ag-frontend-port-iis"
}
variable "ag_frontend_ip_config" {
  default = "ag-frontend-ip-config-iis"
}
variable "ag_backend_address_pool" {
  default = "ag-backend-pool-iis"
}
variable "ag_backend_http_setting" {
  default = "ag-backend-http-setting-iis"
}
variable "ag_http_listener" {
  default = "ag-http-listener"
}
variable "ag_request_routing_rule" {
  default = "ag-request-routing-rule-iis"
}
