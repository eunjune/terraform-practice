provider "local" {
  # Configuration options
}

/*
새로운 provider를 정의했다면 terraform init을 해줘야함.
*/
provider "aws" {
  region = "ap-northeast-2"
}

# 관리할 인프라 리소스
/*
실행 방법
1. terraform init : provider 설치.
- .terraform : 아래 정의한 리소스가 다운받아져 있음
- .terraform.lock.hcl : 파일에 락을 걸어서 여러 사람들이 못고치도록?
2. terraform plan
3. terraform apply
- 아래 파일(foo.txt)가 생성됨
- terraform.tfstate : 상태파일
4. terraform destory

*/
resource "local_file" "foo" {
  filename = "${path.module}/foo.txt" # 문자열 안의 ${}은 변수나 function 접근
  content  = "Hello World!"
}


# 인프라 관리시 참조할 데이터
/*
bar.txt가 존재해야지 terraform apply시 에러가 나지 않는다
*/
data "local_file" "bar" {
  filename = "${path.module}/bar.txt"
}

# 결과값 출력
/*
file_bar의 오브젝트가 생성?
Outputs:

file_bar = {
  "content" = <<-EOT
  Hello Devops!

  EOT
  "content_base64" = "SGVsbG8gRGV2b3BzIQo="
  "filename" = "./bar.txt"
  "id" = "d31fb1a80fc1e9f2b4bb460f92f8808a7e5a528e"
}
*/
output "file_bar" {
  value = data.local_file.bar // data를 출력하면 data prefix를 붙임
}

/*
apply를 하면 aws vpc가 새로 생성되게 된다
*/
resource "aws_vpc" "foo" {
  cidr_block = "10.123.0.0/16" # 이걸 변경하는 경우 change로 인식하지 않음. 그렇기 때문에 이런 부분을 잘 파악해서 apply를 해야 함

  tags = {
    "Name" = "This is test vpc"
  }
}

/*
리소스에 대한 정보를 출력해서 알 수 있다
*/
output "vpc_foo" {
  value = aws_vpc.foo // resource를 출력하면 prefix 없음 그냥 이름만
}


data "aws_vpcs" "this" {

}

output "vpcs" {
  value= data.aws_vpcs.this
}
