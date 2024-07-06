
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

resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  name        = "${var.project.name}-${var.vm_name}"
  description = "Managed by Terraform"
  tags        = ["terraform", "ubuntu"]
  started = true

  #timeout in seconds
  timeout_create = "18000"

  node_name = var.virtual_environment.node_name

  cpu {
    cores = 4
  }

  memory {
    dedicated = 8192
  }

  agent {
    # read 'Qemu guest agent' section, change to true only when ready
    enabled = true
  }

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }

  disk {
    datastore_id = var.virtual_environment.datastore_id
    file_id      = proxmox_virtual_environment_download_file.image.id
    interface    = "virtio0"
    #file_format = "raw"
    iothread     = true
    discard      = "on"
    size         = 20
  }

  initialization {
    datastore_id = var.virtual_environment.datastore_id
    ip_config {
      ipv4 {
        address = "${var.vm.ip}/${var.vm.prefix}"
        gateway = "${var.vm.gw}"
      }
    }

    dns {
      servers = "${var.vm.dns_servers}"
    }
    
    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  tpm_state {
    version = "v2.0"
    datastore_id = var.virtual_environment.datastore_id
  }

  #serial_device {}
}

resource "proxmox_virtual_environment_download_file" "image" {
  content_type = "iso"
  datastore_id = "local"
  file_name    = "${var.project.name}.img"
  node_name    = var.virtual_environment.node_name
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

resource "local_file" "connect_script" {
    content     = "ssh ${var.vm.username}@${var.vm.ip} -i ~/.ssh/${var.project.name}.pem"
    filename = "${path.module}/connect.sh"
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.virtual_environment.node_name

  source_raw {
    data = <<-EOF
    #cloud-config
    users:
      - default
      - name: ${var.vm.username}
        groups:
          - sudo
        shell: /bin/bash
        ssh_authorized_keys:
          - ${trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)}
        sudo: ALL=(ALL) NOPASSWD:ALL
    runcmd:
        - apt update >> /tmp/cloud-config
        - apt upgrade -y >> /tmp/cloud-config
        - apt install -y qemu-guest-agent net-tools >> /tmp/cloud-config
        - timedatectl set-timezone Europe/Bratislava >> /tmp/cloud-config
        - systemctl enable qemu-guest-agent >> /tmp/cloud-config
        - systemctl start qemu-guest-agent >> /tmp/cloud-config
        - snap install microk8s --classic --channel=1.30 >> /tmp/cloud-config
        - sudo usermod -a -G microk8s ${var.vm.username} >> /tmp/cloud-config
        - mkdir -p ~/.kube >> /tmp/cloud-config
        - chmod 0700 ~/.kube >> /tmp/cloud-config
        - microk8s enable dns >> /tmp/cloud-config
        - microk8s enable hostpath-storage >> /tmp/cloud-config
        - microk8s start >> /tmp/cloud-config
        - echo "done" > /tmp/cloud-config.done
    EOF

    file_name = "cloud-config.yaml"
  }
}

resource "ansible_group" "group" {
  name     = "${var.project.name}"
}

resource "ansible_host" "host" {
  name     = "${var.project.name}-${var.vm_name}"
  groups = ["${var.project.name}"]
  variables = {
    ansible_host = "${var.vm.ip}"
    ansible_user = "${var.vm.username}"
    ansible_ssh_private_key_file = "~/.ssh/${var.project.name}.pem"
    ansible_python_interpreter = "/usr/bin/python3"
    greetings   = "from host!"
    some        = "variable"
  }
}