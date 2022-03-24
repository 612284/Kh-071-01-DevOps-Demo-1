resource "aws_instance" "prod" {
  ami                    = data.aws_ami.latest_ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.prod_sg.id]
  key_name               = "aws-frakfurt"
  user_data              = file("user_data_prod.sh")
  tags = {
    Name = "prod"
  }
}

resource "aws_security_group" "prod_sg" {
  name = "prod security group"

  dynamic "ingress" {
    for_each = ["80", "22"]
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
    Name = "prod security group"
  }
}

output "prod_public_ip" {
  value = aws_instance.prod.public_ip
}
