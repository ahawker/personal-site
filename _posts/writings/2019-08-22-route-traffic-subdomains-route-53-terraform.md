---
layout: post
title: Routing Traffic for Subdomains with Route53 & Terraform
date: 2019-08-22 2:55:00-8000
author: me
category: writings
tags: [aws, route53, dns, terraform, tutorial]
keywords: [aws, route53, dns, terraform]
---

## Scenario

Let's imagine you own `example.com` and you're looking to setup subdomains to separate your environments, e.g. `dev.example.com` and `staging.example.com`. On our top level domain, we have already created subdomains for certain services, e.g. `api.example.com` and `web.example.com`. This leads us to wanting to create subdomains such as `api.dev.example.com` and `api.staging.example.com` to access these services running within a specific environment.

When creating single depth subdomains, e.g. `api.example.com`, you simply create the DNS record within the `example.com` Route 53 hosted zone and move on your way. However, if we're looking to create multiple depth subdomains, e.g. `api.staging.example.com` or `shopping.api.staging.example.com`, how do we setup our Route 53 hosted zone to support this n-tier domain layout?

## Problem Statement

Given I own `example.com`, I want to run my service subdomains `api.example.com` and `web.example.com` under additional, environment-specific subdomains, `dev.example.com` and `staging.example.com`.

## Solution

Let's break the solution down into a few separate parts and examine them individually.

### Hosted Zones

We need to create a Hosted Zone for each domain (or subdomain) that needs to route traffic. In this case, that would be `example.com`, `dev.example.com`, and `staging.example.com`.

Using private hosted zones instead? Check out the official Terraform documentation for the [aws_route53_zone](https://www.terraform.io/docs/providers/aws/r/route53_zone.html) for more details.

```tf
# Hosted Zone for example.com
resource "aws_route53_zone" "zone_apex" {
  name          = "example.com"
  comment       = "Hosted Zone for example.com"

  tags {
    Name      = "example.com"
    Origin    = "terraform"
    Workspace = "${terraform.workspace}"
  }
}

# Hosted Zone for dev.example.com
resource "aws_route53_zone" "zone_dev" {
  name          = "dev.example.com"
  comment       = "Hosted Zone for dev.example.com"

  tags {
    Name      = "dev.example.com"
    Origin    = "terraform"
    Workspace = "${terraform.workspace}"
  }
}

# Hosted Zone for staging.example.com
resource "aws_route53_zone" "zone_staging" {
  name          = "staging.example.com"
  comment       = "Hosted Zone for staging.example.com"

  tags {
    Name      = "staging.example.com"
    Origin    = "terraform"
    Workspace = "${terraform.workspace}"
  }
}
```

### Hosted Zone NS Records

Each hosted zone created with automatically be assigned a set of `NS` records automatically. These are exported as the [name_servers](https://www.terraform.io/docs/providers/aws/r/route53_zone.html#name_servers) attribute on the [aws_route53_zone](https://www.terraform.io/docs/providers/aws/r/route53_zone.html) resource.

Each hosted zone will have four unique `NS` records, known as a [delegation set](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/route-53-concepts.html#route-53-concepts-reusable-delegation-set). If you have many domains or need to white label your name servers, you can look into creating your own reusable delegation set with the [route53_delegation_set](https://www.terraform.io/docs/providers/aws/r/route53_delegation_set.html) resource.

Each _parent_ hosted zone will need to add a `NS` record for each _child_ hosted zone. In this case, `example.com` would need to have an `NS` record for `dev.example.com` that contains the automatically assigned name servers for the `dev.example.com` hosted zone.

```tf
# Record in the example.com hosted zone that contains the name servers of the dev.example.com hosted zone.
resource "aws_route53_record" "ns_record_dev" {
  type    = "NS"
  zone_id = "${aws_route53_zone.zone_apex.id}"
  name    = "dev"
  ttl     = "86400"
  records = ["${aws_route53_zone.zone_dev.name_servers}"]
}

# Record in the example.com hosted zone that contains the name servers of the staging.example.com hosted zone.
resource "aws_route53_record" "ns_record_staging" {
  type    = "NS"
  zone_id = "${aws_route53_zone.zone_apex.id}"
  name    = "staging"
  ttl     = "86400"
  records = ["${aws_route53_zone.zone_staging.name_servers}"]
}
```

### Hosted Zone Service Records

Each Hosted Zone will need to add records to route the `api` and `web` services to their correct locations. For this example, let's just assume they're `CNAME` records to another domain and these are parametrized using Terraform variables. [^1]

[^1]: <https://www.terraform.io/docs/configuration/variables.html>

```tf
variable "api_cname_record" {
    description = "Value of CNAME record for api.example.com"
}

variable "web_cname_record" {
    description = "Value of CNAME record for web.example.com"
}

variable "api_dev_cname_record" {
    description = "Value of CNAME record for api.dev.example.com"
}

variable "web_dev_cname_record" {
    description = "Value of CNAME record for web.dev.example.com"
}

variable "api_staging_cname_record" {
    description = "Value of CNAME record for api.staging.example.com"
}

variable "web_staging_cname_record" {
    description = "Value of CNAME record for web.staging.example.com"
}
```

Using the variable definitons from above, we can parametrize our `CNAME` record creation for our service subdomains. [^2]

[^2]: <https://www.terraform.io/docs/providers/aws/r/route53_record.html>

```tf
# CNAME record in the example.com hosted zone that points to 'api' service.
resource "aws_route53_record" "record_apex_api" {
  type    = "CNAME"
  name    = "api"
  ttl     = "86400"
  zone_id = "${aws_route53_zone.zone_apex.id}"
  records = ["${var.api_cname_record}"]
}

# CNAME record in the example.com hosted zone that points to 'web' service.
resource "aws_route53_record" "record_apex_web" {
  type    = "CNAME"
  name    = "web"
  ttl     = "86400"
  zone_id = "${aws_route53_zone.zone_apex.id}"
  records = ["${var.web_cname_record}"]
}

# CNAME record in the dev.example.com hosted zone that points to 'api' service.
resource "aws_route53_record" "record_dev_api" {
  type    = "CNAME"
  name    = "api"
  ttl     = "86400"
  zone_id = "${aws_route53_zone.zone_dev.id}"
  records = ["${var.api_dev_cname_record}"]
}

# CNAME record in the dev.example.com hosted zone that points to 'web' service.
resource "aws_route53_record" "record_dev_web" {
  type    = "CNAME"
  name    = "web"
  ttl     = "86400"
  zone_id = "${aws_route53_zone.zone_dev.id}"
  records = ["${var.web_dev_cname_record}"]
}

# CNAME record in the staging.example.com hosted zone that points to 'api' service.
resource "aws_route53_record" "record_staging_api" {
  type    = "CNAME"
  name    = "api"
  ttl     = "86400"
  zone_id = "${aws_route53_zone.zone_staging.id}"
  records = ["${var.api_staging_cname_record}"]
}

# CNAME record in the staging.example.com hosted zone that points to 'web' service.
resource "aws_route53_record" "record_staging_web" {
  type    = "CNAME"
  name    = "web"
  ttl     = "86400"
  zone_id = "${aws_route53_zone.zone_staging.id}"
  records = ["${var.web_staging_cname_record}"]
}
```

## Summary

In order to route traffic to n-tier levels of subdomains in Route53, you must create a new hosted zone for each subdomain that contains records and must add an `NS` record for that subdomain in the hosted zone of its parent.[^3]

[^3]: <https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-routing-traffic-for-subdomains.html>

---