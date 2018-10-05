##############################################################################
# HashiCorp Product Demo - ecommerce site - Apache, MySQL, Tomcat, Apache
##############################################################################

# Create three instances of our web application and an ELB in front of them
# Initial suppport is for CentOS only

resource "aws_instance" "spacelysprockets" {
  iam_instance_profile = "Consul"
  ami                  = "${lookup(var.ami, "${var.region}-centos7")}"
  instance_type        = "${var.ecommerce_instance_type}"
  key_name             = "${var.key_name}"
  count                = "${var.ecommerce_servers}"

  #security_groups = ["${aws_security_group.demo_ecommerce.id}"]
  vpc_security_group_ids = ["${aws_security_group.demo_ecommerce.id}"]
  subnet_id              = "${lookup(var.subnets, count.index % var.ecommerce_servers)}"

  # Remember to use sudo where required.  The centos user has sudo rights.
  connection {
    user        = "centos"
    private_key = "${file("${var.key_path}")}"
  }

  # AWS Instance Tags
  tags {
    Name = "${var.ecomTagName}-${count.index}"
  }

  # TODO: Replace all these shell scripts with Chef recipes.

  # There is no chef solo provisioner (yet).  See https://github.com/hashicorp/terraform/issues/9030
  # Install ChefDK and use it to run chef in local mode.
  provisioner "remote-exec" {
    inline = [
      "curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -c current -P chefdk",
    ]
  }
  # This file must be in place before you can start the client
  # The installation script expects it to exist.
  provisioner "file" {
    source      = "${path.module}/../../shared/scripts/rhel_consul.service"
    destination = "/tmp/consul.service"
  }
  # This is a bit hacky but it works.
  provisioner "remote-exec" {
    inline = [
      "echo ${self.private_ip} > /tmp/my_ipaddress",
      "echo ${var.ecomTagName}-${count.index} > /tmp/nodename",
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
    source      = "${path.module}/../../shared/scripts/service_web.json"
    destination = "/etc/systemd/system/consul.d/service_web.json"
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
  # Install and run our shopping cart
  provisioner "remote-exec" {
    scripts = [
      "${path.module}/../../shared/scripts/run_chef.sh",
    ]
  }
}

resource "aws_security_group" "demo_ecommerce" {
  name        = "demo_ecommerce"
  description = "Ecommerce website security group"
  vpc_id      = "${var.vpc_id}"

  # AWS Instance Tags
  tags {
    Name = "prod-sg"
  }

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

  // This is for the WebUI and API
  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24", "192.168.30.0/24"]
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

  // For remote access via SSH
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

# Create a new load balancer
resource "aws_lb" "prod_lb" {
  name            = "ecommerce-prod-lb"
  internal        = false
  security_groups = ["${aws_security_group.demo_ecommerce.id}"]
  subnets         = ["${var.subnets[0]}", "${var.subnets[1]}", "${var.subnets[2]}"]

  tags = {
    Name = "ecommerce_prod_lb"
  }
}

# Create a target group
resource "aws_lb_target_group" "prod_tg" {
  name     = "ecommerce-prod-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  stickiness = {
    type    = "lb_cookie"
    enabled = true
  }

  health_check = {
    interval            = 30
    path                = "/cart/index.jsp"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

# Create a listener on port 80
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = "${aws_lb.prod_lb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.prod_tg.arn}"
    type             = "forward"
  }
}

# Attach our instances to the target group
resource "aws_lb_target_group_attachment" "prod_tg_server" {
  count            = "${var.ecommerce_servers}"
  target_group_arn = "${aws_lb_target_group.prod_tg.arn}"
  target_id        = "${element(aws_instance.spacelysprockets.*.id, count.index)}"
  port             = 80
}

# Set up a DNS CNAME for our website - Optional
# If you have a domain name you want to use with route 53
# uncomment these lines and make sure you have the correct zone_id
resource "aws_route53_record" "www" {
  zone_id = "Z2ZY8MQBWXTCMU"
  name    = "www.spacelyspacesprockets.info"
  type    = "CNAME"
  ttl     = "5"
  records = ["${aws_lb.prod_lb.dns_name}"]
}

# We're using a Route 53 alias here.
resource "aws_route53_record" "root" {
  zone_id = "Z2ZY8MQBWXTCMU"
  name    = "spacelyspacesprockets.info"
  type    = "A"

  alias {
    name                   = "${aws_lb.prod_lb.dns_name}"
    zone_id                = "${aws_lb.prod_lb.zone_id}"
    evaluate_target_health = true
  }
}
