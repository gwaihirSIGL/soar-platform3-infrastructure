resource "aws_security_group" "lambda" {
  vpc_id = aws_vpc.main.id
  name   = "${local.tag_name}-lambda-sg"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group_rule" "demo_lambda_sg_allow_redis_ingress" {
  type            = "ingress"
  from_port   = 6379
  to_port       = 6379
  protocol     = "tcp"
  security_group_id = "${aws_security_group.lambda.id}"
}
resource "aws_security_group_rule" "demo_lambda_sg_allow_redis_egress" {
  type            = "egress"
  from_port   = 6379
  to_port       = 6379
  protocol     = "tcp"
  security_group_id = "${aws_security_group.lambda.id}"
}


resource "aws_security_group" "rds" {
  vpc_id = aws_vpc.main.id
  name   = "${local.tag_name}-rds-sg"
  ingress {
    description     = "PostgreSQL"
    from_port       = 5432
    protocol        = "tcp"
    to_port         = 5432
    security_groups = [aws_security_group.lambda.id, aws_security_group.ssh.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_security_group" "ssh" {
  vpc_id = aws_vpc.main.id
  name   = "${local.tag_name}-bastion-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "lambda_sg_id" {
  value = aws_security_group.lambda.id
}
