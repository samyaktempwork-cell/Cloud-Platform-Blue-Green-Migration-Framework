
# Platform Migrations – Blue/Green Modernization Project
### AWS | Terraform | Packer | Chef | GitHub Actions

This folder contains the **production-ready implementation** of the Cloud Platform
Blue/Green Migration Framework.

It demonstrates **four enterprise migration scenarios**:

1. **Rapid7 → Qualys** (Security Agent Migration)  
2. **Datadog → Sumo Logic** (Observability Migration)  
3. **Filebeat → Sumo Logic** (Logging Pipeline Migration)  
4. **Legacy Chef InSpec → Standardized Profiles** (Compliance Modernization)

All migrations are performed using a shared **Base Infrastructure Layer** and a unified
**Blue/Green rollout engine**.

---

##  Structure

```
platform-migrations/
│
├── baseline-infra/                 # Core AWS infra (VPC, ALB, ASG blue/green, Packer base AMI)
│
├── migrations/
│   ├── rapid7-to-qualys/
│   ├── datadog-to-sumologic/
│   ├── filebeat-to-sumologic/
│   └── inspec-modernization/
│
├── ci-cd/
│   ├── github-actions/
│   └── scripts/
│
├── diagrams/
│
└── docs/
```

---

##  Base Infrastructure Includes

- Multi-account AWS support  
- S3 + DynamoDB backend for Terraform state  
- VPC module  
- ALB module  
- ASG Blue/Green module  
- Packer base AMI (Amazon Linux 2023 + Chef Client)  
- Base Chef cookbooks  

This layer is **static** and reused by all future migrations.

---

##  Migration Modules

Each migration follows the same pattern:

1. Build Green AMI with Packer  
2. Deploy Green environment via Terraform  
3. Configure with Chef cookbooks  
4. Validate with InSpec & dashboards  
5. Switch ALB to Green  
6. Destroy Blue  

Migration folders contain:

- Packer templates  
- Chef cookbooks  
- Terraform modules  
- Validation SOPs  
- Rollback playbooks  

---

##  Goal

This project simulates a real enterprise platform journey and is suitable for:

- DevOps interviews  
- SRE/Platform engineering roles  
- Architecture portfolios  
- Cloud automation learning  
- Migration design demos  
