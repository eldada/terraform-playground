# Setup the required variables

variable "region" {
  default = "eu-central-1"
}

# WARNING: CIDR "0.0.0.0/0" is full public access to the cluster. You should use a more restrictive CIDR
variable "cluster_public_access_cidrs" {
  default = ["0.0.0.0/0"]
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "private_subnet_cidrs" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "rds_postgres_version" {
  default     = "16.4"
}

variable "db_name" {
  default     = "artifactory"
}

variable "db_username" {
  description = "The username for the database"
  default     = "artifactory"
}

variable "db_password" {
  description = "The password for the database"
  sensitive   = true
  default     = "Password321"
}

variable "cluster_name" {
  default = "jfrog-eks-cluster"
}

variable "s3_bucket_name_suffix" {
  default = "jfrog-demo"
}

variable "artifactory_rds_size_default" {
  default = "db.m7g.2xlarge"
}

variable "artifactory_rds_size_medium" {
  default = "db.m7g.4xlarge"
}

variable "artifactory_rds_size_large" {
  default = "db.m7g.8xlarge"
}

variable "artifactory_rds_size_xlarge" {
  default = "db.m7g.12xlarge"
}

variable "artifactory_rds_size_2xlarge" {
  default = "db.m7g.16xlarge"
}

variable "artifactory_node_size_default" {
  default = "m7g.2xlarge"
}

variable "artifactory_node_size_large" {
  default = "m7g.4xlarge"
}

variable "nginx_node_size_default" {
  default = "c7g.xlarge"
}

variable "nginx_node_size_large" {
  default = "c7g.2xlarge"
}

variable "namespace" {
  default = "jfrog"
}

variable "artifactory_chart_version" {
  default = "107.98.9"
}

variable "common_tag" {
  description = "The 'Group' tag to apply to all resources"
  default = "jfrog"
}

variable "sizing" {
  type        = string
  description = "The sizing templates for the infrastructure and Artifactory"
  default     = "small"

  validation {
    condition     = contains(["small", "medium", "large", "xlarge", "2xlarge"], var.sizing)
    error_message = "Invlid sizing set. Supported sizings are: 'small', 'medium', 'large', 'xlarge' or '2xlarge'"
  }
}
