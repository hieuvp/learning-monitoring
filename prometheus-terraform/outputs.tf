output "instance_id" {
  value       = aws_instance.this.id
  description = "The instance ID"
}

output "hostname" {
  value       = cloudflare_record.this.hostname
  description = "DNS hostname of the instance"
}

output "private_ip" {
  value       = aws_instance.this.private_ip
  description = "Private IP of the instance"
}
