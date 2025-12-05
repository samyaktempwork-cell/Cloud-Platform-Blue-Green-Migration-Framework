#  Rapid7 Insight Agent → Qualys Cloud Agent Migration (Full Module Documentation)

This module performs a complete, enterprise-grade migration from **Rapid7 Insight Agent** to **Qualys Cloud Agent** on Linux instances.

It includes:
-  Terraform migration wrapper (ASG + Launch Template + IAM)
-  Chef migration cookbook (remove Rapid7 → install Qualys → validate)
-  Userdata bootstrap pipeline (first-boot execution)
-  Logging + Status Tracking framework
-  InSpec migration validation
-  Full Blue/Green rollout compatibility

---

#  Module Structure

```
rapid7-to-qualys/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── userdata.tpl
│   ├── dev/dev.tfvars
│   ├── stage/stage.tfvars
│   └── prod/prod.tfvars
│
├── chef/
│   ├── cookbooks/
│   │   └── rapid7_to_qualys/
│   │       ├── attributes/default.rb
│   │       ├── recipes/
│   │       │     ├── logging.rb
│   │       │     ├── remove_rapid7.rb
│   │       │     ├── install_qualys.rb
│   │       │     ├── validate.rb
│   │       │     └── default.rb
│   │       ├── libraries/helpers.rb
│   │       ├── files/default/collect_logs.sh
│   │       └── templates/default/logrotate_migration.erb
│   │
│   ├── roles/rapid7_to_qualys.json
│   └── data_bags/agents/
│         ├── rapid7.json
│         └── qualys.json
│
├── inspec/
│   └── migration_status.rb
│
└── README.md
```

---

#  1. Overview

This module automates the secure replacement of the Rapid7 agent with the Qualys Cloud Agent inside AWS EC2 instances.

##  Capabilities
-  Detect & remove Rapid7
-  Install Qualys agent
-  Register using activation + customer ID
-  Validate service + connectivity
-  Structured migration status JSON
-  Full logging under `/opt/migration/logs`
-  ASG Blue/Green rollout compatible

---

#  2. Terraform Integration (Phase 6)

Terraform is responsible for:

- Creating a new Launch Template  
- Injecting the `userdata.tpl`  
- Creating IAM runtime role  
- Applying Blue/Green ASG rollout  
- Passing activation/customer IDs  
- Ensuring Chef migration runs on boot  

### Usage

```
terraform init
terraform apply -var-file=dev/dev.tfvars
```

---

#  3. Userdata Pipeline (Phase 6)

At first boot:

1. Installs Chef (if not pre-baked) ✔  
2. Creates:

```
/etc/chef/client.rb
/etc/chef/first-boot.json
/opt/migration/logs
/opt/migration/status
```

3. Runs:
```
chef-client -z -j /etc/chef/first-boot.json
```

4. Writes:
```
/opt/migration/status/rapid7_to_qualys.json
```

5. Logs everything to:
```
/opt/migration/logs/migration.log
```

This ensures repeatable, observable migration.

---

#  4. Chef Migration Cookbook (Phase 4)

### remove_rapid7.rb
- Stops `ir_agent`
- Runs Rapid7 uninstall script if present  
- Cleans agent directory  
- Logs each step  

### install_qualys.rb
- Downloads Qualys agent RPM  
- Installs agent  
- Activates via:
```
ActivationId=<id> CustomerId=<id>
```
- Ensures `qualys-cloud-agent` runs  

### validate.rb
- Waits for service to become active  
- Performs retries  
- Logs success or failure  
- Writes status JSON  

### logging.rb (Phase 7)
- Sets up directories  
- Adds log rotation  
- Installs `collect_logs.sh`  
- Sets systemd timer for periodic log archiving  

### default.rb (execution order)
```
logging → remove_rapid7 → install_qualys → validate
```

---

#  5. Logging Framework (Phase 7)

###  Log Directory
```
/opt/migration/logs/migration.log
```

###  Status Directory
```
/opt/migration/status/rapid7_to_qualys.json
```

###  Log Rotation
Located at:
```
/etc/logrotate.d/migration
```

###  Log Collector Script
```
/opt/migration/bin/collect_logs.sh
```

Features:
- Archives logs to `/tmp/migration-logs-<timestamp>.tar.gz`  
- Optionally uploads to S3  
- Never breaks pipeline if AWS CLI missing  

---

#  6. Migration Status File

Example:

```json
{
  "module": "rapid7_to_qualys",
  "env": "dev",
  "timestamp": "2025-12-06T10:23:52Z",
  "status": "success",
  "chef_exit_code": 0
}
```

Possible values for `status`:
- `"success"`
- `"failed"`

The file is consumed by:
- Terraform observers  
- InSpec tests  
- Migration orchestrator (future feature)  

---

#  7. InSpec Validation (Phase 7)

```
inspec exec inspec/
```

Validates:

- Status file exists  
- Status equals `"success"`  
- Qualys service is active  
- Migration logs exist and non-empty  

---

#  8. Migration Execution Flow

### Dev:
```
terraform apply -var-file=dev/dev.tfvars
```

Validate:
```
cat /opt/migration/status/rapid7_to_qualys.json
systemctl status qualys-cloud-agent
```

### Stage:
Move same config to stage tfvars.

### Prod:
Use ASG rolling update or Blue/Green deployment.

---

#  9. Rollback Strategy

Rollback is simple:

- Revert Launch Template to Rapid7-enabled version  
- Revert traffic to Blue ASG  
- Destroy Green ASG  

No agent-level rollback required.

---

#  Security Notes

- Do NOT store Qualys secrets directly in Git  
- Data Bags contain placeholders only  
- Production migration uses Secrets Manager or SSM  
- IAM policy included here is dev-safe (broad) — lock down for prod  

---

#  Future Enhancements

- Qualys heartbeat API validation  
- Automatic batch rollout  
- Centralized S3/DynamoDB migration report store  
- Migration orchestration engine module  
- Structured JSON logging  

---

#  Summary

This module provides a full, automated, observable, and extensible migration workflow from Rapid7 Insight Agent to Qualys Cloud Agent using:

- Terraform  
- AWS ASG Blue/Green pattern  
- Chef local-mode automation  
- Logging & status tracking  
- Validation logic  
- Rollback readiness  

It is designed for real enterprise migration scenarios at scale.

