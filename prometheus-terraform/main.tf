locals {
  application = "Prometheus"
  environment = "Test"

  region        = "ap-southeast-1"
<<<<<<< HEAD
  ami           = "ami-0cbc6aae997c6538a" # Amazon Linux 2
  username      = "ec2-user"
=======
>>>>>>> master
  instance_type = "t2.micro"
  volume_size   = "20"                    # In gibibytes (GiB)
  ami           = "ami-0cbc6aae997c6538a" # Amazon Linux 2
  username      = "ec2-user"

  domain_name = "shopback.engineering"
  domain_id   = data.cloudflare_zones.this.zones[0].id
  subdomain   = lower(local.application)
}

# Create an EC2 instance on AWS
resource "aws_instance" "this" {
  instance_type = local.instance_type

  root_block_device {
    volume_size = local.volume_size
  }

  ami      = local.ami
  key_name = var.ssh_key_name

  connection {
    type        = "ssh"
    host        = self.private_ip
    user        = local.username
    private_key = file(var.ssh_key_path)
  }

  provisioner "file" {
    source      = "~/.ssh/id_rsa"
    destination = "~/.ssh/id_rsa"
  }

  user_data_base64 = filebase64("${path.root}/user-data.sh")

  provisioner "file" {
    source      = "~/.ssh/id_rsa"
    destination = "/home/${local.username}/.ssh/id_rsa"
  }

  connection {
    type        = "ssh"
    host        = self.private_ip
    user        = local.username
    private_key = file(var.ssh_key_path)
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
  name    = local.subdomain
  value   = aws_instance.this.private_ip
  ttl     = "1"
  proxied = "false"
}
