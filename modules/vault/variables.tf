variable "apex_domain" {
  type = string
}

variable "cluster_arn" {
  type = string
}

variable "environment" {
  type = string
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "name" {
  type    = string
  default = "vault"
}

variable "port" {
  type    = number
  default = 8200
}

variable "subnet_ids" {
  type = list(string)
}

variable "vault_audit_log_dir" {
  type    = string
  default = "/var/log/vault"
}

variable "vault_image" {
  type    = string
  default = "vault:1.10.0"
}

variable "vpc_id" {
  type = string
}
