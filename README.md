# Terraform AWS Security

This repository contains Terraform configurations for deploying a secure AWS infrastructure with VPC, EKS cluster, RDS database, and Prisma Cloud integration for security monitoring.

## Architecture

The infrastructure includes:

- **VPC**: Custom VPC with public and private subnets, NAT gateways, and internet gateway
- **EKS**: Kubernetes cluster with managed node groups
- **RDS**: PostgreSQL database with encryption and security groups
- **Prisma Cloud**: Cloud security platform integration for AWS account monitoring and policies

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate permissions
- Prisma Cloud account and API credentials

## Quick Start

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd terraform-aws-security
   ```

2. Update `terraform.tfvars` with your values:
   ```hcl
   region = "us-east-1"
   db_password = "your-secure-password"
   # Add other required variables
   ```

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Validate the configuration:
   ```bash
   terraform validate
   ```

5. Plan the deployment:
   ```bash
   terraform plan
   ```

6. Deploy the infrastructure:
   ```bash
   terraform apply
   ```

## Modules

### VPC Module (`modules/vpc/`)

Creates a VPC with:
- Configurable CIDR block
- Public and private subnets across multiple availability zones
- Internet Gateway
- NAT Gateways for private subnet internet access
- Route tables and associations

### EKS Module (`modules/eks/`)

Deploys an EKS cluster with:
- Managed Kubernetes control plane
- IAM roles for cluster and nodes
- Security groups
- Node groups with configurable instance types and scaling

### RDS Module (`modules/rds/`)

Sets up a PostgreSQL database with:
- DB subnet group
- Security group with restricted access
- Storage encryption
- Backup configuration
- Multi-AZ deployment option

### Prisma Cloud Integration (`prisma-cloud/`)

Integrates AWS account with Prisma Cloud for:
- Cloud account onboarding
- Security policies and compliance monitoring

## Configuration

### Variables

Key variables to configure:

- `region`: AWS region for deployment
- `vpc_cidr`: CIDR block for the VPC
- `cluster_name`: Name of the EKS cluster
- `db_name`: Name of the RDS database
- `db_username`: Database username
- `db_password`: Database password (sensitive)

### Outputs

The configuration provides outputs for:
- VPC details (ID, subnets, gateways)
- EKS cluster endpoint and configuration
- RDS database endpoint and connection details

## Security Features

- VPC isolation with private subnets
- Security groups restricting access
- RDS storage encryption
- IAM roles with least privilege
- Prisma Cloud security monitoring

## Deployment Scripts

Use the provided scripts for automated deployment:

- `scripts/deploy.sh`: Initializes, validates, plans, and applies the configuration
- `scripts/destroy.sh`: Destroys the infrastructure

Make the scripts executable:
```bash
chmod +x scripts/deploy.sh scripts/destroy.sh
```

## Cleanup

To destroy the infrastructure:
```bash
terraform destroy
```

Or use the destroy script:
```bash
./scripts/destroy.sh
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and validation
5. Submit a pull request

## License

This project is licensed under the MIT License.
