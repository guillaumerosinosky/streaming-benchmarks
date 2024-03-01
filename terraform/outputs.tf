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
        for node in digitalocean_droplet.redisdo.* : node
      ]
    }
  )
  filename = "../ansible/inventory/hosts.cfg"
}

resource "local_file" "etc_hosts_cfg" {
  content = templatefile("${path.module}/templates/etc-hosts-private.tpl",
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
        for node in digitalocean_droplet.redisdo.* : node
      ]
    }
  )
  filename = "../ansible/etc-hosts-private.cfg"
}