provider "aws" {
  region  = var.awsregion
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
}

#module "vpc" {
#  source           = "./modules/vpc"
#  application_name = var.app
#  lb_ports         = var.container_ports
#  ecs_task_ports   = {80:80}
#}

module "state" {
  source = "./modules/state"
  application_name = var.app
}