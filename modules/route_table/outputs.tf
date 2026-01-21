# =============================================================================
# Outputs pour le module Route Table
# =============================================================================

output "route_table_id" {
  description = "ID de la table de routage"
  value       = aws_route_table.this.id
}

output "route_table_arn" {
  description = "ARN de la table de routage"
  value       = aws_route_table.this.arn
}

output "route_table_association_id" {
  description = "ID de l'association entre la table de routage et le subnet"
  value       = aws_route_table_association.this.id
}
