output "instance_publicip" {
  value       = aws_instance.vpc_ec2.public_ip
  description = "Public IP of the EC2 instance provisioned"
}

output "vpc-id" {
  value       = aws_vpc.myvpc.id
  description = "VPC_ID"
}