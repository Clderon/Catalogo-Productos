output "namespace" {
  value = kubernetes_namespace.catalogo.metadata[0].name
}

output "api_service_name" {
  value = kubernetes_service.api.metadata[0].name
}
