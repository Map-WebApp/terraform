# MapApp DevSecOps - Terraform Infrastructure

Dự án này triển khai hạ tầng hoàn chỉnh cho ứng dụng Google Maps WebApp trên AWS sử dụng Terraform, tuân thủ nguyên tắc DevSecOps và Infrastructure as Code (IaC).

## Kiến trúc tổng quan

```
terraform/
├── backend.tf                     # Cấu hình backend S3 + DynamoDB
├── environments/                  # Cấu hình cho từng môi trường
│   ├── dev/                      # Môi trường Development
│   │   ├── main.tf               # Module calls cho DEV
│   │   ├── providers.tf          # Provider configuration
│   │   ├── variables.tf          # Variable definitions
│   │   ├── terraform.tfvars      # DEV environment values
│   │   └── outputs.tf            # DEV outputs
│   └── prod/                     # Môi trường Production
│       ├── main.tf               # Module calls cho PROD
│       ├── providers.tf          # Provider configuration
│       ├── variables.tf          # Variable definitions
│       ├── terraform.tfvars      # PROD environment values
│       └── outputs.tf            # PROD outputs
└── modules/                      # Reusable Terraform modules
    ├── vpc/                      # VPC, subnets, NAT, IGW
    ├── eks/                      # EKS cluster và node groups
    ├── iam/                      # IAM roles cho IRSA
    ├── databases/                # RDS, DocumentDB, Redis
    ├── efs/                      # EFS file system
    ├── keypair/                  # EC2 key pairs
    └── helm-releases/            # Helm charts deployment
```

## Đặc điểm chính

### Môi trường DEV (Cost-Optimized)
- **VPC**: Single NAT Gateway để tiết kiệm chi phí
- **EKS**: 2 nodes t3.medium 
- **RDS**: Single-AZ db.t4g.micro
- **DocumentDB**: 1 instance
- **Redis**: Single node, no replicas
- **CI/CD Tools**: Jenkins + ArgoCD được triển khai

### Môi trường PROD (High Availability)
- **VPC**: Multiple NAT Gateways across AZs
- **EKS**: 3 nodes t3.large với auto-scaling
- **RDS**: Multi-AZ db.t4g.small
- **DocumentDB**: 3-node cluster
- **Redis**: Primary + 2 replicas
- **Security**: Chỉ có infrastructure controllers, không có CI/CD tools

## Yêu cầu tiên quyết

1. **AWS CLI** được cấu hình với credentials
2. **Terraform** >= 1.5
3. **kubectl** để quản lý Kubernetes
4. **Helm** để quản lý Helm charts
5. **Tài khoản AWS** với quyền tạo VPC, EKS, RDS, DocumentDB, ElastiCache

## Cài đặt và triển khai

### Bước 1: Chuẩn bị Backend

Tạo S3 bucket và DynamoDB table cho Terraform state:

```bash
# Tạo S3 bucket (thay tên bucket cho duy nhất)
aws s3api create-bucket \
  --bucket mapapp-terraform-state-storage \
  --region ap-southeast-1 \
  --create-bucket-configuration LocationConstraint=ap-southeast-1

# Bật versioning cho bucket
aws s3api put-bucket-versioning \
  --bucket mapapp-terraform-state-storage \
  --versioning-configuration Status=Enabled

# Tạo DynamoDB table cho state locking
aws dynamodb create-table \
  --table-name mapapp-terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

### Bước 2: Triển khai môi trường DEV

```bash
# Di chuyển vào thư mục dev
cd terraform/environments/dev

# Cập nhật file terraform.tfvars với SSH key của bạn
# Thay thế giá trị public_key với SSH public key thực tế

# Khởi tạo Terraform
terraform init

# Xem plan trước khi apply
terraform plan -var-file="terraform.tfvars"

# Apply configuration
terraform apply -var-file="terraform.tfvars"
```

### Bước 3: Cấu hình kubectl cho DEV

```bash
# Cấu hình kubectl để kết nối cluster DEV
aws eks update-kubeconfig --region ap-southeast-1 --name mapapp-dev-eks

# Kiểm tra nodes
kubectl get nodes

# Kiểm tra pods trong các namespace
kubectl get pods -A
```

### Bước 4: Truy cập Jenkins và ArgoCD (DEV)

```bash
# Lấy thông tin Jenkins
kubectl get svc -n cicd

# Port-forward để truy cập Jenkins UI
kubectl port-forward svc/jenkins -n cicd 8080:8080

# Lấy mật khẩu admin Jenkins
kubectl get secret jenkins -n cicd -o jsonpath="{.data.jenkins-admin-password}" | base64 -d

