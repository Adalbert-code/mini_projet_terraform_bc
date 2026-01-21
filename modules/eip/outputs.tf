# =============================================================================
# Outputs pour le module eip
# =============================================================================

output "eip_id" {
  description = "ID de l'adresse IP élastique"
  value       = aws_eip.this.id
}

output "public_ip" {
  description = "Adresse IP publique"
  value       = aws_eip.this.public_ip
}

output "public_dns" {
  description = "Nom DNS public de l'EIP"
  value       = aws_eip.this.public_dns
}

output "allocation_id" {
  description = "ID d'allocation de l'EIP"
  value       = aws_eip.this.allocation_id
}
