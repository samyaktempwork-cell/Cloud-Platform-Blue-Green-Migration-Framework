#  Chef Code for Rapid7 → Qualys Migration

Contains all Chef logic needed to remove Rapid7 and install + activate Qualys.

##  Structure

    chef/
    ├── cookbooks/
    ├── roles/
    └── data_bags/

##  Components

- **Cookbooks**: migration logic  
- **Roles**: run_list entrypoint  
- **Data Bags**: agent metadata (no secrets)  

##  Execution Flow

1. Chef-client runs in local mode  
2. Rapid7 removal  
3. Qualys install + activation  
4. Validation  
5. Status markers written  

##  Future Improvements

- Rollback  
- Log rotation  
- Heartbeat API verification  
