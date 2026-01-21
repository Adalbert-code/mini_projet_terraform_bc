# =============================================================================
# Orchestration des modules pour le déploiement Jenkins
# =============================================================================

# -----------------------------------------------------------------------------
# Module 1: VPC - Réseau virtuel privé
# -----------------------------------------------------------------------------
module "vpc" {
  source = "../modules/vpc"

  vpc_name       = var.vpc_name
  vpc_cidr_block = var.vpc_cidr_block
  tags           = var.common_tags
}

# -----------------------------------------------------------------------------
# Module 2: Subnet - Sous-réseau public
# -----------------------------------------------------------------------------
module "subnet" {
  source = "../modules/subnet"

  vpc_id                  = module.vpc.vpc_id
  subnet_name             = var.subnet_name
  subnet_cidr_block       = var.subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags                    = var.common_tags
}

# -----------------------------------------------------------------------------
# Module 3: Internet Gateway - Accès Internet
# -----------------------------------------------------------------------------
module "igw" {
  source = "../modules/igw"

  vpc_id   = module.vpc.vpc_id
  igw_name = var.igw_name
  tags     = var.common_tags
}

# -----------------------------------------------------------------------------
# Module 4: Route Table - Table de routage avec route vers Internet
# -----------------------------------------------------------------------------
module "route_table" {
  source = "../modules/route_table"

  vpc_id           = module.vpc.vpc_id
  igw_id           = module.igw.igw_id
  subnet_id        = module.subnet.subnet_id
  route_table_name = var.route_table_name
  tags             = var.common_tags
}

# -----------------------------------------------------------------------------
# Module 5: Keypair - Génération dynamique de la paire de clés
# -----------------------------------------------------------------------------
module "keypair" {
  source = "../modules/keypair"

  key_name         = var.key_name
  private_key_path = "${path.module}/${var.key_name}.pem"
  tags             = var.common_tags
}

# -----------------------------------------------------------------------------
# Module 6: Security Group - Ouverture des ports 22, 80, 443, 8080
# -----------------------------------------------------------------------------
module "security_group" {
  source = "../modules/security_group"

  sg_name        = var.sg_name
  sg_description = "Security group for Jenkins server - allows SSH, HTTP, HTTPS and Jenkins"
  vpc_id         = module.vpc.vpc_id
  ingress_rules  = var.ingress_rules
  tags           = var.common_tags
}

# -----------------------------------------------------------------------------
# Module 7: EIP - Adresse IP publique
# -----------------------------------------------------------------------------
module "eip" {
  source = "../modules/eip"

  eip_name = var.eip_name
  tags     = var.common_tags
}

# -----------------------------------------------------------------------------
# Module 8: EBS - Volume de données pour Jenkins
# -----------------------------------------------------------------------------
module "ebs" {
  source = "../modules/ebs"

  volume_name       = var.ebs_volume_name
  availability_zone = var.availability_zone
  volume_size       = var.ebs_volume_size
  tags              = var.common_tags
}

# -----------------------------------------------------------------------------
# Module 9: EC2 - Instance Ubuntu Jammy pour Jenkins
# -----------------------------------------------------------------------------
module "ec2" {
  source = "../modules/ec2"

  instance_name      = var.instance_name
  instance_type      = var.instance_type
  key_name           = module.keypair.key_name
  security_group_ids = [module.security_group.sg_id]
  subnet_id          = module.subnet.subnet_id
  availability_zone  = var.availability_zone
  root_volume_size   = var.root_volume_size
  tags               = var.common_tags

  depends_on = [module.keypair, module.security_group, module.route_table]
}

# -----------------------------------------------------------------------------
# Attachement du volume EBS à l'instance EC2
# -----------------------------------------------------------------------------
resource "aws_volume_attachment" "jenkins_ebs_attachment" {
  device_name = "/dev/sdf"
  volume_id   = module.ebs.volume_id
  instance_id = module.ec2.instance_id

  depends_on = [module.ec2, module.ebs]
}

# -----------------------------------------------------------------------------
# Association de l'EIP à l'instance EC2
# -----------------------------------------------------------------------------
resource "aws_eip_association" "jenkins_eip_association" {
  instance_id   = module.ec2.instance_id
  allocation_id = module.eip.allocation_id

  depends_on = [module.ec2, module.eip]
}

