#This script creates an ec2 instance
# Declare the provider
provider "aws" {
  region = "us-west-1"  # Replace with your desired region
}

# Create a key pair (optional, you can also reference an existing one)
resource "aws_key_pair" "my_key" {
  key_name   = "my-key"
  public_key = file("./id_rsa.pub")  # Path to your public key
}

# Create a security group
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change this to restrict access to your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allows all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 instance
resource "aws_instance" "web" {
  ami           = "ami-0fda60cefceeaa4d3"  # Replace with your desired AMI
  instance_type = "t2.micro"  # Instance type
  key_name      = aws_key_pair.my_key.key_name  # Use the created key pair

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "MyTerraformInstance"
  }
}

# Output the instance's public IP
output "instance_public_ip" {
  value = aws_instance.web.public_ip
}

# Create an AMI that will start a machine whose root device is backed by
# an EBS volume populated from a snapshot. We assume that such a snapshot
# already exists with the id "snap-xxxxxxxx".
resource "aws_ami" "example" {
  name                = "terraform-example"
  root_device_name    = "/dev/xvda"
  imds_support        = "v2.0" # Enforce usage of IMDSv2. You can safely remove this line if your application explicitly doesn't support it.
  ebs_block_device {
    device_name = "/dev/xvda"
    snapshot_id = "snap-0f3fe49fb236b3945"
    volume_size = 8
  }
}
