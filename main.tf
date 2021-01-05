provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "netflixrg" {
  name     = "netflixres"
  location = "${var.region}"
}

resource "azurerm_virtual_network" "netflixnet" {
  name                = "example-network"
  resource_group_name = azurerm_resource_group.netflixrg.name
  location            = azurerm_resource_group.netflixrg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "netflixsubnet" {
  name                 = "netflixsubnet"
  resource_group_name  = azurerm_resource_group.netflixrg.name
  virtual_network_name = azurerm_virtual_network.netflixnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_linux_virtual_machine_scale_set" "netflixss" {
  name                = "example-vmss"
  resource_group_name = azurerm_resource_group.netflixrg.name
  location            = azurerm_resource_group.netflixrg.location
  sku                 = "Standard_F2"
  instances           = 3
  admin_username      = "lin"

  admin_ssh_key {
    username   = "lin"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "example"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.netflixsubnet.id
    }
  }
}