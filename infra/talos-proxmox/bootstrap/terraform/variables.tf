variable "cluster_name" {
  description = "Name of the Talos cluster"
  type        = string
  default     = "homelab-k8s"
}

locals {
  cluster_endpoint = "https://${var.controlplane_ip}:6443"
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

variable "controlplane_ip" {
  description = "IP address of the control plane node"
  type        = string
}

variable "worker_ips" {
  description = "List of worker node IPs"
  type        = list(string)
}
