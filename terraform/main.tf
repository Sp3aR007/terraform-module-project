provider "aws" {
  region = local.location
}

locals {
  instance_type = "t2.micro"
  location      = "us-east-1"
  image_id      = "ami-084568db4383264d4"
  vpc_cidr      = "10.0.0.0/16"
}

module "bastion" {
  source         = "../modules/bastion"
  image_id       = local.image_id
  instance_type  = local.instance_type
  key_name       = "terraform"
  ssh_key        = "terraform"
  bastion_sg     = module.network.bastion_sg
  public_subnets = module.network.public_subnets
}


module "network" {
  source                        = "../modules/network"
  vpc_cidr                      = local.vpc_cidr
  public_subnet_count           = 2
  availabilityzone              = "us-east-1a"
  azs                           = 2
  private_frontend_subnet_count = 2
  private_backend_subnet_count  = 2
  private_database_subnet_count = 2
  db_subnet_group               = true
}


module "frontend" {
  source                   = "../modules/frontend"
  ssh_key                  = "terraform1"
  key_name                 = "terraform1"
  instance_type            = local.instance_type
  image_id                 = local.image_id
  frontend_sg              = module.network.frontend_sg
  private_frontend_subnets = module.network.private_frontend_subnets
  target_group_arn         = module.loadbalancer.lb_tg
}

module "backend" {
  source                  = "../modules/backend"
  ssh_key                 = "terraform2"
  key_name                = "terraform2"
  instance_type           = local.instance_type
  image_id                = local.image_id
  backend_sg              = module.network.backend_sg
  private_backend_subnets = module.network.private_backend_subnets
}

module "loadbalancer" {
  source            = "../modules/loadbalancer"
  lb_sg             = module.network.lb_sg
  public_subnets    = module.network.public_subnets
  app_asg           = module.frontend.app_asg
  tg_port           = 80
  tg_protocol       = "HTTP"
  vpc_id            = module.network.vpc_id
  listener_port     = 80
  listener_protocol = "HTTP"
  azs               = 2
}

module "database" {
  source = "../modules/database"
  db_storage           = 10
  db_engine_version    = "8.0"
  db_instance_class    = "db.t3.micro"
  db_name              = var.database_name
  dbuser               = var.database_user
  dbpassword           = var.database_password
  db_identifier        = "three-tier-db"
  skip_db_snapshot     = true
  rds_sg               = module.network.db_sg
  db_subnet_group_name = module.network.db_subnet_group_name[0]
}