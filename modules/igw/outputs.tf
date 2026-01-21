# =============================================================================
# Outputs pour le module IGW
# =============================================================================

output "igw_id" {
  description = "ID de l'Internet Gateway"
  value       = aws_internet_gateway.this.id
}

output "igw_arn" {
  description = "ARN de l'Internet Gateway"
  value       = aws_internet_gateway.this.arn
}
