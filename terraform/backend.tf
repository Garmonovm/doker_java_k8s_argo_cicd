terraform {
  backend "s3" {
    bucket       = "karpenterlab-tfstate"
    key          = "lab-php/terraform.tfstate"
    region       = "eu-central-1"
    use_lockfile = true
  }
}
