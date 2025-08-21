
locals {
  controlplane_ip = var.controlplane_ip
  worker_ips      = var.worker_ips
  all_nodes       = concat([local.controlplane_ip], local.worker_ips)
}
