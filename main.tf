#1 : Create a VPC
resource "aws_vpc" "myvpc" {
  cidr_block = "20.0.0.0/16"
  tags = {
    Name = "MyTFVPC"
  }
}

#  2: Create a public subnet
resource "aws_subnet" "PublicSubnet" {
  vpc_id                  = aws_vpc.myvpc.id
  availability_zone       = "us-east-1a"
  cidr_block              = "20.0.1.0/24"
  map_public_ip_on_launch = true
}

# 3 : create a private subnet
resource "aws_subnet" "PrivSubnet" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "20.0.2.0/24"
  map_public_ip_on_launch = true

}


#  4 : create IGW

resource "aws_internet_gateway" "myIgw" {
  vpc_id = aws_vpc.myvpc.id
}

#  5 : route Tables for public subnet
resource "aws_route_table" "PublicRT" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIgw.id
  }
}


#  7 : route table association public subnet 
resource "aws_route_table_association" "PublicRTAssociation" {
  subnet_id      = aws_subnet.PublicSubnet.id
  route_table_id = aws_route_table.PublicRT.id
}

# for the key_pair
resource "aws_key_pair" "TF_key" {
  key_name   = "TF_key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "TF-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "TF_key.pem"
}

# data "aws_vpc" "existing_vpc" {
#   filter {
#     name   = "tag:Name"
#     values = ["Default VPC"]
#   }
# }


resource "aws_security_group" "allow_tlsTF" {
  name        = "allow_tlsTF"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    description      = "outgoing traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }

  tags = {
    Name = "Custom_Module_Security_Group"
  }


}

data "aws_ami" "amzlinux" {
  most_recent = "true"
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}

data "template_file" "user_data" {
  template = file("${abspath(path.module)}/userdata.yaml")
}
# AWS INSTANCE
resource "aws_instance" "vpc_ec2" {
  ami                         = data.aws_ami.amzlinux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.PublicSubnet.id
  associate_public_ip_address = true
  key_name                    = "TF_key"
  vpc_security_group_ids      = [aws_security_group.allow_tlsTF.id]
  tags = {
    Name      = "Custom-EC2"
    user_data = data.template_file.user_data.rendered
  }

}




