terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

resource "cloudflare_record" "example" {
  zone_id = data.cloudflare_zones.zone.id
  name    = "example"
  value   = "192.0.2.1"
  type    = "A"
  ttl     = 3600
  proxied = false
}

data "cloudflare_zones" "zone" {
  filter {
    name = var.zone_name
  }
}
