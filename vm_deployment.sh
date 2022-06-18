#!/bin/bash
#

cat << EOF | tee /mnt/extra/management.xml
<network>
  <name>mgt</name>
  <uuid>7ed704dd-3901-452c-91d0-58ad75901b2d</uuid>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr100' stp='on' delay='0'/>
  <mac address='52:54:00:d8:3f:1d'/>
  <dns>
    <host ip='192.168.255.101'>
      <hostname>node1.esxi.lab</hostname>
    </host>
    <host ip='192.168.255.102'>
      <hostname>node2.esxi.lab</hostname>
    </host>
    <host ip='192.168.255.103'>
      <hostname>node3.esxi.lab</hostname>
    </host>
    <host ip='192.168.255.200'>
      <hostname>vcenter.esxi.lab</hostname>
    </host>
  </dns>
  <ip address='192.168.255.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.255.2' end='192.168.255.99'/>
      <host mac='08:4F:A9:00:00:01' name='node1' ip='192.168.255.101'/>
      <host mac='08:4F:A9:00:00:02' name='node2' ip='192.168.255.102'/>
      <host mac='08:4F:A9:00:00:03' name='node3' ip='192.168.255.103'/>
      <host mac='08:4F:A9:00:00:04' name='node4' ip='192.168.255.104'/>
      <host mac='08:4F:A9:00:00:05' name='node5' ip='192.168.255.105'/>
      <host mac='08:4F:A9:00:00:06' name='node6' ip='192.168.255.106'/>
      <host mac='08:4F:A9:00:00:07' name='node7' ip='192.168.255.107'/>
      <host mac='08:4F:A9:00:00:08' name='node8' ip='192.168.255.108'/>
      <host mac='08:4F:A9:00:00:09' name='node9' ip='192.168.255.109'/>
      <host mac='08:4F:A9:00:00:0A' name='node10' ip='192.168.255.110'/>
      <host mac='08:4F:A9:00:00:0B' name='node11' ip='192.168.255.111'/>
      <host mac='08:4F:A9:00:00:0C' name='node12' ip='192.168.255.112'/>
      <host mac='08:4F:A9:00:00:0D' name='node13' ip='192.168.255.113'/>
      <host mac='08:4F:A9:00:00:0E' name='node14' ip='192.168.255.114'/>
      <host mac='08:4F:A9:00:00:0F' name='node15' ip='192.168.255.115'/>
      <host mac='52:54:00:8a:8b:c1' name='node0' ip='192.168.255.100'/>
    </dhcp>
  </ip>
</network>
EOF

virsh net-define /mnt/extra/management.xml && virsh net-autostart management && virsh net-start management && virsh net-list --all

./kvm-install-vm create -c 4 -m 16384 -d 100 -t ubuntu2004 -f host-passthrough -k /root/.ssh/id_rsa.pub -l /mnt/extra/virt/images -L /mnt/extra/virt/vms -b virbr100 -T US/Eastern -M 52:54:00:8a:8b:c1 node0

virsh list --all && brctl show && virsh net-list --all

sleep 90

ssh -o "StrictHostKeyChecking=no" ubuntu@node0 "uname -a && sudo ip a"

ssh -o "StrictHostKeyChecking=no" ubuntu@node0 'echo "root:gprm8350" | sudo chpasswd'
ssh -o "StrictHostKeyChecking=no" ubuntu@node0 'echo "ubuntu:kyax7344" | sudo chpasswd' 
ssh -o "StrictHostKeyChecking=no" ubuntu@node0 "sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config"
ssh -o "StrictHostKeyChecking=no" ubuntu@node0 "sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config" 
ssh -o "StrictHostKeyChecking=no" ubuntu@node0 "sudo systemctl restart sshd"
ssh -o "StrictHostKeyChecking=no" ubuntu@node0 "sudo rm -rf /root/.ssh/authorized_keys"

