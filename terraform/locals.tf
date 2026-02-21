locals {
  azs          = slice(data.aws_availability_zones.available.names, 0, 3)
  cluster_name = "${var.project_name}-${var.environment}"
  account_id   = data.aws_caller_identity.current.account_id
  ecr_registry = "${local.account_id}.dkr.ecr.${var.region}.amazonaws.com"
}
