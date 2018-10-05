output "corp_homepage" {
  value = "http://${aws_route53_record.www.name}/"
}

output "consul_master" {
  value = "http://${aws_instance.server.0.public_dns}:8500/ui/"
}

output "vault_load_ba" {
  value = "http://${aws_lb.vault_lb.dns_name}:8200"
}

output "prod_load_bal" {
  value = "http://${aws_lb.prod_lb.dns_name}/"
}

output "prod_server_0" {
  value = "http://${aws_instance.spacelysprockets.0.public_dns}"
}

output "prod_server_1" {
  value = "http://${aws_instance.spacelysprockets.1.public_dns}"
}

output "prod_server_2" {
  value = "http://${aws_instance.spacelysprockets.2.public_dns}"
}
