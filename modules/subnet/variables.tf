# =============================================================================
# Variables pour le module Subnet
# =============================================================================

variable "vpc_id" {
  description = "ID du VPC dans lequel créer le subnet"
  type        = string
}

variable "subnet_cidr_block" {
  description = "Bloc CIDR pour le subnet"
  type        = string
  default     = "10.0.1.0/24"

  validation {
    condition     = can(cidrhost(var.subnet_cidr_block, 0))
    error_message = "Le bloc CIDR doit être une adresse CIDR valide."
  }
}

variable "availability_zone" {
  description = "Zone de disponibilité pour le subnet"
  type        = string
}

variable "subnet_name" {
  description = "Nom du subnet"
  type        = string
  default     = "jenkins-subnet"
}

variable "map_public_ip_on_launch" {
  description = "Attribuer automatiquement une IP publique aux instances lancées dans ce subnet"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags à appliquer au subnet"
  type        = map(string)
  default     = {}
}
