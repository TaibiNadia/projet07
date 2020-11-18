resource "aws_instance" "bastion" {
    ami = "ami-0e9073d7ac75f4491"
    availability_zone = "eu-west-3a"
    instance_type = "t2.micro"
    key_name = var.aws_key_name
    vpc_security_group_ids = [aws_security_group.bastion.id]
    subnet_id = aws_subnet.public.id
    associate_public_ip_address = true
    source_dest_check = false
    tags = {
        Name = "VPC Bastion"
    }
}
output "bastion_id" {
  value = aws_instance.bastion.id
  description = "The id of the bastion"
}
output "public_ip_bastion" {
   value = aws_instance.bastion.public_ip
   description = "The public IP of the bastion"
}

resource "aws_instance" "web" {
    ami = lookup(var.amis, var.aws_region)
    availability_zone = "eu-west-3a"
    instance_type = "t2.micro"
    key_name = var.aws_key_name
    vpc_security_group_ids = [aws_security_group.web.id]
    subnet_id = aws_subnet.public.id
    associate_public_ip_address = true
    source_dest_check = false
    tags = {
        Name = "Web Server"
    }
}
output "public_ip_web" {
  value = aws_instance.web.public_ip
  description = "The public IP of the web server"
}
output "name_web" {
  value = aws_instance.web.tags.Name
  description = "The Name of the web server"
}
output "state_web" {
  value = aws_instance.web.instance_state
  description = "The state of the web server" 
}

resource "aws_ami_from_instance" "web_ami" {
   name               = "web_ami"
   source_instance_id = aws_instance.web.id
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name          = "vpc_rds_subnet_group"
  description   = "Our main group of subnets"
  subnet_ids    = aws_subnet.private.*.id
}

resource "aws_db_instance" "db" {
    allocated_storage    = 20
    vpc_security_group_ids = [aws_security_group.db.id]
    storage_type         = "gp2"
    engine               = "mysql"
    engine_version       = "5.7"
    instance_class       = "db.t2.micro"
    name                 = "mydb"
    username             = "foo"
    password             = "hypersecret"
    parameter_group_name = "default.mysql5.7"
    db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.id
    tags = {
        Name = "DB Server"
    }
}
output "rds_instance_id" {
   value = aws_db_instance.db.id
   description = "The ID of the RDS instance"
}
output "rds_instance_address" {
   value = aws_db_instance.db.address
   description = "The address (aka hostname) of RDS instance"
}
output "rds_instance_endpoint" {
   value = aws_db_instance.db.endpoint
   description = "The endpoint (hostname:port) of the RDS instance"
}

