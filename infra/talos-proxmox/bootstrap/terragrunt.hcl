
terraform {
  source = "./terraform"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "provision" {
  config_path = "../provision"
}

inputs = {
  controlplane_ips = dependency.provision.outputs.controlplane_ips
  worker_ips      = dependency.provision.outputs.worker_ips
}