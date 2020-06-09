# Description
This role add Prometheus elasticsearch_exporter to CentOS systems with initd and systemd services.

# Run
See: https://docs.ansible.com/ansible/2.5/user_guide/playbooks_reuse_roles.html#using-roles

# GitHub project
https://github.com/justwatchcom/elasticsearch_exporter/



# hosts.yaml example 
```
---
[elastic.di.prod]
elastic01.dc66.di.prod
elastic02.dc66.di.prod
elasticmaster01.dc66.di.prod
elasticmaster02.dc66.di.prod
elasticmaster03.dc66.di.prod
```

# ➜ run.yaml example ✗ cat ../prometheus_elasticsearch_exporter.yaml 
```
---
- hosts: elastic.di.prod
  gather_facts: True
  roles:
    - role: prometheus_elasticsearch_exporter
```

