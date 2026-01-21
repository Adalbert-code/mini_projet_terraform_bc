# =============================================================================
# Outputs pour le module ec2
# =============================================================================

output "instance_id" {
  description = "ID de l'instance EC2"
  value       = aws_instance.this.id
}

output "instance_arn" {
  description = "ARN de l'instance EC2"
  value       = aws_instance.this.arn
}

output "private_ip" {
  description = "Adresse IP privée de l'instance"
  value       = aws_instance.this.private_ip
}

output "public_dns" {
  description = "Nom DNS public de l'instance"
  value       = aws_instance.this.public_dns
}

output "availability_zone" {
  description = "Zone de disponibilité de l'instance"
  value       = aws_instance.this.availability_zone
}

output "ami_id" {
  description = "ID de l'AMI utilisée"
  value       = data.aws_ami.ubuntu_jammy.id
}

output "ami_name" {
  description = "Nom de l'AMI utilisée"
  value       = data.aws_ami.ubuntu_jammy.name
}
