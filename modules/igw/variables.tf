# =============================================================================
# Variables pour le module IGW
# =============================================================================

variable "vpc_id" {
  description = "ID du VPC auquel attacher l'Internet Gateway"
  type        = string
}

variable "igw_name" {
  description = "Nom de l'Internet Gateway"
  type        = string
  default     = "jenkins-igw"
}

variable "tags" {
  description = "Tags à appliquer à l'Internet Gateway"
  type        = map(string)
  default     = {}
}
