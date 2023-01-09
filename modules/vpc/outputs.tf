output "vpc_id" {
    value = data.aws_vpc.vpc.id
}

output "public_subnets" {
    value = aws_subnet.public
}

output "private_subnets" {
    value = aws_subnet.private
}

output "alb_security_group_id" {
    value = aws_security_group.alb_security_group.id
}

output "web_server_security_group_id" {
    value = aws_security_group.web_server_security_group.id
}

output "web_server_security_group_for_alb_id" {
    value = aws_security_group.web_server_security_group_for_alb.id
}

output "rds_security_group_id" {
    value = aws_security_group.rds_security_group.id
}