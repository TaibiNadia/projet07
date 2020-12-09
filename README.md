Requirements:
- Terraform
- Ansible
- AWS

The purpose is to automate the creation of the infrastructure and the setup of the latest wordpress application, creating a fully operational AWS VPC network (subnets, routing tables, igw, etc), it will also create everything that need to be for creating EC2 and RDS instances (security key, security group, subnet group).

It will also create the Elastic Load Balancer and add the EC2 instance(s) automatically that were created using ansible playbook.

#####Resources:
- Create a VPC with 4x VPC subnets (2x public and 2x private) in different AZ zones inside the AWS region
- Create one specific security group for Bastion only accesible on port 22
- Create one specific security group for EC2 wordpress only accessible from load balancer or bastion
- Create one specific security group for rds 3306 (from EC2 instances and not from public internet facing, only from vpc)
- Create one specific security group for load balancer on port 80
- Provision ec2 instances with default ubuntu 18.04 LTS ami in 2 different private AZ
- Provision one RDS instance in private subnets
- Launch and configure public facing VPC LB (cross_az_load_balancing) and attach VPC subnets
- Register EC2 instances on LB

#####Tools used:
```
ansible --version
ansible 2.9.6
```
```
terraform version
Terraform v0.12.24
```
Before using the terraform, we need to export AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY as environment variables:

export AWS_ACCESS_KEY_ID="xxxxxxxxxxxxxxxx"
export AWS_SECRET_ACCESS_KEY="yyyyyyyyyyyyyyyyyyyy"

or use it with AWS CLI configuration.

#####1. Infrastructure:

Initialize terraform: 
```
cd terraform 
terraform init
```

Check config variables at terraform/variables.yml

To generate and show an execution plan (dry run): 
```
terraform plan
```

You can select one of ubuntu images from Ubuntu Amazon EC2 AMI Locator, based on your aws region and edit in terraform/variables.yml

To build or makes actual changes in infrastructure: 
```
terraform apply
```

To inspect Terraform state or plan: 
```
terraform show
```

To destroy Terraform-managed infrastructure: 
```
terraform destroy
```

Note: Terraform stores the state of the managed infrastructure from the last time Terraform was run. Terraform uses the state to create plans and make changes to the infrastructure.

Once the Terraform create all the resources over AWS, it will use ansible to install the wordpress over the EC2 instance(s).

#####2. Ansible

Change database DB_HOSTNAME in ansible/site.yml 
Change bastion IP address and web IP address in ansible/inventory.yml
Change bastion IP address in ansible/ssh.cfg

###### Play-book:
Install the nginx: nginx.yml
Install PHP7.2-FPM with modules: php7.yml
Install wordpress: deploy.yml

ansible-playbook site.yml

###### Use custom connexion 

`ssh -F ./ansible/ssh.cfg xx.xx.xx.xx`

###### Launch Ansible
```
ansible-playbook site.yml
```
