variable "eks_cluster_name" {
  type        = string
  description = "eks cluster name"
  default     = "bluebird"
}

variable "k8s_version" {
  type        = string
  description = "kubernetes version"
  default     = "1.29"
}

variable "workers_config" {
  type        = map(any)
  description = "workers config"
  default = {
    worker = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.small"]
      capacity_type  = "SPOT"
    }
  }
}

variable "repository_name" {
  type        = string
  description = "The name of the ECR repository"
  default     = "bluebird"
}

variable "image_tag_mutability" {
  type        = string
  default     = "MUTABLE"
  description = "The tag mutability settings for the repository."
}

variable "force_delete" {
  type        = bool
  default     = true
  description = "Specifies whether the repository should be deleted when the Terraform resource is destroyed"
}

variable "scan_on_push" {
  type        = bool
  default     = true
  description = "Indicates whether images are scanned after being pushed to the repository"
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "rds_master_user" {
  description = "Rds master username"
  type        = string
}

variable "rds_password" {
  description = "Rds password for master user"
  type        = string
}