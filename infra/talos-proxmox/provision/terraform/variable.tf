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
