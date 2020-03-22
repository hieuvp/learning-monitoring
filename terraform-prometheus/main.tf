provider "aws" {
  region = "ap-southeast-1"
}

locals {
  application = "Prometheus"
  environment = "Test"

  instance_type = "t2.micro"

  # Amazon Linux 2 AMI
  ami = "ami-0cbc6aae997c6538a"
}

# Create an EC2 resource on AWS
resource "aws_instance" "this" {
  instance_type = local.instance_type
  ami           = local.ami
  key_name      = var.aws_key_name

  tags = {
    Name        = "${upper(local.environment)}-${lower(local.application)}"
    Application = local.application
    Environment = local.environment
  }
}

# Create a DNS record on Cloudflare
resource "cloudflare_record" "this" {
  zone_id = var.cloudflare_zone_id

  type  = "A"
  value = aws_instance.this.private_ip

  name    = lower(local.application)
  ttl     = "1"
  proxied = "false"
}
