# -*- mode: ruby -*-
# vi: set ft=ruby :

PREFIXES=["10.10.10"]

machines = {
#   Name        CPU, RAM, NETs
'master'    => [  1,   1, {1 => "101" }],

'slave-01'  => [  2,   2, {1 => "201" }],
'slave-02'  => [  2,   2, {1 => "202" }],
'slave-03'  => [  2,   2, {1 => "203" }]
}

Vagrant.configure("2") do |config|

	config.vm.box = "bento/centos-7"

  config.hostmanager.enabled      = true
  config.hostmanager.manage_guest = true
  config.hostmanager.manage_host  = true

  config.ssh.insert_key = false

	machines.each_with_index do |(name, (cpu, ram, nets, hdds)), i|

		hostname = "%s" % [name]

		config.vm.define "#{hostname}" do |box|

			box.vm.hostname = "#{hostname}"

			nets.each {|key, suffix|
				box.vm.network :private_network, ip: PREFIXES[key-1] + "." + suffix
			}

			box.vm.provider :virtualbox do |vbox|
				vbox.name = "#{hostname}"
				vbox.customize ["modifyvm", :id, "--cpus",   cpu]
				vbox.customize ["modifyvm", :id, "--memory", ram * 1024]
        vbox.check_guest_additions = false
			end

      box.vm.synced_folder ".", "/vagrant", type: 'virtualbox'
      box.vm.synced_folder "download", "/vagrant/download", create: true

			if (i == ((machines.length) - 1))
	       box.vm.provision :ansible do |ansible|
	         ansible.compatibility_mode = "2.0"
	         ansible.limit = "all"
	         ansible.playbook = "provisioning/playbook.yml"
	       end
	    end
		end
	end
end
