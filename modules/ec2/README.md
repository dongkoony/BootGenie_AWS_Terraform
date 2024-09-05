# EC2 오토스케일링 모듈

[![EN](https://img.shields.io/badge/lang-en-blue.svg)](README-us.md) 
[![KR](https://img.shields.io/badge/lang-kr-red.svg)](README.md)

#### [View English Documentation (EN)](README-us.md)

이 디렉토리는 AWS EC2 인스턴스의 오토스케일링을 위한 Terraform 구성을 포함하고 있습니다. 이 모듈은 웹 서버와 애플리케이션 서버 모두에 대한 오토스케일링 그룹(ASG)을 설정합니다.

## 디렉토리 구조

```
modules/ec2/
├── main.tf
├── outputs.tf
├── README.md
├── variables.tf
```

## 주요 기능

1. 웹 서버와 앱 서버를 위한 시작 템플릿 생성
2. 오토스케일링 그룹 설정
3. CloudWatch 알람을 통한 스케일 인/아웃 정책 구현

## 스케일 인/아웃 정책

### 웹 서버
- **스케일 아웃**: CPU 사용률이 70% 이상일 때
- **스케일 인**: CPU 사용률이 30% 이하일 때

### 앱 서버
- **스케일 아웃**: CPU 사용률이 75% 이상일 때
- **스케일 인**: CPU 사용률이 30% 이하일 때

두 서버 유형 모두 스케일링 작업 사이에 300초(5분)의 쿨다운 기간이 설정되어 있습니다.

## 코드 구조 설명

1. **시작 템플릿 (`aws_launch_template`)**
   - 인스턴스 타입, AMI, 보안 그룹 등 인스턴스 설정을 정의합니다.
   - 사용자 데이터 스크립트를 통해 인스턴스 초기 설정을 수행합니다.

2. **오토스케일링 그룹 (`aws_autoscaling_group`)**
   - 최소, 최대, 원하는 용량을 설정합니다.
   - 시작 템플릿을 참조하여 새 인스턴스를 생성합니다.

3. **CloudWatch 알람 (`aws_cloudwatch_metric_alarm`)**
   - CPU 사용률을 모니터링하여 스케일 인/아웃 조건을 정의합니다.

4. **오토스케일링 정책 (`aws_autoscaling_policy`)**
   - CloudWatch 알람에 의해 트리거되어 인스턴스 수를 조정합니다.

## 사용 방법

1. `variables.tf` 파일에서 필요한 변수들을 설정합니다.
2. 메인 Terraform 구성에서 이 모듈을 호출합니다:

```hcl
module "ec2_autoscaling" {
  source = "./modules/ec2"
  
  # 필요한 변수들을 여기에 전달
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  # ... 기타 변수들 ...
}
```

3. `terraform init`, `terraform plan`, `terraform apply` 명령을 실행하여 리소스를 생성합니다.

## 커스터마이징

- `variables.tf` 파일에서 스케일링 임계값, 인스턴스 타입 등을 조정할 수 있습니다.
- `main.tf` 파일에서 추가적인 정책이나 알람을 정의할 수 있습니다.

## 주의사항

- 스케일링 정책을 변경할 때는 비용과 성능 사이의 균형을 고려해야 합니다.
- 테스트 환경에서 충분히 검증한 후 프로덕션 환경에 적용하세요.

## 향후 개선 사항

- 다양한 지표(예: 메모리 사용률, 네트워크 트래픽)를 기반으로 한 스케일링 정책 추가
- 예측 스케일링(Predictive Scaling) 구현 고려