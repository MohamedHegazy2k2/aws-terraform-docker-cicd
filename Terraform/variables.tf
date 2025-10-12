variable "region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "eu-north-1"
}

variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0a716d3f3b16d290c"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = "vpc-0dcd0752cba421c53"
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
  default     = "subnet-08b45c3be43b3f7ab"
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
  default     = "1"
}

