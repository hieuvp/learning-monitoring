provider "aws" {
  region = "ap-southeast-1"
}

locals {
  application = "Prometheus"
  environment = "Test"

  instance_type = "t2.micro"
  ami           = "ami-0cbc6aae997c6538a"
}

# Create an EC2 resource on AWS
resource "aws_instance" "this" {
  instance_type = local.instance_type
  ami           = local.ami
  key_name      = var.key_name

  tags = {
    Name        = "${upper(local.environment)}-${lower(local.application)}"
    Application = local.application
    Environment = local.environment
  }
}
