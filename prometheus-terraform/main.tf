provider "aws" {
  region = "ap-southeast-1"
}

# Create an EC2 instance on AWS
resource "aws_instance" "this" {
  instance_type = local.instance_type
  ami           = local.ami
  key_name      = var.aws_key_name

  user_data_base64 = filebase64("${path.root}/user_data.sh")

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
