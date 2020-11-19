resource "aws_launch_configuration" "web-config" {
    name                = "web-configuration"
    image_id            = aws_ami_from_instance.web_ami.id
    instance_type       = "t2.micro"
    security_groups     = [aws_security_group.web.id]
    
    lifecycle {
       create_before_destroy = true
    }  
}

resource "aws_autoscaling_group" "web-asg" {
   name                    = "web-asg"
   launch_configuration    = aws_launch_configuration.web-config.name
   vpc_zone_identifier     = [aws_subnet.public.id]
   min_size                = 1
   max_size                = 2
   desired_capacity        = 1
   load_balancers          = [aws_alb.web-alb.name]
}

resource "aws_alb" "web-alb" {
    name            = "web-loadbalancer"
    security_groups = [aws_security_group.loadbalancer.id]
    subnets = [aws_subnet.public.id]

    tags = {
      Name = "web-loadbalancer"
    }
}

resource "aws_alb_target_group" "web-alb-target-group" {
    name          = "web-alb-target-group"
    vpc_id        = aws_vpc.main_vpc.id
    port          = "80"
    protocol      = "HTTP"

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
      Name = "alb-web-target-group"
    }
}

resource "aws_alb_listener" "web-alb-listener" {
    load_balancer_arn      = aws_alb.web-alb.arn 
    port                   = 80
    protocol               = "HTTP"     
    default_action {
        target_group_arn = aws_alb_target_group.web-alb-target-group.arn
        type             = "forward" 
    }
}
