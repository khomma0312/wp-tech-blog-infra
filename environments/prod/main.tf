terraform {
	required_providers {
		aws = {
			source  = "hashicorp/aws"
			version = ">= 4.0"
		}
	}

	backend "s3" {
		bucket = "wp-tech-blog-infra"
		key    = "terraform.tfstate"
		region = "ap-northeast-1"
	}
}

provider "aws" {
	region = var.region

	default_tags {
		tags = {
			env = var.env
			project_name = var.project_name
		}
	}
}

module "vpc" {
    source = "../../modules/vpc"
	region = var.region
    vpc_id = var.vpc_id
	project_name = var.project_name
}

module "acm" {
	source = "../../modules/acm"
	domain_name = var.domain_name
}

module "web_server" {
	source = "../../modules/ec2"
	project_name = var.project_name
	public_subnets = module.vpc.public_subnets
	web_server_security_group_id = module.vpc.web_server_security_group_id
	web_server_security_group_for_alb_id = module.vpc.web_server_security_group_for_alb_id
}

module "alb" {
	source = "../../modules/alb"
	project_name = var.project_name
	public_subnets = module.vpc.public_subnets
	security_group_id = module.vpc.alb_security_group_id
	ssl_certificate_arn = module.acm.alb_certificate_arn
	vpc_id = module.vpc.vpc_id
	instance_ids = module.web_server.instance_ids
	domain_name = var.domain_name
}

module "cloudfront" {
	source = "../../modules/cloudfront"
	domain_name = var.domain_name
	alb_domain_name = module.alb.alb_domain_name
	cf_header_secret_value = var.cf_header_secret_value
	ssl_certificate_arn = module.acm.cloudfront_certificate_arn
}

module "rds" {
	source = "../../modules/rds"
	project_name = var.project_name
	rds_security_group_id = module.vpc.rds_security_group_id
	private_subnets = module.vpc.private_subnets
	db_name = var.db_name
	db_user = var.db_user
	db_password = var.db_password
}