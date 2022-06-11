ESXI_DOMAIN = 'esxi.lab'
MANAGEMENT_CERTIFICATE_PATH = "shared/tls/example-esxi-ca/#{ESXI_DOMAIN}"
DATASTORE_DISK_SIZE_GB = 80
HOSTS = 3

# enable typed triggers.
# NB this is needed to modify the libvirt domain scsi controller model to virtio-scsi.
ENV['VAGRANT_EXPERIMENTAL'] = 'typed_triggers'

require 'open3'

# create the management certificate that will be used to access the esxi
# management web interface (hostd).
def ensure_management_certificate
  return if File.exists? MANAGEMENT_CERTIFICATE_PATH
  system("bash provision-certificate.sh #{ESXI_DOMAIN}")
end

ensure_management_certificate

Vagrant.configure(2) do |config|
  (1..HOSTS).each do |i|
    config.vm.define "node#{i}" do |node|
      node.vm.box = 'esxi-7.0.3-amd64'
      # node.vm.box = 'esxi-7.0.3-uefi-amd64'
      # node.vm.network "private_network", ip: "192.168.100.2#{i}"
      # node.vm.network "private_network", ip: "192.168.200.2{i}"
      node.vm.hostname = "node#{i}.esxi.lab"

    config.vm.provider 'libvirt' do |lv|
      lv.management_network_name = "management"
      lv.management_network_address = "192.168.255.0/24"
      lv.management_network_mac = "52:54:00:8a:8b:c#{i}"
      lv.memory = 64*1024
      lv.cpus = 12
      lv.storage :file, :bus => 'ide', :cache => 'unsafe', :size => "#{DATASTORE_DISK_SIZE_GB}G"
    end

    # NB you must use `privileged: false` in the provisioning steps because esxi
    #    does not have the `sudo` command, and, by default, you are already
    #    executing commands as root.

    # do not Join the VMware Customer Experience Improvement Program.
    config.vm.provision :shell, privileged: false, inline: 'esxcli system settings advanced set -o /UserVars/HostClientCEIPOptIn -i 2'

    # configure the management certificate.
    config.vm.provision :file, source: MANAGEMENT_CERTIFICATE_PATH, destination: '/tmp/tls'
    config.vm.provision :shell, privileged: false, path: 'provision-management-certificate.sh'

    # create the datastore1 datastore in the second disk.
    config.vm.provision :shell, privileged: false, path: 'provision-datastore.sh'

    # show the installation summary.
    config.vm.provision :shell, privileged: false, path: 'summary.sh'
    
  end
 end 
end
