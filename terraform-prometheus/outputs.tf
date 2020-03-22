output "instance_id" {
  value       = aws_instance.this.id
  description = "The instance ID."
}

output "public_ip" {
  value       = aws_instance.this.public_ip
  description = "Public IP of instance."
}
