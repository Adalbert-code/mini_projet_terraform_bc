# =============================================================================
# Outputs pour le module ebs
# =============================================================================

output "volume_id" {
  description = "ID du volume EBS"
  value       = aws_ebs_volume.this.id
}

output "volume_arn" {
  description = "ARN du volume EBS"
  value       = aws_ebs_volume.this.arn
}

output "availability_zone" {
  description = "Zone de disponibilité du volume"
  value       = aws_ebs_volume.this.availability_zone
}

output "volume_size" {
  description = "Taille du volume en GB"
  value       = aws_ebs_volume.this.size
}
