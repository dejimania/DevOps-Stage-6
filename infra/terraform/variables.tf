variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0ecb62995f68bb549" # Ubuntu 20.04 LTS
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.large"
}

variable "key_name" {
  description = "AWS key pair name"
  type        = string
}

variable "private_key_path" {
  description = "Path to private key file"
  type        = string
}