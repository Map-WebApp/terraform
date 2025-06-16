output "key_name" {
  description = "The name of the created EC2 key pair."
  value       = aws_key_pair.this.key_name
} 