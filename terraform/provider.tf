terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.34.1"
    }
  }
#  cloud {
#    organization = "Revsolz"
#
#    workspaces {
#      name = "fracsol-experiment"
#    }
#  }
}

variable "DO_TOKEN" {
  sensitive = true
  default = "token"
}

variable "SSH_KEY" {
  sensitive = true
  default = "~/.ssh/spa-experiment.pub"
}

variable "SSH_PRIVATE_KEY" {
  sensitive = true
  default = "~/.ssh/spa-experiment"
}

provider "digitalocean" {
  token = var.DO_TOKEN
}

# Create a new SSH key
resource "digitalocean_ssh_key" "ssh-key" {
  name       = "ssh-key"
  public_key = file(var.SSH_KEY)
}