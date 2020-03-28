provider "aws" {
  region = "ap-southeast-1"
}

locals {
  application = "Prometheus"
  environment = "Test"

  ami           = "ami-0cbc6aae997c6538a" # Amazon Linux 2
  instance_type = "t2.micro"
  volume_size   = "20" # In gibibytes (GiB)

  domain_name = "shopback.engineering"
  domain_id   = data.cloudflare_zones.this.zones[0].id
  subdomain   = lower(local.application)
}

# Create an EC2 instance on AWS
resource "aws_instance" "this" {
  ami           = local.ami
  instance_type = local.instance_type

  root_block_device {
    volume_size = local.volume_size
  }

  key_name         = var.ssh_key_name
  user_data_base64 = filebase64("${path.root}/user-data.sh")

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
  name    = local.subdomain
  value   = aws_instance.this.private_ip
  ttl     = "1"
  proxied = "false"
}
