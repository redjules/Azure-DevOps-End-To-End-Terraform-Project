variable "public_key_loc" {
  default = "C:/Users/dpste/OneDrive/Documents/terraform/intech-azure-quickstart/scripts/id_rsa.pub"
}

variable "resource_group_location" {
  type        = string
  default     = "switzerlandnorth"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "intech"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}