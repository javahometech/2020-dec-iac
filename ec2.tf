# resource "aws_instance" "web" {
#   ami                         = lookup(var.ami_ids, var.region)
#   instance_type               = "t2.micro"
#   subnet_id                   = aws_subnet.public.*.id[0]
#   associate_public_ip_address = true
#   vpc_security_group_ids      = [aws_security_group.web_sg.id]
#   key_name                    = "oct-7am"
#   iam_instance_profile        = aws_iam_instance_profile.ec2_s3_put_profile.id
#   user_data                   = file("apache.sh")
#   tags = {
#     Name = "HelloWorld-${local.ws}"
#   }
# }

# create security group

resource "aws_security_group" "web_sg" {
  name        = "web_security_group"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.example.id

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_security_group"
  }
}

# Attach IAM role

resource "aws_iam_role" "ec2_s3_put_role" {
  name = "ec2_s3_put_role_${local.ws}"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy" "ec2_s3_put_policy" {
  name   = "ec2_s3_put_policy_${local.ws}"
  role   = aws_iam_role.ec2_s3_put_role.id
  policy = data.template_file.init.rendered
}

resource "aws_iam_instance_profile" "ec2_s3_put_profile" {
  name = "ec2_s3_put_profile_${local.ws}"
  role = aws_iam_role.ec2_s3_put_role.name
}

# template

data "template_file" "init" {
  template = file("ec2_s3_policy.tpl")
  vars = {
    s3_bucket_arn = var.s3_bucket_arn
  }
}