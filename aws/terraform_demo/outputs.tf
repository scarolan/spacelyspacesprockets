output "dev_servers" {
    value = ["${aws_instance.spacelysprocketsdev.*.public_dns}"]
}

output "dev_load_bal" {
    value = "http://${aws_lb.dev_lb.dns_name}/"
}

# output "dev_homepage" {
#     value = "http://${aws_route53_record.dev.name}/"
# }
