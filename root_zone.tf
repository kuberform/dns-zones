variable "root_zone" {
  type        = "string"
  description = "The root zone to use for Kubernetes deployments."
  default     = "k8s.example.net"
}

resource "aws_route53_zone" "root_zone" {
  name          = "${var.root_zone}"
  comment       = "Kubernetes Root Zone"
  force_destroy = true

  tags {
    Name    = "kuberform-root-zone"
    Owner   = "infrastructure"
    Billing = "costcenter"
  }
}

resource "aws_route53_record" "region_records" {
  count   = "${length(var.regions)}"
  zone_id = "${aws_route53_zone.root_zone.zone_id}"
  name    = "${element(var.regions, count.index)}.${var.root_zone}"
  type    = "NS"
  ttl     = "86400"
  records = ["${aws_route53_delegation_set.kubernetes.name_servers}"]
}

resource "aws_route53_zone" "region_zone" {
  count             = "${length(var.regions)}"
  name              = "${element(var.regions, count.index)}.${var.root_zone}"
  delegation_set_id = "${aws_route53_delegation_set.kubernetes.id}"
  comment           = "Kubernetes Region Zone ${upper(element(var.regions, count.index))}"
  force_destroy     = true

  tags {
    Name    = "kuberform-region-zone-${element(var.regions, count.index)}"
    Owner   = "infrastructure"
    Billing = "costcenter"
  }
}

output "root_zone_id" {
  value = "${aws_route53_zone.root_zone.zone_id}"
}

output "root_zone_nameservers" {
  value = "${aws_route53_zone.root_zone.name_servers}"
}

output "region_zones" {
  value = "${zipmap(var.regions, aws_route53_zone.region_zone.*.zone_id)}"
}
