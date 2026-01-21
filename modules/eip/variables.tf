# =============================================================================
# Variables pour le module eip
# =============================================================================

variable "eip_name" {
  description = "Nom de l'adresse IP élastique"
  type        = string
}

variable "tags" {
  description = "Tags à appliquer à la ressource"
  type        = map(string)
  default     = {}
}
