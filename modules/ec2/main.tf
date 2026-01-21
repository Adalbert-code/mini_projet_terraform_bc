# =============================================================================
# Module: ec2
# Description: Création d'une instance EC2 Ubuntu Jammy avec taille/tags variabilisés
# =============================================================================

# Récupération de l'AMI Ubuntu Jammy 22.04 LTS la plus récente
data "aws_ami" "ubuntu_jammy" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Création de l'instance EC2
resource "aws_instance" "this" {
  ami                    = data.aws_ami.ubuntu_jammy.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.security_group_ids
  availability_zone      = var.availability_zone
  subnet_id              = var.subnet_id

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    encrypted             = var.root_volume_encrypted
    delete_on_termination = true
  }

  tags = merge(var.tags, { Name = var.instance_name })
}
