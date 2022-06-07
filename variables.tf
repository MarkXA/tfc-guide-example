variable "name_prefix" {
  type        = string
  default     = "rasp"
  description = "Prefix of the resource name."
}

variable "location" {
  type        = string
  default     = "westus3"
  description = "Location of the resource."
}

variable "CUSTOMER" {
  type = string
}

variable "FRONTNAME" {
  type = string
}