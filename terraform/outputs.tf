# generate inventory file for Ansible

resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/templates/hosts.tpl",
    {

      kafka_nodes = [
        for node in digitalocean_droplet.kafka.* : node
      ]
      zookeeper_nodes = [
        for node in digitalocean_droplet.zookeeper.* : node
      ]
      stream_nodes = [
        for node in digitalocean_droplet.stream.* : node
      ]
      load_nodes = [
        for node in digitalocean_droplet.load.* : node
      ]
      redis_nodes = [
        for node in digitalocean_droplet.redis.* : node
      ]
    }
  )
  filename = "../ansible/inventory/hosts.cfg"
}