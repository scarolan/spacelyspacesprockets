variable "platform" {
  default     = "rhel"
  description = "The OS Platform"
}

variable "user" {
  default = "ec2-user"
}

variable "owner" {
  default = "team-se@hashicorp.com"
}

variable "demo_name" {
  default = "spacelydemo"
}

# Packer-built AMI
variable "demoami" {
  description = "AMI to use for the demo"
}

variable "key_name" {
  description = "SSH key name in your AWS account for AWS instances."
  default     = "scarolan"
}

#variable "private_ssh_key" {
#  description = "Private SSH key for accessing EC2 instances.  Must be uploaded/created in the AWS console."
#}

variable "subdomain" {
  description = "Subdomain of your environment.  Example: dev1.spacelyspacesprockets.info"
}

variable "domainname" {
  default = "spacelyspacesprockets.info"
}

variable "region" {
  description = "The region of AWS, for AMI lookups."
  default     = "us-west-2"
}

variable "ecommerce_servers" {
  description = "The number of demo ecommerce servers to launch."
}

variable "ecommerce_instance_type" {
  default     = "t2.medium"
  description = "AWS Instance type, if you change, make sure it is compatible with AMI, not all AMIs allow all instance types "
}

variable "ecomTagName" {
  default = "🚀 SpacelySprockets 🛸"

  #default     = "SpacelySprockets"
  description = "Name tag for the ecommerce servers"
}

variable "subnets" {
  type        = "map"
  description = "map of subnets to deploy your infrastructure in, must have as many keys as your server count (default 3), -var 'subnets={\"0\"=\"subnet-12345\",\"1\"=\"subnets-23456\"}' "

  default = {
    "0" = "subnet-8ddab7d7"
    "1" = "subnet-82992cc9"
    "2" = "subnet-8ddab7d7"
  }
}

variable "vpc_id" {
  type        = "string"
  description = "ID of the VPC to use - in case your account doesn't have default VPC"
  default     = "vpc-5dd7ff24"
}
