# VagrantTest
##Steps:
### Create a Vagrantfile using the box puphpet/ubuntu1404-x64:
  ```bash
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
  ```bash
  curl -L https://www.opscode.com/chef/install.sh | bash
  ```
  print the version number with `chef-solo -v` 
### Install the nginx webserver via chef-solo
  ```
  git clone https://github.com/opscode-cookbooks/nginx.git cookbooks/nginx
  ```
