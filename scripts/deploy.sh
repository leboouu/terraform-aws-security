#!/bin/bash

# Terraform AWS Security Deployment Script

set -e  # Exit on any error

echo "Initializing Terraform..."
terraform init

echo "Validating Terraform configuration..."
terraform validate

echo "Planning Terraform deployment..."
terraform plan -out=tfplan

echo "Applying Terraform configuration..."
terraform apply tfplan

echo "Deployment completed successfully!"
