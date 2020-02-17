aws_region = "eu-west-1"
vpc_cidr = "172.140.0.0/16"
public_cidrs = [
    "172.140.1.0/24",
    "172.140.2.0/24"
    ]
accessip = "0.0.0.0/0"
key_name = "tf_key"
public_key_path = "/opt/id_rsa.pub"
server_instance_type = "t2.micro"
instance_count = 2
