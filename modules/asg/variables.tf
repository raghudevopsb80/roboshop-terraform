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
variable "lb_subnet_ids" {
  default = []
}
variable "dns_name" {}
variable "listener_arn" {}
variable "lb_rule_priority" {}





