variable "talos_image_id" {
  type        = string
  description = "ID of the Talos image file to use for VM disk."
}

variable "vm_name" {
  type        = string
  description = "Name of the virtual machine"
}

variable "cpu_cores" {
  type        = number
  default     = 2
  description = "Number of CPU cores"
}

variable "memory_size" {
  type        = number
  default     = 4096
  description = "Memory size in MB"
}

variable "disk_size" {
  type        = number
  default     = 20
  description = "Disk size in GB"
}

variable "network_name" {
  type        = string
  default     = "vmbr0"
  description = "Network bridge name"
}

variable "pve_datastore_id" {
  type        = string
  default     = "local-zfs"
  description = "Proxmox datastore ID"
}

variable "pve_node_name" {
  type        = string
  default     = "proxmox"
  description = "Proxmox node name"
}

variable "ip_type" {
  type        = string
  default     = "dhcp"
  description = "IP configuration type: 'dhcp' or 'static'"
  validation {
    condition     = contains(["dhcp", "static"], var.ip_type)
    error_message = "IP type must be either 'dhcp' or 'static'."
  }
}

variable "static_ip_address" {
  type        = string
  default     = null
  description = "Static IP address with CIDR notation (e.g., '192.168.1.100/24')"
}

variable "gateway" {
  type        = string
  default     = null
  description = "Gateway IP address (required when using static IP)"
}

variable "dns_domain" {
  type        = string
  default     = "local"
  description = "DNS domain"
}

variable "dns_servers" {
  type        = list(string)
  default     = ["1.1.1.1", "8.8.8.8"]
  description = "List of DNS servers"
}

variable "enable_cloud_init" {
  type        = bool
  default     = false
  description = "Enable cloud-init configuration"
}

variable "enable_tpm" {
  type        = bool
  default     = false
  description = "Enable TPM 2.0"
}

variable "cluster_name" {
  type        = string
  default     = "talos-cluster"
  description = "Talos cluster name"
}

variable "cluster_endpoint" {
  type        = string
  default     = ""
  description = "Talos cluster endpoint URL"
}

variable "node_type" {
  type        = string
  default     = "worker"
  description = "Node type: 'controlplane' or 'worker'"
  validation {
    condition     = contains(["controlplane", "worker"], var.node_type)
    error_message = "Node type must be either 'controlplane' or 'worker'."
  }
}

variable "node_labels" {
  type        = map(string)
  default     = {}
  description = "Kubernetes node labels"
}

variable "node_taints" {
  type        = list(string)
  default     = []
  description = "Kubernetes node taints"
}

variable "install_disk" {
  type        = string
  default     = "/dev/vda"
  description = "Disk to install Talos on"
}

variable "custom_talos_config" {
  type        = string
  default     = ""
  description = "Custom Talos configuration in YAML format"
}