# -----------------------------------------------------------------------------
# Provisioning: Installation de Docker et Jenkins
# -----------------------------------------------------------------------------
resource "null_resource" "jenkins_provisioner" {
  depends_on = [
    aws_eip_association.jenkins_eip_association,
    aws_volume_attachment.jenkins_ebs_attachment
  ]

  # Trigger pour re-provisionner si l'instance change
  triggers = {
    instance_id = module.ec2.instance_id
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = module.keypair.private_key_pem
    host        = module.eip.public_ip
    timeout     = "5m"
  }

  # Copie du fichier docker-compose.yml
  provisioner "file" {
    source      = "${path.module}/files/docker-compose.yml"
    destination = "/home/ubuntu/docker-compose.yml"
  }

  # Installation de Docker et lancement de Jenkins
  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "set -e",

      "echo '=== Waiting for cloud-init to complete ==='",
      "cloud-init status --wait || true",

      "echo '=== Updating system packages ==='",
      "sudo apt-get update -y",

      "echo '=== Installing Docker ==='",
      "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update -y",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin",

      "echo '=== Configuring Docker ==='",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo usermod -aG docker ubuntu",

      "echo '=== Formatting and mounting EBS volume ==='",
      "sudo mkfs -t ext4 /dev/xvdf || true",
      "sudo mkdir -p /var/jenkins_home",
      "sudo mount /dev/xvdf /var/jenkins_home || true",
      "echo '/dev/xvdf /var/jenkins_home ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab",
      "sudo chown -R 1000:1000 /var/jenkins_home",

      "echo '=== Starting Jenkins with Docker Compose ==='",
      "cd /home/ubuntu",
      "sudo docker compose up -d",

      "echo '=== Jenkins deployment completed ==='",
      "echo 'Jenkins will be available at http://${module.eip.public_ip}:8080'",
      "echo 'Please wait a few minutes for Jenkins to fully start'"
    ]
  }
}

# -----------------------------------------------------------------------------
# Export des métadonnées dans jenkins_ec2.txt
# -----------------------------------------------------------------------------
resource "local_file" "jenkins_metadata" {
  depends_on = [null_resource.jenkins_provisioner]

  filename = "${path.module}/jenkins_ec2.txt"
  content  = <<-EOT
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                        JENKINS SERVER METADATA                                ║
    ╠══════════════════════════════════════════════════════════════════════════════╣
    ║                                                                              ║
    ║  Public IP Address  : ${module.eip.public_ip}
    ║  Public DNS         : ${module.eip.public_dns}
    ║  Jenkins URL        : http://${module.eip.public_ip}:8080
    ║                                                                              ║
    ╠══════════════════════════════════════════════════════════════════════════════╣
    ║                           NETWORK DETAILS                                     ║
    ╠══════════════════════════════════════════════════════════════════════════════╣
    ║                                                                              ║
    ║  VPC ID             : ${module.vpc.vpc_id}
    ║  VPC CIDR           : ${var.vpc_cidr_block}
    ║  Subnet ID          : ${module.subnet.subnet_id}
    ║  Subnet CIDR        : ${var.subnet_cidr_block}
    ║                                                                              ║
    ╠══════════════════════════════════════════════════════════════════════════════╣
    ║                           INSTANCE DETAILS                                    ║
    ╠══════════════════════════════════════════════════════════════════════════════╣
    ║                                                                              ║
    ║  Instance ID        : ${module.ec2.instance_id}
    ║  Instance Type      : ${var.instance_type}
    ║  Availability Zone  : ${var.availability_zone}
    ║  AMI ID             : ${module.ec2.ami_id}
    ║  AMI Name           : ${module.ec2.ami_name}
    ║  Private IP         : ${module.ec2.private_ip}
    ║                                                                              ║
    ╠══════════════════════════════════════════════════════════════════════════════╣
    ║                           STORAGE DETAILS                                     ║
    ╠══════════════════════════════════════════════════════════════════════════════╣
    ║                                                                              ║
    ║  EBS Volume ID      : ${module.ebs.volume_id}
    ║  EBS Volume Size    : ${var.ebs_volume_size} GB
    ║                                                                              ║
    ╠══════════════════════════════════════════════════════════════════════════════╣
    ║                           SECURITY DETAILS                                    ║
    ╠══════════════════════════════════════════════════════════════════════════════╣
    ║                                                                              ║
    ║  Security Group ID  : ${module.security_group.sg_id}
    ║  Key Pair Name      : ${module.keypair.key_name}
    ║  SSH Key Path       : ${module.keypair.private_key_path}
    ║                                                                              ║
    ╠══════════════════════════════════════════════════════════════════════════════╣
    ║                           SSH ACCESS                                          ║
    ╠══════════════════════════════════════════════════════════════════════════════╣
    ║                                                                              ║
    ║  ssh -i ${module.keypair.private_key_path} ubuntu@${module.eip.public_ip}
    ║                                                                              ║
    ╠══════════════════════════════════════════════════════════════════════════════╣
    ║                           INITIAL ADMIN PASSWORD                              ║
    ╠══════════════════════════════════════════════════════════════════════════════╣
    ║                                                                              ║
    ║  To get the initial admin password, run:                                     ║
    ║  sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword ║
    ║                                                                              ║
    ╚══════════════════════════════════════════════════════════════════════════════╝

    Deployed at: ${timestamp()}
  EOT
}
