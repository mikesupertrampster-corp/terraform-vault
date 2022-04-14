variable "account_id" {
  type = string
}

variable "apex_domain" {
  type = string
}

variable "bootstrap_role" {
  type = string
}

variable "environment" {
  type = string
}

variable "keypair" {
  type = string
}

variable "region" {
  type = string
}

variable "subnet" {
  type    = string
  default = "public"
}

variable "tags" {
  type = map(string)
}
