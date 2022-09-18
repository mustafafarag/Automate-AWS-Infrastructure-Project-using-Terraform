provider "aws" {
  region = "eu-west-3"
}



variable "vpc_cidr_blocks" {}
variable "subnet_cidr_blocks" {}
variable "avail_zone" {}
variable "env_prefix" {}
variable "my_ip" {}
variable "puplic_key_location" {}
variable "instance_type" {}




resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_blocks
  tags = {
    Name : "${var.env_prefix}-vpc"
  }
}





resource "aws_subnet" "myapp-subnit-1" {

  vpc_id = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_cidr_blocks
  availability_zone = var.avail_zone

  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
}





# think of this as a virtual router to our network

resource "aws_route_table" "myapp-reoute-table" {
  vpc_id = aws_vpc.myapp-vpc.id



  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }


  tags = {
    Name = "${var.env_prefix}-rtb"
  }

}






# THink of this as modem for our network 
resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id
  
  
  tags = {
    Name = "${var.env_prefix}-igw"
  }

  
}





resource "aws_route_table_association" "a-rtb-subnet" {


  subnet_id = aws_subnet.myapp-subnit-1.id
  route_table_id = aws_route_table.myapp-reoute-table.id
  
}











resource "aws_security_group" "myapp-sg" {
  name = "myapp-sg"
  vpc_id = aws_vpc.myapp-vpc.id


  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.my_ip]
  }


  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }


  tags = {
    Name : "${var.env_prefix}-sg"
  }

}







# Creating EC2-Instance



data  "aws_ami" "latest_amazon_linux_image" {

  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }


  filter {

    name = "virtualization-type" 
    values = ["hvm"]

  }
}






output "aws_ami_id" {
  value = data.aws_ami.latest_amazon_linux_image.id
  
}


output "ec2_puplic_ip" {
  value = aws_instance.myapp-server.public_ip
  
}










resource "aws_key_pair" "ssh-key" {

  key_name = "server-key"
  public_key = "${file(var.puplic_key_location)}"
  
}










resource "aws_instance" "myapp-server" {


  ami = data.aws_ami.latest_amazon_linux_image.id
  instance_type = var.instance_type
  
  
  
  subnet_id = aws_subnet.myapp-subnit-1.id
  vpc_security_group_ids = [aws_security_group.myapp-sg.id]
  availability_zone = var.avail_zone


  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name




  user_data = file("entry-script.sh")


  tags = {
    Name = "${var.env_prefix}-server"
  }

  
}