
provider "aws" {
  region = "ap-northeast-2"
}

# ami 가져오기
data "aws_ami" "ubuntu" {
  most_recent = true # filter를 거쳐서 온 ami들 중에 가장 최신 ami 가져옴

  #
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }


  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# instance 생성하기
# aws_instance => 리소스종류
# ubuntu => 종류에 대한 네이밍
resource "aws_instance" "ubuntu" {
  ami           = data.aws_ami.ubuntu.image_id
  instance_type = "t2.micro"

  tags = {
    Name = "ej-ubuntu"
  }
}