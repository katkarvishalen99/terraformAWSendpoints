variable "region" {
    default = "ap-south-1"
        description = "Region to create resources"
    type = string
}
variable "ami" {
    default = "ami-013e83f579886baeb"
        description = "EC2 instance AMI"
}
variable "instance_type" {
    default = "t2.micro"
        description = "EC2 instance type"
    type = string
}
variable "aws_vpc_endpoint" {
        type = set(string)
                description = "Interface Endpoints"
        default = [
                    "ssm",
                    "ssmmessages",
                    "ec2messages"
                  ]
}
variable "policy_arn" {
        type = set(string)
                description = "Policies"
        default = [
                    "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy",
                    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
                    "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
                                  ]
}