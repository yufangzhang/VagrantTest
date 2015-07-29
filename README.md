# VagrantTest
##Pre-Requisites:
+ ###[Vagrant] (https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.4.dmg)
+ ###Chef-solo:
  ```
  curl -L https://www.opscode.com/chef/install.sh | bash
  ```
  print the version number with `chef-solo -v` 
+ ###Vagrant plugins:
  ```
  vagrant plugin install vagrant-omnibus
  vagrant plugin install vagrant-berkshelf
  ```
  
  * Berkshelf is a tool for managing cookbook dependencies. 
  * The omnibus plugin is useful to ensure you're using the latest revision of chef. 
+ ###The Vagrant Berkshelf plugin requires Berkshelf from the [Chef Development Kit](https://downloads.getchef.com/chef-dk)
##Steps:
+ ###Install the nginx webserver via chef-solo
  ```
  berks cookbook chef-repo
  cd chef-repo
  ```
+ ###Edit the Vagrantfile to install `nginx`:
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
    chef.add_recipe "apt"
    chef.add_recipe "nginx"
  end

  end
  ```
+ ###Edit the Berksfile to:
  ```
  source "https://supermarket.chef.io"
  metadata
  cookbook "nginx", "~> 2.6"
  ```
