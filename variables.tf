variable "do_token" {
  description = "Access token to DO"
  type        = string
}

# Add a task_name tag
variable "tag_task_name" {}

# Add a user_email tag
variable "tag_admin_email" {}

# Add a new SSH key for admin access from file
variable "admin_ssh_key_name" {}
variable "admin_ssh_key_path" {}
