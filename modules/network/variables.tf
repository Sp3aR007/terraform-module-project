variable "public_subnet_count" {
    type = number
    description = "Number of subnets required for public subnets in vpc"
    default = 0
}

variable "private_frontend_subnet_count" {
    type = number
    description = "Number of subnets required for private subnets for frontend instances in vpc"
    default = 0 
}

variable "private_backend_subnet_count" {
    type = number
    description = "Number of subnets required for private subnets for frontend instances in vpc"
    default = 0  
}


variable "vpc_cidr" {
    type = string
}

variable "availabilityzone" {}

variable "azs" {}

variable "db_subnet_group" {
    type = bool
}

variable "private_database_subnet_count" {
    type = number
    description = "Numbers of subnets for database"
}