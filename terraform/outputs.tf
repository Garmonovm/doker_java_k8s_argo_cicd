output "repository_urls" {
  description = "Map of repository name to full ECR URL. Use this in docker build/push commands and K8s image references."
  value = {
    for name, repo in aws_ecr_repository.this :
    name => repo.repository_url
  }
}


output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}


