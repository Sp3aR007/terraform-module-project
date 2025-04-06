variable "ssh_key" {
  type = string
}

variable "database_name" {
  type    = string
  default = "terraform"
}

variable "database_user" {
  type      = string
  sensitive = true
  default   = "terraform"
}

variable "database_password" {
  type      = string
  sensitive = true
  default = "terraform"
}