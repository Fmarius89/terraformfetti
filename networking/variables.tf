variable "vpc_cidr" {
    default = "172.40.0.0/16"
}

variable "public_cidrs" {
     default = [
         "172.40.1.0/24",
         "172.40.2.0/24"
     ]
}

variable "accessip" {
     default = "0.0.0.0/0"
}

variable "target_id" {
  type = list
}
