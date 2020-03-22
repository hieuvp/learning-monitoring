output "hostname" {
  value       = cloudflare_record.this.hostname
  description = ""
}

output "instance_id" {
  value       = aws_instance.this.id
  description = "The instance ID"
}

output "private_ip" {
  value       = aws_instance.this.private_ip
  description = "Private IP of the instance"
}
