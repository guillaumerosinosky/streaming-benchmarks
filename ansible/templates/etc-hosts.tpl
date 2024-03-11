{% if group != 'stream' %}
127.0.0.1 localhost {{ ansible_hostname }}
{% endif %}

{% for host in groups['all'] %}
{% if host != inventory_hostname %}
{{ hostvars[host]['ansible_private_ip']}} {{ host }}
{% endif %}
{% endfor %}


# The following lines are desirable for IPv6 capable hosts
::1 localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
