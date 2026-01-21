# =============================================================================
# Variables pour le module keypair
# =============================================================================

variable "key_name" {
  description = "Nom de la paire de clés AWS"
  type        = string
}

variable "rsa_bits" {
  description = "Taille de la clé RSA en bits"
  type        = number
  default     = 4096
}

variable "private_key_path" {
  description = "Chemin où sauvegarder la clé privée"
  type        = string
}

variable "tags" {
  description = "Tags à appliquer à la ressource"
  type        = map(string)
  default     = {}
}
