variable "platform" {
  default     = "centos"
  description = "The OS Platform"
}

variable "user" {
  default = "centos"
}

# Stock AMI
variable "demoami" {
  default = "ami-b63ae0ce"
}

# # Packer-built AMI
# variable "demoami" {
#   default = "ami-fc52ee84"
#   description = "eCommerce Website - CentOS 7 - v0.3"
# }

variable "key_name" {
  description = "SSH key name in your AWS account for AWS instances."
  default = "scarolan"
}

variable "private_ssh_key" {
  description = "Private SSH key for accessing EC2 instances.  Must be uploaded/created in the AWS console."
}

variable "region" {
  default     = "us-west-2"
  description = "The region of AWS, for AMI lookups."
}

variable "ecommerce_servers" {
  default     = "1"
  description = "The number of demo ecommerce servers to launch."
}

variable "ecommerce_instance_type" {
  default     = "t2.medium"
  description = "AWS Instance type, if you change, make sure it is compatible with AMI, not all AMIs allow all instance types "
}

variable "ecomTagName" {
  default     = "ecommerce"
  description = "Name tag for the ecommerce servers"
}

variable "subnets" {
  type = "map"
  description = "map of subnets to deploy your infrastructure in, must have as many keys as your server count (default 3), -var 'subnets={\"0\"=\"subnet-12345\",\"1\"=\"subnets-23456\"}' "
  default = {
    "0" = "subnet-ff6ca0b5",
    "1" = "subnet-b0f3c99f",
    "2" = "subnet-f85f64a5"
  }
}

variable "vpc_id" {
  type = "string"
  description = "ID of the VPC to use - in case your account doesn't have default VPC"
  default = "vpc-ec04008b"
}
