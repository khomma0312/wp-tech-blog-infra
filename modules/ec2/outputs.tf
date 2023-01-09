output "instance_ids" {
    value = [
        aws_instance.web_server.id,
    ]
}

output "availability_zone" {
    # TODO: 以下はテスト用なので一通り構築終わったら「_2」を消す
    value = aws_instance.web_server.availability_zone
}