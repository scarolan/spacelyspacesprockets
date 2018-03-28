output "dev_server_0" {
    value = "http://${aws_instance.spacelysprocketsdev.0.public_dns}"
}

# output "dev_server_1" {
#     value = "http://${aws_instance.spacelysprocketsdev.1.public_dns}"
# }

# output "dev_server_2" {
#     value = "http://${aws_instance.spacelysprocketsdev.2.public_dns}"
# }

# output "dev_load_bal" {
#     value = "http://${aws_lb.dev_lb.dns_name}/"
# }

# output "dev_homepage" {
#     value = "http://${aws_route53_record.dev.name}/"
# }