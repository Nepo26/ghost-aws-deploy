provider "aws" {
  region  = var.awsregion
  shared_credentials_files = ["~/.aws/credentials"]
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

module "vpc" {
  source = "./modules/vpc"

  public_subnet_cidrs = ["10.0.0.1/24","10.0.0.2/24", "10.0.0.3/24"]
  private_subnet_cidrs = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

  app = var.app
}

module "ec2" {
  source = "./modules/ec2"

  ami_id              = ""
  ami_key_pair_name   = ""
  instance_type       = "t2.small"
  number_of_instances = 1
  subnet_id           = vpc.public_subnet_id
}