resource "null_resource" "null_copy_ssh_key_to_bastion" {
  depends_on = [azurerm_linux_virtual_machine.bastion_host_linuxvm]
  connection {
    type        = "ssh"
    host        = azurerm_linux_virtual_machine.bastion_host_linuxvm.public_ip_address
    user        = azurerm_linux_virtual_machine.bastion_host_linuxvm.admin_username
    private_key = file("${path.module}/ssh-keys/terraform-azure.pem")
  }
  provisioner "file" {
    source      = "ssh-keys/terraform-azure.pem"
    destination = "/tmp/terraform-azure.pem"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod 400 /tmp/terraform-azure.pem"
    ]
  }
}