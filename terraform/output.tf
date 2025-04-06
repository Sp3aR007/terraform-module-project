
output "load_balancer_endpoint" {
  value = module.loadbalancer.lb_endpoint
}

output "database_endpoint" {
  value = module.database.db_endpoint
}