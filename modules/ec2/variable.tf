variable "name" {}
variable "instance_type" {}
variable "allow_port" {}
variable "allow_sg_cidr" {}
variable "subnet_ids" {}
variable "vpc_id" {}
variable "env" {}
variable "bastion_nodes" {}
variable "capacity" {
  default = {}
}
variable "asg" {}
variable "vault_token" {}
variable "zone_id" {}
variable "internal" {
  default = null
}
variable "lb_subnet_ids" {
  default = []
}

variable "allow_lb_sg_cidr" {
  default = []
}


