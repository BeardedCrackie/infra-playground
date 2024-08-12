variable "virtual_environment" {
    type = object({
        password = string
        endpoint = string
        username = string
        node_name = string
        datastore_id = string
    })
    sensitive = true
} 

variable "project" {
    type = object({
        name = string
    })
} 

variable "image_url" {
    type = string
    default = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

variable "vm" {
    type = object({
        username = string
        ip = string
        prefix = string
        gw = string
        dns_servers = list(string)
    })
    default = {
      username = "ubuntu"
      ip = "192.168.0.80"
      prefix = "24"
      gw = "192.168.0.1"
      dns_servers = ["8.8.8.8"]
    }
} 

variable "vm_ip" {
    type = string
}

variable "vm_name" {
    type = string
    default = "vm"
}

variable "priv_key_path" {
    type = string
    description = "Path to the public key file"
    default     = "~/.ssh/id_rsa"
}

locals {
  priv_key_content = file(pathexpand(var.priv_key_path))
}

variable "public_key_path" {
  description = "Path to the public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

locals {
  public_key_content = file(pathexpand(var.public_key_path))
}