output "public_subnets" {
    value = aws_subnet.public
}

output "private_subnets" {
    value = aws_subnet.public
}

output "elb_security_group_id" {
    value = aws_security_group.elb_security_group.id
}

output "web_server_security_group_id" {
    value = aws_security_group.web_server_security_group.id
}

output "web_server_security_group_for_elb_id" {
    value = aws_security_group.web_server_security_group_for_elb.id
}

output "rds_security_group_id" {
    value = aws_security_group.rds_security_group.id
}