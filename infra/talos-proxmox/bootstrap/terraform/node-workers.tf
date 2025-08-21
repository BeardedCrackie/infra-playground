
data "talos_machine_configuration" "worker" {
  count = length(local.worker_ips)
  cluster_name     = var.cluster_name
  machine_type     = "worker"
  cluster_endpoint = local.cluster_endpoint
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

resource "talos_machine_configuration_apply" "worker" {
  count = length(local.worker_ips)
  
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker[count.index].machine_configuration
  node                        = local.worker_ips[count.index]
  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk = "/dev/vda"
          image = "factory.talos.dev/nocloud-installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.10.6"
        }
      }
    })
  ]
}
