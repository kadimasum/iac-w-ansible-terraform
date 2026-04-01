variable "name" {
  type        = string
  description = "Instance Name tag value"
}

variable "ami" {
  type        = string
  description = "AMI ID for the instance"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "List of security group IDs to attach"
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
