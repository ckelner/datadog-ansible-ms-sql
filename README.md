# THIS IS A WORK IN PROGRESS - DOES NOT WORK AT THIS TIME

# datadog-ansible-ms-sql
Datadog + Ansible for Windows Servers running MS SQL.

# Provision
- [AWS Quickstart](https://docs.aws.amazon.com/quickstart/latest/sql/welcome.html)
  - Be sure to follow https://docs.aws.amazon.com/quickstart/latest/sql/step3.html
    - If you use defaults, when you use the RDGW you need to connect as `example\Admin`
- Or alternatively provision SQL servers manually using [AWS supplied AMIs](https://aws.amazon.com/windows/resources/amis/).
  - https://d1.awsstatic.com/whitepapers/RDS/Deploying_SQLServer_on_AWS.pdf

- Be sure to open port `3389` (RDP) and `5986` (Ansible win_ping) to your IP.

# Architecture
![arch](https://docs.aws.amazon.com/quickstart/latest/sql/images/sql-server-on-aws-architecture.png)

# Ansible
- http://docs.ansible.com/ansible/latest/intro_windows.html#windows-system-prep

## Target Servers
Be sure to prep windows servers for Ansible by following [these instructions](http://docs.ansible.com/ansible/latest/intro_windows.html#windows-system-prep).

## Credentials
Copy [group_vars/tmobile-manual.yml.example](./group_vars/tmobile-manual.yml.example) to `group_vars/tmobile-manual.yml` and fill in the necessary credentials.

## Inventory
Create an inventory file locally (e.g. `./inventory` which has been ignored in .gitignore [server ips could be commited to SCM if so desired if working in a private setting with a team larger than one]) and use it with the `-i <inventory-path>` when you run ansible, or update `/etc/ansible/hosts` on your machine. File should contain something akin to:

```
[tmobile-manual]
<ip/DNS>
<ip/DNS>
...
```

Test the connectivity to these servers: `ansible <inventory-group-name> -i <inventory-file> -m win_ping` which should result in something like:
```
<ip-address> | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
<ip-address> | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

# SQL Server
Failover: https://docs.aws.amazon.com/quickstart/latest/sql/step4.html

# Generate Load
There's a few scripts in the repo to do random things too. #TODO

- https://github.com/ErikEJ/SqlQueryStress
- https://www.brentozar.com/archive/2015/05/how-to-fake-load-tests-with-sqlquerystress/
- http://use-the-index-luke.com/sql/example-schema/sql-server/performance-testing-scalability

# Links
- https://gist.github.com/ckelner/c14812e83e5d78eac62c7e99c15c79af
- https://docs.datadoghq.com/integrations/faq/can-i-collect-sql-server-performance-metrics-beyond-what-is-available-in-the-sys-dm-os-performance-counters-table-try-wmi/
- https://docs.datadoghq.com/integrations/faq/how-to-retrieve-wmi-metrics/
- https://docs.datadoghq.com/integrations/faq/how-can-i-collect-more-metrics-from-my-sql-server-integration/
- http://wutils.com/wmi/root/cimv2/win32_perfformatteddata/
