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

variable "priv_key_path" {
    type = string
    description = "Path to the public key file"
    default     = "~/.ssh/id_rsa"
}

locals {
  priv_key_content = file(pathexpand(var.priv_key_path))
}

variable "control_plane_nodes" {
  description = "List of control plane node definitions"
  type = list(object({
    vm_name           = string
    cpu_cores         = number
    memory_size       = number
    disk_size         = number  
    ipv4_address      = string
    ipv4_gateway      = optional(string)
  }))
  default = []
}

variable "worker_nodes" {
  description = "List of worker node definitions"
  type = list(object({
    vm_name           = string
    cpu_cores         = number
    memory_size       = number
    disk_size         = number  
    ipv4_address      = string
    ipv4_gateway      = optional(string)
  }))
  default = []
}

variable "dns_config" {
  description = "DNS configuration for cluster nodes"
  type = object({
    domain  = string
    servers = list(string)
  })
  default = {
    domain  = "local"
    servers = ["1.1.1.1", "8.8.8.8"]
  }
}