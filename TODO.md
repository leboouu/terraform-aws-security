# TODO for RDS Module Corrections

- [x] Add missing variables 'parameter_group_family' and 'tags' to modules/rds/variables.tf
- [x] Change parameter group names to be generic (remove '-postgres-')
- [x] Make SSL parameter dynamic based on engine (ssl for postgres, rds.force_ssl for mysql)
- [x] Change all parameter group tags to use var.common_tags for consistency
- [ ] Run terraform validate to check for errors
