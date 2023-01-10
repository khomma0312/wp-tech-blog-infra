output "instance_ids" {
    value = [
        aws_instance.web_server.id,
    ]
}

output "availability_zone" {
    value = aws_instance.web_server.availability_zone
}