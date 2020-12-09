resource "aws_instance" "bastion" {
  ami                         = "ami-00373688fb7818d45"
  availability_zone           = "eu-west-3a"
  instance_type               = "t2.micro"
  key_name                    = var.aws_key_name
  vpc_security_group_ids      = [aws_security_group.bastion_SG.id]
  subnet_id                   = aws_subnet.public[0].id
  associate_public_ip_address = true
  source_dest_check           = false
  tags = {
    Name = "Bastion"
  }
}
output "bastion_public_ip" {
  value       = aws_instance.bastion.public_ip
  description = "The public IP of the bastion"
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "vpc_rds_subnet_group"
  description = "Our main group of subnets"
  subnet_ids  = aws_subnet.private.*.id
}

resource "aws_db_instance" "db" {
  allocated_storage      = 20
  vpc_security_group_ids = [aws_security_group.db_SG.id]
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  name                   = "mydb"
  username               = "foo"
  password               = "hypersecret"
  parameter_group_name   = "default.mysql5.7"
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.id
  tags = {
    Name = "DB Server"
  }
}
output "rds_instance_address" {
  value       = aws_db_instance.db.address
  description = "The address (aka hostname) of RDS instance"
}

