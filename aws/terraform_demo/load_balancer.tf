# Create a DNS record and Load Balancer

# Set up a data source for our zone.  This is so we can programatically
# fetch the zone_id from Route 53.
data "aws_route53_zone" "zone" {
  name         = "${var.domainname}."
  private_zone = false
}

# Create a DNS record for the environment 
resource "aws_route53_record" "subdomain" {
  zone_id = "${data.aws_route53_zone.zone.id}"
  name    = "${var.subdomain}.${var.domainname}"
  type    = "A"

  # Create an alias for the load balancer
  alias {
    name                   = "dualstack.${aws_lb.ecom_lb.dns_name}"
    zone_id                = "${aws_lb.ecom_lb.zone_id}"
    evaluate_target_health = true
  }
}

# Create a Load Balancer
resource "aws_lb" "ecom_lb" {
  name            = "ecommerce-${var.subdomain}-lb"
  internal        = false
  security_groups = ["${aws_security_group.ecommerce_sg.id}"]
  subnets         = ["${module.vpc.public_subnets[0]}", "${module.vpc.public_subnets[1]}", "${module.vpc.public_subnets[2]}"]

  tags = {
    Name  = "${var.subdomain}_${var.domainname}_lb"
    owner = "${var.owner}"
    TTL   = "8"
  }
}

# Create a target group
resource "aws_lb_target_group" "ecom_tg" {
  name     = "ecommerce-${var.subdomain}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${module.vpc.vpc_id}"

  stickiness = {
    type    = "lb_cookie"
    enabled = true
  }

  health_check = {
    interval            = 30
    path                = "/index.html"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

# Create a listener on port 80
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = "${aws_lb.ecom_lb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.ecom_tg.arn}"
    type             = "forward"
  }
}

# Create a listener on port 443
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = "${aws_lb.ecom_lb.arn}"
  port              = "443"
  protocol          = "HTTPS"

  # This is configured in certificate.tf
  certificate_arn = "${aws_acm_certificate_validation.cert.certificate_arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.ecom_tg.arn}"
    type             = "forward"
  }
}

# Attach our instances to the target group
resource "aws_lb_target_group_attachment" "ecom_tg_server" {
  count            = "${var.ecommerce_servers}"
  target_group_arn = "${aws_lb_target_group.ecom_tg.arn}"
  target_id        = "${element(aws_instance.spacelysprockets.*.id, count.index)}"
  port             = 80
}
