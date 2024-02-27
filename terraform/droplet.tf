resource "digitalocean_droplet" "zookeeper" {
  count    = var.zookeeper-node-count
  name     = "zookeeper-node-0${(count.index + 1)}"
  image    = var.droplet-os-version
  region   = var.droplet-region
  size     = var.droplet-size
  ssh_keys = [
    digitalocean_ssh_key.ssh-key.fingerprint
  ]

  connection {
    user        = "root"
    type        = "ssh"
    host        = self.ipv4_address
    private_key = var.SSH_PRIVATE_KEY
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "git clone https://github.com/elkhan-shahverdi/streaming-benchmarks.git",
      "./streaming-benchmarks/initial-setup.sh",
    ]
  }
}

resource "digitalocean_droplet" "kafka" {
  count    = var.kafka-node-count
  name     = "kafka-node-0${(count.index + 1)}"
  image    = var.droplet-os-version
  region   = var.droplet-region
  size     = var.droplet-size
  ssh_keys = [
    digitalocean_ssh_key.ssh-key.fingerprint
  ]
}

#resource "digitalocean_droplet" "stream" {
#  count    = var.stream-node-count
#  name     = "stream-node-0${(count.index + 1)}"
#  image    = var.droplet-os-version
#  region   = var.droplet-region
#  size     = var.droplet-size
#  ssh_keys = [
#    digitalocean_ssh_key.ssh-key.fingerprint
#  ]
#}
#
#resource "digitalocean_droplet" "load" {
#  count    = var.load-node-count
#  name     = "load-node-0${(count.index + 1)}"
#  image    = var.droplet-os-version
#  region   = var.droplet-region
#  size     = var.droplet-size
#  ssh_keys = [
#    digitalocean_ssh_key.ssh-key.fingerprint
#  ]
#}

resource "digitalocean_droplet" "redis" {
  name     = "redis"
  image    = var.droplet-os-version
  region   = var.droplet-region
  size     = var.droplet-size
  ssh_keys = [
    digitalocean_ssh_key.ssh-key.fingerprint
  ]
}


output "redis_private_ip" {
  value = digitalocean_droplet.redis.ipv4_address_private
}

output "zookeeper_private_ip" {
  value = digitalocean_droplet.zookeeper.*.ipv4_address_private
}

output "kafka_private_ip" {
  value = digitalocean_droplet.kafka.*.ipv4_address_private
}

output "redis_public_ip" {
  value = digitalocean_droplet.redis.ipv4_address
}

output "zookeeper_public_ip" {
  value = digitalocean_droplet.zookeeper.*.ipv4_address
}

output "kafka_public_ip" {
  value = digitalocean_droplet.kafka.*.ipv4_address
}