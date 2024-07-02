# variables.tf

variable "aws_region" {
  description = "The AWS region to deploy resources."
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "The AMI ID for the Ubuntu EC2 instance."
  type        = string
  default     = "ami-02db9aef7e06dc062"
}

variable "instance_type" {
  description = "The instance type for the EC2 instance."
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "The key pair name to use for the EC2 instance."
  type        = string
}

variable "my_ip_address" {
  description = "Your IP address to allow SSH access."
  type        = string
}

variable "bucket_name" {
  description = "The name of the S3 bucket for Jenkins artifacts."
  type        = string
}
