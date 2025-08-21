data "local_file" "ansible_inventory" {
  filename = "../../ansible/inventory.yaml"
}

locals {
  inventory = yamldecode(data.local_file.ansible_inventory.content)
  hosts = local.inventory["microk8s"]["hosts"]
  gateway = local.inventory["microk8s"]["vars"]["gateway"]
  dns_servers = local.inventory["microk8s"]["vars"]["dns_servers"]
}

resource "proxmox_virtual_environment_download_file" "image" {
  content_type = "iso"
  datastore_id = "local"
  file_name    = "ubuntu.img"
  node_name    = var.virtual_environment.node_name
  url          = var.image_url
  overwrite    = false
}

module "proxmox-ubuntu-vm" {
  for_each    = local.hosts
  source      = "./modules/proxmox-ubuntu-vm"
  vm_name     = each.key
  public_key  = local.public_key_content
  vm_username = var.vm_username
  cpu_cores   = 4
  memory_size = 8142
  static_ip_address = "${each.value.ansible_host}/24"
  ip_type     = "static"
  image_id    = proxmox_virtual_environment_download_file.image.id
  gateway     = local.gateway
  pve_datastore_id = var.virtual_environment.datastore_id
  dns_servers = local.dns_servers
}