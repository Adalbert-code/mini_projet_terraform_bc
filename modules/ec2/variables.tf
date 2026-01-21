# =============================================================================
# Variables pour le module ec2
# =============================================================================

variable "instance_name" {
  description = "Nom de l'instance EC2"
  type        = string
}

variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Nom de la paire de clés pour l'accès SSH"
  type        = string
}

variable "security_group_ids" {
  description = "Liste des IDs de groupes de sécurité"
  type        = list(string)
}

variable "availability_zone" {
  description = "Zone de disponibilité pour l'instance"
  type        = string
}

variable "subnet_id" {
  description = "ID du subnet dans lequel déployer l'instance"
  type        = string
}

variable "root_volume_size" {
  description = "Taille du volume root en GB"
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "Type du volume root"
  type        = string
  default     = "gp3"
}

variable "root_volume_encrypted" {
  description = "Activer le chiffrement du volume root"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags à appliquer à l'instance"
  type        = map(string)
  default     = {}
}
