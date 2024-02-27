[kafka]
%{ for ip in kafka_nodes ~}
${ip}
%{ endfor ~}

[zookeeper]
%{ for ip in zookeeper_nodes ~}
${ip}
%{ endfor ~}

[stream]
%{ for ip in stream_nodes ~}
${ip}
%{ endfor ~}

[load]
%{ for ip in load_nodes ~}
${ip}
%{ endfor ~}

[redis]
%{ for ip in redis_nodes ~}
${ip}
%{ eyesndfor ~}