# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"
VAGRANT_NAME=File.basename(Dir.getwd)

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at http://vagrantup.com.

  # My config

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "bento/centos-7.1"
  config.vm.provision :shell, :path => "bootstrap.sh", :args => VAGRANT_NAME
  config.vm.provision :shell, :path => "specific_bootstrap.sh", :args => VAGRANT_NAME

  #config.vm.base_mac = "00163E9482A9"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  #config.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/centos-64-x64-vbox4210.box"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  #config.vm.network :forwarded_port, guest: 80, host: 8080
  #config.vm.network :bridged

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.

  config.vm.network "private_network", type: "dhcp", nic_type: "virtio"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  #config.vm.network :public_network, {bridge:'eth0',auto_config:true}

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  # config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider :virtualbox do |vb|
   vb.gui = false
   vb.name = VAGRANT_NAME

   # Use VBoxManage to customize the VM. For example to change memory:
   vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  config.vm.hostname = VAGRANT_NAME + ".vagrant.dev"
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ip_resolver = proc do |vm, resolving_vm|
    if hostname = (vm.ssh_info && vm.ssh_info[:host])
      `vagrant ssh -c "hostname -I"`.split()[1]
    end
  end
end
