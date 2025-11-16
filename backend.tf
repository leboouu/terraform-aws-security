# ============================================================================
# backend.tf
# ============================================================================

terraform {
  backend "s3" {
    # Configuration backend S3 pour state file
    # À configurer selon votre environnement
    
    # bucket         = "terraform-state-secure-app-ACCOUNT_ID"
    # key            = "prod/terraform.tfstate"
    # region         = "eu-west-1"
    # encrypt        = true
    # dynamodb_table = "terraform-state-lock"
    # kms_key_id     = "arn:aws:kms:eu-west-1:ACCOUNT_ID:key/KEY_ID"
    
    # Tags pour le bucket S3 (à créer manuellement)
    # Tags:
    #   Name        = "Terraform State"
    #   Environment = "Production"
    #   Purpose     = "State Management"
  }
}

# Script pour créer le backend S3
# aws s3api create-bucket \
#   --bucket terraform-state-secure-app-$(aws sts get-caller-identity --query Account --output text) \
#   --region eu-west-1 \
#   --create-bucket-configuration LocationConstraint=eu-west-1

# aws s3api put-bucket-versioning \
#   --bucket terraform-state-secure-app-$(aws sts get-caller-identity --query Account --output text) \
#   --versioning-configuration Status=Enabled

# aws s3api put-bucket-encryption \
#   --bucket terraform-state-secure-app-$(aws sts get-caller-identity --query Account --output text) \
#   --server-side-encryption-configuration '{
#     "Rules": [{
#       "ApplyServerSideEncryptionByDefault": {
#         "SSEAlgorithm": "aws:kms"
#       }
#     }]
#   }'

# aws dynamodb create-table \
#   --table-name terraform-state-lock \
#   --attribute-definitions AttributeName=LockID,AttributeType=S \
#   --key-schema AttributeName=LockID,KeyType=HASH \
#   --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5