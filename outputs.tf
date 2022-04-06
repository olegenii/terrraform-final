# Show created droplets info
output "vps_list" {
  value = [for i, vps in digitalocean_droplet.vps :
  "${vps.name}.${var.aws_route53_zone} (${vps.ipv4_address}) user: ${var.vps_user_name} | password: ${random_string.random[i].result}"]
}