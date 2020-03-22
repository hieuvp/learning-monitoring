output "instance_id" {
  value       = aws_instance.this.id
  description = "The instance ID"
}

output "private_ip" {
  value       = aws_instance.this.private_ip
  description = "Private IP of the instance"
}

output "public_ip" {
  value       = aws_instance.this.public_ip
  description = "Public IP of the instance"
}
