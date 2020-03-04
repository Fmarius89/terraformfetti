provider "aws" {
    region = "${var.aws_region}"
}

module "networking" {
    source = "./networking"
    vpc_cidr = "${var.vpc_cidr}"
    public_cidrs = "${var.public_cidrs}"
    accessip = "${var.accessip}"
    target_id = "${module.compute.target_id}"
}

module "compute" {
    source = "./compute"
    instance_count = "${var.instance_count}"
    key_name = "${var.key_name}"
    public_key_path = "${var.public_key_path}"
    subnets = "${module.networking.public_subnets}"
    security_group = "${module.networking.public_sg}"
    subnet_ips = "${module.networking.subnet_ips}"
    instance_type = "${var.server_instance_type}"
}

module "bucket" {
    source = "./bucket" 
    project_name = "${var.project_name}"
}
