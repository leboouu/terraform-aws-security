#!/bin/bash

# Terraform AWS Security Destroy Script

set -e  # Exit on any error

echo "Planning Terraform destruction..."
terraform plan -destroy -out=tfplan-destroy

echo "Destroying Terraform resources..."
terraform apply tfplan-destroy

echo "Cleanup completed successfully!"
