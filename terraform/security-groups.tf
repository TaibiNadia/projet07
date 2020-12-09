resource "aws_security_group" "bastion_SG" {
  vpc_id      = aws_vpc.main_vpc.id
  name        = "Bastion Security Group"
  description = "Bastion Security Group"

  tags = {
    Name = "Bastion_SG"
  }
}

resource "aws_security_group_rule" "http_to_bastion_ingress_rule" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion_SG.id
}
resource "aws_security_group_rule" "bastion_allow_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion_SG.id
}


resource "aws_security_group" "web_SG" {
  vpc_id      = aws_vpc.main_vpc.id
  name        = "web Security Group"
  description = "web Security Group"

  tags = {
    Name = "Web_SG"
  }
}
resource "aws_security_group_rule" "lb_to_web_ingress_rule" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.loadbalancer_SG.id
  security_group_id        = aws_security_group.web_SG.id
}
resource "aws_security_group_rule" "bastion_to_web_ingress_rule" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_SG.id
  security_group_id        = aws_security_group.web_SG.id
}
resource "aws_security_group_rule" "web_allow_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_SG.id
}


resource "aws_security_group" "db_SG" {
  vpc_id      = aws_vpc.main_vpc.id
  name        = "db Security Group"
  description = "db Security Group"

  tags = {
    Name = "DB_SG"
  }
}
resource "aws_security_group_rule" "web_to_db_ingress_rule" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web_SG.id
  security_group_id        = aws_security_group.db_SG.id
}
resource "aws_security_group_rule" "bastion_to_db_ingress_rule" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_SG.id
  security_group_id        = aws_security_group.db_SG.id
}

resource "aws_security_group_rule" "rds_allow_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.db_SG.id
}


resource "aws_security_group" "loadbalancer_SG" {
  vpc_id      = aws_vpc.main_vpc.id
  name        = "loadbalancer Security Group"
  description = "loadbalancer Security Group"

  tags = {
    Name = "LB_SG"
  }
}
resource "aws_security_group_rule" "http_to_lb_ingress_rule" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.loadbalancer_SG.id
}

resource "aws_security_group_rule" "bastion_to_lb_ingress_rule" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_SG.id
  security_group_id        = aws_security_group.loadbalancer_SG.id
}
resource "aws_security_group_rule" "lb_allow_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.loadbalancer_SG.id
}
