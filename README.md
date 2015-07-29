# VagrantTest
##Steps:
### Create a Vagrantfile using the box puphpet/ubuntu1404-x64:
  ```
  vagrant init
  vagrant box add puphpet/ubuntu1404-x64
  ```
  
  configure the Vagrantfile
  ```
  config.vm.box = "puphpet/ubuntu1404-x64";
  ```
  
  boot the virtual machine running ubuntu 14.04
  ```
  vagrant up
  ```
### Install the lastest version of chef-solo:
  ```
  curl -L https://www.opscode.com/chef/install.sh | bash
  ```
  print the version number with `chef-solo -v` 
### To more effectively use chef I'd advise installing the following vagrant plugins:
  ```
  vagrant plugin install vagrant-omnibus
  vagrant plugin install vagrant-berkshelf
  ```
  
  Berkshelf is a tool for managing cookbook dependencies. The omnibus plugin is useful to ensure you're using the latest revision of chef.
### Install the nginx webserver via chef-solo
  ```
  git clone https://github.com/opscode-cookbooks/nginx.git cookbooks/nginx
  ```
  Edit the Vagrantfile to install `nginx`:
  ```
  Vagrant.configure("2") do |config|

  # Box details
  config.vm.box = "Berkshelf-CentOS-6.3-x86_64-minimal"
  config.vm.box_url = "https://dl.dropbox.com/u/31081437/Berkshelf-CentOS-6.3-x86_64-minimal.box"

  # Plugins
  config.berkshelf.enabled = true
  config.omnibus.chef_version = :latest

  # Chef solo provisioning
  config.vm.provision :chef_solo do |chef|
    chef.add_recipe "nginx"
  end

end
```
