# Terraform을 사용한 AWS 웹 서버 아키텍처

이 저장소에는 AWS에서 고가용성과 확장성을 갖춘 웹 서버 아키텍처를 배포하기 위한 Terraform 구성 파일이 포함되어 있습니다. 이 아키텍처는 여러 계층의 보안, 로드 밸런싱, 자동 확장 및 고가용성을 포함합니다.

## 아키텍처 개요

이 아키텍처에서는 다음과 같은 AWS 서비스를 사용합니다:

- **Amazon S3**: 백업을 위한 정적 스토리지.
- **AWS WAF**: 웹 응용 프로그램 방화벽을 통해 일반적인 웹 공격으로부터 보호.
- **Amazon Route 53**: 도메인 이름 해석을 위한 DNS 서비스.
- **AWS Shield**: DDoS 보호.
- **Amazon CloudFront**: 콘텐츠 전송 네트워크(CDN)로 콘텐츠를 캐시하고 전송.
- **VPC**: 네트워크를 격리하는 가상 프라이빗 클라우드.
- **공용 서브넷**: 인스턴스에 인터넷 액세스를 제공하는 NAT 게이트웨이용.
- **프라이빗 서브넷**: 웹 및 애플리케이션 서버용.
- **NAT 게이트웨이**: 프라이빗 서브넷의 리소스에 대한 아웃바운드 인터넷 액세스를 활성화.
- **애플리케이션 로드 밸런서**: 들어오는 트래픽을 여러 인스턴스에 분산.
- **EC2 인스턴스**: 웹 및 애플리케이션 서버용.
- **자동 확장 그룹**: 로드를 처리하기 위해 적절한 수의 인스턴스를 실행하도록 보장.

## 다이어그램

![aws_boot_genie](https://github.com/dongkoony/BootGenie_AWS_Terraform/assets/109497684/6ec604bc-19a8-4711-87ed-da40def5669a)

## 전제 조건

- Terraform 0.12+ 설치
- AWS CLI가 적절한 자격 증명으로 구성됨
- Route 53에 등록된 기존 도메인

## 설정 지침

1. **저장소 클론:**

   ```bash
   git clone https://github.com/dongkoony/BootGenie_AWS_Terraform.git
   cd BootGenie_AWS_Terraform
   ```

2. **Terraform 초기화:**

   ```bash
   terraform init
   ```

3. **구성 파일 사용자 지정:**

   `variables.tf` 파일을 편집하여 원하는 리전, 인스턴스 유형 및 기타 매개변수에 맞게 설정합니다.

4. **배포 계획:**

   ```bash
   terraform plan
   ```

   출력 결과를 검토하고 예상대로 설정되었는지 확인합니다.

5. **구성 적용:**

   ```bash
   terraform apply
   ```

   `yes`를 입력하여 배포를 확인합니다.

## Terraform 구성 파일

- **main.tf**: VPC, 서브넷, NAT 게이트웨이 및 라우트 테이블에 대한 주요 구성을 포함합니다.
- **security_groups.tf**: 인바운드 및 아웃바운드 트래픽을 제어하는 보안 그룹을 정의합니다.
- **ec2_instances.tf**: 웹 및 애플리케이션 서버용 EC2 인스턴스를 구성합니다.
- **load_balancers.tf**: 애플리케이션 로드 밸런서를 설정합니다.
- **auto_scaling.tf**: 웹 및 앱 서버용 자동 확장 그룹을 구성합니다.
- **waf.tf**: 웹 애플리케이션 보호를 위한 AWS WAF를 설정합니다.
- **cloudfront.tf**: Amazon CloudFront를 CDN으로 구성합니다.
- **route53.tf**: Route 53을 사용하여 DNS 설정을 관리합니다.

## 변수

`variables.tf` 파일에서 다음 변수를 사용자 지정할 수 있습니다:

- `aws_region`: 리소스를 배포할 AWS 리전.
- `vpc_cidr`: VPC의 CIDR 블록.
- `public_subnets`: 공용 서브넷의 CIDR 블록 목록.
- `private_subnets`: 프라이빗 서브넷의 CIDR 블록 목록.
- `instance_type`: EC2 인스턴스 유형.
- `key_name`: 인스턴스에 대한 SSH 액세스를 위한 키 페어 이름.
- `domain_name`: 애플리케이션의 도메인 이름.

## 출력

다음 출력이 제공됩니다:

- `alb_dns_name`: 애플리케이션 로드 밸런서의 DNS 이름.
- `web_instance_ids`: 웹 서버 인스턴스의 ID.
- `app_instance_ids`: 애플리케이션 서버 인스턴스의 ID.

## 정리

이 Terraform 구성을 통해 생성된 리소스를 삭제하려면 다음을 실행하세요:

```bash
terraform destroy
```

`yes`를 입력하여 삭제를 확인합니다.

## 기여

기여를 환영합니다! 개선 사항이나 수정 사항을 논의하려면 풀 리퀘스트를 제출하거나 이슈를 열어주세요.

## 라이선스

이 프로젝트는 MIT 라이선스에 따라 라이선스가 부여됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

