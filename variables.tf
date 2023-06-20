variable "instance_type" {
  type        = string
  description = "instance type that will be used for instance"
}
variable "vpc_id" {
  type = string
}


variable "server_name" {
  type    = string
  default = "Apache Example Server"
}