# =============================================================================
# Outputs pour le module VPC
# =============================================================================

output "vpc_id" {
  description = "ID du VPC"
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "ARN du VPC"
  value       = aws_vpc.this.arn
}

output "vpc_cidr_block" {
  description = "Bloc CIDR du VPC"
  value       = aws_vpc.this.cidr_block
}

output "vpc_main_route_table_id" {
  description = "ID de la table de routage principale du VPC"
  value       = aws_vpc.this.main_route_table_id
}
