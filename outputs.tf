# Show created droplets info
output "vps_list" {
  value = [for i, vps in digitalocean_droplet.vps :
  "${i+1}: ${vps.name}.${var.aws_route53_zone} ${vps.ipv4_address} ${random_string.random[i].result}"]
}