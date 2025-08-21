variable "image_id" {
  type        = string
  description = "ID of the downloaded image file to use for VM disk."
}

variable "vm_name" {
    type = string
    default = "vm"
}

variable "vm_count" {
    type = number
    default = 1
}

variable "public_key" {
    type = string
    description = "public key"
}

variable "vm_username" {
    type = string
    default = "ubuntu"
}

variable "cpu_cores" {
    type = number
    default = 1
}

variable "memory_size" {
    type = number
    default = 2048
}

variable "network_name" {
    type = string
    default = "vmbr0"
}

variable "pve_datastore_id" {
    type = string
    default = "local-zfs"
}

variable "pve_node_name" {
    type = string
    default = "proxmox"
}

variable "ip_type" {
  description = "Type of IP assignment: 'dhcp' or 'static'"
  type        = string
  default     = "dhcp"
}

variable "static_ip_address" {
  description = "Static IP address with CIDR"
  type        = string
  default     = ""
}

variable "gateway" {
  description = "Gateway for static IP"
  type        = string
  default     = ""
}

variable "dns_domain" {
  description = "DNS search domain for the VM."
  type        = string
  default     = "local"
}

variable "dns_servers" {
  description = "List of DNS servers for the VM."
  type        = list(string)
  default     = ["8.8.8.8"]
}
