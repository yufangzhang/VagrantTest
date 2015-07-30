# VagrantTest
##Pre-Requisites:
+ ### [Vagrant] (https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.4.dmg)

+ ### Chef-solo:
  ```
  curl -L https://www.opscode.com/chef/install.sh | bash
  ```
  print the version number with `chef-solo -v` 
+ ### Vagrant plugins:
  ```
  vagrant plugin install vagrant-omnibus
  vagrant plugin install vagrant-berkshelf
  ```
  
  * Berkshelf is a tool for managing cookbook dependencies. 
  * The omnibus plugin is useful to ensure you're using the latest revision of chef. 

+ ### The Vagrant Berkshelf plugin requires Berkshelf from the [Chef Development Kit](https://downloads.getchef.com/chef-dk)

##Steps:

+ ### Install the nginx webserver via chef-solo
  ```
  berks cookbook chef-repo
  cd chef-repo
  ```
  
+ ### Edit the Vagrantfile to install `nginx`:
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
  
+ ### Edit the Berksfile to:
  ```
  source "https://supermarket.chef.io"
  metadata
  cookbook "nginx", "~> 2.6"
  ```
  
+ ### Check if nginx is listening on port80 using Vagrant's shell provisioner:
  * Add port forwarding to Vagrantfile:
  ```
  config.vm.network :forwarded_port, guest: 80, host: 8080
  ```
  
  * Configure Vagrant to run this shell script when setting up our machine
  ```
  config.vm.provision :shell, path: "setup.sh"
  ```
  * check it out with browser
  ```
  http://127.0.0.1:8080
  ```
  It will show a 404 Not Found error because we haven’t added any content to our web site yet, the important part is that Nginx Server sent the response: `nginx/1.4.6 (Ubuntu)`

+ ### Vagrant user and admin group:
  
  * Add vagrant user foo to admin group
    Edit `recipes/default.rb` to create user `foo` and group `admin`on the test machine.
    ```
    group 'admin'
    user 'foo' do
      group 'admin'
      system true
      shell '/bin/bash'
    end
    ```
    Save the file and re-run `vagrant provision`
    Note that because we are using well-defined resources that are completely idempotent, if we run vagrant provision again, the Chef run executes more quickly and it does not try to re-create the user/group it already created.
    
    * Add multiple lines to /etc/sudoer file:
    ```
    # Vagrant user can sudo without a password
    vagrant ALL=(ALL) NOPASSWD:ALL
    # users in admin group can sudo with a password
    %admin  ALL=(ALL) ALL
    ```
  
  * 
+ 
