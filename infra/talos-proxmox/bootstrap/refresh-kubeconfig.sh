#!/bin/bash

# Script to refresh kubeconfig when control plane nodes change
# Usage: ./refresh-kubeconfig.sh

echo "🔄 Refreshing kubeconfig after control plane changes..."

# Taint the kubeconfig resource to force recreation
echo "📌 Tainting kubeconfig resource..."
terragrunt taint talos_cluster_kubeconfig.this

# Taint the local kubeconfig file as well
echo "📌 Tainting kubeconfig file..."
terragrunt taint local_file.kubeconfig

# Apply changes
echo "🚀 Applying changes..."
terragrunt apply

echo "✅ Kubeconfig refreshed! New kubeconfig should contain updated server endpoint."
