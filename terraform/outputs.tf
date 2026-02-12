output "namespace" {
  description = "Kubernetes namespace"
  value       = kubernetes_namespace.devops.metadata[0].name
}

output "deployment_name" {
  description = "Deployment name"
  value       = kubernetes_deployment.devops_microservice.metadata[0].name
}

output "service_name" {
  description = "Service name"
  value       = kubernetes_service.devops_service.metadata[0].name
}

output "service_type" {
  description = "Service type"
  value       = kubernetes_service.devops_service.spec[0].type
}

output "service_port" {
  description = "Service port"
  value       = kubernetes_service.devops_service.spec[0].port[0].port
}

output "ingress_name" {
  description = "Ingress name"
  value       = kubernetes_ingress_v1.devops_ingress.metadata[0].name
}

output "ingress_host" {
  description = "Ingress host"
  value       = var.ingress_host
}

output "hpa_name" {
  description = "HPA name"
  value       = kubernetes_horizontal_pod_autoscaler_v2.devops_hpa.metadata[0].name
}

output "hpa_min_replicas" {
  description = "HPA minimum replicas"
  value       = kubernetes_horizontal_pod_autoscaler_v2.devops_hpa.spec[0].min_replicas
}

output "hpa_max_replicas" {
  description = "HPA maximum replicas"
  value       = kubernetes_horizontal_pod_autoscaler_v2.devops_hpa.spec[0].max_replicas
}

output "configmap_name" {
  description = "ConfigMap name"
  value       = kubernetes_config_map.devops_config.metadata[0].name
}

output "secret_name" {
  description = "Secret name"
  value       = kubernetes_secret.devops_secrets.metadata[0].name
}
