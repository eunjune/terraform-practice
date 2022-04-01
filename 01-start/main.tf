provider "local" {
  # Configuration options

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
  value = data.local_file.bar
}