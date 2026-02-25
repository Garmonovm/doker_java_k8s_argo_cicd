module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "6.5.0"
  name                 = "${var.project_name}-vpc"
  cidr                 = var.vpc_cidr
  azs                  = local.azs
  private_subnets      = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k)]
  public_subnets       = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 48)]
  enable_nat_gateway   = true
  single_nat_gateway   = var.nat_gateway_single
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                      = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"             = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.15.1"

  name               = var.cluster_name
  kubernetes_version = var.cluster_version
  # Disable automode
  compute_config = {
    enabled = false
  }
  endpoint_public_access  = true
  endpoint_private_access = true
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.vpc.private_subnets
  addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    "${var.cluster_name}" = {
      instance_types = var.instance_types
      capacity_type  = var.capacity_type

      min_size     = var.node_group_min_size
      max_size     = var.node_group_max_size
      desired_size = var.node_group_desired_size
      #disk_size      = var .disk_size # required for prod, many logs and many pods, using ebs, if not specified using root of the instance
    }
  }

  access_entries = {
    # Provide additional access to the EKS if required
    eks_admin = {
      principal_arn = var.eks_admin_user
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "1.22"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_metrics_server               = true
  enable_aws_load_balancer_controller = true

  aws_load_balancer_controller = {
    chart_version = "1.13.4"
    set = [{
      name  = "clusterName"
      value = module.eks.cluster_name
      },
      { name  = "vpcId"
        value = module.vpc.vpc_id
      },
      { name  = "awsRegion"
        value = var.region
      }
    ]
  }
  enable_cluster_autoscaler = true
  cluster_autoscaler = {
    chart_version = "9.55.1"
  }

  enable_argocd = true
  argocd = {
    namespace     = "argocd"
    chart_version = "7.8.3"
    values        = [templatefile("${path.module}/../argocd/argocd-values.yaml", {})]
  }
}

resource "aws_ecr_repository" "this" {
  for_each = var.ecr_repositories

  name                 = each.key
  image_tag_mutability = each.value.image_tag_mutability
  force_delete         = each.value.force_delete

  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }
}

# ECR Lifecycle Policy
resource "aws_ecr_lifecycle_policy" "this" {
  for_each   = aws_ecr_repository.this
  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        # Rule 1: delete untagged images after 1 day
        # Untagged = pushed but no tag assigned (e.g. failed CI builds)
        rulePriority = 1
        description  = "Remove untagged images after 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      },
      {
        # Rule 2: clean up CI build images (sha-* tags from develop branch)
        # Keep the last 20 CI images, older ones are deleted
        rulePriority = 2
        description  = "Keep last 20 CI build images (sha-* tags)"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["sha-"]
          countType     = "imageCountMoreThan"
          countNumber   = 20
        }
        action = {
          type = "expire"
        }
      },
      {
        # Rule 3: keep only the last N release images (v* tags)
        # These are production releases — keep more of them
        rulePriority = 3
        description  = "Keep last ${var.image_retention_count} release images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = var.image_retention_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}


##apply root app argocd

resource "kubernetes_manifest" "argocd_allflex_apps" {
  manifest = yamldecode(file("${path.module}/../argocd/projects/allflex-apps.yaml"))
  depends_on = [
    module.eks_blueprints_addons
  ]
}

resource "kubernetes_manifest" "argocd_root_app" {
  manifest = yamldecode(file("${path.module}/../argocd/root-app.yaml"))

  depends_on = [
    kubernetes_manifest.argocd_allflex_apps
  ]
}
