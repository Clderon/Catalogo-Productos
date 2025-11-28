variable "namespace" {
  type        = string
  default     = "catalogo"
  description = "Namespace para la app"
}

variable "api_image" {
  type    = string
  default = "product-api:1.1"
}

variable "replicas" {
  type    = number
  default = 2
}