module "vpc" {
  source = "./modules/vpc"

  cidr = var.vpc["cidr"]
  env = var.env
}