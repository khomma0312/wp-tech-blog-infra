resource "aws_iam_role" "web_server_role" {
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Sid = ""
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            },
        ]
    })

    managed_policy_arns = [
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
        "arn:aws:iam::aws:policy/AmazonS3FullAccess",
        aws_iam_policy.ssm_get_parameter_policy.arn
    ]
}

resource "aws_iam_policy" "ssm_get_parameter_policy" {
    name = "ssm_get_parameter_policy"

    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Sid : ""
                Effect = "Allow"
                Action = "ssm:GetParameter"
                Resource = "arn:aws:ssm:ap-northeast-1:113244625788:parameter/${var.project_name}_*"
            },
        ]
    })
}
