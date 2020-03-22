locals {
  ami           = "ami-0cbc6aae997c6538a"
  instance_type = "t2.micro"
}

locals {
  application = "Prometheus"
  environment = "Test"

  tags = {
    Name        = "${upper(local.environment)}-${lower(local.application)}"
    Application = local.application
    Environment = local.environment
  }
}
