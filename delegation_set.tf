resource "aws_route53_delegation_set" "kubernetes" {
  reference_name = "kuberform-${md5(var.root_zone)}"
}
