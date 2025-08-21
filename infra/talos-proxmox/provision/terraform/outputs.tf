
# Output the IP addresses
output "controlplane_ip" {
  value = module.talos_controlplane_01.ipv4_address
}

output "worker_ips" {
  value = module.talos_worker[*].ipv4_address
}
