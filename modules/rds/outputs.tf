# ============================================================================
# MODULES/RDS/outputs.tf
# ============================================================================

output "db_instance_id" {
  description = "ID de l'instance RDS"
  value       = aws_db_instance.main.id
}

output "db_instance_arn" {
  description = "ARN de l'instance RDS"
  value       = aws_db_instance.main.arn
}

output "db_instance_endpoint" {
  description = "Endpoint de l'instance RDS"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "db_instance_address" {
  description = "Adresse de l'instance RDS"
  value       = aws_db_instance.main.address
}

output "db_instance_port" {
  description = "Port de l'instance RDS"
  value       = aws_db_instance.main.port
}

output "db_instance_name" {
  description = "Nom de la base de données"
  value       = aws_db_instance.main.db_name
}

output "db_instance_username" {
  description = "Nom d'utilisateur master"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "db_instance_password" {
  description = "Mot de passe master"
  value       = random_password.master_password.result
  sensitive   = true
}

output "security_group_id" {
  description = "ID du security group RDS"
  value       = aws_security_group.rds.id
}

output "db_subnet_group_name" {
  description = "Nom du subnet group"
  value       = aws_db_subnet_group.main.name
}

output "connection_string" {
  description = "Chaîne de connexion"
  value       = "${var.engine}://${aws_db_instance.main.username}:${random_password.master_password.result}@${aws_db_instance.main.endpoint}/${aws_db_instance.main.db_name}"
  sensitive   = true
}
