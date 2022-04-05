terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.19.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "digitalocean" {
  # Configuration options
  token = var.do_token
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

data "aws_route53_zone" "selected" {
  name = var.aws_route53_zone
}

resource "aws_route53_record" "www" {
  count = var.do_vps_count
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = element(digitalocean_droplet.vps.*.name, count.index)
  type    = "A"
  ttl     = "300"
  records = [element(digitalocean_droplet.vps.*.ipv4_address, count.index)]
}

# Create a task_name tag
resource "digitalocean_tag" "task_name" {
  name = var.tag_task_name
}

# Create a user_email tag
resource "digitalocean_tag" "user_email" {
  name = var.tag_admin_email
}

# Create a new SSH key for admin access from file
resource "digitalocean_ssh_key" "ubuntu_ssh_admin" {
  name = var.admin_ssh_key_name
  public_key = file(var.admin_ssh_key_path)
}

# Get SSH key for rebrain access
data "digitalocean_ssh_key" "ubuntu_ssh_rebrain" {
  name = "REBRAIN.SSH.PUB.KEY"
}

# Create a new vps Droplet in the fra1 region with tags and ssh keys
resource "digitalocean_droplet" "vps" {
  count = var.do_vps_count
  image  = "ubuntu-20-04-x64"
  name   = format("%s-%s", var.aws_route53_record_name, count.index + 1)
  region = "fra1"
  size   = "s-1vcpu-1gb"
  tags   = [digitalocean_tag.task_name.id, digitalocean_tag.user_email.id]
  ssh_keys = [digitalocean_ssh_key.ubuntu_ssh_admin.id, data.digitalocean_ssh_key.ubuntu_ssh_rebrain.id]

  connection {
    host        = element(digitalocean_droplet.vps.*.ipv4_address, count.index)
    type        = "ssh"
    user        = "root"
    private_key = file(var.admin_ssh_privkey_path)
  }
  
  provisioner "remote-exec" {
    inline = [
      "useradd ${var.vps_user_name} -p ${var.vps_user_password}",
    ]
  }
}