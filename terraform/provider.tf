terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.34.1"
    }
    ansible = {
      source = "ansible/ansible"
      version = "1.2.0"
    }
  }
  cloud {
    organization = "Revsolz"

    workspaces {
      name = "fracsol-experiment"
    }
  }
}

provider "ansible" {
  # Configuration options
}

variable "DO_TOKEN" {
  sensitive = true
}

variable "SSH_KEY" {
  sensitive = true
}

variable "SSH_PRIVATE_KEY" {
  sensitive = true
}

provider "digitalocean" {
  token = var.DO_TOKEN
}

# Create a new SSH key
resource "digitalocean_ssh_key" "ssh-key" {
  name       = "ssh-key"
  public_key = var.SSH_KEY
}