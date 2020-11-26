variable "name" {
    default = "test"
}

variable "environment" {
    default = "test"
}
variable "azs" {
     description = "AZ for subnets"
     default = "eu-west-3a,eu-west-3b" 
}

variable "aws_access_key" {
    default = "xxxxxxxxxxxxxxxxxxx"
}

variable "aws_secret_key" {
    default = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" 
}

variable "aws_key_path" { 
    default = "/home/vagrant/"
}

variable "aws_key_name" {
    default = "key_pair"
}

variable "aws_region" {
  description = "EC2 Region for the VPC"
  default     = "eu-west-3"
}

variable "amis" {
  description = "AMIs by region"
  default = {
    eu-west-3 = "ami-00373688fb7818d45"
  }
}
variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default     = "10.0.0.0/16"
}
variable "public_subnets_cidr" {
  description = "CIDR for the Public Subnets"
  default     = "10.0.10.0/24,10.0.11.0/24"
}
variable "private_subnet_a_cidr" {
  description = "CIDR for the Private Subnet A"
  default     = "10.0.1.0/24"
}
variable "private_subnet_b_cidr" {
  description = "CIDR for Private Subnet B"
  default     = "10.0.2.0/24" 
}

variable "private_subnets_cidr" {
  description = "CIDR for private subnets"
  default     = "10.0.1.0/24,10.0.2.0/24"
}

