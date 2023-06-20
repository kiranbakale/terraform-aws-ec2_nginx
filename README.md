A customised Terraform Module to provision VPC,Internet Gateway,Route tables,Subnets and a public Instance that is running Nginx.

Not intended for production use. Just showcasing how to create a public module on Terraform Registry

```hcl

terraform {

}

provider "aws" {
  region = "us-east-1"
}

module "vpc_ec2" {
  source = "../Simple_ec2_vpc/terraform-aws-vpc_ec2"
  vpc_id = var.vpc_id
  instance_type = var.instance_type
}

```