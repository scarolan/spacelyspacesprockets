##############################################################################
# HashiCorp Product Demo - Vault instances
##############################################################################

resource "aws_instance" "vault" {
  # TODO: Create a new IAM profile if necessary
  iam_instance_profile   = "Consul"
  ami                    = "${var.vault_ami}"
  instance_type          = "${var.vault_instance_type}"
  key_name               = "${var.key_name}"
  count                  = "${var.vault_nodes}"
  vpc_security_group_ids = ["${aws_security_group.vault.id}"]
  subnet_id              = "${lookup(var.subnets, count.index % var.servers)}"

  connection {
    user        = "${lookup(var.user, var.platform)}"
    private_key = "${file("${var.key_path}")}"
  }

  tags {
    Name       = "${var.vaultTagName}-${count.index}"
    ConsulRole = "Vault"
  }

  ##############################################################################
  # Consul client install
  ##############################################################################

  # These provisioners get Consul installed and set up
  # This file must be in place before you can start the client
  # The installation script expects it to exist.
  provisioner "file" {
    source      = "${path.module}/../../shared/scripts/debian_consul.service"
    destination = "/tmp/consul.service"
  }
  # This is a bit hacky but it works.
  provisioner "remote-exec" {
    inline = [
      "echo ${self.private_ip} > /tmp/my_ipaddress",
      "echo ${var.vaultTagName}-${count.index} > /tmp/nodename",
    ]
  }
  # Installs consul as a service but does not start it.
  provisioner "remote-exec" {
    scripts = [
      "${path.module}/../../shared/scripts/install_consul_client.sh",
    ]
  }
  # Set up a service and health check
  provisioner "file" {
    source      = "${path.module}/../../shared/scripts/service_vault.json"
    destination = "/etc/systemd/system/consul.d/service_vault.json"
  }
  # Ping www.google.com check
  provisioner "file" {
    source      = "${path.module}/../../shared/scripts/check_ping_google.json"
    destination = "/etc/systemd/system/consul.d/check_ping_google.json"
  }
  # Summon the daemon
  provisioner "remote-exec" {
    scripts = [
      "${path.module}/../../shared/scripts/consul_service.sh",
    ]
  }

  ##############################################################################
  # Vault install
  ##############################################################################

  # These provisioners get Vault installed and set up on systemd
  # This file must be in place before you can start the client
  # The installation script expects it to exist.
  provisioner "file" {
    source      = "${path.module}/../../shared/scripts/debian_vault.service"
    destination = "/tmp/vault.service"
  }
  # This is a bit hacky but it works.
  provisioner "remote-exec" {
    inline = [
      "echo ${self.private_ip} > /tmp/my_ipaddress",
      "echo ${var.vaultTagName}-${count.index} > /tmp/nodename",
    ]
  }
  # Installs vault as a service but does not start it.
  provisioner "remote-exec" {
    scripts = [
      "${path.module}/../../shared/scripts/install_vault_client.sh",
    ]
  }
  # Set up a service and health check
  provisioner "file" {
    source      = "${path.module}/../../shared/scripts/service_vault.json"
    destination = "/etc/systemd/system/consul.d/service_vault.json"
  }
  # Ping www.google.com check
  provisioner "file" {
    source      = "${path.module}/../../shared/scripts/check_ping_google.json"
    destination = "/etc/systemd/system/consul.d/check_ping_google.json"
  }
  # Summon the daemon
  provisioner "remote-exec" {
    scripts = [
      "${path.module}/../../shared/scripts/vault_service.sh",
    ]
  }
}

resource "aws_security_group" "vault" {
  name        = "vault_${var.platform}"
  description = "Vault servers security group"
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

  // These are for maintenance
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // This is for the WebUI
  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // HTTP traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // HTTPS traffic
  ingress {
    from_port   = 443
    to_port     = 443
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

# Create a load balancer to put in front of the Vault instances
# Create a new load balancer
resource "aws_lb" "vault_lb" {
  name            = "vault-lb"
  internal        = true
  security_groups = ["${aws_security_group.vault.id}"]
  subnets         = ["${var.subnets[0]}", "${var.subnets[1]}", "${var.subnets[2]}"]

  tags = {
    Name = "vault_lb"
  }
}

# Create a target group
resource "aws_lb_target_group" "vault_tg" {
  name     = "vault-tg"
  port     = 8200
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check = {
    interval            = 30
    path                = "/v1/sys/health"
    port                = 8200
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

# Create a listener on port 8200
resource "aws_lb_listener" "vault_listener" {
  load_balancer_arn = "${aws_lb.vault_lb.arn}"
  port              = "8200"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.vault_tg.arn}"
    type             = "forward"
  }
}

# Attach our instances to the target group
resource "aws_lb_target_group_attachment" "vault_tg_server0" {
  target_group_arn = "${aws_lb_target_group.vault_tg.arn}"
  target_id        = "${element(aws_instance.vault.*.id, count.index)}"
  port             = 8200
}
