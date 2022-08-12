resource "aws_instance" "worker" {
  ami                    = data.aws_ami.latest_ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.worker_sg.id]
  key_name               = "aws-frakfurt"
  user_data              = file("user_data_worker.sh")
  tags = {
    Name = "worker"
  }
}
resource "aws_security_group" "worker_sg" {
  name = "worker security group"
  dynamic "ingress" {
    for_each = ["50000", "22"]
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
    Name = "worker security group"
  }
}
