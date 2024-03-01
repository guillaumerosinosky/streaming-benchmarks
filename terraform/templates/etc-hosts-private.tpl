%{ for node in kafka_nodes ~}
${node.ipv4_address} ${node.name}
%{ endfor ~}
%{ for node in zookeeper_nodes ~}
${node.ipv4_address} ${node.name}
%{ endfor ~}
%{ for node in stream_nodes ~}
${node.ipv4_address} ${node.name}
%{ endfor ~}
%{ for node in load_nodes ~}
${node.ipv4_address} ${node.name}
%{ endfor ~}
%{ for node in redis_nodes ~}
${node.ipv4_address} ${node.name}
%{ endfor ~}