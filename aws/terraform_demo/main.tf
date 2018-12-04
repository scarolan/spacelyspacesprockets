##############################################################################
# HashiCorp Product Demo - ecommerce site - Apache, MySQL, Tomcat, Apache
##############################################################################

provider "aws" {
  region = "${var.region}"
}

module "vpc" {
  source  = "app.terraform.io/spacelyspacesprockets/vpc/aws"
  version = "1.43.1"

  azs              = ["us-west-2a", "us-west-2b", "us-west-2c"]
  cidr             = "10.100.0.0/16"
  default_vpc_name = "${var.demo_name}"

  default_vpc_tags = {
    "Name" = "${var.demo_name}"

    "owner" = "${var.owner}"
  }

  name           = "${var.subdomain}-${var.demo_name}-vpc"
  public_subnets = ["10.100.10.0/24", "10.100.20.0/24", "10.100.30.0/24"]
}

resource "aws_instance" "spacelysprockets" {
  ami                    = "${var.demoami}"
  instance_type          = "${var.ecommerce_instance_type}"
  key_name               = "${var.key_name}"
  count                  = "${var.ecommerce_servers}"
  vpc_security_group_ids = ["${aws_security_group.ecommerce_sg.id}"]

  # This puts one server in each subnet, up to the total number of subnets.
  #subnet_id = "${lookup(var.subnets, count.index % var.ecommerce_servers)}"
  # This just crams them all in one subnet
  subnet_id = "${module.vpc.public_subnets[0]}"

  # This is the provisioning user
  #connection {
  #    user = "${var.user}"
  #    private_key = "${var.private_ssh_key}"
  #}

  # AWS Instance Tags
  tags {
    Name  = "${var.ecomTagName}-${var.subdomain}-${count.index}"
    owner = "${var.owner}"
    TTL   = "8"
  }

  ## Install Chef
  #provisioner "remote-exec" {
  #    inline = [
  #    "curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -c current -P chefdk"
  #    ]
  #}

  # # Install the development web server stack
  #provisioner "remote-exec" {
  #    scripts = [
  #        "${path.module}/../../shared/scripts/run_chef_dev.sh"
  #    ]
  #}
}

resource "aws_security_group" "ecommerce_sg" {
  name        = "ecommerce_sg_${var.subdomain}"
  description = "Ecommerce website security group"
  vpc_id      = "${module.vpc.vpc_id}"

  # AWS Instance Tags
  tags {
    Name = "${var.subdomain}-sg"
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

    
# Test comment
