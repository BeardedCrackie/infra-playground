locals {
  talos = {
    version = "v1.10.6"
  }
  # Create maps from lists for stable resource addressing
  control_plane_map = { for node in var.control_plane_nodes : node.vm_name => node }
  worker_map = { for node in var.worker_nodes : node.vm_name => node }
}

resource "proxmox_virtual_environment_download_file" "talos_image" {
  content_type = "iso"
  datastore_id = "local"
  file_name    = "${var.project_name}-talos-${local.talos.version}-nocloud-amd64.img"
  node_name    = var.virtual_environment.node_name
  url          = "https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/${local.talos.version}/nocloud-amd64.iso"
  overwrite    = false
}

# Create controlplane nodes
module "talos_controlplane" {
  source   = "./modules/proxmox-talos-vm"
  for_each = local.control_plane_map

  # VM Configuration
  vm_name        = each.value.vm_name
  talos_image_id = proxmox_virtual_environment_download_file.talos_image.id
  pve_node_name  = var.virtual_environment.node_name
  
  # Hardware specs
  cpu_cores      = each.value.cpu_cores
  memory_size    = each.value.memory_size
  disk_size      = each.value.disk_size
  pve_datastore_id = var.virtual_environment.datastore_id

  # Network configuration
  enable_cloud_init = true
  dns_servers       = var.dns_config.servers
  ipv4_address = each.value.ipv4_address
  ipv4_gateway = each.value.ipv4_gateway
  
  # Optional features
  enable_tpm = true
}

# Create worker nodes
module "talos_worker" {
  source   = "./modules/proxmox-talos-vm"
  for_each = local.worker_map

  # VM Configuration
  vm_name        = each.value.vm_name
  talos_image_id = proxmox_virtual_environment_download_file.talos_image.id
  pve_node_name  = var.virtual_environment.node_name
  
  # Hardware specs
  cpu_cores      = each.value.cpu_cores
  memory_size    = each.value.memory_size
  disk_size      = each.value.disk_size
  pve_datastore_id = var.virtual_environment.datastore_id
  
  # Network configuration
  enable_cloud_init = true
  dns_servers       = var.dns_config.servers
  ipv4_address = each.value.ipv4_address
  ipv4_gateway = each.value.ipv4_gateway

  # Talos specific
  node_type    = "worker"
  cluster_name = "homelab-k8s"
  
  # Node labels for workers
  node_labels = {
    "node-role.kubernetes.io/worker" = ""
    "node-type"                      = "worker"
    "environment"                    = "homelab"
  }
}
