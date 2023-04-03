
/*
tf workplace -> function
variable -> argument
local -> local variable
output -> return value
*/

provider "aws" {
  region = "ap-northeast-2"
}

# 값을 정의하지 않으면 terraform apply 할 때 변수 주입하라고 나옴
variable "vpc_name" {
  description = "생성되는 VPC 이름"
  type = string
  default = "default"
}

locals {
  common_tags = {
    Project = "Network"
    Owner = "jej"
  }
}

output "vpc_name" {
  value = module.vpc.name
}

output "vpc_id" {
  value = module.vpc.id
}

output "vpc_cidr" {
  description = "생성된 VPC의 CIDR 영역"
  value = module.vpc.cidr_block
}

output "public_subnet_group" {
  value = module.vpc.subnet_group__public
}

output "private_subnet_group" {
  value = module.vpc.subnet_group__private
}

output "subnet_groups" {
  value = {
    public = module.subnet_group__public
    private = module.subnet_group__private
  }
}

module "vpc" {
  source  = "tedilabs/network/aws//modules/vpc"
  version = "0.24.0"

  name                  = var.vpc_name
  cidr_block            = "10.0.0.0/16"

  internet_gateway_enabled = true

  dns_hostnames_enabled = true
  dns_support_enabled   = true

  tags = local.common_tags
}

module "subnet_group__public" {
  source  = "tedilabs/network/aws//modules/subnet-group" # 여기서는 terraform registry를 source로
  version = "0.24.0"

  name                    = "${module.vpc.name}-public" # 다른 module 참조
  vpc_id                  = module.vpc.id
  map_public_ip_on_launch = true

  subnets = {
    "${module.vpc.name}-public-001/az1" = {
      cidr_block           = "10.0.0.0/24"
      availability_zone_id = "apne2-az1"
    }
    "${module.vpc.name}-public-002/az2" = {
      cidr_block           = "10.0.1.0/24"
      availability_zone_id = "apne2-az2"
    }
  }

  tags = {}
}

module "subnet_group__private" {
  source  = "tedilabs/network/aws//modules/subnet-group"
  version = "0.24.0"

  name                    = "${module.vpc.name}-private"
  vpc_id                  = module.vpc.id
  map_public_ip_on_launch = false

  subnets = {
    "${module.vpc.name}-private-001/az1" = {
      cidr_block           = "10.0.10.0/24"
      availability_zone_id = "apne2-az1"
    }
    "${module.vpc.name}-private-002/az2" = {
      cidr_block           = "10.0.11.0/24"
      availability_zone_id = "apne2-az2"
    }
  }

  tags = {}
}

module "route_table__public" {
  source  = "tedilabs/network/aws//modules/route-table"
  version = "0.24.0"

  name   = "${module.vpc.name}-public"
  vpc_id = module.vpc.id

  subnets = module.subnet_group__public.ids

  ipv4_routes = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = module.vpc.internet_gateway_id
    },
  ]

  tags = {}
}

module "route_table__private" {
  source  = "tedilabs/network/aws//modules/route-table"
  version = "0.24.0"

  name   = "${module.vpc.name}-private"
  vpc_id = module.vpc.id

  subnets = module.subnet_group__private.ids

  ipv4_routes = []

  tags = {}
}