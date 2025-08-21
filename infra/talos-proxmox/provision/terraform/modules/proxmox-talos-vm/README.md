# Proxmox Talos VM Terraform Module

This Terraform module creates Talos Linux virtual machines on Proxmox VE with cloud-init configuration.

## Features

- Creates Talos Linux VMs on Proxmox VE
- Supports both controlplane and worker nodes
- Cloud-init configuration for automated setup
- Flexible networking (DHCP or static IP)
- Optional TPM 2.0 support
- Customizable node labels and taints
- Support for custom Talos configurations

## Requirements

- Terraform >= 1.0
- Proxmox VE with Talos Linux ISO template
- Network connectivity to Proxmox VE

## Usage

### Basic Example

```hcl
locals {
  talos = {
    version = "v1.7.4"
  }
}

resource "proxmox_virtual_environment_download_file" "talos_image" {
  content_type = "iso"
  datastore_id = "local"
  file_name    = "talos-${local.talos.version}-nocloud-amd64.img"
  node_name    = var.virtual_environment.node_name
  url          = "https://factory.talos.dev/image/787b79bb847a07ebb9ae37396d015617266b1cef861107eaec85968ad7b40618/${local.talos.version}/nocloud-amd64.raw.gz"
  decompression_algorithm = "gz"
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
```

## Prerequisites

### Preparing Talos Image

1. Talos ISO url via talos factory (https://factory.talos.dev/)

