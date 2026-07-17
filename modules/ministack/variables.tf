variable "namespace" {
  default = "ministack"
}

variable "image" {
  default = "ministackorg/ministack:latest"
}

variable "storage_class" {
  default = ""
}

variable "storage_size" {
  default = "10Gi"
}
