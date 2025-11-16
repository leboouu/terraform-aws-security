# Terraform AWS Security

This repository contains Terraform configurations for deploying a comprehensive secure AWS infrastructure including VPC, EKS cluster, RDS database, Application Load Balancer with WAF, advanced security services, monitoring, and Prisma Cloud integration for security monitoring.

## Architecture

The infrastructure includes:

- **VPC**: Custom VPC with public and private subnets, NAT gateways, internet gateway, and VPC flow logs
- **EKS**: Kubernetes cluster with managed node groups, encryption, and IAM roles
- **RDS**: PostgreSQL database with encryption, security groups, and enhanced monitoring
- **ALB**: Application Load Balancer with WAF protection, access logs, and cross-zone load balancing
- **Security Services**: GuardDuty, CloudTrail, AWS Config, KMS encryption, and Secrets Manager
- **Monitoring**: CloudWatch alarms, log groups, and SNS alerts for security and operational notifications
- **Prisma Cloud**: Cloud security platform integration for AWS account monitoring and policies

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate permissions
- Prisma Cloud account and API credentials

### Provider Credentials

#### AWS Provider
Configure AWS credentials using one of the following methods:

1. **AWS CLI Configuration** (recommended):
   ```bash
   aws configure
   ```

2. **Environment Variables**:
   ```bash
   export AWS_ACCESS_KEY_ID="your-access-key"
   export AWS_SECRET_ACCESS_KEY="your-secret-key"
   export AWS_DEFAULT_REGION="us-east-1"
   ```

3. **Shared Credentials File** (`~/.aws/credentials`):
   ```ini
   [default]
   aws_access_key_id = your-access-key
   aws_secret_access_key = your-secret-key
   region = us-east-1
   ```

#### Prisma Cloud Provider
Obtain your Prisma Cloud credentials from the Prisma Cloud Console:

1. Log in to your Prisma Cloud account
2. Navigate to **Settings > Access Keys**
3. Generate a new access key pair
4. Set the credentials as environment variables:
   ```bash
   export PRISMA_ACCESS_KEY="your-prisma-access-key"
   export PRISMA_SECRET_KEY="your-prisma-secret-key"
   ```

For the Prisma Cloud integration, you'll also need:
- Your AWS Account ID (found in AWS Console under **My Account**)
- An IAM user or role with appropriate permissions for Prisma Cloud to scan your AWS account

## Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/leboouu/terraform-aws-security.git
   cd terraform-aws-security
   ```

2. Update `terraform.tfvars` with your values:
   ```hcl
   region = "us-east-1"
   db_password = "your-secure-password"

   # Prisma Cloud credentials (if using Prisma Cloud integration)
   prisma_access_key = "your-prisma-access-key"
   prisma_secret_key = "your-prisma-secret-key"
   aws_account_id = "123456789012"  # Your AWS Account ID
   aws_access_key = "your-aws-access-key"  # For Prisma Cloud integration
   aws_secret_key = "your-aws-secret-key"  # For Prisma Cloud integration

   # Add other required variables as needed
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
- VPC flow logs for network monitoring

### EKS Module (`modules/eks/`)

Deploys an EKS cluster with:
- Managed Kubernetes control plane
- IAM roles for cluster and nodes with IRSA support
- Security groups
- Node groups with configurable instance types and scaling
- Cluster and node encryption using KMS
- CloudWatch logging for control plane

### RDS Module (`modules/rds/`)

Sets up a PostgreSQL database with:
- DB subnet group
- Security group with restricted access
- Storage encryption using KMS
- Backup configuration
- Multi-AZ deployment option
- Enhanced monitoring with CloudWatch
- Performance Insights

### ALB Module (`modules/ALB/`)

Deploys an Application Load Balancer with:
- WAF v2 Web ACL with rate limiting, managed rules, and geo-blocking
- Access logs stored in S3
- Cross-zone load balancing
- Deletion protection for production environments
- HTTP/2 support

### Security Module (`security/`)

Provides comprehensive security services:
- **GuardDuty**: Threat detection and monitoring
- **CloudTrail**: API activity logging with CloudWatch integration and alerts
- **AWS Config**: Resource configuration monitoring with compliance rules
- **KMS**: Encryption keys for EKS, RDS, CloudWatch, SNS, and Secrets Manager
- **Secrets Manager**: Secure storage for database credentials

### Prisma Cloud Integration (`prisma-cloud/`)

Integrates AWS account with Prisma Cloud for:
- Cloud account onboarding
- Security policies and compliance monitoring
- Custom policy creation and management

## Configuration

### Variables

Key variables to configure:

- `region`: AWS region for deployment
- `vpc_cidr`: CIDR block for the VPC
- `cluster_name`: Name of the EKS cluster
- `db_name`: Name of the RDS database
- `db_username`: Database username
- `db_password`: Database password (sensitive)
- `enable_guardduty`: Enable AWS GuardDuty (default: true)
- `enable_cloudtrail`: Enable AWS CloudTrail (default: true)
- `enable_config`: Enable AWS Config (default: true)
- `enable_waf`: Enable WAF for ALB (default: true)
- `security_team_email`: Email for security alerts
- `ops_team_email`: Email for operational alerts

### Outputs

The configuration provides outputs for:
- VPC details (ID, subnets, gateways)
- EKS cluster endpoint and configuration
- RDS database endpoint and connection details
- ALB DNS name and ARN
- Security service IDs (GuardDuty detector, CloudTrail name, etc.)
- KMS key ARNs for various services
- SNS topic ARN for alerts

## Security Features

- **Network Security**: VPC isolation with private subnets, security groups, and NACLs
- **Encryption**: KMS encryption for EKS, RDS, CloudWatch logs, SNS, and Secrets Manager
- **Access Control**: IAM roles with least privilege, IRSA for EKS service accounts
- **Threat Detection**: GuardDuty for continuous threat monitoring
- **Audit Logging**: CloudTrail with CloudWatch alerts for root account usage
- **Compliance Monitoring**: AWS Config rules for resource compliance
- **Web Application Security**: WAF with rate limiting, managed rules, and geo-blocking
- **Secrets Management**: Secure storage of database credentials in Secrets Manager
- **Prisma Cloud Integration**: Advanced security monitoring and policy enforcement

## Deployment Scripts

Use the provided scripts for automated deployment:

- `scripts/deploy.sh`: Initializes, validates, plans, and applies the configuration
- `scripts/destroy.sh`: Destroys the infrastructure

Make the scripts executable:
```bash
chmod +x scripts/deploy.sh scripts/destroy.sh
```

## Monitoring and Alerts

The infrastructure includes comprehensive monitoring and alerting:

- **CloudWatch Alarms**: CPU/memory utilization for EKS, RDS connections, and CloudTrail root usage
- **SNS Topics**: Email notifications for security and operational alerts
- **CloudWatch Logs**: Centralized logging for applications, CloudTrail, and VPC flow logs
- **Enhanced Monitoring**: Detailed metrics for RDS and EKS clusters

## Cost Optimization

- Spot instances support for EKS node groups
- Auto-scaling based on resource utilization
- Lifecycle policies for S3 buckets (ALB logs, CloudTrail logs)
- Configurable instance types and storage sizes

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
