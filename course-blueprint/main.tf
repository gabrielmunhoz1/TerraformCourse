provider "aws" {
  region     = var.region
}

data "aws_ami" "latest_amazon_linux" {
  owners = ["137112412989"]
  most_recent = true
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_availability_zones" "available" {}

locals {
  tags = {
    project = "course"
    #function length https://developer.hashicorp.com/terraform/language/functions/length
    number_of_azs = length(data.aws_availability_zones.available.names)
    #function join https://developer.hashicorp.com/terraform/language/functions/join
    name_of_azs   = join(",", data.aws_availability_zones.available.names)
  }
}

resource "aws_instance" "ubuntu_ec2" {
  ami           = var.ec2_ami
  instance_type = var.ec2_type
  user_data     = file("userData.sh")

  # we can use "merge" to add a specific content in var
  tags = merge(var.tags, {Name = "terraformCourse"}, local.tags)

  #it will create another instance with the changes made, and then destroy the old one (almost zero downtime)
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "second_ubuntu_ec2" {
  ami           = var.ec2_ami
  instance_type = var.ec2_type
  
  tags = {
    Name = "terraformCourse"
  }

  # This instance will be created (or deleted) after the ubuntu_ec2 instance
  depends_on = [ aws_instance.ubuntu_ec2 ]
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

# generating a random password to use in any resource
resource "random_password" "my_password" {
  length = 12
  special = true
  override_special = "#&"
}

# using random password to a ssm value
resource "aws_ssm_parameter" "foo" {
  name  = "myCoursePassword"
  type  = "String"
  value = random_password.my_password.result

  depends_on = [ random_password.my_password ]
}



