
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
    ansible = {
      version = "~> 1.3.0"
      source  = "ansible/ansible"
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
    hostname = var.ct_name

    ip_config {
      ipv4 {
        address = var.ct_ip
        gateway = "192.168.0.1"
      }
    }

    user_account {
      keys = [
        file(var.ct_pub_key)
        #trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)
        #trimspace(tls_private_key.ubuntu_container_key.public_key_openssh)
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
    #template_file_id = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
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
  url          = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.tar.gz"
}

resource "random_password" "ubuntu_container_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}


output "ubuntu_container_password" {
  value     = random_password.ubuntu_container_password.result
  sensitive = true
}


resource "ansible_group" "group" {
  name     = "${var.project.name}"
}

resource "ansible_host" "host" {
  name     = "${var.project.name}-${var.ct_name}"
  groups = ["${var.project.name}"]
  variables = {
    ansible_host = var.ct_ip
    ansible_user = "root"
    ansible_ssh_private_key_file = "~/.ssh/${var.project.name}.pem"
    ansible_python_interpreter = "/usr/bin/python3"
    greetings   = "from host!"
    some        = "variable"
  }
}