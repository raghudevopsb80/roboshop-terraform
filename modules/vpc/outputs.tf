output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "app_subnet_ids" {
  value = aws_subnet.app.*.id
}

output "web_subnet_ids" {
  value = aws_subnet.web.*.id
}

output "db_subnet_ids" {
  value = aws_subnet.db.*.id
}

output "subnets" {
  value = tomap({
    "web"    = aws_subnet.web.*.id
    "app"    = aws_subnet.app.*.id
    "db"     = aws_subnet.db.*.id
    "public" = aws_subnet.public.*.id

  })
}

output "vpc_cidr" {
  value = var.cidr
}

output "default_vpc_cidr" {
  value = var.default_vpc_cidr
}

