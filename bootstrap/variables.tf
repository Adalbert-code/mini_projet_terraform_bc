# =============================================================================
# Variables pour le bootstrap
# =============================================================================

variable "aws_region" {
  description = "Région AWS pour créer les ressources"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Nom du bucket S3 pour le state Terraform (doit être unique globalement)"
  type        = string
  default     = "jenkins-terraform-state-adaln-2026"

  validation {
    condition     = length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
    error_message = "Le nom du bucket doit contenir entre 3 et 63 caractères."
  }
}

variable "dynamodb_table_name" {
  description = "Nom de la table DynamoDB pour le state locking"
  type        = string
  default     = "jenkins-terraform-locks"
}

variable "tags" {
  description = "Tags communs à appliquer aux ressources"
  type        = map(string)
  default = {
    Project     = "Jenkins-Terraform"
    ManagedBy   = "Terraform"
    Environment = "shared"
  }
}
