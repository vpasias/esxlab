# -*- mode: ruby -*-
# vi: set ft=ruby :

ESXI_DOMAIN = 'esxi.lab'
#MANAGEMENT_CERTIFICATE_PATH = "shared/tls/example-esxi-ca/#{ESXI_DOMAIN}"
DATASTORE_DISK_SIZE_GB = 900
HOSTS = 3

# enable typed triggers.
# NB this is needed to modify the libvirt domain scsi controller model to virtio-scsi.
ENV['VAGRANT_EXPERIMENTAL'] = 'typed_triggers'

require 'open3'

Vagrant.configure(2) do |config|
  
  (1..HOSTS).each do |i|
    config.vm.define "node#{i}" do |node|
      node.vm.box = 'esxi-7.0.3-amd64'
      # node.vm.box = 'esxi-7.0.3-uefi-amd64'
      node.vm.network "private_network", ip: "192.168.100.2#{i}"
      node.vm.network "private_network", ip: "192.168.200.2#{i}"
      node.vm.hostname = "node#{i}.esxi.lab"

      node.vm.provider 'libvirt' do |lv|
        lv.management_network_name = "vagrant-libvirt"
        lv.management_network_mac = "08:4F:A9:00:00:0#{i}"
        lv.cpu_mode = 'host-passthrough'
        lv.nested = true
        lv.memory = 32*1024
        lv.cpus = 8
        lv.storage :file, :bus => 'ide', :cache => 'unsafe', :size => "#{DATASTORE_DISK_SIZE_GB}G"
      end
    
    # create the management certificate that will be used to access the esxi
    # management web interface (hostd).
    #def ensure_management_certificate
    #  return if File.exists? MANAGEMENT_CERTIFICATE_PATH
    #  system("bash provision-certificate.sh #{ESXI_DOMAIN}")
    #end

    #ensure_management_certificate

    # NB you must use `privileged: false` in the provisioning steps because esxi
    #    does not have the `sudo` command, and, by default, you are already
    #    executing commands as root.

    # do not Join the VMware Customer Experience Improvement Program.
    node.vm.provision :shell, privileged: false, inline: 'esxcli system settings advanced set -o /UserVars/HostClientCEIPOptIn -i 2'

    # configure the management certificate.
    #node.vm.provision :file, source: MANAGEMENT_CERTIFICATE_PATH, destination: '/tmp/tls'
    #node.vm.provision :shell, privileged: false, path: 'provision-management-certificate.sh'
    
    # create the datastore1 datastore in the second disk.
    #node.vm.provision :shell, privileged: false, path: 'provision-datastore.sh'

    # show the installation summary.
    node.vm.provision :shell, privileged: false, path: 'summary.sh'
    
  end
 end 

    config.vm.define "node0" do |mgt|
      mgt.vm.box = "peru/windows-10-enterprise-x64-eval"
      # mgt.vm.box = "peru/windows-server-2022-standard-x64-eval"
      mgt.vm.network "private_network", ip: "192.168.100.20"
      mgt.vm.hostname = "node0"
      mgt.vm.provider 'libvirt' do |lvn|
        lvn.cpu_mode = 'host-passthrough'
        lvn.nested = true        
        lvn.memory = 8*1024
        lvn.cpus = 4
      end  
    end

end
