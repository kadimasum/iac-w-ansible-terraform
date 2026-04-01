resource "aws_instance" "this" {
  ami           = var.ami
  instance_type = var.instance_type

  vpc_security_group_ids = var.vpc_security_group_ids

  tags = merge({
    Name = var.name
  }, var.tags)
}
