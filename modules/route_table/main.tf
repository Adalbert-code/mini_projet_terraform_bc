# =============================================================================
# Module Route Table - Création d'une table de routage
# =============================================================================

# Création de la table de routage
resource "aws_route_table" "this" {
  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = var.route_table_name
    }
  )
}

# Route vers Internet via l'Internet Gateway
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.this.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.igw_id
}

# Association de la table de routage avec le subnet
resource "aws_route_table_association" "this" {
  subnet_id      = var.subnet_id
  route_table_id = aws_route_table.this.id
}
