# Terraform Environments – README

This directory contains **environment-level Terraform configurations** for the Cloud Platform Blue-Green Migration Framework.

Each environment folder (dev, stage, prod) contains its own remote backend configuration and variable definitions:

- `backend.hcl` – Remote state backend for that environment  
- `<env>.tfvars` – Environment-specific configuration values  
- *(Optional)* `main.tf` – Thin wrapper for local execution (ci/cd uses root-level main.tf)

This ensures each environment remains completely isolated and independently deployable while sharing the same Terraform core modules at the root level.

---

##  Folder Structure

```
env/
├── dev/
│   ├── backend.hcl
│   └── dev.tfvars
│
├── stage/
│   ├── backend.hcl
│   └── stage.tfvars
│
└── prod/
    ├── backend.hcl
    └── prod.tfvars
```

---

##  Purpose of Environment Folders

### ✔ Clean separation of environments  
Each environment uses separate:
- Terraform state  
- Variables  
- IAM roles  
- CIDR blocks  
- AMIs (blue/green)  
- Instance sizes  

### ✔ No duplication of infra logic  
All module wiring stays in the root-level `main.tf`.

### ✔ Multi-account AWS support  
Each environment assumes a different IAM role using GitHub Actions.

---

##  Deploying an Environment

Move to the Terraform root directory:

```
cd platform-migrations/baseline-infra/terraform
```

###  Deploy DEV Environment

```
terraform init -backend-config=env/dev/backend.hcl
terraform apply -var-file=env/dev/dev.tfvars
```

###  Deploy STAGE Environment

```
terraform init -backend-config=env/stage/backend.hcl
terraform apply -var-file=env/stage/stage.tfvars
```

###  Deploy PROD Environment

```
terraform init -backend-config=env/prod/backend.hcl
terraform apply -var-file=env/prod/prod.tfvars
```

---

##  Required GitHub Secrets for CI/CD

GitHub Actions uses environment-specific IAM AssumeRole values:

```
DEV_IAM_ROLE
STAGE_IAM_ROLE
PROD_IAM_ROLE
```

Example in Actions:

```
role-to-assume: ${{ secrets.DEV_IAM_ROLE }}
```

---

##  Architectural Benefits

This structure enables:

- Multi-account isolation  
- Clean and scalable infra structure  
- Zero code duplication  
- Blue/Green support for every environment  
- Safe promotion model (dev → stage → prod)  
- GitOps-ready pipelines (matrix mode)  

---