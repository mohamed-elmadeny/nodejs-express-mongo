
variable "ssh_public_key" {
  type = string

}


variable "aws_region" {
  default = "eu-west-3"
  type    = string
}
variable "instance_type" {
  default = "t2.2xlarge"
  type    = string
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
  type    = string
}


variable "subnet_cidr" {
  default = "10.0.1.0/24"
  type    = string


}
variable "ebs_disk_size" {
  default = 100
  type    = number

}
variable "root_volume_size" {
  default = 20
  type    = number
}
