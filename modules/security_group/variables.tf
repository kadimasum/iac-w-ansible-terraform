variable "name" {
  type        = string
  description = "Security group name"
}

variable "description" {
  type        = string
  description = "Security group description"
  default     = "Security group for EC2 instances"
}

variable "ingress" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "egress" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }]
}

variable "tags" {
  type    = map(string)
  default = {}
}
