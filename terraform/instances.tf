resource "aws_instance" "bastion" {
    ami = "ami-0e9073d7ac75f4491"
    availability_zone = "eu-west-3a"
    instance_type = "t2.micro"
    key_name = var.aws_key_name
    vpc_security_group_ids = [aws_security_group.bastion.id]
    subnet_id = aws_subnet.public[0].id
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
output "bastion_public_ip" {
   value = aws_instance.bastion.public_ip
   description = "The public IP of the bastion"
}

resource "aws_instance" "web" {
    ami = lookup(var.amis, var.aws_region)
    availability_zone = "eu-west-3b"
    instance_type = "t2.micro"
    key_name = var.aws_key_name
    vpc_security_group_ids = [aws_security_group.web.id]
    subnet_id = aws_subnet.private[1].id
    associate_public_ip_address = false
    source_dest_check = false
    
//    provisioner "remote-exec" {
 //        #Install Python for Ansible
//         inline = ["sudo apt-get update && sudo apt-get install python"]
//
//         connection {
//             type                = "ssh"
//             user                = "ubuntu"
//             agent               = false
//             host                = aws_instance.web.private_ip
//             bastion_host        = aws_instance.bastion.public_ip
//             bastion_user        = "ubuntu"
//             bastion_private_key = file("../key_pair")
//             timeout             = "2m" 
//         }
//    }
//    provisioner "local-exec" {
//         command = "../ansible/ansible-playbook site.yml"
//    } 
    tags = {
        Name = "Web Server"
    }
}
output "web_id" {
  value = aws_instance.web.id
  description = "The public ID of the web server"
}
output "web_name" {
  value = aws_instance.web.tags.Name
  description = "The Name of the web server"
}
output "web_state" {
  value = aws_instance.web.instance_state
  description = "The state of the web server" 
}

resource "aws_ami_from_instance" "web_ami" {
   name               = "web-ami"
   source_instance_id = aws_instance.web.id
   tags = {
        Name = "Web AMI"
   }
}
output "web_ami_name" {
   value = aws_ami_from_instance.web_ami.name
   description = "The name of the web AMI"
}

output "web_ami_id" {
   value = aws_ami_from_instance.web_ami.id
   description = "The id of the web AMI"
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

