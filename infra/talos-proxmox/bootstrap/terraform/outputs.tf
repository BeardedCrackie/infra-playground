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