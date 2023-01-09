locals {
    project_name = replace(var.project_name, "_", "-")
}

resource "aws_db_instance" "rds" {
    allocated_storage               = 20
    apply_immediately               = true
    availability_zone               = var.availability_zone
    backup_retention_period         = 7
    backup_window                   = "18:00-18:30"
    ca_cert_identifier              = "rds-ca-2019"
    db_name                         = var.db_name
    db_subnet_group_name            = aws_db_subnet_group.rds.name
    enabled_cloudwatch_logs_exports = [ "error", "slowquery" ]
    engine                          = "mysql"
    engine_version                  = "5.7"
    final_snapshot_identifier       = "final-${var.project_name}-snapshot"
    identifier                      = local.project_name
    instance_class                  = "db.t3.micro"
    maintenance_window              = "Sun:19:00-Sun:19:30"
    max_allocated_storage           = 30
    option_group_name               = aws_db_option_group.mysql.name
    parameter_group_name            = aws_db_parameter_group.mysql.name
    port                            = 3306
    storage_encrypted               = true
    vpc_security_group_ids          = [var.rds_security_group_id]
    username                        = var.db_user
    password                        = var.db_password
}

resource "aws_db_subnet_group" "rds" {
    name       = "${var.project_name}-subnet-group"
    subnet_ids = [for subnet in var.private_subnets : subnet.id]

    tags = {
        Name = "${var.project_name}-subnet-group"
    }
}

resource "aws_db_option_group" "mysql" {
    name                 = "${local.project_name}-option-group"
    engine_name          = "mysql"
    major_engine_version = "5.7"

    option {
        option_name                    = "MEMCACHED"
        port                           = "11211"
        vpc_security_group_memberships = [var.rds_security_group_id]
    }
}

resource "aws_db_parameter_group" "mysql" {
    name   = "${local.project_name}-parameter-group"
    family = "mysql5.7"

    parameter {
        name  = "character_set_server"
        value = "utf8"
    }

    parameter {
        name  = "character_set_client"
        value = "utf8"
    }

    parameter {
        name         = "general_log"
        value        = "1"
        apply_method = "immediate"
    }

    parameter {
        name         = "slow_query_log"
        value        = "1"
        apply_method = "immediate"
    }

    parameter {
        name         = "long_query_time"
        value        = "0"
        apply_method = "immediate"
    }

    parameter {
        name         = "log_output"
        value        = "FILE"
        apply_method = "immediate"
    }
}
