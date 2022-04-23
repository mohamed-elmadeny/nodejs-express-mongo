resource "aws_key_pair" "ssh_key" {
  key_name   = "mykey"
  public_key = var.ssh_public_key
}


resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr

  tags = {
    Name = "Main"
  }
}


data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]


  filter {
    name   = "name"
    values = ["Ubuntu*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

}

resource "aws_security_group" "server_SG" {
  name        = "allow_all_in_out"
  description = "Allow all inbound, outbound traffic to jump box"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "ssh from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}


resource "aws_default_route_table" "internet" {
  default_route_table_id = aws_vpc.main.default_route_table_id



  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "default"
  }
}


resource "aws_eip" "eip" {
  vpc = true

}


resource "aws_instance" "ec2_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.server_SG.id]
  key_name               = aws_key_pair.ssh_key.key_name

  root_block_device {
    volume_size = var.root_volume_size
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.ec2_instance.id
  allocation_id = aws_eip.eip.id
}

resource "aws_ebs_volume" "volume" {
  availability_zone = aws_instance.ec2_instance.availability_zone
  size              = var.ebs_disk_size

  tags = {
    Name = "data_volume"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/xvdh"
  volume_id   = aws_ebs_volume.volume.id
  instance_id = aws_instance.ec2_instance.id

}
