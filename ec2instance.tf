provider "aws" {
   region = "ap-south-1"
}

resource "aws_instance" "exampleinstance" {
  ami           = "ami-0d81306eddc614a45"
  instance_type = "t2.micro"
  subnet_id     = "subnet-08b023ededc2d6b08"
  key_name      = "UBUNTU2"
  tags = {
    Name = "Example_Instance"
  }
}

