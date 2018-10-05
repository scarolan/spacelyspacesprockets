##############################################################################
# HashiCorp Product Demo - Consul cluster
##############################################################################

# First we stand up three consul servers in a clustered configuration
# Credit: https://github.com/hashicorp/consul/blob/master/terraform/aws/consul.tf
resource "aws_instance" "server" {
  iam_instance_profile = "Consul"
  ami                  = "${lookup(var.ami, "${var.region}-${var.platform}")}"
  instance_type        = "${var.consul_instance_type}"
  key_name             = "${var.key_name}"
  count                = "${var.servers}"

  #security_groups = ["${aws_security_group.consul.id}"]
  vpc_security_group_ids = ["${aws_security_group.consul.id}"]
  subnet_id              = "${lookup(var.subnets, count.index % var.servers)}"

  connection {
    user        = "${lookup(var.user, var.platform)}"
    private_key = "${file("${var.key_path}")}"
  }

  #Instance tags
  tags {
    Name       = "${var.tagName}-${count.index}"
    ConsulRole = "Server"
  }

  provisioner "file" {
    source      = "${path.module}/../../shared/scripts/${lookup(var.service_conf, var.platform)}"
    destination = "/tmp/${lookup(var.service_conf_dest, var.platform)}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${var.servers} > /tmp/consul-server-count",
      "echo ${aws_instance.server.0.private_ip} > /tmp/consul-server-addr",
      "echo ${self.private_ip} > /tmp/my_ipaddress",
      "echo ${var.tagName}-${count.index} > /tmp/nodename",
    ]
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/../../shared/scripts/install_consul_server.sh",
      "${path.module}/../../shared/scripts/consul_service.sh",
      "${path.module}/../../shared/scripts/ip_tables.sh",
    ]
  }
}

resource "aws_security_group" "consul" {
  name        = "consul_${var.platform}"
  description = "Consul internal traffic + maintenance."
  vpc_id      = "${var.vpc_id}"

  // These are for internal traffic
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "udp"
    self      = true
  }

  // This is for the WebUI
  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Allow consul connections from our 'production' network
  ingress {
    from_port   = 8300
    to_port     = 8302
    protocol    = "tcp"
    cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24", "192.168.30.0/24"]
  }

  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "tcp"
    cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24", "192.168.30.0/24"]
  }

  // These are for maintenance
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // This is for outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
