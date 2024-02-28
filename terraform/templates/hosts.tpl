[kafka]
%{ for node in kafka_nodes ~}
${node.name} ansible_host=${node.ipv4_address} ansible_private_ip=${node.ipv4_address_private}
%{ endfor ~}

[zookeeper]
%{ for node in zookeeper_nodes ~}
${node.name} ansible_host=${node.ipv4_address} ansible_private_ip=${node.ipv4_address_private}
%{ endfor ~}

[stream]
%{ for node in stream_nodes ~}
${node.name} ansible_host=${node.ipv4_address} ansible_private_ip=${node.ipv4_address_private}
%{ endfor ~}

[load]
%{ for node in load_nodes ~}
${node.name} ansible_host=${node.ipv4_address} ansible_private_ip=${node.ipv4_address_private}
%{ endfor ~}

[redis]
%{ for node in redis_nodes ~}
${node.name} ansible_host=${node.ipv4_address} ansible_private_ip=${node.ipv4_address_private}
%{ endfor ~}