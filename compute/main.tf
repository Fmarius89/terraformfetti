#-------computer/main.tf

data "aws_ami" "server_ami" {
    most_recent = true

    owners = ["amazon"]

    filter {
       name = "owner-alias"
       values = ["amazon"]
}

    filter {
       name = "name"
       values = ["amzn-ami-hvm*-x86_64-gp2"]
 }
}

resource "aws_key_pair" "tf_auth" {
     key_name = "${var.key_name}"
     public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "tf_server" {
     count = "${var.instance_count}"
     instance_type = "${var.instance_type}"
     ami = "${data.aws_ami.server_ami.id}"

    connection {
       private_key = "${file("/home/ec2-user/.ssh/id_rsa")}"
       user = "ec2-user"
       type = "ssh"
    
}
    provisioner "remote-exec" {
     inline = [
       "sudo yum -y install docker",
       "sudo service docker start",
       "sudo docker run -d -p 80:80 nginx"
     ]
}
       

     tags {
         Name = "tf_server-${count.index +1}"
         #Name = "tf_marius"
}     
     key_name = "${aws_key_pair.tf_auth.id}"
     vpc_security_group_ids = ["${var.security_group}"]
     subnet_id = "${element(var.subnets, count.index)}"
 }  


