# it shows the id of the security group when the resource is applied 
output "security_group_id" {
  value = aws_security_group.terraformCourse.id
}