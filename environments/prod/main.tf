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

module "web_server" {
	source = "../../modules/ec2"
	project_name = var.project_name
	public_subnets = module.vpc.public_subnets
	web_server_security_group_id = module.vpc.web_server_security_group_id
	web_server_security_group_for_elb_id = module.vpc.web_server_security_group_for_elb_id
}
