[all:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'

[kafka]
%{ for node in kafka_nodes ~}
${node.name} ansible_host=${node.ipv4_address} ansible_user=root ansible_private_ip=${node.ipv4_address_private} ansible_ssh_private_key_file=~/.ssh/spa-experiment
%{ endfor ~}

[zookeeper]
%{ for node in zookeeper_nodes ~}
${node.name} ansible_host=${node.ipv4_address} ansible_user=root ansible_private_ip=${node.ipv4_address_private} ansible_ssh_private_key_file=~/.ssh/spa-experiment
%{ endfor ~}

[stream]
%{ for node in stream_nodes ~}
${node.name} ansible_host=${node.ipv4_address} ansible_user=root ansible_private_ip=${node.ipv4_address_private} ansible_ssh_private_key_file=~/.ssh/spa-experiment
%{ endfor ~}

[load]
%{ for node in load_nodes ~}
${node.name} ansible_host=${node.ipv4_address} ansible_user=root ansible_private_ip=${node.ipv4_address_private} ansible_ssh_private_key_file=~/.ssh/spa-experiment
%{ endfor ~}

[redis]
%{ for node in redis_nodes ~}
${node.name} ansible_host=${node.ipv4_address} ansible_user=root ansible_private_ip=${node.ipv4_address_private} ansible_ssh_private_key_file=~/.ssh/spa-experiment
%{ endfor ~}