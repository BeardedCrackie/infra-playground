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

variable "project_name" {
    type = string
} 

variable "vm_username" {
    type = string
    default = "ubuntu"
} 

variable "vm_count" {
    type = number
    default = 1
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

variable "image_url" {
    type = string
    default = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}