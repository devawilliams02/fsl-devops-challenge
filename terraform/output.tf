output "website_bucket" {
  value = module.static_site.website_bucket
}

output "cdn_domain_name" {
  value = module.static_site.cdn_domain_name
}

output "logs_bucket" {
  value = module.static_site.logs_bucket
}
