module "bp-es-poc" {
  source                        = "../Module"
  resource_group_location       = "centralindia"
  create_resource_group         = false
  resource_group_name           = "dns-rg"
  vm_name                       = "bp-es-poc-vm"
  ssh_key                       = "bp-es-poc_key"
  ssh_key_rg                    = "dns-rg"
  username                      = "azureadmin"
  vm_size                       = "Standard_F2s_v2"
  enable_accelerated_networking = true
  subnet_name                   = "default"
  vnet_rg_name                  = "dns-rg"
  vnet_name                     = "gs-sync-vnet"
  os_publisher                  = "Canonical"
  os_offer                      = "0001-com-ubuntu-server-focal"
  os_sku                        = "20_04-lts-gen2"
  image_version                 = "latest"
  caching_type                  = "ReadWrite"
  pip_add_allocation            = "Static"
  os_disk_size_gb               = "30"
  disk_size_gb                  = null
  disk_type                     = "Standard_LRS"
  private_ip_address            = "10.0.0.5"
  public_ip_name                = "bp-es-poc-mvm-pip"
  create_public_ip              = false
  custom_data                   = base64encode(file("${path.module}/custom_data_script.tpl"))
  # data_disk_name                = "b2b-prod-hub-Linux_vm-datadisk"
  # data_disk_storage_acc_type    = "StandardSSD_LRS"
  # data_disk_lun                 = 1
}
