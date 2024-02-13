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
