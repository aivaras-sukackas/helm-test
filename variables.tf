variable "project_name" {
}

variable "ingress_certificate_body" {
  default = ""
}

variable "ingress_certificate_key" {
  default = ""
}

variable "secret_bucket_arn" {
  default = ""
}

variable "secret_bucket_name" {
  default = ""
}

variable "bucket_arn" {
}

variable "bucket_name" {
}

variable "bucket_region" {
}

variable "database_name" {
}

variable "database_endpoint_host" {
}

variable "database_endpoint_port" {
}

variable "database_master_user" {
}

variable "database_master_pass" {
}

variable "session_endpoint_host" {
}

variable "session_endpoint_port" {
}

variable "database_ro_users" {
}

variable "database_rw_users" {
}

variable "extra_secrets" {
  type = map(string)
}

