
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
module "talos_controlplane_01" {
  source = "./modules/proxmox-talos-vm"

  # VM Configuration
  vm_name         = "talos-cp-01"
  talos_image_id  = proxmox_virtual_environment_download_file.talos_image.id
  pve_node_name   = "proxmox"
  
  # Hardware specs
  cpu_cores    = 2
  memory_size  = 4096
  disk_size    = 30
  
  # Network configuration
  ip_type            = "static"
  static_ip_address  = "192.168.0.60/24"
  gateway           = "192.168.0.1"
  dns_servers       = ["192.168.0.1", "1.1.1.1"]
  
  # Optional features
  enable_tpm = true
}

# Create worker nodes
module "talos_worker" {
  source = "./modules/proxmox-talos-vm"
  count  = 2

  # VM Configuration
  vm_name        = "talos-worker-${count.index + 1}"
  talos_image_id = proxmox_virtual_environment_download_file.talos_image.id
  pve_node_name  = "proxmox"
  
  # Hardware specs
  cpu_cores   = 4
  memory_size = 8192
  disk_size   = 50
  
  # Network configuration (using DHCP for workers)
  ip_type = "dhcp"
  enable_cloud_init = true
  
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
