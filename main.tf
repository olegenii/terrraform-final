terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.19.0"
    }
  }
}

provider "digitalocean" {
# Configuration options
  token = var.do_token
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

data "external" "get_sshkey" {
  program = ["bash", "./get_ssh_key.sh", var.do_token]
}

data "external" "get_sshkey" {
  program = ["bash", "./get_ssh_key.sh", var.do_token]
}

# Create a new vps Droplet in the fra1 region with tags and ssh keys
resource "digitalocean_droplet" "vps" {
  image  = "ubuntu-20-04-x64"
  name   = "rebrain-devops-tf2"
  region = "fra1"
  size   = "s-1vcpu-1gb"
  tags   = [digitalocean_tag.task_name.id, digitalocean_tag.user_email.id]
  ssh_keys = [digitalocean_ssh_key.ubuntu_ssh_admin.id,data.external.get_sshkey.result.id]
}

output "droplet_ip_address" {
  value = digitalocean_droplet.vps.ipv4_address
}

output "ssh_key_rebrain" {
  value = data.external.get_sshkey.result
}

output "ssh_key_rebrain" {
  value = data.external.get_sshkey.result
}
