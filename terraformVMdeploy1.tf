
terraform{
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "~>2.31.1"
        }
    }
}

provider "azurerm" {
    features {}

variable "client_secret" {

subscription_id = "d66af87f-6456-4537-9389-f23d8e64f39e"
  client_id       = "499b84ac-1321-427f-aa17-267ca6975798"
  client_secret   = var.client_secret
  tenant_id       = "e39456e9-3ae1-4eb3-af3d-a93477ca8313"
}

data "azurerm_resource_group" "test" {
  name = "rgCLI"
  /* location = "eastus" */

}
data "azurerm_virtual_network" "test" {
name= "rgCLI-vnet"
resource_group_name = "rgCLI"
}
data "azurerm_subnet" "test" {
  name                 = "rgCLI-subnet"
  virtual_network_name = "rgCLI-vnet"
  resource_group_name  = "rgCLI"
}

resource "azurerm_network_interface" "test" {
  name                = "mynic"
  location            = data.azurerm_resource_group.test.location
  resource_group_name = data.azurerm_resource_group.test.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = data.azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}
output "tls_private_key" {
    value = tls_private_key.example_ssh.private_key_pem
    sensitive = true
}
resource "azurerm_linux_virtual_machine" "vmtest" {
    name                  = "deployvm"
    location              = data.azurerm_resource_group.test.location
    resource_group_name   = data.azurerm_resource_group.test.name
        network_interface_ids = [azurerm_network_interface.test.id]
        size                              =     "Standard_DS1_v2"
    admin_username      = "adminuser"
    admin_password = "Password1234!"

  admin_ssh_key {
    username   = "adminuser"
    public_key     = tls_private_key.example_ssh.public_key_openssh
  }

source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

 os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

}