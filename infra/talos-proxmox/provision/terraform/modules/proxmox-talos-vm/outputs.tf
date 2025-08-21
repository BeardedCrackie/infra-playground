output "vm_name" {
  description = "Name of the created VM"
  value       = proxmox_virtual_environment_vm.talos_vm.name
}

output "vm_id" {
  description = "ID of the created VM"
  value       = proxmox_virtual_environment_vm.talos_vm.id
}

output "ipv4_address" {
  description = "IPv4 address of the VM"
  value = try(
    [for ip in proxmox_virtual_environment_vm.talos_vm.ipv4_addresses[7] : 
      ip if !startswith(ip, "127.")
    ][0],
    null
  )
}

output "node_name" {
  description = "Proxmox node where the VM is created"
  value       = proxmox_virtual_environment_vm.talos_vm.node_name
}
