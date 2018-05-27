# -*- mode: ruby -*-
# vi: set ft=ruby :

# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/xenial64"
  
  config.vm.hostname = "chef"

  config.vm.network "private_network", ip: "192.168.33.10"
 
  config.vm.network :public_network,:bridge=>"enp0s8"
 
  config.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
  end


  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  
 config.vm.provision :chef_solo do |chef|
	# indicamos la ruta donde se almacenan los libros de recetas
	chef.cookbooks_path = "cookbooks"
	chef.add_recipe "wordpress"

 end
  
end
