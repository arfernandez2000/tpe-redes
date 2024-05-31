locals {
  ip_address_id = "/subscriptions/6f21dcad-00e6-4158-8f70-2ea60ad42b29/resourceGroups/${azurerm_resource_group.rg.name}/providers/Microsoft.Network/publicIPAddresses/public-ip"
}


resource "azurerm_public_ip" "public_ip" {
  name                = "public-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "public_nic" {
  name                = "public-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "public-default"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"

    public_ip_address_id = local.ip_address_id
  }
}

resource "tls_private_key" "ssh" {
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "azurerm_linux_virtual_machine" "vms_public" {
  name                = "public-machine"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F2"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.public_nic.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.ssh.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

}

resource "azurerm_network_security_group" "public_nsg" {
  name                = "public-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                 = "Allow8080"
    priority             = 1001
    direction            = "Inbound"
    access               = "Allow"
    protocol             = "Tcp"
    source_port_range    = "*"
    destination_port_range = "8080"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                 = "Allow3000"
    priority             = 1002
    direction            = "Inbound"
    access               = "Allow"
    protocol             = "Tcp"
    source_port_range    = "*"
    destination_port_range = "3000"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "public_nic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.public_nic.id
  network_security_group_id = azurerm_network_security_group.public_nsg.id
}
