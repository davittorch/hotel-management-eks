output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value     = module.eks.cluster_certificate_authority_data
  sensitive = true
}

output "cluster_id" {
  value = module.eks.cluster_id
}

output "token" {
  value     = data.aws_eks_cluster_auth.cluster.token
  sensitive = true
}