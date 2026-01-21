# =============================================================================
# Module: eip
# Description: Allocation d'une adresse IP élastique (Elastic IP)
# =============================================================================

resource "aws_eip" "this" {
  domain = "vpc"

  tags = merge(var.tags, { Name = var.eip_name })
}
