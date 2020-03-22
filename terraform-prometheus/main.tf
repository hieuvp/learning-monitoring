# Create an EC2 resource on AWS
resource "aws_instance" "this" {
  ami           = local.ami
  instance_type = local.instance_type
  key_name      = var.key_name

  tags = local.tags
}
