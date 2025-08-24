variable "cluster_name" {
  description = "Name of the Talos cluster"
  type        = string
  default     = "homelab-k8s"
}

variable "kubernetes_version" {
  description = "Kubernetes version to use"
  type        = string
  default     = "1.30.6"
}

variable "talos_version" {
  description = "Talos version to use"
  type        = string
  default     = "v1.10.6"
}

variable "controlplane_ips" {
  description = "List of control plane node IPs"
  type        = list(string)
  
  validation {
    condition     = length(var.controlplane_ips) >= 1
    error_message = "At least one control plane IP must be provided."
  }
  
  validation {
    condition     = length(var.controlplane_ips) % 2 == 1
    error_message = "The number of control plane nodes should be odd (1, 3, 5, etc.) for proper etcd quorum."
  }
}

variable "cluster_vip" {
  description = "Virtual IP for the cluster API endpoint (optional - uses first control plane IP if not provided)"
  type        = string
  default     = ""
}

variable "bootstrap_node_ip" {
  description = "IP of the node to use for bootstrap operations (optional - uses first available control plane if not provided)"
  type        = string
  default     = ""
}

variable "force_kubeconfig_recreation" {
  description = "Set to current timestamp to force kubeconfig recreation (e.g., run date +%s)"
  type        = string
  default     = ""
}

variable "worker_ips" {
  description = "List of worker node IPs"
  type        = list(string)
}
