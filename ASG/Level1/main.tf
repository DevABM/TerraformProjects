terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

#Add the resource details


resource "aws_instance" "jenkins" {
  ami                         = "ami-04b70fa74e45c3917" # using free tier ami of Ubuntu avoiding Amazon Linux 2023 as it has issues with jenkins
  instance_type               = "t2.micro"
  key_name                    = "LUIT"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jen-sg.id]
  user_data                   = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y openjdk-11-jdk
              sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins
              sudo systemctl start jenkins
              sudo systemctl enable jenkins
              EOF

  tags = {
    Name = "Jenkins WebServer"
  }
}


resource "aws_security_group" "jen-sg" {
  description = "Allow SSH traffic and HTTPS traffic"
  tags = {
    Name = "jen-sg"
  }


  ingress {
    description = "Allow SSH Traffic"
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS Traffic"
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Traffic for jenkins server at 8080"
    from_port   = 8080
    protocol    = "tcp"
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1" # semantically equivalent to all ports
  }

}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl
resource "aws_s3_bucket" "jenkinsbucket77890" {
  bucket = "my-tf-jenkins-bucket-jjjjjjjj"
  tags = {
    Name = "Jenkins WebServer"
  }

}

resource "aws_s3_bucket_ownership_controls" "jenkinsbucket77890" {
  bucket = aws_s3_bucket.jenkinsbucket77890.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "jenkinsbucket77890" {
  depends_on = [aws_s3_bucket_ownership_controls.jenkinsbucket77890]

  bucket = aws_s3_bucket.jenkinsbucket77890.id
  acl    = "private"
}