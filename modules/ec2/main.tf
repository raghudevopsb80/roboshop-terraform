resource "aws_security_group" "allow_tls" {
  name        = "${var.name}-${var.env}-sg"
  description = "${var.name}-${var.env}-sg"
  vpc_id      = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = var.bastion_nodes
  }

  ingress {
    from_port   = var.allow_port
    to_port     = var.allow_port
    protocol    = "TCP"
    cidr_blocks = var.allow_sg_cidr
  }

  tags = {
    Name = "${var.name}-${var.env}-sg"
  }
}


resource "aws_launch_template" "main" {
  name                   = "${var.name}-${var.env}-lt"
  image_id               = data.aws_ami.rhel9.image_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.allow_tls.id]

  tags = {
    Name = "${var.name}-${var.env}-sg"
  }
}

