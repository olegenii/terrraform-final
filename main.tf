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
    random = {
      source = "hashicorp/random"
      version = "3.1.2"
    }
  }
}

provider "digitalocean" {
  # Configuration options
  token = var.do_token
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-central-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

data "aws_route53_zone" "selected" {
  name = var.aws_route53_zone
}

resource "aws_route53_record" "www" {
  count = local.num
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = digitalocean_droplet.vps[count.index].name
  type    = "A"
  ttl     = "300"
  records = [digitalocean_droplet.vps[count.index].ipv4_address]
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

# Get random passwords
resource "random_string" "random" {
  count = local.num
  length = 8
  special = true
}

# Create a new vps Droplet in the fra1 region with tags and ssh keys
resource "digitalocean_droplet" "vps" {
  count = local.num
  image  = "ubuntu-20-04-x64"
  name = "${split("-", var.devs[count.index])[1]}-${split("-", var.devs[count.index])[0]}"
  region = "fra1"
  size   = "s-1vcpu-1gb"
  tags   = [digitalocean_tag.task_name.id, digitalocean_tag.user_email.id]
  ssh_keys = [digitalocean_ssh_key.ubuntu_ssh_admin.id, data.digitalocean_ssh_key.ubuntu_ssh_rebrain.id]

  connection {
    host        = "${self.ipv4_address}"
    type        = "ssh"
    user        = "root"
    private_key = file(var.admin_ssh_privkey_path)
  }
  
  provisioner "remote-exec" {
    inline = ["echo ${var.vps_user_name}:${random_string.random[count.index].result} | chpasswd"]
  }
}

# Create an ouput file using template
resource "local_file" "vps" {
  filename = "${path.module}/${var.file_out}"
  content  = templatefile("${path.module}/${var.file_in}", {domain = var.aws_route53_zone, vps_list = digitalocean_droplet.vps, random = random_string.random})
}

locals {
  num = length(var.devs)
}