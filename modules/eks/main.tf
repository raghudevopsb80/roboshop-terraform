resource "aws_security_group" "cluster-sg" {
  name        = "${var.env}-eks-cluster-sg"
  description = "${var.env}-eks-cluster-sg"
  vpc_id      = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = [var.vpc_cidr, var.default_vpc_cidr]
  }

  tags = {
    Name = "${var.env}-eks-cluster-sg"
  }
}


resource "aws_eks_cluster" "main" {
  name     = "${var.env}-eks"
  role_arn = aws_iam_role.eks-cluster.arn
  version  = var.eks_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false
    security_group_ids      = [aws_security_group.cluster-sg.id]
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = var.kms_arn
    }
  }

  enabled_cluster_log_types = ["api", "authenticator", "audit", "scheduler", "controllerManager"]

}

resource "aws_launch_template" "main" {
  for_each = var.node_groups
  name     = each.key

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
      encrypted   = true
      kms_key_id  = var.kms_arn
    }
  }

  tags = {
    Name = each.key
  }
}


resource "aws_eks_node_group" "main" {
  for_each        = var.node_groups
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = each.key
  node_role_arn   = aws_iam_role.eks-node.arn
  subnet_ids      = var.subnet_ids
  instance_types  = each.value["instance_types"]
  capacity_type   = each.value["capacity_type"]

  launch_template {
    name    = each.key
    version = "$Latest"
  }

  scaling_config {
    desired_size = each.value["min_size"]
    max_size     = each.value["max_size"]
    min_size     = each.value["min_size"]
  }
}

resource "aws_eks_addon" "addons" {
  for_each                    = var.add_ons
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = each.key
  addon_version               = each.value
  resolve_conflicts_on_create = "OVERWRITE"
}

module "eks-iam-access" {
  source   = "./eks-iam-access"
  for_each = var.eks-iam-access

  cluster_name      = aws_eks_cluster.main.name
  kubernetes_groups = each.value["kubernetes_groups"]
  principal_arn     = each.value["principal_arn"]
  policy_arn        = each.value["policy_arn"]
}

