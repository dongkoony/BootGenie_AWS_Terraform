# AWS Infrastructure with Terraform

이 프로젝트는 Terraform을 사용하여 AWS에 고가용성과 보안이 강화된 인프라를 구축하는 것을 목표로 합니다. 모듈화된 Terraform 코드를 통해 인프라를 효율적으로 관리하고 확장할 수 있습니다.

## 아키텍처

이 프로젝트의 아키텍처는 다음과 같은 AWS 서비스를 사용합니다:

- VPC (Virtual Private Cloud)
- EC2 (Elastic Compute Cloud)
- ALB (Application Load Balancer)
- Route 53
- WAF (Web Application Firewall)

![aws_boot_genie](https://github.com/dongkoony/BootGenie_AWS_Terraform/assets/109497684/6ec604bc-19a8-4711-87ed-da40def5669a)


## 주요 기능

- 고가용성을 위한 다중 AZ (Availability Zone) 구성
- 오토 스케일링을 통한 확장성 및 탄력성 확보
- ELB를 통한 트래픽 분산 및 HTTPS 통신 지원
- Route 53을 사용한 도메인 관리 및 DNS 서비스
- WAF를 통한 웹 애플리케이션 보안 강화

## 사전 요구 사항

이 프로젝트를 실행하기 위해서는 다음이 필요합니다:

- AWS 계정
- Terraform 설치 (버전 0.13 이상)
- AWS CLI 설치 및 구성

## 시작하기

1. 이 저장소를 클론합니다:
```
git clone https://github.com/your-username/aws_BootGenie.git
```

2. 프로젝트 디렉토리로 이동합니다:
```
cd aws_BootGenie
```

3. `terraform.tfvars` 파일을 생성하고 필요한 변수를 설정합니다:
```
cp terraform.tfvars.example terraform.tfvars
```

4. Terraform 초기화를 수행합니다:
```
terraform init
```

5. Terraform 계획을 확인합니다:
```
terraform plan
```

6. Terraform 적용을 실행합니다:
```
terraform apply
```

## 프로젝트 구조

- `main.tf`: 메인 Terraform 설정 파일
- `variables.tf`: Terraform 변수 정의 파일
- `outputs.tf`: Terraform 출력 정의 파일
- `terraform.tfvars`: Terraform 변수 값 파일 (예시)
- `modules/`: Terraform 모듈 디렉토리
  - `vpc/`: VPC 모듈
  - `ec2/`: EC2 모듈
  - `elb/`: ELB 모듈
  - `route53/`: Route 53 모듈
  - `waf/`: WAF 모듈 // 준비 중
