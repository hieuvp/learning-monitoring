variable "aws_key_name" {
  type        = string
  description = "The key name to use for the ec2 instance"
}

variable "aws_key_path" {
  type        = string
  description = "The key path to use for the ec2 instance"
}

variable "cloudflare_domain" {
  type        = string
  description = "The domain name you want to use"
}
