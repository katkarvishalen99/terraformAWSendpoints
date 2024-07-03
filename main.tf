#===================VPC========================
resource "aws_vpc" "vpc-endpoint" {
        cidr_block = "10.0.0.0/16"
        enable_dns_support = true
        enable_dns_hostnames = true

        tags = {
         Name = "vpc-endpoint"
  }
}
#===================subnet========================
resource "aws_subnet" "vpc-endpoint-subnet" {
        vpc_id = aws_vpc.vpc-endpoint.id
        cidr_block = "10.0.1.0/24"
        map_public_ip_on_launch = false

        tags = {
         Name = "vpc-endpoint-subnet"
  }
}
#===================route table========================
data "aws_route_table" "vpc-endpoint-rt" {
        vpc_id = aws_vpc.vpc-endpoint.id

}
resource "aws_route_table_association" "private_rt_association" {
        route_table_id = data.aws_route_table.vpc-endpoint-rt.id
        subnet_id = aws_subnet.vpc-endpoint-subnet.id
}
#===================Security Group========================
resource "aws_security_group" "sg1" {
        vpc_id = aws_vpc.vpc-endpoint.id
        egress {
                from_port = 0
                to_port = 0
                protocol = "All"
                cidr_blocks = ["0.0.0.0/0"]
        }
        ingress {
                description = "HTTPS from VPC"
                from_port = 443
                to_port = 443
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
          }

        tags = {
         Name = "vpc-endpoint-sg"
  }
}
#===================Endpoint========================
resource "aws_vpc_endpoint" "endpoint" {
        vpc_id = aws_vpc.vpc-endpoint.id
        for_each = toset(var.aws_vpc_endpoint)
        service_name = "com.amazonaws.${var.region}.${each.value}"
        vpc_endpoint_type = "Interface"
        subnet_ids = [aws_subnet.vpc-endpoint-subnet.id]
        security_group_ids = [aws_security_group.sg1.id]
        private_dns_enabled = true

        tags = {
         Name = "${each.value}"
  }
}
resource "aws_vpc_endpoint" "s3" {
        vpc_id = aws_vpc.vpc-endpoint.id
        service_name = "com.amazonaws.${var.region}.s3"
        route_table_ids = [data.aws_route_table.vpc-endpoint-rt.id]

        tags = {
         Name = "s3"
  }
}
#====================EBS============================
resource "aws_ebs_volume" "ec2-ebs" {
        availability_zone = "${var.region}a"
        size = 8
}
#====================EC2============================

resource "aws_instance" "vpc-endpoint-ec2" {
        ami = var.ami
        instance_type = var.instance_type
        iam_instance_profile = aws_iam_instance_profile.ec2-profile.name
        security_groups = [aws_security_group.sg1.id]
        subnet_id = aws_subnet.vpc-endpoint-subnet.id
                key_name = "terraform"

        tags = {
         Name = "vpc-ec2"
  }
}
#===================IAM==============================
resource "aws_iam_role" "ec2-role" {
        name = "ec2-iam-role"
        assume_role_policy = "${file("ec2-assume-role.json")}"
}
#=====================IAM policy attachment==================
resource "aws_iam_role_policy_attachment" "iam-role-attach" {
        for_each = toset(var.policy_arn)
        role =  aws_iam_role.ec2-role.id
        policy_arn = each.value
}
#=====================Instance Profile================
resource "aws_iam_instance_profile" "ec2-profile" {
        name = "ec2-profile-1"
        role = aws_iam_role.ec2-role.name
}