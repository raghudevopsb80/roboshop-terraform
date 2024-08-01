env           = "dev"
bastion_nodes = ["172.31.91.201/32"]
zone_id       = "Z00376861T6KFA01SJSIS"

vpc = {
  cidr               = "10.10.0.0/16"
  public_subnets     = ["10.10.0.0/24", "10.10.1.0/24"]
  web_subnets        = ["10.10.2.0/24", "10.10.3.0/24"]
  app_subnets        = ["10.10.4.0/24", "10.10.5.0/24"]
  db_subnets         = ["10.10.6.0/24", "10.10.7.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]
  default_vpc_id     = "vpc-0928c2748fecca727"
  default_vpc_rt     = "rtb-085f965c93773f7e5"
  default_vpc_cidr   = "172.31.0.0/16"
}

apps = {

  frontend = {
    subnet_ref       = "web"
    instance_type    = "t3.small"
    allow_port       = 80
    allow_sg_cidr    = ["10.10.0.0/24", "10.10.1.0/24"]
    allow_lb_sg_cidr = ["0.0.0.0/0"]
    capacity = {
      desired = 1
      max     = 1
      min     = 1
    }
    lb_ref           = "public"
    lb_rule_priority = 1
  }

  catalogue = {
    subnet_ref       = "app"
    instance_type    = "t3.small"
    allow_port       = 8080
    allow_sg_cidr    = ["10.10.4.0/24", "10.10.5.0/24"]
    allow_lb_sg_cidr = ["10.10.2.0/24", "10.10.3.0/24", "10.10.4.0/24", "10.10.5.0/24"]
    capacity = {
      desired = 1
      max     = 1
      min     = 1
    }
    lb_ref           = "private"
    lb_rule_priority = 1
  }

  cart = {
    subnet_ref       = "app"
    instance_type    = "t3.small"
    allow_port       = 8080
    allow_sg_cidr    = ["10.10.4.0/24", "10.10.5.0/24"]
    allow_lb_sg_cidr = ["10.10.2.0/24", "10.10.3.0/24", "10.10.4.0/24", "10.10.5.0/24"]
    capacity = {
      desired = 1
      max     = 1
      min     = 1
    }
    lb_ref           = "private"
    lb_rule_priority = 2
  }

  user = {
    subnet_ref       = "app"
    instance_type    = "t3.small"
    allow_port       = 8080
    allow_sg_cidr    = ["10.10.4.0/24", "10.10.5.0/24"]
    allow_lb_sg_cidr = ["10.10.2.0/24", "10.10.3.0/24", "10.10.4.0/24", "10.10.5.0/24"]
    capacity = {
      desired = 1
      max     = 1
      min     = 1
    }
    lb_ref           = "private"
    lb_rule_priority = 3
  }

  shipping = {
    subnet_ref       = "app"
    instance_type    = "t3.small"
    allow_port       = 8080
    allow_sg_cidr    = ["10.10.4.0/24", "10.10.5.0/24"]
    allow_lb_sg_cidr = ["10.10.2.0/24", "10.10.3.0/24", "10.10.4.0/24", "10.10.5.0/24"]
    capacity = {
      desired = 1
      max     = 1
      min     = 1
    }
    lb_ref           = "private"
    lb_rule_priority = 4
  }

  payment = {
    subnet_ref       = "app"
    instance_type    = "t3.small"
    allow_port       = 8080
    allow_sg_cidr    = ["10.10.4.0/24", "10.10.5.0/24"]
    allow_lb_sg_cidr = ["10.10.2.0/24", "10.10.3.0/24", "10.10.4.0/24", "10.10.5.0/24"]
    capacity = {
      desired = 1
      max     = 1
      min     = 1
    }
    lb_ref           = "private"
    lb_rule_priority = 5
  }

}

db = {
  mongo = {
    subnet_ref    = "db"
    instance_type = "t3.small"
    allow_port    = 27017
    allow_sg_cidr = ["10.10.4.0/24", "10.10.5.0/24"]
  }
  mysql = {
    subnet_ref    = "db"
    instance_type = "t3.small"
    allow_port    = 3306
    allow_sg_cidr = ["10.10.4.0/24", "10.10.5.0/24"]
  }
  rabbitmq = {
    subnet_ref    = "db"
    instance_type = "t3.small"
    allow_port    = 5672
    allow_sg_cidr = ["10.10.4.0/24", "10.10.5.0/24"]
  }
  redis = {
    subnet_ref    = "db"
    instance_type = "t3.small"
    allow_port    = 6379
    allow_sg_cidr = ["10.10.4.0/24", "10.10.5.0/24"]
  }
}

load_balancers = {
  private = {
    internal           = true
    load_balancer_type = "application"
    allow_lb_sg_cidr   = ["10.10.2.0/24", "10.10.3.0/24", "10.10.4.0/24", "10.10.5.0/24"]
    subnet_ref         = "app"
    acm_https_arn      = null
    listener_port      = "80"
    listener_protocol  = "HTTP"
    ssl_policy         = null
  }

  public = {
    internal           = false
    load_balancer_type = "application"
    allow_lb_sg_cidr   = ["0.0.0.0/0"]
    subnet_ref         = "public"
    acm_https_arn      = "arn:aws:acm:us-east-1:633788536644:certificate/764c1d94-5562-48f4-be92-fca22568f53d"
    listener_port      = "443"
    listener_protocol  = "HTTPS"
    ssl_policy         = "ELBSecurityPolicy-2016-08"
  }
}


