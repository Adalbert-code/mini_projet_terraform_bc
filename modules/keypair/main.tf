# =============================================================================
# Module: keypair
# Description: Génération dynamique d'une paire de clés SSH pour l'accès EC2
# =============================================================================

# Génération de la clé privée RSA
resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = var.rsa_bits
}

# Création de la paire de clés AWS
resource "aws_key_pair" "this" {
  key_name   = var.key_name
  public_key = tls_private_key.this.public_key_openssh

  tags = var.tags
}

# Sauvegarde de la clé privée en local
resource "local_file" "private_key" {
  content         = tls_private_key.this.private_key_pem
  filename        = var.private_key_path
  file_permission = "0400"
}
