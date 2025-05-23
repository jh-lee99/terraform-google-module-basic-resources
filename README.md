# Terraform Google Cloud 기본 리소스 모듈

이 저장소는 Google Cloud Platform(GCP)에서 자주 사용되는 기본 리소스를 생성하기 위한 Terraform 모듈 모음입니다.

## 모듈 구성

이 프로젝트는 다음과 같은 모듈을 포함하고 있습니다:

### 네트워킹 모듈
- **[VPC](./modules/networking/vpc/README.md)**: VPC 네트워크, 서브넷, Cloud Router, Cloud NAT 생성

### 컴퓨트 모듈
- **[Instance](./modules/compute/instance/README.md)**: 단일 컴퓨트 인스턴스(VM) 생성
- **[MIG](./modules/compute/mig/README.md)**: 관리형 인스턴스 그룹(MIG) 생성
- **[Load Balancer](./modules/compute/loadbalancer/README.md)**: 리전 외부 애플리케이션 로드 밸런서 생성

### 서비스 모듈
- **[Docker Ubuntu](./modules/services/docker-ubuntu/README.md)**: Docker가 설치된 Ubuntu 인스턴스 생성

## 사용 예제

다음과 같은 예제가 제공됩니다:

- **[VPC 테스트](./examples/vpc-test/README.md)**: VPC 네트워크 모듈 사용 예제
- **[인스턴스 테스트](./examples/instance-test/README.md)**: 컴퓨트 인스턴스 모듈 사용 예제
- **[서비스 테스트](./examples/service-test/README.md)**: MIG와 로드 밸런서를 결합한 서비스 구축 예제

## 시작하기

### 사전 요구사항

- Terraform v1.10 이상
- Google Cloud SDK
- Google Cloud 프로젝트 및 적절한 권한을 가진 서비스 계정

### 설치 및 사용

1. 이 저장소를 클론합니다:
   ```bash
   git clone https://github.com/your-username/terraform-google-module-basic-resources.git
   cd terraform-google-module-basic-resources
   ```

2. 원하는 예제 디렉토리로 이동합니다:
   ```bash
   cd examples/vpc-test
   ```

3. terraform.tfvars 파일을 생성하고 필요한 변수를 설정합니다.

4. Terraform 초기화 및 적용:
   ```bash
   terraform init -backend-config=backend.hcl
   terraform plan -var-file="terraform.tfvars"
   terraform apply -var-file="terraform.tfvars"
   ```

## 기여하기

1. 이 저장소를 포크합니다.
2. 새 브랜치를 생성합니다: `git checkout -b feature/your-feature-name`
3. 변경사항을 커밋합니다: `git commit -m 'Add some feature'`
4. 포크한 저장소에 푸시합니다: `git push origin feature/your-feature-name`
5. Pull Request를 생성합니다.

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.