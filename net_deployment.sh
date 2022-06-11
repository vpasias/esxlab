#!/bin/bash
#

cat > /home/iason/temp/management.xml <<EOF
<network>
  <name>management</name>
  <forward mode='nat'/>
  <bridge name='virbr100' stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
  <mac address='52:54:00:8a:8b:cd'/>
  <ip address='192.168.255.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.255.2' end='192.168.255.199'/>
      <host mac='52:54:00:8a:8b:c1' ip='192.168.255.101'/>
      <host mac='52:54:00:8a:8b:c2' ip='192.168.255.102'/>
      <host mac='52:54:00:8a:8b:c3' ip='192.168.255.103'/>
      <host mac='52:54:00:8a:8b:c4' ip='192.168.255.104'/>
      <host mac='52:54:00:8a:8b:c5' ip='192.168.255.105'/>
      <host mac='52:54:00:8a:8b:c6' ip='192.168.255.106'/>
      <host mac='52:54:00:8a:8b:c7' ip='192.168.255.107'/>
      <host mac='52:54:00:8a:8b:c8' ip='192.168.255.108'/>
      <host mac='52:54:00:8a:8b:c9' ip='192.168.255.109'/>
    </dhcp>
  </ip>
</network>
EOF

virsh net-define /mnt/extra/management.xml && virsh net-autostart management && virsh net-start management

ip a && sudo virsh net-list --all
