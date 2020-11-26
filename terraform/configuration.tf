resource "aws_launch_configuration" "web-config" {
    name                = "web-configuration"
    image_id            = aws_ami_from_instance.web_ami.id
    instance_type       = "t2.micro"
    security_groups     = [aws_security_group.web.id]

    lifecycle {
       create_before_destroy = true
    }  
}

resource "aws_autoscaling_group" "web-asgroup" {
   name                    = "web-auto-scaling-group"
   launch_configuration    = aws_launch_configuration.web-config.name
   vpc_zone_identifier     = [aws_subnet.public[0].id, aws_subnet.public[1].id]  
   min_size                = 1
   max_size                = 2
   desired_capacity        = 1
   target_group_arns       = [aws_lb_target_group.web-lb-target-group.arn]
}

resource "aws_lb" "web-lb" {
    name            = "web-loadbalancer"
    security_groups = [aws_security_group.loadbalancer.id]
    subnets         = [aws_subnet.public[0].id, aws_subnet.public[1].id]     

    tags = {
      Name = "WEB-LOBA"
    }
}

resource "aws_lb_target_group" "web-lb-target-group" {
    name          = "web-loadbalancer-target-group"
    vpc_id        = aws_vpc.main_vpc.id
    port          = "80"
    protocol      = "HTTP"
    lifecycle {
        create_before_destroy = true
    }
    health_check {
        healthy_threshold   = 2
        unhealthy_threshold = 2
        interval            = 30
        matcher             = 200
        path                = "/"
        port                = 80
        protocol            = "HTTP"
        timeout = 5
    }
    tags = {
      Name = "WEB-LB-TG"
    }
}

resource "aws_lb_listener" "web-lb-listener-http" {
    load_balancer_arn      = aws_lb.web-lb.arn 
    port                   = 80
    protocol               = "HTTP"     

    default_action {
        target_group_arn = aws_lb_target_group.web-lb-target-group.arn
        type             = "forward" 
    }
}
 
