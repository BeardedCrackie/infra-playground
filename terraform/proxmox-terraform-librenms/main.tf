
terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.61.1"
    }
    null = {
      source = "hashicorp/null"
      version = "3.2.2"
    }
  }
}

provider "proxmox" {
  endpoint = var.virtual_environment.endpoint
  username = var.virtual_environment.username
  password = var.virtual_environment.password
  insecure  = true
  ssh {
    agent    = false
    private_key = file(var.priv_key)
  }
}




resource "proxmox_virtual_environment_container" "ubuntu_container" {
  description = "Managed by Terraform"

  node_name = var.virtual_environment.node_name

  initialization {
    hostname = "tf-libreNMS"

    ip_config {
      ipv4 {
        address = "192.168.0.60/24"
        gateway = "192.168.0.1"
      }
    }

    user_account {
      keys = [
        trimspace(tls_private_key.ubuntu_container_key.public_key_openssh)
      ]
      password = random_password.ubuntu_container_password.result
    }
  }

  memory {
    swap = 512
  }

  disk {
    datastore_id = var.virtual_environment.datastore_id
  }
  
  network_interface {
    name = "veth0"
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.ct_image.id
    type             = "ubuntu"
  }

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }
}

resource "proxmox_virtual_environment_download_file" "ct_image" {
  file_name = "${var.project.name}-ubuntu-24.04-lts-image.tar.xz"
  content_type = "vztmpl"
  datastore_id = "local"
  node_name = var.virtual_environment.node_name
  url          = "https://images.linuxcontainers.org/images/ubuntu/noble/amd64/default/20240730_07%3A42/rootfs.tar.xz"
}

resource "random_password" "ubuntu_container_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

resource "tls_private_key" "ubuntu_container_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

output "ubuntu_container_password" {
  value     = random_password.ubuntu_container_password.result
  sensitive = true
}

output "ubuntu_container_private_key" {
  value     = tls_private_key.ubuntu_container_key.private_key_pem
  sensitive = true
}

output "ubuntu_container_public_key" {
  value = tls_private_key.ubuntu_container_key.public_key_openssh
}

