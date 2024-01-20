
terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.43.2"
    }
  }
}

provider "proxmox" {
  endpoint = var.virtual_environment.endpoint
  api_token = var.virtual_environment.api_token
  insecure  = true
  ssh {
    agent    = true
    username = var.virtual_environment.username
  }
}

resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  name        = "terraform-provider-proxmox-ubuntu-vm"
  description = "Managed by Terraform"
  tags        = ["terraform", "ubuntu"]

  #timeout in seconds
  #timeout_create = "18000"

  node_name = "proxmox"
  #vm_id     = 4321

  clone {
    vm_id   = 9001
  }

  agent {
    # read 'Qemu guest agent' section, change to true only when ready
    enabled = false
  }

  #startup {
    #order      = "3"
    #up_delay   = "60"
    #down_delay = "60"
  #}

}
