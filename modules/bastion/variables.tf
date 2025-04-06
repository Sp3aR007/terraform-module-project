variable "ssh_key" {
  type  = string
}
variable "key_name" {
    type = string
}
variable "instance_type" {
  type = string
}
variable "image_id" {
  type = string
}
variable "bastion_sg" {}


variable "public_subnets" {}