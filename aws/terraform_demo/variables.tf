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
<<<<<<< HEAD
  # Spacely Sprockets AMI
  default = "ami-02e24b56fc62551ed"

  # Cogswell Cogs AMI
  #default = "ami-03969108478119621"
  description = "eCommerce Website - RHEL 7 - v0.9"
=======
  description = "eCommerce Website AMI"
>>>>>>> development
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

variable "region" {
  description = "The region of AWS, for AMI lookups."
<<<<<<< HEAD
  default     = "us-east-1"
=======
  default     = "us-west-2"
>>>>>>> development
}

variable "ecommerce_servers" {
  description = "The number of demo ecommerce servers to launch."
}

variable "ecommerce_instance_type" {
  default     = "t2.medium"
  description = "AWS Instance type, if you change, make sure it is compatible with AMI, not all AMIs allow all instance types "
}

variable "ecomTagName" {
  #default     = "🚀 SpacelySprockets 🛸"
  default     = "SpacelySprockets"
  description = "Name tag for the ecommerce servers"
}

variable "subnets" {
  type        = "map"
  description = "map of subnets to deploy your infrastructure in, must have as many keys as your server count (default 3), -var 'subnets={\"0\"=\"subnet-12345\",\"1\"=\"subnets-23456\"}' "

  default = {
<<<<<<< HEAD
    "0" = "subnet-ff6ca0b5"
    "1" = "subnet-b0f3c99f"
    "2" = "subnet-f85f64a5"
=======
    "0" = "subnet-8ddab7d7"
    "1" = "subnet-82992cc9"
    "2" = "subnet-8ddab7d7"
>>>>>>> development
  }
}

variable "vpc_id" {
  type        = "string"
  description = "ID of the VPC to use - in case your account doesn't have default VPC"
<<<<<<< HEAD
  default     = "vpc-c45ccfbf"
}

variable "domainname" {
  default = "spacelyspacesprockets.info"
=======
  default     = "vpc-5dd7ff24"
>>>>>>> development
}