# Lấy thông tin ArgoCD
kubectl get svc -n argocd

# Port-forward để truy cập ArgoCD UI  
kubectl port-forward svc/argocd-server -n argocd 8443:443

# Lấy mật khẩu admin ArgoCD
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
```

### Bước 5: Triển khai môi trường PROD (tùy chọn)

```bash
# Di chuyển vào thư mục prod
cd terraform/environments/prod

# Cập nhật terraform.tfvars cho production
# Đảm bảo sử dụng mật khẩu mạnh và SSH key cho production

# Khởi tạo Terraform
terraform init

# Xem plan trước khi apply
terraform plan -var-file="terraform.tfvars"

# Apply configuration (cần phê duyệt cẩn thận cho PROD)
terraform apply -var-file="terraform.tfvars"
```

## Quản lý và Bảo trì

### Kiểm tra trạng thái hạ tầng

```bash
# Xem outputs
terraform output

# Kiểm tra state
terraform show

# Validate cấu hình
terraform validate
```

### Cập nhật hạ tầng

```bash
# Luôn chạy plan trước
terraform plan -var-file="terraform.tfvars"

# Apply thay đổi
terraform apply -var-file="terraform.tfvars"
```

### Xóa hạ tầng (cẩn thận!)

```bash
# DEV environment
cd terraform/environments/dev
terraform destroy -var-file="terraform.tfvars"

# PROD environment (cần phê duyệt đặc biệt)
cd terraform/environments/prod
terraform destroy -var-file="terraform.tfvars"
```

## Bảo mật

### IAM Roles và IRSA
- Mỗi service sử dụng IAM Role riêng thông qua IRSA
- Tuân thủ nguyên tắc least privilege
- Không sử dụng AWS Access Keys tĩnh

### Network Security
- Tất cả databases nằm trong private subnets
- Security Groups hạn chế traffic theo nguyên tắc least access
- VPC có NAT Gateway cho outbound internet access

### Secrets Management
- Database passwords được mã hóa trong Terraform state
- Khuyến khích sử dụng AWS Secrets Manager hoặc HashiCorp Vault cho production
- SSH keys không được commit vào repository

## Monitoring và Logging

### Prometheus & Grafana (DEV)
```bash
# Kiểm tra Prometheus
kubectl get pods -n monitoring

# Truy cập Grafana (nếu được cài đặt)
kubectl port-forward svc/grafana -n monitoring 3000:80
```

### EKS Cluster Logs
```bash
# Xem logs của pods
kubectl logs -f <pod-name> -n <namespace>

# Xem events
kubectl get events --sort-by=.metadata.creationTimestamp
```

## Troubleshooting

### Lỗi thường gặp

1. **Terraform state lock**
   ```bash
   # Xóa lock nếu bị stuck (cẩn thận!)
   aws dynamodb delete-item \
     --table-name mapapp-terraform-state-lock \
     --key '{"LockID":{"S":"<lock-id>"}}'
   ```

2. **EKS nodes không join cluster**
   ```bash
   # Kiểm tra IAM roles và security groups
   kubectl get nodes
   kubectl describe node <node-name>
   ```

3. **Database connection issues**
   ```bash
   # Kiểm tra security groups
   aws ec2 describe-security-groups --group-ids <sg-id>
   
   # Test connectivity từ pod
   kubectl run test-pod --image=mysql:8.0 -it --rm -- mysql -h <endpoint> -u admin -p
   ```

4. **Helm releases fail**
   ```bash
   # Kiểm tra Helm releases
   helm list -A
   
   # Xem logs chi tiết
   kubectl describe pod <pod-name> -n <namespace>
   ```

## Kiến trúc chi phí

### DEV Environment (ước tính hàng tháng)
- EKS Cluster: $73
- EC2 Instances (2 x t3.medium): ~$60
- RDS MySQL (db.t4g.micro): ~$12
- DocumentDB (1 x db.t4g.medium): ~$50
- ElastiCache Redis (cache.t3.micro): ~$12
- NAT Gateway: ~$45
- **Total ước tính: ~$252/tháng**

### PROD Environment (ước tính hàng tháng)
- EKS Cluster: $73
- EC2 Instances (3 x t3.large): ~$190
- RDS MySQL Multi-AZ (db.t4g.small): ~$50
- DocumentDB (3 x db.r6g.large): ~$450
- ElastiCache Redis với replicas: ~$60
- NAT Gateways (3): ~$135
- **Total ước tính: ~$958/tháng**

## Đóng góp

1. Fork repository
2. Tạo feature branch
3. Commit changes
4. Push to branch
5. Tạo Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
