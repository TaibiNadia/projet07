resource "aws_launch_configuration" "web" {
    name                = "web-configuration"
    image_id            = aws_ami_from_instance.web_ami.id
    instance_type       = "t2.micro"
    security_groups     = ["aws_security_group.web.id"]
    associate_public_ip_address = true  
}

resource "aws_autoscaling_group" "web" {
   name                    = "web-asg"
   launch_configuration    = aws_launch_configuration.web.name
   vpc_zone_identifier     = ["aws_subnet.public.id"]
   min_size                = 1
   max_size                = 1
   desired_capacity        = 1
   target_group_arns       = ["aws_elb.lb.name"]

}

resource "aws_elb" "lb" {
    name = "web-loadbalancer"
    subnets = [aws_subnet.public.id]
    health_check {
        healthy_threshold = 2
        unhealthy_threshold = 2
        timeout = 5
        target = "HTTP:80/"
        interval = 30
    }
    listener {
        instance_port = 80
        instance_protocol = "http"
        lb_port = 80
        lb_protocol = "http"
    }
    cross_zone_load_balancing = true
    instances = [aws_instance.web.id]
    security_groups = [aws_security_group.loadbalancer.id]
    tags = {
        Name = "Web load balancer"
    }
}
