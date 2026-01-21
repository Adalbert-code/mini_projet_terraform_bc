# =============================================================================
# Variables pour le module VPC
# =============================================================================

variable "vpc_cidr_block" {
  description = "Bloc CIDR pour le VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr_block, 0))
    error_message = "Le bloc CIDR doit être une adresse CIDR valide."
  }
}

variable "vpc_name" {
  description = "Nom du VPC"
  type        = string
  default     = "jenkins-vpc"
}

variable "enable_dns_hostnames" {
  description = "Activer les noms d'hôtes DNS dans le VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Activer le support DNS dans le VPC"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags à appliquer au VPC"
  type        = map(string)
  default     = {}
}
