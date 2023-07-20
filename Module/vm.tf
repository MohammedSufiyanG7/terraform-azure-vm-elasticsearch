locals {
  resource_group_name = element(coalescelist(data.azurerm_resource_group.RG.*.name, azurerm_resource_group.newrg.*.name, [""]), 0)
  location            = element(coalescelist(data.azurerm_resource_group.RG.*.location, azurerm_resource_group.newrg.*.location, [""]), 0)
  #  availability_set_id = element(coalescelist(data.azurerm_availability_set.as.*.id, azurerm_availability_set.as.*.id, [""]), 0)
}

data "azurerm_ssh_public_key" "ssh_key" {
  name                = var.ssh_key
  resource_group_name = var.ssh_key_rg
}

data "azurerm_resource_group" "RG" {
  count = var.create_resource_group == false ? 1 : 0
  name  = var.resource_group_name
}

resource "azurerm_resource_group" "newrg" {
  count    = var.create_resource_group == true ? 1 : 0
  location = var.resource_group_location
  name     = var.resource_group_name
}

data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = "dns-rg"
  virtual_network_name = "gs-sync-vnet"
  depends_on = [
    data.azurerm_resource_group.RG
  ]
}

# Create public IPs
resource "azurerm_public_ip" "pip" {
  count               = var.create_public_ip ? 1 : 0
  name                = var.public_ip_name
  location            = "Central India"
  resource_group_name = local.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "nic" {
  name                = var.vm_name
  resource_group_name = local.resource_group_name
  location            = var.resource_group_location
  # enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = var.subnet_name
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = var.pip_add_allocation
    private_ip_address            = var.private_ip_address
    public_ip_address_id          = var.create_public_ip == true ? azurerm_public_ip.pip.0.id : null
  }

  depends_on = [
    data.azurerm_subnet.subnet
  ]
}

resource "azurerm_network_interface_security_group_association" "nsgass" {
  count                     = var.attach_nsg == false ? 0 : 1
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = data.azurerm_network_security_group.nsg.id
}

data "azurerm_network_security_group" "nsg" {
  resource_group_name = "dns-rg"
  name                = "bp-es-poc-nsg"
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = var.vm_name
  resource_group_name             = local.resource_group_name
  location                        = var.resource_group_location
  size                            = var.vm_size
  admin_username                  = var.username
  network_interface_ids           = [azurerm_network_interface.nic.id]
  disable_password_authentication = true
  provision_vm_agent              = true
  allow_extension_operations      = true
  computer_name                   = var.vm_name
  custom_data                     = var.custom_data

  admin_ssh_key {
    username   = var.username
    public_key = data.azurerm_ssh_public_key.ssh_key.public_key
  }

  os_disk {
    name                 = "${var.vm_name}-osdisk-01"
    caching              = var.caching_type
    storage_account_type = var.disk_type
    disk_size_gb         = var.os_disk_size_gb

  }
  source_image_reference {
    publisher = var.os_publisher
    offer     = var.os_offer
    sku       = var.os_sku
    version   = var.image_version
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      boot_diagnostics
    ]
  }
  depends_on = [
    azurerm_network_interface_security_group_association.nsgass,
  ]
}

