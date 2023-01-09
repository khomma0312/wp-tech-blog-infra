variable "backend_bucket_name" {
    type = string
}

variable "region" {
    type = string
    default = "ap-northeast-1"
}

variable "env" {
    type = string
    default = "prod"
}

variable "project_name" {
    type = string
}

variable "vpc_id" {
    type = string
}

variable "domain_name" {
    type = string
}

variable "cf_header_secret_value" {
    type = string
}

variable "db_name" {
    type = string
}

variable "db_user" {
    type = string
}

variable "db_password" {
    type = string
}