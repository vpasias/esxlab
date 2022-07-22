#!/bin/bash
#
HOME=/mnt/extra/

cat > /mnt/extra/management.xml <<EOF
<network>
  <name>management</name>
  <forward mode='nat'/>
  <bridge name='virbr101' stp='on' delay='0'/>
  <ip address='192.168.254.1' netmask='255.255.255.248'>
    <dhcp>
      <range start='192.168.254.2' end='192.168.254.6'/>
      <host mac='52:54:00:8a:8b:c1' name='node0' ip='192.168.254.3'/>
    </dhcp>
  </ip>
</network>
EOF

virsh net-define /mnt/extra/management.xml && virsh net-autostart management && virsh net-start management

ip a && sudo virsh net-list --all

sleep 20

#  AIO
./kvm-install-vm create -c 52 -m 262144 -t centos8 -d 1200 -f host-passthrough -k /root/.ssh/id_rsa.pub -l /mnt/extra/virt/images -L /mnt/extra/virt/vms -b virbr101 -T US/Eastern -M 52:54:00:8a:8b:c1 node0

sleep 60

sudo virsh net-list --all && sudo brctl show && sudo virsh list --all

ssh -o "StrictHostKeyChecking=no" centos@node0 "sudo ip a"

ssh -o "StrictHostKeyChecking=no" centos@node0 'echo "root:gprm8350" | sudo chpasswd'
ssh -o "StrictHostKeyChecking=no" centos@node0 'echo "centos:kyax7344" | sudo chpasswd'
ssh -o "StrictHostKeyChecking=no" centos@node0 "sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config"
ssh -o "StrictHostKeyChecking=no" centos@node0 "sudo systemctl restart sshd"
ssh -o "StrictHostKeyChecking=no" centos@node0 "sudo rm -rf /root/.ssh/authorized_keys"

ssh -o "StrictHostKeyChecking=no" centos@node0 "cat << EOF | sudo tee /etc/modprobe.d/kvm.conf
options kvm_intel nested=1
EOF"

ssh -o "StrictHostKeyChecking=no" centos@node0 "sudo modprobe -r kvm_intel && sudo modprobe -a kvm_intel"

ssh -o "StrictHostKeyChecking=no" centos@node0 "sudo dnf -y update && sudo dnf install -y git" 
ssh -o "StrictHostKeyChecking=no" centos@node0 "sudo dnf -y install centos-release-ansible-29"
ssh -o "StrictHostKeyChecking=no" centos@node0 'sudo sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/CentOS-SIG-ansible-29.repo'
ssh -o "StrictHostKeyChecking=no" centos@node0 "sudo dnf --enablerepo=centos-ansible-29 -y install ansible"
ssh -o "StrictHostKeyChecking=no" centos@node0 "sudo dnf module -y install python38"

ssh -o "StrictHostKeyChecking=no" centos@node0 "sudo reboot"
