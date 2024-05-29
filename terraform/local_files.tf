resource "local_file" "db_vms_key" {
  content  = tls_private_key.ssh_db.private_key_pem
  filename = "../keys/db_public.pem"
  file_permission = "0400"
}

resource "local_file" "public_vms_key" {
  content  = tls_private_key.ssh.private_key_pem
  filename = "../keys/public.pem"
  file_permission = "0400"
}

resource "local_file" "ws_vms_key" {
  content  = tls_private_key.ssh_ws.private_key_pem
  filename = "../keys/ws_public.pem"
  file_permission = "0400"
}

resource "local_file" "inventory" {
  content  = <<-EOT
    [public]
    ${azurerm_public_ip.public_ip.ip_address} ansible_ssh_private_key_file="keys/public.pem"

    [ws]
    ${azurerm_linux_virtual_machine.vms_ws[0].private_ip_address} ansible_ssh_private_key_file="keys/ws_public.pem"
    ${azurerm_linux_virtual_machine.vms_ws[1].private_ip_address} ansible_ssh_private_key_file="keys/ws_public.pem"

    [db]
    ${azurerm_linux_virtual_machine.vms_db[0].private_ip_address} ansible_ssh_private_key_file="keys/db_public.pem"
    ${azurerm_linux_virtual_machine.vms_db[1].private_ip_address} ansible_ssh_private_key_file="keys/db_public.pem"

  EOT
  filename = "../inventory/inv.ini"
}