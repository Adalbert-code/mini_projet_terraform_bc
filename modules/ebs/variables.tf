# =============================================================================
# Variables pour le module ebs
# =============================================================================

variable "volume_name" {
  description = "Nom du volume EBS"
  type        = string
}

variable "availability_zone" {
  description = "Zone de disponibilité pour le volume"
  type        = string
}

variable "volume_size" {
  description = "Taille du volume en GB"
  type        = number
  default     = 20
}

variable "volume_type" {
  description = "Type de volume EBS (gp2, gp3, io1, io2, st1, sc1)"
  type        = string
  default     = "gp3"
}

variable "encrypted" {
  description = "Activer le chiffrement du volume"
  type        = bool
  default     = true
}

variable "iops" {
  description = "IOPS pour les volumes gp3/io1/io2"
  type        = number
  default     = 3000
}

variable "throughput" {
  description = "Throughput en MB/s pour les volumes gp3"
  type        = number
  default     = 125
}

variable "tags" {
  description = "Tags à appliquer à la ressource"
  type        = map(string)
  default     = {}
}
