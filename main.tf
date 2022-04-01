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
  name = "task_name:devops-terraform-02"
}

# Create a user_email tag
resource "digitalocean_tag" "user_email" {
  name = "user_email:oleg_satalkin_at_gmail_com"
}

# Get SSH key for admin access
data "digitalocean_ssh_key" "ubuntu_ssh_admin" {
  name = "Ubuntu SSH key"
}

data "external" "get_sshkey" {
  program = ["bash", "./get_ssh_key.sh" var.do_token]
}

# Create a new vps Droplet in the fra1 region with tags and ssh keys
resource "digitalocean_droplet" "vps" {
  image  = "ubuntu-20-04-x64"
  name   = "rebrain-devops-tf2"
  region = "fra1"
  size   = "s-1vcpu-1gb"
  tags   = [digitalocean_tag.task_name.id, digitalocean_tag.user_email.id]
  ssh_keys = [data.digitalocean_ssh_key.ubuntu_ssh_admin.id,data.external.get_sshkey.result.id]
}

output "ssh_key_rebrain" {
  value = data.external.get_sshkey.result
}