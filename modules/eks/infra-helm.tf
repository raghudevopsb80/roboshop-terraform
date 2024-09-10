resource "null_resource" "kube-config" {
  depends_on = [aws_eks_node_group.main]

  provisioner "local-exec" {
    command = <<EOF
aws eks update-kubeconfig --name ${var.env}-eks
kubectl apply -f /opt/vault-token.yaml
EOF
  }
}

## External Secrets
resource "helm_release" "external-secrets" {

  depends_on = [null_resource.kube-config]

  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = "kube-system"
}

resource "null_resource" "external-secrets-store" {
  depends_on = [helm_release.external-secrets, null_resource.kube-config]

  provisioner "local-exec" {
    command = <<EOF
kubectl apply -f - <<EOK
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: vault-backend
spec:
  provider:
    vault:
      server: "http://vault-internal.rdevopsb80.online:8200/"
      path: "roboshop-${var.env}"
      version: "v2"
      auth:
        tokenSecretRef:
          name: "vault-token"
          key: "token"
          namespace: kube-system
EOK
EOF
  }
}

## Metric Server for HPA.

resource "null_resource" "metrics-server" {
  depends_on = [null_resource.kube-config]

  provisioner "local-exec" {
    command = <<EOF
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
EOF
  }
}


## Prometheus Stack
resource "helm_release" "prometheus-stack" {

  depends_on = [null_resource.kube-config]

  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "kube-system"

  values = [
    file("${path.module}/helm-configs/prometheus-stack.yaml")
  ]

  set_list {
    name  = "grafana.ingress.hosts"
    value = ["grafana-${var.env}.rdevopsb80.online"]
  }

  set_list {
    name  = "prometheus.ingress.hosts"
    value = ["prometheus-${var.env}.rdevopsb80.online"]
  }

}

## Nginx ingress
# resource "helm_release" "nginx-ingress" {
#
#   depends_on = [null_resource.kube-config]
#
#   name       = "ingress-nginx"
#   repository = "https://kubernetes.github.io/ingress-nginx"
#   chart      = "ingress-nginx"
#   namespace  = "kube-system"
#   wait       = true
#
#   values = [
#     file("${path.module}/helm-configs/nginx-ingress.yaml")
#   ]
#
# }


## External DNS
resource "helm_release" "external-dns" {

  depends_on = [null_resource.kube-config]

  name       = "route53-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  namespace  = "kube-system"
}


## AWS Load Balancer Controller ingress
resource "helm_release" "aws-controller-ingress" {

  depends_on = [null_resource.kube-config]

  name       = "aws-ingress"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.main.name
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

}

### Uninstall resource
# resource "null_resource" "uninstall" {
#
#   provisioner "local-exec" {
#     when    = destroy
#     command = <<EOF
# kubectl delete ingress prometheus-grafana -n kube-system
# kubectl delete ingress prometheus-kube-prometheus-prometheus -n kube-system
# EOF
#   }
#
# }

## Filebeat Helm Chart
resource "helm_release" "filebeat" {

  depends_on = [null_resource.kube-config]

  name       = "filebeat"
  repository = "https://helm.elastic.co"
  chart      = "filebeat"
  namespace  = "kube-system"

  values = [
    file("${path.module}/helm-configs/filebeat.yaml")
  ]

}

