provider "aws" {
  region = "ap-southeast-1"
}

locals {
  application = "Prometheus"
  environment = "Test"

  instance_type = "t2.micro"
  volume_size   = "20" # In gibibytes (GiB)

  ami  = "ami-0cbc6aae997c6538a" # Amazon Linux 2
  user = "ec2-user"

  domain_id   = data.cloudflare_zones.this.zones[0].id
  domain_name = lower(local.application)
}

# Create an EC2 instance on AWS
resource "aws_instance" "this" {
  instance_type = local.instance_type
  ami           = local.ami
  key_name      = var.aws_key_name

  root_block_device {
    volume_size = local.volume_size
  }

  connection {
    type        = "ssh"
    host        = self.private_ip
    user        = local.user
    private_key = file(var.aws_key_path)
  }

  tags = {
    Name        = "${upper(local.environment)}-${lower(local.application)}"
    Application = local.application
    Environment = local.environment
  }
}

# Create a DNS record on Cloudflare
resource "cloudflare_record" "this" {
  zone_id = local.domain_id

  type    = "A"
  name    = local.domain_name
  value   = aws_instance.this.private_ip
  ttl     = "1"
  proxied = "false"
}
