# =============================================================================
# Variables pour le module security_group
# =============================================================================

variable "sg_name" {
  description = "Nom du groupe de sécurité"
  type        = string
}

variable "sg_description" {
  description = "Description du groupe de sécurité"
  type        = string
  default     = "Security group managed by Terraform"
}

variable "vpc_id" {
  description = "ID du VPC pour le groupe de sécurité"
  type        = string
}

variable "ingress_rules" {
  description = "Liste des règles d'entrée pour le groupe de sécurité"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "SSH access"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP access"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS access"
    },
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Jenkins access"
    }
  ]
}

variable "tags" {
  description = "Tags à appliquer à la ressource"
  type        = map(string)
  default     = {}
}
