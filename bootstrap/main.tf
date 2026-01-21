# =============================================================================
# Bootstrap - Création du bucket S3 et de la table DynamoDB pour le backend
# =============================================================================
# Ce module doit être exécuté UNE SEULE FOIS avant le déploiement principal
# pour créer l'infrastructure nécessaire au stockage distant du state Terraform
# =============================================================================

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# -----------------------------------------------------------------------------
# Bucket S3 pour le stockage du state Terraform
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket_name

  # Empêcher la suppression accidentelle du bucket (mettre à false pour destroy)
  lifecycle {
    prevent_destroy = false
  }

  # Permet de détruire le bucket même s'il contient des objets
  force_destroy = true

  tags = merge(
    var.tags,
    {
      Name    = var.bucket_name
      Purpose = "Terraform State Storage"
    }
  )
}

# Activer le versioning pour garder l'historique des states
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Activer le chiffrement côté serveur
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bloquer l'accès public au bucket
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------------------------------------------------------
# Table DynamoDB pour le state locking
# -----------------------------------------------------------------------------

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(
    var.tags,
    {
      Name    = var.dynamodb_table_name
      Purpose = "Terraform State Locking"
    }
  )
}
