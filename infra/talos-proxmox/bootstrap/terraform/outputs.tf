output "talosconfig" {
  description = "Talos configuration for accessing the cluster"
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
}

output "kubeconfig" {
  description = "Kubernetes configuration for accessing the cluster (only available when generate_kubeconfig=true)"
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
}

output "kubeconfig_path" {
  description = "Absolute path to the generated kubeconfig file"
  value       = abspath(local_file.kubeconfig.filename)
}

output "ca_certificate" {
  description = "CA certificate for importing to Windows"
  value       = talos_machine_secrets.this.client_configuration.ca_certificate
  sensitive   = true
}

output "cluster_endpoint" {
  description = "Cluster endpoint URL"
  value       = local.cluster_endpoint
}

output "controlplane_nodes" {
  description = "List of control plane node IPs"
  value       = local.controlplane_ips
}

output "bootstrap_node" {
  description = "IP of the node used for bootstrap operations"
  value       = local.bootstrap_node_ip
}