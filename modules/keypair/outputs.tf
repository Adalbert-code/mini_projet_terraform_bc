# =============================================================================
# Outputs pour le module keypair
# =============================================================================

output "key_name" {
  description = "Nom de la paire de clés créée"
  value       = aws_key_pair.this.key_name
}

output "key_id" {
  description = "ID de la paire de clés"
  value       = aws_key_pair.this.key_pair_id
}

output "private_key_pem" {
  description = "Clé privée au format PEM"
  value       = tls_private_key.this.private_key_pem
  sensitive   = true
}

output "public_key_openssh" {
  description = "Clé publique au format OpenSSH"
  value       = tls_private_key.this.public_key_openssh
}

output "private_key_path" {
  description = "Chemin vers le fichier de clé privée"
  value       = local_file.private_key.filename
}