ssh -o "StrictHostKeyChecking=no" ubuntu@node0 "cat << EOF | sudo tee /etc/modprobe.d/qemu-system-x86.conf
options kvm ignore_msrs=1 report_ignored_msrs=0
options kvm_intel nested=1 enable_apicv=0 ept=1
EOF"

ssh -o "StrictHostKeyChecking=no" ubuntu@node0 "cat << EOF | sudo tee /etc/sysctl.conf
net.ipv4.ip_forward=1
net.ipv4.conf.all.forwarding=1
net.ipv6.conf.all.forwarding=1
net.mpls.conf.lo.input=1
net.mpls.conf.ens3.input=1
net.mpls.platform_labels=100000
net.ipv4.tcp_l3mdev_accept=1
net.ipv4.udp_l3mdev_accept=1
EOF"

ssh -o "StrictHostKeyChecking=no" ubuntu@node0 "cat << EOF | sudo tee /etc/sysctl.d/60-lxd-production.conf
fs.inotify.max_queued_events=1048576
fs.inotify.max_user_instances=1048576
fs.inotify.max_user_watches=1048576
vm.max_map_count=262144
kernel.dmesg_restrict=1
net.ipv4.neigh.default.gc_thresh3=8192
net.ipv6.neigh.default.gc_thresh3=8192
net.core.bpf_jit_limit=3000000000
kernel.keys.maxkeys=2000
kernel.keys.maxbytes=2000000
EOF"

ssh -o "StrictHostKeyChecking=no" ubuntu@node0 "sudo apt update -y && sudo apt install vim git wget net-tools locate -y"

ssh -o "StrictHostKeyChecking=no" ubuntu@node0 "sudo apt update && sudo apt upgrade -y"

ssh -o "StrictHostKeyChecking=no" ubuntu@node0 "sudo DEBIAN_FRONTEND=noninteractive apt-get install linux-generic-hwe-20.04 --install-recommends -y"
ssh -o "StrictHostKeyChecking=no" ubuntu@node0 "sudo apt autoremove -y && sudo apt --fix-broken install -y"

ssh -o "StrictHostKeyChecking=no" ubuntu@node0 "sudo apt-get install genisoimage libguestfs-tools libosinfo-bin virtinst qemu qemu-kvm qemu-system git vim net-tools wget curl bash-completion python3-pip libvirt-daemon-system virt-manager bridge-utils libnss-libvirt libvirt-clients osinfo-db-tools intltool sshpass ovmf genometools virt-top haveged -y"
ssh -o "StrictHostKeyChecking=no" ubuntu@node0 "sudo sed -i 's/hosts:          files dns/hosts:          files libvirt libvirt_guest dns/' /etc/nsswitch.conf && sudo lsmod | grep kvm"

ssh -o "StrictHostKeyChecking=no" ubuntu@node0 "sudo usermod -aG libvirt ubuntu && sudo adduser ubuntu libvirt-qemu && sudo adduser ubuntu kvm && sudo adduser ubuntu libvirt-dnsmasq && echo 0 | sudo tee /sys/module/kvm/parameters/halt_poll_ns"
ssh -o "StrictHostKeyChecking=no" ubuntu@node0 "sudo sed -i 's/0770/0777/' /etc/libvirt/libvirtd.conf"

ssh -o "StrictHostKeyChecking=no" ubuntu@node0 "sudo DEBIAN_FRONTEND=noninteractive apt install cinnamon-desktop-environment --install-recommends -y"
ssh -o "StrictHostKeyChecking=no" ubuntu@node0 "sudo DEBIAN_FRONTEND=noninteractive apt install xrdp --install-recommends -y"
ssh -o "StrictHostKeyChecking=no" ubuntu@node0 "sudo ufw allow from any to any port 3389 proto tcp"
ssh -o "StrictHostKeyChecking=no" ubuntu@node0 "sudo systemctl enable --now xrdp"
ssh -o "StrictHostKeyChecking=no" ubuntu@node0 "sudo systemctl set-default graphical.target"

ssh -o "StrictHostKeyChecking=no" ubuntu@node0 "sudo reboot"
