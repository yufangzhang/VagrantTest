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
