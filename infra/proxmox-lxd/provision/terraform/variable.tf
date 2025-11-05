variable "virtual_environment" {
  type = object({
    password     = string
    endpoint     = string
    username     = string
    node_name    = string
    datastore_id = string
  })
  sensitive = true
}

variable "project" {
  type = object({
    name = string
  })
}

variable "priv_key" {
  type = string
}

variable "image_url" {
  type    = string
  default = "https://images.linuxcontainers.org/images/ubuntu/noble/amd64/default/20240730_07%3A42/rootfs.tar.xz"
}
