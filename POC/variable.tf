#variables for the vm creation
variable "resource_group_name" {
  type        = string
  description = " resource_group_name"
  default     = ""
}

variable "vm_name" {
  type        = string
  description = " virtual machine Name"
  default     = "b2b-prod-jenkins-vm"
}

variable "zone" {
  description = "Zone in which VM will be deployed - Supported value in String 1,2 & 3"
  type        = string
  default     = ""
}

variable "ssh_key" {
  type    = string
  default = "b2b-prod-ci-esvm-key"
}

variable "ssh_key_rg" {
  type    = string
  default = "b2b-prod-ci-es-rg"
}

variable "custom_data" {
  description = "User data script for each VMSS"
  type        = string
  default     = ""
}

variable "username" {
  description = "The admin username of the VM that will be deployed."
  type        = string
  default     = ""
}

variable "computer_name" {
  type    = string
  default = "Es-vm"

}
variable "os_disk_type" {
  description = "Defines the disk type to be created. Valid options are Standard_LRS, StandardSSD_LRS & Premium_LRS."
  type        = string
  default     = "Standard_LRS"
}

variable "data_disk_type" {
  description = "Defines the disk type to be created. Valid options are Standard_LRS, StandardSSD_LRS & Premium_LRS."
  type        = string
  default     = "Standard_LRS"
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  type        = string
  default     = "Standard_B2ms"
}


# variable "tags" {
#   type        = map(string)
#   description = "A map of the tags to use on the resources that are deployed with this module."

#   default = {
#     source = "terraform"
#   }
# }

variable "enable_accelerated_networking" {
  type        = bool
  description = "(Optional) Enable accelerated networking on Network interface."
  default     = true
}

variable "subnet_name" {
  description = "Subnet Name"
  type        = string
  default     = ""
}

variable "vnet_rg_name" {
  description = "VNET RG NAME"
  type        = string
  default     = ""
}

variable "vnet_name" {
  description = "VNET Name"
  type        = string
  default     = ""
}

variable "private_ip_address" {
  description = "private ip address"
  type        = string
  default     = ""
}


variable "os_publisher" {
  description = "data disk size in  GB"
  type        = string
  default     = "Canonical"
}

variable "os_offer" {
  description = "data disk size in  GB"
  type        = string
  default     = "UbuntuServer"
}

variable "os_sku" {
  description = "sku of the VM"
  type        = string
  default     = "20_04-lts-gen2"
}

variable "data_disk_name" {
  type        = string
  default     = ""
  description = "name of managed disk want to create from snapshot"
}

variable "data_disk_storage_acc_type" {
  type        = string
  default     = "Standard_LRS"
  description = "type of storage account for disk"
}

variable "data_disk_lun" {
  type        = number
  default     = "10"
  description = "Lun required to attach multiple disk to vm"
}

variable "caching_type" {
  type        = string
  default     = "ReadWrite"
  description = "Type of caching"
}

variable "image_version" {
  type        = string
  default     = "latest"
  description = "image version"
}

variable "pip_add_allocation" {
  type        = string
  default     = "Dynamic"
  description = "private ip address "
}

variable "create_resource_group" {
  type        = bool
  default     = "false"
  description = "bool type of data to create resource group."
}

variable "resource_group_location" {
  type        = string
  default     = "Australia East"
  description = "Location of the resource group."
}

variable "os_disk_size_gb" {
  type        = string
  default     = "1"
  description = "os disk size in giga byte."
}

variable "disk_size_gb" {
  type        = string
  description = "data disk size in giga byte."
  default     = ""
}

variable "creation_opt" {
  type        = string
  default     = "Empty"
  description = "data disk size in giga byte."
}

variable "os_type" {
  type        = string
  default     = "Linux"
  description = "data disk size in giga byte."
}

variable "disk_type" {
  type        = string
  default     = "StandardSSD_LRS"
  description = "data disk size in giga byte."
}

variable "disable_as" {
  description = "disable availability set"
  type        = bool
  default     = true
}

#configuration for NSG

variable "existing_nsg_name" {
  type        = string
  description = "Name of the exisitng network securtiy group"
  default     = "dmzsunnsg"
}

variable "existing_nsg_rg" {
  type        = string
  description = "Name of the exisitng resource group of network securtiy group"
  default     = "b2b-prod-hub-ci-rg"
}

variable "attach_nsg" {
  type        = bool
  description = "boolen true/false to attach network securtiy group"
  default     = false
}

#configuration for publicip address

variable "public_ip_name" {
  type        = string
  description = "Name of the public IP address"
  default     = "bp-es-pip"
}

# variable "public_ip_sku" {
#   type        = string
#   default     = "Standard"
#   description = "SKU of the public IP address"
# }

variable "public_ip_allocation_method" {
  type        = string
  default     = "Static"
  description = "Allocation method of the public IP address"
}

# variable "public_ip_domain_name_label" {
#   type        = string
#   default     = ""
#   description = "Domain name label of the public IP address"
# }
variable "create_public_ip" {
  type        = bool
  default     = "false"
  description = "bool type to create a public ip for a virtual machine."
}
