
resource "proxmox_virtual_environment_vm" "talos_vm" {
  name        = var.vm_name
  description = "Talos VM managed by Terraform"
  tags        = ["terraform", "talos", "kubernetes"]
  started     = true

  # Timeout in seconds
  timeout_create = "18000"

  node_name = var.pve_node_name

  cpu {
    cores = var.cpu_cores
    type  = "host"
  }

  memory {
    dedicated = var.memory_size
  }
  
  agent {
    enabled = true
  }

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }

  disk {
    datastore_id = var.pve_datastore_id
    file_id      = var.talos_image_id
    interface    = "virtio0"
    file_format  = "raw"
    iothread     = true
    discard      = "on"
    size         = var.disk_size
  }

  initialization {
    datastore_id = var.pve_datastore_id
    # For Talos, we don't use Proxmox cloud-init network config since Talos handles networking
    # Only set DNS configuration via cloud-init
    ip_config {
      ipv4 {
        address = var.static_ip_address
        gateway = var.gateway
      }
    }
    dns {
      domain  = var.dns_domain
      servers = var.dns_servers
    }
  }

  network_device {
    bridge = var.network_name
  }

  operating_system {
    type = "l26" # Linux kernel
  }

  # TPM is optional for Talos but can be useful for encryption
  dynamic "tpm_state" {
    for_each = var.enable_tpm ? [1] : []
    content {
      version      = "v2.0"
      datastore_id = var.pve_datastore_id
    }
  }
}
