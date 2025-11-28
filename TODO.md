# TODO for Terraform Errors Fixes

- [x] Fix RDS Parameter Group name conflict: Changed hardcoded name to dynamic `${var.project_name}-${var.environment}-db-params`
- [x] Fix EKS Add-on recreation: Removed `preserve = true` from EBS CSI driver to avoid purging configurations
- [x] Fix EKS Node Group failure: Added dependencies on cluster and add-ons to ensure cluster readiness before node group creation
- [ ] Run terraform apply to verify fixes
