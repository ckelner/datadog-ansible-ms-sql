# datadog-ansible-ms-sql
Datadog + Ansible for Windows Servers running MS SQL

# Provision
[AWS Quickstart](https://docs.aws.amazon.com/quickstart/latest/sql/welcome.html)
Or alternatively provision SQL servers manually using [AWS supplied AMIs](https://aws.amazon.com/windows/resources/amis/).

- Be sure to open port `3389` (RDP) and `5986` (Ansible win_ping) to your IP.

# Architecture
![arch](https://docs.aws.amazon.com/quickstart/latest/sql/images/sql-server-on-aws-architecture.png)

# Ansible
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
