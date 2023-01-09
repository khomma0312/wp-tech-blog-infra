# IAM Roles Modules
module "iam_roles" {
    source = "../iam_roles"
    project_name = var.project_name
}

# AMI
data "aws_ami" "amazon_linux_2" {
    most_recent = true

    filter {
        name   = "owner-alias"
        values = ["amazon"]
    }

    filter {
        name   = "name"
        values = ["amzn2-ami-hvm*"]
    }
}

# Instance Profile
resource "aws_iam_instance_profile" "web_server_iam_profile" {
    role = module.iam_roles.web_server_role_name
}

# EC2
resource "aws_instance" "web_server" {
    ami = data.aws_ami.amazon_linux_2.id
    instance_type = "t2.micro"
    subnet_id = var.public_subnets[0].id
    vpc_security_group_ids = [
        var.web_server_security_group_id,
        var.web_server_security_group_for_alb_id,
    ]

    user_data = file("${path.module}/ec2-user-data.sh")
    user_data_replace_on_change = true
    iam_instance_profile = aws_iam_instance_profile.web_server_iam_profile.name

    private_dns_name_options {
        enable_resource_name_dns_a_record = true
        hostname_type = "ip-name"
    }

    root_block_device {
        encrypted = true
        volume_size = 8
    }

    tags = {
        Name = "${var.project_name}_web_server"
    }
}
