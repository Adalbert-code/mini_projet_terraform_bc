# Rapport Final - Mini-Projet Terraform Jenkins

## Informations du Projet

| Élément | Détail |
|---------|--------|
| **Nom du projet** | Déploiement automatisé d'un serveur Jenkins sur AWS |
| **Technologie principale** | Terraform (Infrastructure as Code) |
| **Cloud Provider** | Amazon Web Services (AWS) |
| **Auteur** | Bootcamp DevOps - EazyTraining |
| **Version** | 1.0.0 |

---

## 1. Contexte et Objectifs

### 1.1 Contexte

Ce projet s'inscrit dans le cadre du Bootcamp DevOps EazyTraining. L'objectif est de démontrer la maîtrise de Terraform pour automatiser le déploiement d'une infrastructure cloud complète hébergeant un serveur Jenkins conteneurisé.

### 1.2 Objectifs atteints

- ✅ Création d'une architecture modulaire réutilisable
- ✅ Déploiement d'un VPC dédié avec réseau complet
- ✅ Provisionnement d'une instance EC2 Ubuntu Jammy
- ✅ Installation automatisée de Jenkins via Docker Compose
- ✅ Génération dynamique des clés SSH
- ✅ Gestion du state Terraform distant (S3 + DynamoDB)
- ✅ Export automatique des métadonnées

---

## 2. Architecture Technique

### 2.1 Schéma d'Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              AWS CLOUD                                       │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                         VPC (10.0.0.0/16)                             │  │
│  │                                                                       │  │
│  │  ┌─────────────────────────────────────────────────────────────────┐  │  │
│  │  │                  Subnet Public (10.0.1.0/24)                    │  │  │
│  │  │                     Availability Zone: us-east-1a               │  │  │
│  │  │                                                                 │  │  │
│  │  │  ┌───────────────────────────────────────────────────────────┐  │  │  │
│  │  │  │                 EC2 Instance (t2.medium)                  │  │  │  │
│  │  │  │                   Ubuntu Jammy 22.04                      │  │  │  │
│  │  │  │                                                           │  │  │  │
│  │  │  │  ┌─────────────────┐    ┌─────────────────────────────┐   │  │  │  │
│  │  │  │  │   EBS Volume    │    │      Docker Engine          │   │  │  │  │
│  │  │  │  │    (30 GB)      │    │                             │   │  │  │  │
│  │  │  │  │   /dev/xvdf     │    │  ┌─────────────────────┐    │   │  │  │  │
│  │  │  │  │                 │    │  │  Jenkins Container  │    │   │  │  │  │
│  │  │  │  │  Mounted on:    │◄───┤  │    (Port 8080)      │    │   │  │  │  │
│  │  │  │  │ /var/jenkins_   │    │  │                     │    │   │  │  │  │
│  │  │  │  │     home        │    │  └─────────────────────┘    │   │  │  │  │
│  │  │  │  └─────────────────┘    └─────────────────────────────┘   │  │  │  │
│  │  │  │                                                           │  │  │  │
│  │  │  │  Security Group: SSH(22), HTTP(80), HTTPS(443), 8080      │  │  │  │
│  │  │  └───────────────────────────────────────────────────────────┘  │  │  │
│  │  │                              │                                  │  │  │
│  │  └──────────────────────────────┼──────────────────────────────────┘  │  │
│  │                                 │                                     │  │
│  │  ┌──────────────────────────────┼──────────────────────────────────┐  │  │
│  │  │              Route Table     │                                  │  │  │
│  │  │           0.0.0.0/0 ─────────┘                                  │  │  │
│  │  └──────────────────────────────┬──────────────────────────────────┘  │  │
│  │                                 │                                     │  │
│  └─────────────────────────────────┼─────────────────────────────────────┘  │
│                                    │                                        │
│                        ┌───────────┴───────────┐                            │
│                        │   Internet Gateway    │                            │
│                        └───────────┬───────────┘                            │
│                                    │                                        │
└────────────────────────────────────┼────────────────────────────────────────┘
                                     │
                         ┌───────────┴───────────┐
                         │     Elastic IP        │
                         │   (Accès Public)      │
                         └───────────┬───────────┘
                                     │
                                     ▼
                              ┌─────────────┐
                              │  Internet   │
                              │   Users     │
                              └─────────────┘
