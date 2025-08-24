# Output the IP addresses
output "controlplane_ips" {
  value = values(module.talos_controlplane)[*].ipv4_address
}

output "worker_ips" {
  value = values(module.talos_worker)[*].ipv4_address
}
