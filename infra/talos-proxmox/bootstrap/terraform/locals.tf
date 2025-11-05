
locals {
  controlplane_ips = var.controlplane_ips
  worker_ips       = var.worker_ips
  all_nodes        = concat(local.controlplane_ips, local.worker_ips)

  # Use cluster VIP if provided, otherwise use first control plane IP
  cluster_endpoint_ip = var.cluster_vip != "" ? var.cluster_vip : local.controlplane_ips[0]
  cluster_endpoint    = "https://${local.cluster_endpoint_ip}:6443"

  # Use specific bootstrap node IP if provided, otherwise use first available control plane
  bootstrap_node_ip = var.bootstrap_node_ip != "" ? var.bootstrap_node_ip : local.controlplane_ips[0]

  # Hash of critical values to trigger kubeconfig recreation
  kubeconfig_trigger = md5(join(",", [
    local.cluster_endpoint,
    local.bootstrap_node_ip,
    join(",", local.controlplane_ips)
  ]))
}
