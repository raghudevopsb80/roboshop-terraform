resource "aws_eks_cluster" "main" {
  name     = "${var.env}-eks"
  role_arn = aws_iam_role.eks-cluster.arn
  version  = var.eks_version

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
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

  scaling_config {
    desired_size = each.value["min_size"]
    max_size     = each.value["max_size"]
    min_size     = each.value["min_size"]
  }
}

resource "aws_eks_addon" "addons" {
  for_each      = var.add_ons
  cluster_name  = aws_eks_cluster.main.name
  addon_name    = each.key
  addon_version = each.value
}

resource "aws_eks_access_policy_association" "workstation-access" {
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::633788536644:role/workstation-role"

  access_scope {
    type       = "cluster"
  }
}

