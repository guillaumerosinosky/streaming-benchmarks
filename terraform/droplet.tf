resource "digitalocean_droplet" "zookeeper" {
  count    = var.zookeeper-node-count
  name     = "zookeeper-node-${format("%02d", (count.index + 1))}"
  image    = var.droplet-os-version
  region   = var.droplet-region
  size     = var.zookeeper-droplet-size
  ssh_keys = [
    digitalocean_ssh_key.ssh-key.fingerprint
  ]

  connection {
    user        = "root"
    type        = "ssh"
    host        = self.ipv4_address
    private_key = file(var.SSH_PRIVATE_KEY)
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "git clone https://github.com/elkhan-shahverdi/streaming-benchmarks.git",
    ]
  }
}

resource "digitalocean_droplet" "kafka" {
  count    = var.kafka-node-count
  name     = "kafka-node-${format("%02d", (count.index + 1))}"
  image    = var.droplet-os-version
  region   = var.droplet-region
  size     = var.kafka-droplet-size
  ssh_keys = [
    digitalocean_ssh_key.ssh-key.fingerprint
  ]

  connection {
    user        = "root"
    type        = "ssh"
    host        = self.ipv4_address
    private_key = file(var.SSH_PRIVATE_KEY)
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "git clone https://github.com/elkhan-shahverdi/streaming-benchmarks.git",
    ]
  }
}

resource "digitalocean_droplet" "stream" {
  count    = var.stream-node-count
  name     = "stream-node-${format("%02d", (count.index + 1))}"
  image    = var.droplet-os-version
  region   = var.droplet-region
  size     = var.stream-droplet-size
  ssh_keys = [
    digitalocean_ssh_key.ssh-key.fingerprint
  ]

  connection {
    user        = "root"
    type        = "ssh"
    host        = self.ipv4_address
    private_key = file(var.SSH_PRIVATE_KEY)
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "git clone https://github.com/elkhan-shahverdi/streaming-benchmarks.git",
    ]
  }
}

resource "digitalocean_droplet" "load" {
  count    = var.load-node-count
  name     = "load-node-${format("%02d", (count.index + 1))}"
  image    = var.droplet-os-version
  region   = var.droplet-region
  size     = var.load-droplet-size
  ssh_keys = [
    digitalocean_ssh_key.ssh-key.fingerprint
  ]

  connection {
    user        = "root"
    type        = "ssh"
    host        = self.ipv4_address
    private_key = file(var.SSH_PRIVATE_KEY)
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "git clone https://github.com/elkhan-shahverdi/streaming-benchmarks.git",
    ]
  }
}

resource "digitalocean_droplet" "redisdo" {
  name     = "redisdo"
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
    private_key = file(var.SSH_PRIVATE_KEY)
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "git clone https://github.com/elkhan-shahverdi/streaming-benchmarks.git",
    ]
  }
}

output "redis_private_ip" {
  value = digitalocean_droplet.redisdo.ipv4_address_private
}
output "redis_public_ip" {
  value = digitalocean_droplet.redisdo.ipv4_address
}

output "zookeeper_private_ip" {
  value = digitalocean_droplet.zookeeper.*.ipv4_address_private
}
output "zookeeper_public_ip" {
  value = digitalocean_droplet.zookeeper.*.ipv4_address
}

output "kafka_private_ip" {
  value = digitalocean_droplet.kafka.*.ipv4_address_private
}
output "kafka_public_ip" {
  value = digitalocean_droplet.kafka.*.ipv4_address
}

output "stream_private_ip" {
  value = digitalocean_droplet.stream.*.ipv4_address_private
}
output "stream_public_ip" {
  value = digitalocean_droplet.stream.*.ipv4_address
}

output "load_private_ip" {
  value = digitalocean_droplet.load.*.ipv4_address_private
}
output "load_public_ip" {
  value = digitalocean_droplet.load.*.ipv4_address
}