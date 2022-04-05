# Show created droplets info
output "vps_list" {
  value = [for vps in digitalocean_droplet.vps :
  "${vps.name}.${var.aws_route53_zone} (${vps.ipv4_address})"]
}