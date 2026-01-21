# =============================================================================
# Outputs pour le module security_group
# =============================================================================

output "sg_id" {
  description = "ID du groupe de sécurité"
  value       = aws_security_group.this.id
}

output "sg_name" {
  description = "Nom du groupe de sécurité"
  value       = aws_security_group.this.name
}

output "sg_arn" {
  description = "ARN du groupe de sécurité"
  value       = aws_security_group.this.arn
}
