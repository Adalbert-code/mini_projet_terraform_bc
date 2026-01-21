# =============================================================================
# Outputs pour le module Subnet
# =============================================================================

output "subnet_id" {
  description = "ID du subnet"
  value       = aws_subnet.this.id
}

output "subnet_arn" {
  description = "ARN du subnet"
  value       = aws_subnet.this.arn
}

output "subnet_cidr_block" {
  description = "Bloc CIDR du subnet"
  value       = aws_subnet.this.cidr_block
}

output "availability_zone" {
  description = "Zone de disponibilité du subnet"
  value       = aws_subnet.this.availability_zone
}
