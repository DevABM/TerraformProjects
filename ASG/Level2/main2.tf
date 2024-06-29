# main.tf

# Get the default VPC
data "aws_vpc" "default" {
  default = true
}


# Security Group for Jenkins
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "Allow SSH and Jenkins traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_address]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance for Jenkins
resource "aws_instance" "jenkins" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name


  user_data = file("jenkins.sh")
  tags = {
    Name = "jenkins_server"
  }

  security_groups = [aws_security_group.jenkins_sg.name]
}

# S3 bucket for Jenkins artifacts
resource "aws_s3_bucket" "jenkins_artifacts" {
  bucket = var.bucket_name

  tags = {
    Name = "jenkins_artifacts"
  }
}


resource "aws_s3_bucket_ownership_controls" "jenkins_artifacts" {
  bucket = aws_s3_bucket.jenkins_artifacts.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "jenkins_artifacts" {
  depends_on = [aws_s3_bucket_ownership_controls.jenkins_artifacts]

  bucket = aws_s3_bucket.jenkins_artifacts.id
  acl    = "private"
}

output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}

output "s3_bucket_name" {
  value = aws_s3_bucket.jenkins_artifacts.bucket
}
