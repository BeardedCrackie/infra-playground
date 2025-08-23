
locals {
  talos = {
    version = "v1.10.6"
  }
}

resource "proxmox_virtual_environment_download_file" "talos_image" {
  content_type = "iso"
  datastore_id = "local"
  file_name    = "${var.project_name}-talos-${local.talos.version}-nocloud-amd64.img"
  node_name    = var.virtual_environment.node_name
  url          = "https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/${local.talos.version}/nocloud-amd64.iso"
  overwrite    = false
}

# Create a controlplane node
module "talos_controlplane" {
  source = "./modules/proxmox-talos-vm"
  count  = length(var.control_plane_nodes)

  # VM Configuration
  vm_name        = var.control_plane_nodes[count.index].vm_name
  talos_image_id = proxmox_virtual_environment_download_file.talos_image.id
  pve_node_name  = var.virtual_environment.node_name
  
  # Hardware specs
  cpu_cores      = var.control_plane_nodes[count.index].cpu_cores
  memory_size    = var.control_plane_nodes[count.index].memory_size
  disk_size      = var.control_plane_nodes[count.index].disk_size
  
  # Network configuration (using DHCP for workers)
  enable_cloud_init = true
  dns_servers       = var.dns_config.servers
  ipv4_address = var.control_plane_nodes[count.index].ipv4_address
  ipv4_gateway = var.control_plane_nodes[count.index].ipv4_gateway
  
  # Optional features
  enable_tpm = true
}

# Create worker nodes
module "talos_worker" {
  source = "./modules/proxmox-talos-vm"
  count  = length(var.worker_nodes)

  # VM Configuration
  vm_name        = var.worker_nodes[count.index].vm_name
  talos_image_id = proxmox_virtual_environment_download_file.talos_image.id
  pve_node_name  = var.virtual_environment.node_name
  
  # Hardware specs
  cpu_cores      = var.worker_nodes[count.index].cpu_cores
  memory_size    = var.worker_nodes[count.index].memory_size
  disk_size      = var.worker_nodes[count.index].disk_size
  
  # Network configuration (using DHCP for workers)
  enable_cloud_init = true
  dns_servers       = var.dns_config.servers
  ipv4_address = var.worker_nodes[count.index].ipv4_address
  ipv4_gateway = var.worker_nodes[count.index].ipv4_gateway

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
