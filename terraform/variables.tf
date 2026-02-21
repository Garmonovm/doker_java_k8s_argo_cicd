variable "region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "allflex"
}

variable "assume_role_arn" {
  description = "IAM role ARN to assume for AWS provider"
  type        = string
}


variable "ecr_repositories" {
  description = "Map of ECR repositories to create. Key = repo name."
  type = map(object({
    image_tag_mutability = optional(string, "IMMUTABLE")
    scan_on_push         = optional(bool, true)
    force_delete         = optional(bool, false)
  }))
  default = {
    # "php-app"  = {}
    "java-app" = {}
  }
}

variable "image_retention_count" {
  description = "Number of images to keep per repository. Older images are deleted automatically by lifecycle policy."
  type        = number
  default     = 10
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "nat_gateway_single" {
  description = "Use a single NAT gateway (saves cost in non-prod)"
  type        = bool
  default     = true
}


variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "allflex-prod"
}

variable "cluster_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.35"
}

variable "instance_types" {
  description = "EC2 instance types for the managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "capacity_type" {
  description = "Capacity type for nodes: ON_DEMAND or SPOT"
  type        = string
  default     = "SPOT"
}

variable "node_group_min_size" {
  description = "Minimum number of nodes in the node group"
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in the node group"
  type        = number
  default     = 3
}

variable "node_group_desired_size" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 1
}

variable "eks_admin_user" {
  description = "Additional IAM ARN for EKS cluster admin access"
  type        = string
}

# ---------------------------------------------------------------------------
# GitHub Actions (for OIDC federation)
# ---------------------------------------------------------------------------

variable "github_org" {
  description = "GitHub organization or username (e.g. 'mycompany')"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name (e.g. 'doker_java_k8s_argo-ci_cd')"
  type        = string
}
