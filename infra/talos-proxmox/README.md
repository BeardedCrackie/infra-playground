# Talos Proxmox Cluster Setup

This directory provisions a Talos Kubernetes cluster on Proxmox using Terraform and Terragrunt.

## 1. Create Your `root.hcl`

Copy the example config and edit values as needed:

```bash
cp root.hcl.example root.hcl
```

Edit in your Proxmox credentials, datastore, and network info.
Set cluster and MetalLB IP pool variables.

## 2. Run All Units
Initialize and apply all modules (provision, bootstrap, apps):

```bash
cd infra/clusters/talos-proxmox/provision
terragrunt apply-all
```

## 3. Run Only a Specific Unit
To run only one unit (e.g., bootstrap):

```bash
cd infra/clusters/talos-proxmox/bootstrap
terragrunt apply
```

## 4. Delete (Destroy) Only a Specific Unit
To destroy only one unit (e.g., apps):

```bash
cd infra/clusters/talos-proxmox/apps
terragrunt destroy
```

## Notes
Each subfolder (provision, bootstrap, apps) is a Terragrunt unit.
You can run terragrunt plan or terragrunt apply in any unit folder.
Outputs (like kubeconfig) are written to each unit's folder.

See root.hcl.example for config reference.