
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
    file_id      = proxmox_virtual_environment_download_file.image.id
    interface    = "virtio0"
    #file_format = "raw"
    iothread     = true
    discard      = "on"
    size         = 20
  }

  initialization {
    datastore_id = "local-zfs"
    ip_config {
      ipv4 {
        address = "${var.vm.ip}/${var.vm.prefix}"
        gateway = "${var.vm.gw}"
      }
    }

    dns {
      servers = "${var.vm.dns_servers}"
    }
    
    user_account {
      keys     = [trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)]
      password = random_password.ubuntu_vm_password.result
      username = var.vm.username
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

resource "proxmox_virtual_environment_download_file" "image" {
  content_type = "iso"
  datastore_id = "local"
  file_name    = "${var.project.name}.img"
  node_name    = "proxmox"
  url          = var.image_url
  overwrite = false
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
  #filename = "${path.module}/privkey.pem"
  filename = pathexpand("~/.ssh/${var.project.name}.pem")
  content = tls_private_key.ubuntu_vm_key.private_key_pem
}

resource "local_sensitive_file" "cloud_public" { 
  filename = "${path.module}/id_rsa.pub"
  #content = tls_private_key.ubuntu_vm_key.private_key_pem
  content = tls_private_key.ubuntu_vm_key.public_key_openssh
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

resource "local_file" "foo" {
    content     = "ssh ${var.vm.username}@${var.vm.ip} -i ~/.ssh/${var.project.name}.pem"
    filename = "${path.module}/connect.sh"
}

#data "local_file" "ssh_public_key" {
#  filename = "${path.module}/id_rsa.pub"
#}

#resource "null_resource" "copy_file_on_vm" {
#  depends_on = [
#    proxmox_virtual_environment_vm.ubuntu_vm,
#    local_sensitive_file.cloud_pem
#  ]
#  triggers = {
#    always_run = timestamp()
#  }
#  
#  connection {
#    type        = "ssh"
#    user        = "${var.vm.username}"
#    private_key = tls_private_key.ubuntu_vm_key.private_key_pem
#    host        = "${var.vm.ip}"
#  }
#  provisioner "remote-exec" {
#    inline = [
#      "sudo apt update",
#      "sudo apt upgrade -y"
#    ]
#  }
#}