
# Terraform Remote State Backend (Shared Services)

This module creates the **S3 bucket + DynamoDB lock table** used as a centralized Terraform
remote backend for the entire Cloud Platform Blue/Green Migration Framework.

It follows **enterprise multi-account patterns**, where the shared-services account manages
state storage and locking, and workload accounts (dev, stage, prod) assume roles to access it.

---
Q
##  Resources Created

### 1. **S3 Bucket for Terraform State**
- Stores terraform `.tfstate` files
- Versioning enabled (keeps history of every change)
- Server-side encryption (`AES256`)
- Protected from accidental deletion using `prevent_destroy`
- Tagged for cost and audit visibility

### 2. **DynamoDB Table for Terraform Locking**
- Prevents concurrent `terraform apply`
- Required for safe automated CI/CD pipelines
- Hash key: `LockID`
- On-demand pricing (PAY_PER_REQUEST)

---

##  Folder Structure

```
baseline-infra/
└── terraform/
    └── global/
        └── backend-s3-dynamodb/
            ├── main.tf
            ├── variables.tf
            ├── outputs.tf
            └── README.md
```

---

##  How to Deploy This Backend

>  Run this **once manually** before enabling any Terraform environments.

### **1. Initialize Terraform**
```
terraform init
```

### **2. Review Plan**
```
terraform plan
```

### **3. Apply**
```
terraform apply
```

This will output:

- `backend_bucket_name`
- `dynamodb_lock_table`

Use these in:

```
accounts/dev/backend.tf
accounts/stage/backend.tf
accounts/prod/backend.tf
```

---

##  Why Use a Shared Services Backend?

| Benefit | Description |
|--------|-------------|
| **Security** | Terraform state stored in a locked-down account |
| **Separation of Duties** | Dev/Stage/Prod cannot modify backend infra |
| **Cross-Account CI/CD** | GitHub Actions assumes role into each environment |
| **Versioning Safety** | Automatic recovery through versioned S3 objects |
| **Enterprise-Grade Workflow** | Mirrors real-world cloud platform setups |

---

##  Required IAM Permissions

### S3
- `s3:CreateBucket`
- `s3:PutBucketVersioning`
- `s3:PutEncryptionConfiguration`
- `s3:PutBucketTagging`

### DynamoDB
- `dynamodb:CreateTable`
- `dynamodb:DescribeTable`
- `dynamodb:PutItem`

---

## 🧾 Example Output

```
backend_bucket_name = "cloudplatform-tfstate-shared"
dynamodb_lock_table = "tf-state-locks"
```

---

##  Status

✔️ Ready  
⬜ Wire into environment backends  
⬜ Link CI/CD workflows  
⬜ Validate cross-account access  

---

##  Summary

This backend is the **foundation** for:

- Secure Terraform state management  
- Blue/Green infra deployment  
- Multi-account environment automation  