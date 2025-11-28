# Cloud Platform Blue/Green Migration Framework  
### Security, Observability & Compliance Modernization on AWS (Terraform, Packer, Chef)

This project demonstrates a **real-world enterprise migration framework** where core AWS infrastructure remains unchanged (Terraform, Packer, Chef Server), while multiple platform components are modernized using a **Blue/Green migration strategy**.

It includes **four realistic migrations**, all automated and orchestrated across AWS:

- **Rapid7 ➜ Qualys** (Vulnerability Management)
- **Datadog ➜ Sumo Logic** (Observability: Metrics, APM, Logs)
- **Filebeat ➜ Sumo Logic** (Logging Pipeline)
- **Legacy Chef InSpec ➜ Modernized Org-Level Compliance Profiles**

This repository is designed as a **production-like, end-to-end platform engineering project** that demonstrates:
- Infrastructure-as-Code (Terraform)
- Immutable Infrastructure (Packer AMIs)
- Configuration Management (Chef Server)
- Blue/Green release strategy
- CI/CD automation
- Agent lifecycle management
- Migration validation steps
- Rollback strategy

---

##  Architecture Overview

### **Static Baseline Infrastructure**
These components remain unchanged and act as the foundation:
- **AWS** (VPC, EC2, ALB/Target Groups, ASG)
- **Terraform** (IaC for environment provisioning)
- **Packer** (AMI builds)
- **Chef Server** (configuration management)

---

##  Blue/Green Migration Flow  
All migrations follow this standardized flow:

1. **Packer builds a new Green AMI**
   - Removes Rapid7, Datadog, Filebeat  
   - Installs Qualys agent  
   - Installs Sumo Logic collector  
   - Updates logging paths  
   - Includes InSpec wrapper & new profiles  

2. **Terraform creates Green ASG**
   - Tags: `color=green`  
   - Env: dev → stage → prod  
   - Chef bootstraps on instance startup  

3. **Chef configures agents on Green nodes**
   - Qualys activation  
   - Sumo sources, dashboards  
   - Application log configuration  

4. **InSpec runs compliance profiles**
   - CIS benchmarks  
   - Org-specific hardening  
   - Application security checks  

5. **Validation**
   - Qualys dashboard detects new assets  
   - Sumo logs & metrics visible  
   - InSpec passes on Green nodes  

6. **Traffic Shift**
   - ALB/ELB target group updated → Green ASG  

7. **Blue Decommission**
   - Terraform scales Blue ASG to zero  
   - Old AMIs & agents removed  

---

##  Repository Structure (Suggested)

```
platform-migrations/
├── README.md
├── docs/
├── diagrams/
├── terraform/
├── packer/
├── chef/
└── inspec/
```

---

##  Migration Modules

### **1. Rapid7 → Qualys**
- Remove Rapid7 agent  
- Install & activate Qualys agent  
- Asset tagging validation  

### **2. Datadog → Sumo Logic**
- Remove Datadog  
- Install Sumo Logic collector  
- Configure dashboards, log & metric sources  

### **3. Filebeat → Sumo Logic**
- Remove Filebeat  
- Route logs through Sumo collector  
- Line-count and ingestion validation  

### **4. InSpec Modernization**
- New CIS + organizational profiles  
- Automated InSpec runs during Green testing  

---

##  Usage Flow

```
packer build packer/templates/app-green.json
terraform apply terraform/envs/dev
validate → shift traffic → promote AMI
terraform apply stage → prod
```

---

##  Rollback Strategy

If validation fails:

1. Switch ALB back to Blue  
2. Destroy Green ASG  
3. Fix cookbooks / AMI issues  
4. Rebuild Green v2  
5. Retry rollout  

---

##  Summary

This project is a **production-ready blueprint** for modernizing:  
- Security Agents  
- Observability Stacks  
- Logging Pipelines  
- Compliance Scanning  

Using **AWS + Terraform + Packer + Chef + Blue/Green**.

It demonstrates senior-level DevOps / Platform Engineering capabilities end-to-end.
