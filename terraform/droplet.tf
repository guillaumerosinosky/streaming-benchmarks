resource "digitalocean_droplet" "zookeeper" {
  count    = var.zookeeper-node-count
  name     = "zookeeper-node-0${count.index}"
  image    = var.droplet-os-version
  region   = var.droplet-region
  size     = var.droplet-size
  ssh_keys = [
    digitalocean_ssh_key.ssh-key.id
  ]
}

resource "digitalocean_droplet" "kafka" {
  count    = var.kafka-node-count
  name     = "kafka-node-0${count.index}"
  image    = var.droplet-os-version
  region   = var.droplet-region
  size     = var.droplet-size
  ssh_keys = [
    digitalocean_ssh_key.ssh-key.id
  ]
}

resource "digitalocean_droplet" "stream" {
  count    = var.stream-node-count
  name     = "stream-node-0${count.index}"
  image    = var.droplet-os-version
  region   = var.droplet-region
  size     = var.droplet-size
  ssh_keys = [
    digitalocean_ssh_key.ssh-key.id
  ]
}

resource "digitalocean_droplet" "load" {
  count    = var.load-node-count
  name     = "load-node-0${count.index}"
  image    = var.droplet-os-version
  region   = var.droplet-region
  size     = var.droplet-size
  ssh_keys = [
    digitalocean_ssh_key.ssh-key.id
  ]
}

resource "digitalocean_droplet" "redis" {
  name     = "redis"
  image    = var.droplet-os-version
  region   = var.droplet-region
  size     = var.droplet-size
  ssh_keys = [
    digitalocean_ssh_key.ssh-key.id
  ]
}


output "instance_ip" {
  value = aws_instance.my_instance.public_ip
}
