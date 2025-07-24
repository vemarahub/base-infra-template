# modules/ecs/variables.tf

variable "project_name" {
  description = "The name of the project, used for naming resources"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where ECS resources will be deployed"
  type        = string
}

variable "alb_security_group_id" {
  description = "The ID of the security group for the Application Load Balancer"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain logs in CloudWatch"
  type        = number
  default     = 7
}

variable "tags" {
  description = "A map of tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "enable_container_insights" {
  description = "Whether to enable Container Insights for the ECS cluster"
  type        = bool
  default     = false
}

variable "container_ports" {
  description = "List of container ports to allow ingress traffic"
  type        = list(number)
  default     = []
}