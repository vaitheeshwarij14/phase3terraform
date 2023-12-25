provider "aws" {
  access_key = "AKIAVGTZN2DJZ4D2RZ4A"
  secret_key = "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"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1a"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1b"
  
  tags = {
    Name = "private-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-security-group"
  description = "Security group for bastion host"
  vpc_id      = aws_vpc.main.id
    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my_security_group"
  }
  # Ingress and egress rules should be defined here based on your requirements
}

resource "aws_instance" "bastion_host" {
  ami           = "ami-03f4878755434977f"
  instance_type = "t2.micro"
  
  subnet_id     = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "BastionHost"
  }
}

resource "aws_instance" "private_ec2" {
  ami           = "ami-03f4878755434977f"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet.id

  tags = {
    Name = "PrivateEC2Instance"
  }
}

output "bastion_host_public_ip" {
  value = aws_instance.bastion_host.public_ip
}