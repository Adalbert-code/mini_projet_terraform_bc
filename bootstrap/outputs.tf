# =============================================================================
# Outputs pour le bootstrap
# =============================================================================

output "s3_bucket_name" {
  description = "Nom du bucket S3 pour le state"
  value       = aws_s3_bucket.terraform_state.id
}

output "s3_bucket_arn" {
  description = "ARN du bucket S3"
  value       = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_name" {
  description = "Nom de la table DynamoDB pour le locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "dynamodb_table_arn" {
  description = "ARN de la table DynamoDB"
  value       = aws_dynamodb_table.terraform_locks.arn
}

output "backend_config" {
  description = "Configuration à utiliser dans le backend Terraform"
  value       = <<-EOT

    # Ajoutez cette configuration dans votre fichier providers.tf :

    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.terraform_state.id}"
        key            = "jenkins/terraform.tfstate"
        region         = "${var.aws_region}"
        encrypt        = true
        dynamodb_table = "${aws_dynamodb_table.terraform_locks.name}"
      }
    }
  EOT
}
