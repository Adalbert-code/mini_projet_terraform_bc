# =============================================================================
# Outputs pour l'application Jenkins
# =============================================================================

# -----------------------------------------------------------------------------
# Informations de connexion
# -----------------------------------------------------------------------------

output "jenkins_url" {
  description = "URL d'accès à l'interface web Jenkins"
  value       = "http://${module.eip.public_ip}:8080"
}

output "public_ip" {
  description = "Adresse IP publique du serveur Jenkins"
  value       = module.eip.public_ip
}

output "public_dns" {
  description = "Nom DNS public du serveur Jenkins"
  value       = module.eip.public_dns
}

output "ssh_command" {
  description = "Commande SSH pour se connecter au serveur"
  value       = "ssh -i ${module.keypair.private_key_path} ubuntu@${module.eip.public_ip}"
}

# -----------------------------------------------------------------------------
# Informations réseau
# -----------------------------------------------------------------------------

output "vpc_id" {
  description = "ID du VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "Bloc CIDR du VPC"
  value       = module.vpc.vpc_cidr_block
}

output "subnet_id" {
  description = "ID du subnet"
  value       = module.subnet.subnet_id
}

output "subnet_cidr" {
  description = "Bloc CIDR du subnet"
  value       = module.subnet.subnet_cidr_block
}

output "igw_id" {
  description = "ID de l'Internet Gateway"
  value       = module.igw.igw_id
}

output "route_table_id" {
  description = "ID de la table de routage"
  value       = module.route_table.route_table_id
}

# -----------------------------------------------------------------------------
# Informations sur l'instance
# -----------------------------------------------------------------------------

output "instance_id" {
  description = "ID de l'instance EC2"
  value       = module.ec2.instance_id
}

output "instance_type" {
  description = "Type de l'instance EC2"
  value       = var.instance_type
}

output "availability_zone" {
  description = "Zone de disponibilité"
  value       = var.availability_zone
}

output "ami_id" {
  description = "ID de l'AMI utilisée"
  value       = module.ec2.ami_id
}

output "ami_name" {
  description = "Nom de l'AMI utilisée"
  value       = module.ec2.ami_name
}

output "private_ip" {
  description = "Adresse IP privée de l'instance"
  value       = module.ec2.private_ip
}

# -----------------------------------------------------------------------------
# Informations sur le stockage
# -----------------------------------------------------------------------------

output "ebs_volume_id" {
  description = "ID du volume EBS"
  value       = module.ebs.volume_id
}

output "ebs_volume_size" {
  description = "Taille du volume EBS en GB"
  value       = var.ebs_volume_size
}

# -----------------------------------------------------------------------------
# Informations sur la sécurité
# -----------------------------------------------------------------------------

output "security_group_id" {
  description = "ID du groupe de sécurité"
  value       = module.security_group.sg_id
}

output "key_name" {
  description = "Nom de la paire de clés"
  value       = module.keypair.key_name
}

output "private_key_path" {
  description = "Chemin vers la clé privée SSH"
  value       = module.keypair.private_key_path
}

# -----------------------------------------------------------------------------
# Fichier de métadonnées
# -----------------------------------------------------------------------------

output "metadata_file" {
  description = "Chemin vers le fichier de métadonnées Jenkins"
  value       = local_file.jenkins_metadata.filename
}
