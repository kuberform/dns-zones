resource "aws_route53_delegation_set" "kubernetes" {
  reference_name = "kuberform"
}
