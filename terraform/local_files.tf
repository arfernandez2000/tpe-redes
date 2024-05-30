resource "local_file" "db_vms_key" {
  content  = tls_private_key.ssh_db.private_key_pem
  filename = "../keys/db_private.pem"
  file_permission = "0400"
}

resource "local_file" "public_vms_key" {
  content  = tls_private_key.ssh.private_key_pem
  filename = "../keys/private.pem"
  file_permission = "0400"
}

resource "local_file" "ws_vms_key" {
  content  = tls_private_key.ssh_ws.private_key_pem
  filename = "../keys/ws_private.pem"
  file_permission = "0400"
}

resource "local_file" "inventory" {
  content  = <<-EOT
    [public]
    ${azurerm_public_ip.public_ip.ip_address} ansible_ssh_private_key_file="keys/private.pem"

    [ws]
    ${azurerm_linux_virtual_machine.vms_ws[0].private_ip_address} ansible_ssh_private_key_file="keys/ws_private.pem"
    ${azurerm_linux_virtual_machine.vms_ws[1].private_ip_address} ansible_ssh_private_key_file="keys/ws_private.pem"

    [db]
    ${azurerm_linux_virtual_machine.vms_db[0].private_ip_address} ansible_ssh_private_key_file="keys/db_private.pem" primary=true
    ${azurerm_linux_virtual_machine.vms_db[1].private_ip_address} ansible_ssh_private_key_file="keys/db_private.pem" secondary=true

  EOT
  filename = "../inventory/inventory.ini"
}

resource "local_file" "environment" {
  content  = <<-EOT
    DB_HOST=${azurerm_linux_virtual_machine.vms_db[0].private_ip_address}
  EOT
  filename = "../web-server/.env"
}