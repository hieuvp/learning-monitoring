data "cloudflare_zones" "this" {
  filter {
    name   = local.domain_name
    status = "active"
    paused = false
  }
}