```

### 2.2 Composants Déployés

| Composant | Type | Configuration |
|-----------|------|---------------|
| VPC | aws_vpc | CIDR: 10.0.0.0/16, DNS enabled |
| Subnet | aws_subnet | CIDR: 10.0.1.0/24, Public |
| Internet Gateway | aws_internet_gateway | Attaché au VPC |
| Route Table | aws_route_table | Route 0.0.0.0/0 → IGW |
| Security Group | aws_security_group | Ports: 22, 80, 443, 8080 |
| EC2 Instance | aws_instance | t2.medium, Ubuntu 22.04 |
| EBS Volume | aws_ebs_volume | 30 GB, gp3, chiffré |
| Elastic IP | aws_eip | IP publique statique |
| Key Pair | aws_key_pair | RSA 4096 bits, généré dynamiquement |

---

## 3. Structure du Projet

```
jenkins-terraform/
│
├── app/                              # Application principale
│   ├── main.tf                      # Orchestration des 9 modules
│   ├── variables.tf                 # Variables globales
│   ├── outputs.tf                   # Outputs du déploiement
│   ├── providers.tf                 # Configuration AWS + Backend S3
│   └── files/
│       └── docker-compose.yml       # Configuration Jenkins
│
├── bootstrap/                        # Configuration du backend distant
│   ├── main.tf                      # Création S3 + DynamoDB
│   ├── variables.tf                 # Variables du bootstrap
│   ├── outputs.tf                   # Configuration backend
│   └── terraform.tfvars.example     # Exemple de configuration
│
├── modules/                          # 9 Modules réutilisables
│   ├── vpc/                         # Module VPC
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── subnet/                      # Module Subnet
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── igw/                         # Module Internet Gateway
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── route_table/                 # Module Route Table
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── security_group/              # Module Security Group
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── keypair/                     # Module Key Pair
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── ec2/                         # Module EC2
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── ebs/                         # Module EBS
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── eip/                         # Module Elastic IP
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── scripts/                          # Scripts utilitaires
│   ├── generate-graph.ps1           # Génération schéma (Windows)
│   └── generate-graph.sh            # Génération schéma (Linux/Mac)
│
├── Documentation/                    # Documentation pédagogique
│   └── ...                          # Code entièrement commenté
│
├── README.md                         # Documentation principale
├── RAPPORT_FINAL.md                  # Ce rapport
└── .gitignore                        # Fichiers à ignorer par Git
```

---

## 4. Modules Terraform

### 4.1 Vue d'ensemble des modules

| Module | Responsabilité | Dépendances |
|--------|----------------|-------------|
| `vpc` | Création du réseau virtuel | Aucune |
| `subnet` | Création du sous-réseau | vpc |
| `igw` | Accès Internet | vpc |
| `route_table` | Routage du trafic | vpc, igw, subnet |
| `keypair` | Authentification SSH | Aucune |
| `security_group` | Règles de firewall | vpc |
| `eip` | IP publique statique | Aucune |
| `ebs` | Stockage persistant | Aucune |
| `ec2` | Instance de calcul | keypair, security_group, subnet |

### 4.2 Graphe des dépendances

```
                    ┌─────────┐
                    │   VPC   │
                    └────┬────┘
                         │
         ┌───────────────┼───────────────┐
         │               │               │
         ▼               ▼               ▼
    ┌─────────┐    ┌─────────┐    ┌──────────────┐
    │ Subnet  │    │   IGW   │    │Security Group│
    └────┬────┘    └────┬────┘    └──────┬───────┘
         │               │               │
         └───────┬───────┘               │
                 │                       │
                 ▼                       │
         ┌─────────────┐                 │
         │ Route Table │                 │
         └──────┬──────┘                 │
                │                        │
                └────────────┬───────────┘
                             │
    ┌─────────┐              │              ┌─────────┐
    │ Keypair │──────────────┼──────────────│   EBS   │
    └─────────┘              │              └────┬────┘
                             ▼                   │
                        ┌─────────┐              │
                        │   EC2   │◄─────────────┘
                        └────┬────┘        (attachment)
                             │
                             ▼
                        ┌─────────┐
                        │   EIP   │
                        └─────────┘
                       (association)
