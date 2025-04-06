variable "ssh_key" {
    type = string
}

variable "key_name" {
    type = string
}

variable "instance_type" {
    type = string
    description = "Type of the instance for the frontend"
}

variable "image_id" { 
    type = string
    description = "Image id (AMI) for the frontend instances"
}

variable "frontend_sg" {
    description = "Security group for the frontend instances"
}

variable "private_frontend_subnets" { 
    description = "Subnets for the frontend instances"
}

variable "target_group_arn" { 
    description = "Target Group for frontend austo scaling group"
}
