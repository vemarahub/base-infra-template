
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "github-runner"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "public_key" {
  description = "Public key for SSH access"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository URL (e.g., https://github.com/username/repo)"
  type        = string
}