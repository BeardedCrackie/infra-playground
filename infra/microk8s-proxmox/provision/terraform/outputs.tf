
output "vm_ipv4_address" {
  value = { for k, m in module.proxmox-ubuntu-vm : k => m.ipv4_address }
}
