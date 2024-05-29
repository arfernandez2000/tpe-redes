
resource "azurerm_network_interface" "ws_nic" {
  count = 2
  name                = "ws${count.index}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${count.index}-default"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"

  }
}

resource "tls_private_key" "ssh_ws" {
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "azurerm_linux_virtual_machine" "vms_ws" {
  count = 2
  name                = "ws${count.index}-machine"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1ls"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.ws_nic[count.index].id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.ssh_ws.public_key_openssh
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

resource "azurerm_network_security_group" "ws_nsg" {
  count = 2
  name                = "ws${count.index}-nsg"
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
    source_address_prefix      = "10.0.0.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                 = "Allow3000"
    priority             = 1001
    direction            = "Inbound"
    access               = "Allow"
    protocol             = "Tcp"
    source_port_range    = "*"
    destination_port_range = "3000"
    source_address_prefix = "10.0.0.0/24"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "ws_nic_nsg_assoc" {
  count = 2
  network_interface_id      = azurerm_network_interface.ws_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.ws_nsg[count.index].id
}
