# =============================================================================
# Module: ebs
# Description: Création d'un volume EBS avec taille variabilisée
# =============================================================================

resource "aws_ebs_volume" "this" {
  availability_zone = var.availability_zone
  size              = var.volume_size
  type              = var.volume_type
  encrypted         = var.encrypted
  iops              = var.volume_type == "gp3" ? var.iops : null
  throughput        = var.volume_type == "gp3" ? var.throughput : null

  tags = merge(var.tags, { Name = var.volume_name })
}