```

---

## 5. Bonnes Pratiques Implémentées

### 5.1 Infrastructure as Code

| Pratique | Implémentation |
|----------|----------------|
| **Modularité** | 9 modules indépendants et réutilisables |
| **Idempotence** | Exécutions multiples = même résultat |
| **Versioning** | Code versionné avec Git |
| **Documentation** | README, commentaires, rapport |

### 5.2 Sécurité

| Pratique | Implémentation |
|----------|----------------|
| **Chiffrement EBS** | Volumes chiffrés par défaut |
| **Chiffrement State** | Backend S3 avec encryption |
| **Clés dynamiques** | Génération automatique RSA 4096 |
| **Accès restreint** | Security Group avec ports spécifiques |
| **Bucket privé** | Block public access sur S3 |

### 5.3 Maintenabilité

| Pratique | Implémentation |
|----------|----------------|
| **Variables typées** | Types et descriptions sur toutes les variables |
| **Valeurs par défaut** | Defaults sensibles pour un démarrage rapide |
| **Tags cohérents** | Tags uniformes sur toutes les ressources |
| **Outputs documentés** | Descriptions sur tous les outputs |

### 5.4 State Management

| Pratique | Implémentation |
|----------|----------------|
| **State distant** | Backend S3 |
| **State locking** | DynamoDB / use_lockfile |
| **Versioning** | S3 bucket versioning activé |
| **Protection** | prevent_destroy sur le bucket |

---

## 6. Guide de Déploiement

### 6.1 Prérequis

```bash
# Outils requis
- Terraform >= 1.0.0
- AWS CLI configuré
- Compte AWS avec permissions suffisantes
```

### 6.2 Étapes de déploiement

```bash
# 1. Cloner le repository
git clone <repository-url>
cd jenkins-terraform

# 2. Créer le backend (optionnel mais recommandé)
cd bootstrap
terraform init
terraform apply

# 3. Déployer l'infrastructure Jenkins
cd ../app
terraform init
terraform plan
terraform apply

# 4. Récupérer les informations de connexion
terraform output
```

### 6.3 Accès à Jenkins

```bash
# URL Jenkins
http://<PUBLIC_IP>:8080

# Connexion SSH
ssh -i jenkins-key.pem ubuntu@<PUBLIC_IP>

# Mot de passe initial Jenkins
sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

---

## 7. Fichiers Générés

### 7.1 jenkins_ec2.txt

Fichier généré automatiquement contenant :
- Adresse IP publique
- Nom DNS public
- URL Jenkins
- Informations VPC/Subnet
- Commande SSH
- Instructions pour le mot de passe

### 7.2 Clé SSH

Fichier `jenkins-key.pem` généré dans le dossier `app/` avec les permissions 0400.

---

## 8. Coûts Estimés (AWS)

| Ressource | Type | Coût estimé/mois |
|-----------|------|------------------|
| EC2 | t2.medium | ~$33.00 |
| EBS (Root) | 20 GB gp3 | ~$1.60 |
| EBS (Data) | 30 GB gp3 | ~$2.40 |
| Elastic IP | Associée | $0.00 |
| S3 (State) | < 1 GB | ~$0.03 |
| DynamoDB | On-demand | ~$0.00 |
| **Total estimé** | | **~$37/mois** |

*Note: Les coûts peuvent varier selon la région et l'utilisation.*

---

## 9. Évolutions Possibles

### 9.1 Court terme

- [ ] Ajouter un certificat SSL/TLS (Let's Encrypt)
- [ ] Configurer un nom de domaine (Route 53)
- [ ] Ajouter des alertes CloudWatch

### 9.2 Moyen terme

- [ ] Implémenter un Auto Scaling Group
- [ ] Ajouter un Load Balancer (ALB)
- [ ] Configurer des backups automatiques

### 9.3 Long terme

- [ ] Migration vers EKS (Kubernetes)
- [ ] Pipeline CI/CD avec Jenkins
- [ ] Multi-région / Disaster Recovery

---

## 10. Conclusion

Ce projet démontre une maîtrise complète de Terraform pour le déploiement d'infrastructure cloud. L'architecture modulaire permet une réutilisation facile des composants, tandis que les bonnes pratiques de sécurité et de maintenabilité assurent une solution production-ready.

### Compétences démontrées

- ✅ Terraform (HCL, modules, state management)
- ✅ AWS (VPC, EC2, EBS, S3, DynamoDB, IAM)
- ✅ Docker & Docker Compose
- ✅ Linux Administration
- ✅ Infrastructure as Code
- ✅ Documentation technique

---

**Projet réalisé dans le cadre du Bootcamp DevOps - EazyTraining**
