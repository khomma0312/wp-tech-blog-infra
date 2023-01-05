data "aws_vpc" "vpc" {
    id = var.vpc_id
}

data "aws_availability_zones" "availability_zones" {
    filter {
        name   = "region-name"
        values = [var.region]
    }
}

# Subnets
resource "aws_subnet" "public" {
    count = 3
    vpc_id = data.aws_vpc.vpc.id
    availability_zone = data.aws_availability_zones.availability_zones.names[count.index]
    cidr_block = cidrsubnet(data.aws_vpc.vpc.cidr_block, 8, count.index * 10)
    map_public_ip_on_launch = true
    tags = {
        "Name" = "${var.project_name}_public_${count.index}"
    }
}

resource "aws_subnet" "private" {
    count = 3
    vpc_id = data.aws_vpc.vpc.id
    availability_zone = data.aws_availability_zones.availability_zones.names[count.index]
    cidr_block = cidrsubnet(data.aws_vpc.vpc.cidr_block, 8, (count.index + length(aws_subnet.public)) * 10)
    tags = {
        Name = "${var.project_name}_private_${count.index}"
    }
}

resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = data.aws_vpc.vpc.id

    tags = {
        Name = "${var.project_name}_igw"
    }
}

# Route Table
resource "aws_route_table" "public" {
    vpc_id = data.aws_vpc.vpc.id

    tags = {
        Name = "${var.project_name}_public_rtb"
    }
}

resource "aws_route_table" "private" {
    vpc_id = data.aws_vpc.vpc.id

    tags = {
        Name = "${var.project_name}_private_rtb"
    }
}

resource "aws_route" "public" {
    destination_cidr_block = "0.0.0.0/0"
    route_table_id         = aws_route_table.public.id
    gateway_id             = aws_internet_gateway.internet_gateway.id
}

# Associate route table and route record
resource "aws_route_table_association" "public" {
    count = length(aws_subnet.public)
    subnet_id      = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
    count = length(aws_subnet.private)
    subnet_id      = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private.id
}

# Security Groups
resource "aws_security_group" "elb_security_group" {
    vpc_id = data.aws_vpc.vpc.id
    name = "elb_security_group"
}

resource "aws_security_group" "web_server_security_group" {
    vpc_id = data.aws_vpc.vpc.id
    name = "web_server_security_group"
}

resource "aws_security_group" "web_server_security_group_for_elb" {
    vpc_id = data.aws_vpc.vpc.id
    name = "web_server_security_group_for_elb"
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [ aws_security_group.elb_security_group.id ]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        security_groups = [ aws_security_group.elb_security_group.id ]
    }
}

resource "aws_security_group" "rds_security_group" {
    vpc_id = data.aws_vpc.vpc.id
    name = "rds_security_group"
    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = [ aws_security_group.web_server_security_group.id ]
    }
}
