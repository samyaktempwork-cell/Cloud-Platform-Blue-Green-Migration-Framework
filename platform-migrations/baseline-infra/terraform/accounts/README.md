# Terraform Accounts – README

This directory contains **account-level Terraform configurations** for the Cloud Platform Blue-Green Migration Framework.

Each AWS account (`dev`, `stage`, `prod`, `shared-services`) has its own isolated Terraform configuration folder containing:

- `backend.tf` – Remote state backend for that account  
- `main.tf` – Module wiring for account-specific resources  
- `variables.tf` – Inputs required for that account  
- `outputs.tf` – Account-relevant outputs  

This mirrors how **large enterprises structure multi-account AWS environments**, ensuring:
- Full account isolation  
- Independent deployments  
- Least-privilege IAM boundaries  
- Predictable CI/CD pipelines  
- Clear lifecycle separation (bootstrap vs workload infra)

---

##  Folder Structure

```
accounts/
├── README.md
│
├── dev/
│   ├── backend.tf
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── stage/
│   ├── backend.tf
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── prod/
│   ├── backend.tf
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
└── shared-services/
    ├── backend.tf
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

---

#  Purpose of Each Account

##  DEV Account
Used for:
- Testing Terraform modules  
- Validating AMI builds  
- Early-stage migration testing (Rapid7 → Qualys, Datadog → Sumo, Filebeat → Sumo)  
- Safely experimenting with Blue/Green rollout  

Contains:
- VPC  
- ALB  
- ASG Blue/Green  
- IAM roles  
- SGs  

---

##  STAGE Account
Used for:
- Pre-production validation  
- QA  
- Canary-style Blue/Green rollout testing  
- Staging of new AMIs before promoting to prod  

Mirrors prod but allows slightly more open CIDRs.

---

##  PROD Account
Used for:
- Production application workloads  
- Business-critical uptime  
- Hardened security posture  
- Restricted traffic  
- Final Blue/Green cutover  

Includes:
- Production VPC  
- Strict ALB + SG rules  
- Larger ASG capacity  
- Dedicated IAM assume-role  

---

##  SHARED-SERVICES Account
This account holds **global platform resources**, typically:

- Terraform backend (S3 + DynamoDB)  
- IAM cross-account roles  
- Organization guardrails (optional future scope)  
- CloudTrail, Config, GuardDuty, KMS keys (future)  

It does **not** include application workloads.

---

#  File Responsibilities

## `backend.tf`
Specifies where the Terraform state for this account is stored:

```
terraform {
  backend "s3" {
    bucket         = "YOUR_BACKEND_BUCKET"
    key            = "dev/base-infra/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "tf-state-locks"
    encrypt        = true
  }
}
```

Each account uses a **unique key** in the S3 bucket.

---

## `main.tf`
Defines which Terraform modules run in this account.

Example (dev/stage/prod):
- VPC  
- Security groups  
- ALB  
- ASG Blue/Green  
- IAM roles  

Example (shared-services):
- IAM roles  
- Backend infra (if needed)  
- Logging guardrails  

---

## `variables.tf`
Account-specific configuration such as:

- AWS account role ARN  
- AMI IDs  
- CIDR blocks  
- SSH/HTTP CIDRs  
- Desired ASG capacity  

---

## `outputs.tf`
Useful values after deployment:

- VPC ID  
- ALB DNS  
- ASG names  
- IAM instance profile  

---

#  Deploying Any Account

Navigate into the correct account folder, then:

```
terraform init
terraform plan
terraform apply
```

Because each account has its own backend and variables, no flags are required.

---

#  Required GitHub Secrets for CI/CD

Each account requires a role for GitHub Actions:

```
DEV_IAM_ROLE
STAGE_IAM_ROLE
PROD_IAM_ROLE
SHARED_SVCS_IAM_ROLE
```

These are used by the Terraform CI/CD pipeline via:

```
role-to-assume: ${{ secrets.DEV_IAM_ROLE }}
```

---

#  Enterprise Architecture Benefits

This structure allows:

- Fully isolated AWS accounts  
- Clear account bootstrap vs environment infra  
- Zero cross-account state pollution  
- GitOps-friendly multi-account pipelines  
- Predictable disaster recovery  
- Easy extension for new accounts (UAT, DR, sandbox)  

---