output "web_servers" {
  value = ["${aws_instance.spacelysprockets.*.public_dns}"]
}

output "load_bal" {
  value = "http://${aws_lb.ecom_lb.dns_name}/"
}

output "homepage" {
  value = "http://${aws_route53_record.subdomain.name}/"
}
