# =============================================================================
# Variables globales pour l'application Jenkins
# =============================================================================

# -----------------------------------------------------------------------------
# Variables AWS
# -----------------------------------------------------------------------------

variable "aws_region" {
  description = "Région AWS pour le déploiement"
  type        = string
  default     = "us-east-1"
}

variable "availability_zone" {
  description = "Zone de disponibilité AWS"
  type        = string
  default     = "us-east-1a"
}

variable "environment" {
  description = "Environnement de déploiement (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# -----------------------------------------------------------------------------
# Variables VPC
# -----------------------------------------------------------------------------

variable "vpc_name" {
  description = "Nom du VPC"
  type        = string
  default     = "jenkins-vpc"
}

variable "vpc_cidr_block" {
  description = "Bloc CIDR pour le VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# -----------------------------------------------------------------------------
# Variables Subnet
# -----------------------------------------------------------------------------

variable "subnet_name" {
  description = "Nom du subnet"
  type        = string
  default     = "jenkins-subnet"
}

variable "subnet_cidr_block" {
  description = "Bloc CIDR pour le subnet"
  type        = string
  default     = "10.0.1.0/24"
}

# -----------------------------------------------------------------------------
# Variables Internet Gateway
# -----------------------------------------------------------------------------

variable "igw_name" {
  description = "Nom de l'Internet Gateway"
  type        = string
  default     = "jenkins-igw"
}

# -----------------------------------------------------------------------------
# Variables Route Table
# -----------------------------------------------------------------------------

variable "route_table_name" {
  description = "Nom de la table de routage"
  type        = string
  default     = "jenkins-route-table"
}

# -----------------------------------------------------------------------------
# Variables EC2
# -----------------------------------------------------------------------------

variable "instance_name" {
  description = "Nom de l'instance EC2 Jenkins"
  type        = string
  default     = "jenkins-server"
}

variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
  default     = "t2.medium"
}

variable "root_volume_size" {
  description = "Taille du volume root en GB"
  type        = number
  default     = 20
}

# -----------------------------------------------------------------------------
# Variables EBS
# -----------------------------------------------------------------------------

variable "ebs_volume_size" {
  description = "Taille du volume EBS additionnel en GB"
  type        = number
  default     = 30
}

variable "ebs_volume_name" {
  description = "Nom du volume EBS"
  type        = string
  default     = "jenkins-data"
}

# -----------------------------------------------------------------------------
# Variables Security Group
# -----------------------------------------------------------------------------

variable "sg_name" {
  description = "Nom du groupe de sécurité"
  type        = string
  default     = "jenkins-sg"
}

variable "ingress_rules" {
  description = "Règles d'entrée pour le groupe de sécurité"
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
      description = "Jenkins web interface"
    }
  ]
}

# -----------------------------------------------------------------------------
# Variables Keypair
# -----------------------------------------------------------------------------

variable "key_name" {
  description = "Nom de la paire de clés SSH"
  type        = string
  default     = "jenkins-key"
}

# -----------------------------------------------------------------------------
# Variables EIP
# -----------------------------------------------------------------------------

variable "eip_name" {
  description = "Nom de l'adresse IP élastique"
  type        = string
  default     = "jenkins-eip"
}

# -----------------------------------------------------------------------------
# Tags communs
# -----------------------------------------------------------------------------

variable "common_tags" {
  description = "Tags communs à appliquer à toutes les ressources"
  type        = map(string)
  default = {
    Application = "Jenkins"
    Owner       = "DevOps"
  }
}
