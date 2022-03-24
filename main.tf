provider "aws" {
}

data "aws_ami" "latest_ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

data "aws_eip" "jenkins_public_ip" {
  public_ip = var.aws_elastic_ip
}


data "template_file" "user_data_master" {
  template = templatefile("user_data_master.tftpl", {
    j_login          = var.jenkins_login,
    j_pass           = var.jenkins_pass,
    dh_login         = var.docker_hub_login,
    dh_pass          = var.docker_hub_password,
    dh_repo          = var.docker_hub_repo,
    gh_token         = var.git_hub_token,
    gh_app_repo      = var.git_hub_repo_app,
    gh_pipeline_repo = var.git_hub_repo_pipeline
    w_user           = var.worker_user,
    w_key            = file(var.worker_id_rsa),
    worker_ip        = aws_instance.worker.public_ip,
    prod_ip          = aws_instance.prod.public_ip
  })
}

resource "aws_eip_association" "my_eip_association" {
  instance_id   = aws_instance.jenkins.id
  allocation_id = data.aws_eip.jenkins_public_ip.id
}

resource "aws_security_group" "jenkins_sg" {
  name = "jenkins security group"
  dynamic "ingress" {
    for_each = ["50000", "8080", "22"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "jenkins security group"
  }
}

resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.latest_ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name               = "aws-frakfurt"
  user_data              = data.template_file.user_data_master.rendered
  tags = {
    Name = "jenkins master"
  }
  depends_on = [aws_instance.worker, aws_instance.prod]
}

output "jenkins_elastic_ip" {
  value = aws_eip_association.my_eip_association.public_ip
}

variable "aws_elastic_ip" {
  type = string
}
variable "jenkins_login" {
  type = string
}

variable "jenkins_pass" {
  type = string
}

variable "docker_hub_login" {
  type = string
}

variable "docker_hub_password" {
  type = string
}
variable "docker_hub_repo" {
  type = string
}
variable "worker_user" {
  type = string
}
variable "worker_id_rsa" {
  type = string
}
variable "git_hub_token" {
  type = string
}
variable "git_hub_repo_app" {
  type = string
}
variable "git_hub_repo_pipeline" {
  type = string
}
