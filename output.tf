output "prod_public_ip" {
  value = aws_instance.prod.public_ip
}
output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}
output "worker_public_ip" {
  value = aws_instance.worker.public_ip
}
