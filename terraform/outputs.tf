output "public_ip" {
    value = azurerm_public_ip.public_ip.ip_address
}


output "ws_private_ip" {
    value = azurerm_linux_virtual_machine.vms_ws[*].private_ip_address
}

output "db_private_ip" {
    value = azurerm_linux_virtual_machine.vms_db[*].private_ip_address
}