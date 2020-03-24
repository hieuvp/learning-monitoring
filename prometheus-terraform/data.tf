data "cloudflare_zones" "this" {
  filter {
    name   = var.cloudflare_domain
    status = "active"
    paused = false
  }
}
