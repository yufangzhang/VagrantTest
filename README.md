# VagrantTest
## Create a Vagrantfile using the box puphpet/ubuntu1404-x64:
  vagrant init
  vagrant box add puphpet/ubuntu1404-x64
  config.vm.box = "puphpet/ubuntu1404-x64";
  vagrant up
