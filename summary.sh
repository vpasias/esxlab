#!/bin/sh
set -euxo pipefail

fqdn="$(hostname -f)"
management_ip_address="$(esxcli --formatter=csv network ip interface ipv4 get -i vmk0 | tail +2 | awk -F, '{print $4}')"

esxcli system version get

cat <<EOF

To access this system add this host managament IP address to your hosts file:

    sudo bash -c "hosts=\"\$(grep -vE '\\s+$fqdn' /etc/hosts)\"; (echo \"\\\$hosts\"; echo '$management_ip_address $fqdn') >/etc/hosts"
    
Access the management web interface at:
    https://$fqdn
    
And login with the following user name and password:
    root
    HeyH0Password!
    
EOF
