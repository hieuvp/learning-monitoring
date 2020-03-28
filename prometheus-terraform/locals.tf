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
