# Infrastructure As Code With Ansible + Terraform

![img](/images/iackadima.jpeg)

In this workshop I will take you through how to set up infrastructure with Terraform and how to configure it with Ansible. You will successfully set up a web server using code


## ​Prerequisites:

- ​Basic understanding of Linux system administration
- Familiarity with command-line interface (CLI)
- ​Some knowledge of YAML syntax (beneficial but not mandatory)

## ​Materials Needed:

- ​Personal laptop with SSH client installed
- ​Virtualization software (e.g., VirtualBox, VMware)
- ​Ansible installed (instructions will be provided)

## ​Workshop Objectives:
- Understand the concept of Infrastructure as Code (IaC) and its benefits.
- ​Learn the basics of Ansible and its role in implementing IaC.
- Explore practical use cases of Ansible for automating infrastructure tasks.
- Gain hands-on experience in writing Ansible playbooks to configure and manage infrastructure resources.
- ​Learn best practices and tips for effective infrastructure automation.

## Terraform Setup

This repository creates AWS resources using Terraform modules.

- Root files:
  - `main.tf` (provider, modules, and resource orchestration)
  - `variables.tf` (aws_region, aws_access_key, aws_secret_key)
  - `backend.tf` (S3 state backend config)
  - `outputs.tf` (public IPs, instance IDs, security group ID)

- Modules:
  - `modules/security_group`: creates an `aws_security_group` with ingress and egress rules.
  - `modules/instance`: creates an `aws_instance` and exports `id` and `public_ip`.

- `main.tf` uses `for_each` on `local.server_names` to provision multiple instances via a single module.

### Terraform commands

```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

### Backend and credentials

- State backend: `backend.tf` defines S3 backend, with optional DynamoDB locks.
- Credentials: use environment variables to avoid hard-coding:

```bash
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_DEFAULT_REGION="us-east-1"
```

## Ansible Setup

Ansible is used for configuration management on the provisioned servers.

- `playbook.yaml`: define playbook to install and configure web server components on EC2 hosts.
- `hosts`: inventory file listing target hosts (could be updated with Terraform output public IPs).

Typical workflow:

1. Provision infrastructure with Terraform.
2. Add instances to Ansible inventory (`hosts`).
3. Run Ansible playbook:

```bash
ansible-playbook -i hosts playbook.yaml
```

### Notes

- Ensure SSH access to EC2 instances is possible via key pair and ip access rules.
- In production, use dynamic inventory (e.g., `ec2.py`) instead of static `hosts` file.

## Connect With Me

- [LinkedIn](https://www.linkedin.com/in/kadima-samuel-804103bb/)