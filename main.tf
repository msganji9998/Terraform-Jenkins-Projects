
resource "aws_instance" "TF-Instance1" {
  ami           = "ami-0e53db6fd757e38c7" # ap-south-1
  instance_type = "t2.micro"
  tags = {
      Name = "TF-Instance"
  }
}
