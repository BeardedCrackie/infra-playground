
terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.60.1"
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
    agent    = true
  }
}

resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  name        = "${var.project.name}-ubuntu-vm"
  description = "Managed by Terraform"
  tags        = ["terraform", "ubuntu"]
  started = true

  #timeout in seconds
  timeout_create = "18000"

  node_name = "proxmox"

  agent {
    # read 'Qemu guest agent' section, change to true only when ready
    enabled = false
  }

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }

  disk {
    datastore_id = "local-zfs"
    file_id      = proxmox_virtual_environment_download_file.latest_ubuntu_22_jammy_qcow2_img.id
    interface    = "virtio0"
    #file_format = "raw"
    size         = 20
  }

  initialization {
    datastore_id = "local-zfs"
    ip_config {
      ipv4 {
        address = "192.168.0.77/24"
        gateway = "192.168.0.1"
      }
    }

    dns {
      servers = ["8.8.8.8"]
    }
    
    user_account {
      keys     = [trimspace(data.local_file.ssh_public_key.content)]
      password = random_password.ubuntu_vm_password.result
      username = "ubuntu"
    }

     #user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  tpm_state {
    version = "v2.0"
    datastore_id = "local-zfs"
  }

  serial_device {}
}

resource "proxmox_virtual_environment_download_file" "latest_ubuntu_22_jammy_qcow2_img" {
  content_type = "iso"
  datastore_id = "local"
  file_name    = "${var.project.name}-ubuntu_22_jammy.img"
  node_name    = "proxmox"
  url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  overwrite = true
}

resource "random_password" "ubuntu_vm_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

resource "tls_private_key" "ubuntu_vm_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_sensitive_file" "cloud_pem" { 
  filename = "${path.module}/privkey.pem"
  content = tls_private_key.ubuntu_vm_key.private_key_pem
}

output "ubuntu_vm_password" {
  value     = random_password.ubuntu_vm_password.result
  sensitive = true
}

output "ubuntu_vm_private_key" {
  value     = tls_private_key.ubuntu_vm_key.private_key_pem
  sensitive = true
}

output "ubuntu_vm_public_key" {
  value = tls_private_key.ubuntu_vm_key.public_key_openssh
}

data "local_file" "ssh_public_key" {
  filename = "${path.module}/id_rsa.pub"
}

resource "null_resource" "copy_file_on_vm" {
  depends_on = [
    proxmox_virtual_environment_vm.ubuntu_vm,
    local_sensitive_file.cloud_pem
  ]
  triggers = {
    always_run = timestamp()
  }
  
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.ubuntu_vm_key.private_key_pem
    host        = "192.168.0.77"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install git -y",
      "sudo snap install microk8s --classic --channel=1.30 -y"
    ]
  }
}