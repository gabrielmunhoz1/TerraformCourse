provider "aws" {
  region     = var.region
}

resource "aws_instance" "ubuntu_ec2" {
  ami           = var.ec2_ami
  instance_type = var.ec2_type
  user_data     = file("userData.sh")

  tags = {
    Name = "terraformCourse"
  }
}

resource "aws_security_group" "terraformCourse" {
  name = "terraform-course-sg"

  # we can use dynamic block to create the same block for each value of the list specified
  dynamic ingress {
    for_each = ["80", "8080", "443"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}