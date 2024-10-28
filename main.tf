provider "aws" {
  region = "ap-south-1"
}
resource "aws_instance" "TF-linux" {
  ami           = "ami-09b0a86a2c84101e1" # ap-south-1
  instance_type = "t2.micro"
  key_name        = "Jenkins-Key"
  security_groups = ["default"]
  tags = {
      Name = "TF-Instance"
  }
}
