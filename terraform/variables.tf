variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "devops"
}

variable "environment" {
  description = "Environment name (development, production)"
  type        = string
  default     = "production"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "DevOps Microservice"
}

variable "app_version" {
  description = "Application version"
  type        = string
  default     = "1.0.0"
}

variable "api_key" {
  description = "API Key for authentication"
  type        = string
  default     = "2f5ae96c-b558-4c7b-a590-a501ae1c3f6c"
}

variable "jwt_secret" {
  description = "JWT secret key"
  type        = string
  default     = "your-secret-key-change-in-production"
  sensitive   = true
}

variable "image_name" {
  description = "Docker image name"
  type        = string
  default     = "devops-microservice"
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "replicas" {
  description = "Number of pod replicas"
  type        = number
  default     = 2
}

variable "min_replicas" {
  description = "Minimum number of replicas for HPA"
  type        = number
  default     = 2
}

variable "max_replicas" {
  description = "Maximum number of replicas for HPA"
  type        = number
  default     = 10
}

variable "cpu_request" {
  description = "CPU request for containers"
  type        = string
  default     = "100m"
}

variable "memory_request" {
  description = "Memory request for containers"
  type        = string
  default     = "128Mi"
}

variable "cpu_limit" {
  description = "CPU limit for containers"
  type        = string
  default     = "500m"
}

variable "memory_limit" {
  description = "Memory limit for containers"
  type        = string
  default     = "512Mi"
}

variable "cpu_target_percentage" {
  description = "Target CPU utilization percentage for HPA"
  type        = number
  default     = 70
}

variable "memory_target_percentage" {
  description = "Target memory utilization percentage for HPA"
  type        = number
  default     = 80
}

variable "ingress_host" {
  description = "Ingress host"
  type        = string
  default     = "localhost"
}
