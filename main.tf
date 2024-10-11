module "vpc" {
  source = "./modules/vpc"

  cidr               = var.vpc["cidr"]
  env                = var.env
  public_subnets     = var.vpc["public_subnets"]
  app_subnets        = var.vpc["app_subnets"]
  web_subnets        = var.vpc["web_subnets"]
  db_subnets         = var.vpc["db_subnets"]
  availability_zones = var.vpc["availability_zones"]
  default_vpc_id     = var.vpc["default_vpc_id"]
  default_vpc_rt     = var.vpc["default_vpc_rt"]
  default_vpc_cidr   = var.vpc["default_vpc_cidr"]
  kms_key_id         = var.kms_arn
}

module "db" {
  depends_on = [module.vpc]
  source     = "./modules/ec2"

  for_each      = var.db
  name          = each.key
  instance_type = each.value["instance_type"]
  allow_port    = each.value["allow_port"]
  allow_sg_cidr = each.value["allow_sg_cidr"]
  subnet_ids    = module.vpc.subnets[each.value["subnet_ref"]]
  vpc_id        = module.vpc.vpc_id
  env           = var.env
  bastion_nodes = var.bastion_nodes
  vault_token   = var.vault_token
  zone_id       = var.zone_id
  kms_arn       = var.kms_arn
}

module "eks" {
  depends_on     = [module.vpc]
  source         = "./modules/eks"
  env            = var.env
  subnet_ids     = module.vpc.app_subnet_ids
  node_groups    = var.eks["node_groups"]
  eks_version    = var.eks["eks_version"]
  add_ons        = var.eks["add_ons"]
  eks-iam-access = var.eks["eks-iam-access"]
  vpc_id         = module.vpc.vpc_id
  kms_arn        = var.kms_arn
  zone_id        = var.zone_id
}

