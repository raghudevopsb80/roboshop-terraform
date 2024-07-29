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
  count                  = var.asg ? 1 : 0
  name                   = "${var.name}-${var.env}-lt"
  image_id               = data.aws_ami.rhel9.image_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.allow_tls.id]

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    env         = var.env
    role_name   = var.name
    vault_token = var.vault_token
  }))

  tags = {
    Name = "${var.name}-${var.env}-sg"
  }
}


resource "aws_autoscaling_group" "main" {
  count               = var.asg ? 1 : 0
  name                = "${var.name}-${var.env}-asg"
  desired_capacity    = var.capacity["desired"]
  max_size            = var.capacity["max"]
  min_size            = var.capacity["min"]
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.main.*.id[0]
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "${var.name}-${var.env}"
  }
}

resource "aws_instance" "main" {
  count                  = var.asg ? 0 : 1
  ami                    = data.aws_ami.rhel9.image_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.allow_tls.id]

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    env         = var.env
    role_name   = var.name
    vault_token = var.vault_token
  }))

  tags = {
    Name = "${var.name}-${var.env}"
  }
}

resource "aws_route53_record" "instance" {
  count   = var.asg ? 0 : 1
  zone_id = var.zone_id
  name    = "${var.name}.${var.env}"
  type    = "A"
  ttl     = 10
  records = [aws_instance.main.*.id[count.index]]
}

