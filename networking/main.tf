#------networking/main.tf--------


data "aws_availability_zones" "available" {}

resource "aws_vpc" "tf_vpc" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    enable_dns_support    = true

    tags {
       Name = "tf_vpc_marius"

 }
}

resource "aws_internet_gateway" "tf_internet_gateway" {
    vpc_id = "${aws_vpc.tf_vpc.id}"

    tags {
         Name = "tf_igw_marius"
 }
}

resource "aws_route_table" "tf_public_rt" {
    vpc_id = "${aws_vpc.tf_vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.tf_internet_gateway.id} "
 }
    tags {
        Name = "tf_public_marius"
 }
}
resource "aws_default_route_table" "tf_private_rt" {
     default_route_table_id = "${aws_vpc.tf_vpc.default_route_table_id}"
     tags {
         Name = "tf_private_marius"
 }
}

resource "aws_subnet" "tf_public_subnet" {
     count = 3
     vpc_id = "${aws_vpc.tf_vpc.id}"
     cidr_block = "${var.public_cidrs[count.index]}"
     map_public_ip_on_launch = true
     availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
     tags {
         Name = "tf_public_${count.index + 1}"
 }
}

resource "aws_route_table_association" "tf_public_assoc" {
     count = "${aws_subnet.tf_public_subnet.count}"
     subnet_id = "${aws_subnet.tf_public_subnet.*.id[count.index]}"
     route_table_id = "${aws_route_table.tf_public_rt.id}"
}

resource "aws_security_group" "tf_public_sg" {
     name = "tf_public_sg"
     description = "Used for access to the public instances"
     vpc_id = "${aws_vpc.tf_vpc.id}"

    #SSH
    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.accessip}"]
  }

  #HTTP

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.accessip}"]
}  
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol = "tcp"
    cidr_blocks = ["${var.accessip}"]
}
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.tf_public_sg.id}"]
  subnets            = ["${aws_subnet.tf_public_subnet.*.id}"]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "test" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.tf_vpc.id}"
}

resource "aws_lb_target_group_attachment" "test" {
   count = 2
   target_group_arn = "${aws_lb_target_group.test.arn}"
   target_id = "${var.target_id[count.index]}"
   port             = 80
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = "${aws_lb.test.arn}"
  port = 80
  protocol = "HTTP"

  default_action {
  type = "forward"
  target_group_arn = "${aws_lb_target_group.test.arn}"
 }
}

