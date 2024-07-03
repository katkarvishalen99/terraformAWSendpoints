output "ec2_id" {
        value = aws_instance.vpc-endpoint-ec2.id
        description = "instance ID"
}
output "ec2_arn" {
        value = aws_instance.vpc-endpoint-ec2.arn
}