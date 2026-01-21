# =============================================================================
# Variables pour le module Route Table
# =============================================================================

variable "vpc_id" {
  description = "ID du VPC pour la table de routage"
  type        = string
}

variable "igw_id" {
  description = "ID de l'Internet Gateway pour la route vers Internet"
  type        = string
}

variable "subnet_id" {
  description = "ID du subnet à associer à cette table de routage"
  type        = string
}

variable "route_table_name" {
  description = "Nom de la table de routage"
  type        = string
  default     = "jenkins-route-table"
}

variable "tags" {
  description = "Tags à appliquer à la table de routage"
  type        = map(string)
  default     = {}
}
