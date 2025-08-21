# Generate machine secrets
resource "talos_machine_secrets" "this" {}

# Get client configuration
data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = [ local.controlplane_ip ]
}

resource "talos_machine_bootstrap" "this" {
  #count = var.bootstrap_cluster ? 1 : 0
  
  depends_on = [
    talos_machine_configuration_apply.controlplane,
    talos_machine_configuration_apply.worker
  ]
  
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.controlplane_ip
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.this
  ]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.controlplane_ip
}

resource "local_file" "kubeconfig" {
  content  = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename = "${path.module}/kubeconfig"
  file_permission = "0600"
}