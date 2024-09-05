## IAM for EKS
resource "aws_iam_role" "eks-cluster" {
  name = "${var.env}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster.name
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks-cluster.name
}

resource "aws_iam_role" "eks-node" {
  name = "${var.env}-eks-node-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-node.name
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-node.name
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-node.name
}

## External DNS
resource "aws_iam_role" "external-dns-pod-role" {
  name = "${var.env}-eks-external-dns-pod-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "pods.eks.amazonaws.com"
          ]
        },
        "Action" : [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  inline_policy {
    name = "route53-access"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "route53:ChangeResourceRecordSets"
          ],
          "Resource" : [
            "arn:aws:route53:::hostedzone/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "route53:ListHostedZones",
            "route53:ListResourceRecordSets",
            "route53:ListTagsForResource"
          ],
          "Resource" : [
            "*"
          ]
        }
      ]
      }
    )
  }

}

resource "aws_eks_pod_identity_association" "external-dns-pod-role" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "kube-system"
  service_account = "route53-dns-external-dns"
  role_arn        = aws_iam_role.external-dns-pod-role.arn
}


## AWS Load Balancer Controller Ingress
resource "aws_iam_role" "aws-ingress-controller-role" {
  name = "${var.env}-eks-aws-ingress-controller-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "pods.eks.amazonaws.com"
          ]
        },
        "Action" : [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  inline_policy {
    name = "alb-access"

    policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": [
            "ec2:DescribeVpcs",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeInstances",
            "elasticloadbalancing:*",
            "ec2:DescribeSubnets",
            "ec2:DescribeAvailabilityZones",
            "ec2:CreateSecurityGroup",
            "ec2:CreateTags",
            "ec2:AuthorizeSecurityGroupIngress",
            "shield:GetSubscriptionState"
          ],
          "Effect": "Allow",
          "Resource": "*"
        }
      ]
    })
  }

}

resource "aws_eks_pod_identity_association" "aws-ingress-controller-role" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "kube-system"
  service_account = "aws-ingress-aws-load-balancer-controller"
  role_arn        = aws_iam_role.aws-ingress-controller-role.arn
}





