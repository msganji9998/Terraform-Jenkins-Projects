provider "aws" {
    region = "ap-south-1"  
}

resource "aws_instance" "TF-Instance" {
  ami           = "ami-0e53db6fd757e38c7" # us-west-2
  instance_type = "t2.micro"
  tags = {
      Name = "TF-Instance"
  }
}
