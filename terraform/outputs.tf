output "repository_urls" {
  description = "Map of repository name to full ECR URL. Use this in docker build/push commands and K8s image references."
  value = {
    for name, repo in aws_ecr_repository.this :
    name => repo.repository_url
  }
}

output "repository_arns" {
  description = "Map of repository name to ARN. Use in IAM policies to grant push/pull access."
  value = {
    for name, repo in aws_ecr_repository.this :
    name => repo.arn
  }
}

output "registry_id" {
  description = "AWS account ID (ECR registry ID). Used in docker login: aws ecr get-login-password | docker login <registry_id>.dkr.ecr.<region>.amazonaws.com"
  value       = values(aws_ecr_repository.this)[0].registry_id
}

# ---------------------------------------------------------------------------
# EKS Outputs
# ---------------------------------------------------------------------------

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

# ---------------------------------------------------------------------------
# GitHub Actions OIDC
# ---------------------------------------------------------------------------

output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions. Set as GitHub repo variable AWS_ROLE_ARN."
  value       = aws_iam_role.github_actions.arn
}

output "ecr_registry" {
  description = "Full ECR registry URL (ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com)"
  value       = local.ecr_registry
}
