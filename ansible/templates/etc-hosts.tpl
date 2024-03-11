{% for host in groups['all'] %}
{{ hostvars[host]['ansible_private_ip']}} {{ host }}
{% endfor %}


# The following lines are desirable for IPv6 capable hosts
::1 localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
