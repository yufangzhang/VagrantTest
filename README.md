# VagrantTest

##Steps:
  + Install [Vagrant] (https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.4.dmg)
  
  + Configure Vagrant
    * Initialization
     ```
     mkdir puppet-demo
     cd puppet-demo
     vagrant init
     ```
     
     In the `puppet-demo` folder, it should have a Vagrantfile afterwards.
    
    * Edit `Vagrantfile` to add a base box `puphpet/ubuntu1404-x64`:
    
     ```
     Vagrant.configure("2") do |config|
       config.vm.box = "puphpet/ubuntu1404-x64"
       config.vm.network :forwarded_port, host: 5555, guest: 80
     end
     ```
    
     Also, forward all network activity on port 5000 to port 80 within our Vagrant guest machine.
    * Save and run `vagrant up`. It should import the box and be completed sucessfully.
    
  + Use Puppet to automate environment configuration
    * Create directories for Puppet to work from:
     ```
     mkdir -p puppet/{manifests,modules}
     mkdir app
     ```
     
    * Initialize `manifest` 
     Create and edit `puppet/manifests/init.pp` to look like this:
     ```
     #Run apt-get update;
     exec { 'apt-get update':
       path => '/usr/bin',
     }
     #Ensure the Vim package is installed and present; It is optional.
     package { 'vim':
       ensure => present,
     }
     #Ensure the /var/www directory is present.
     file { '/var/www/':
       ensure => 'directory',
     }
     ```
     
    * Edit Vagrantfile to provision Puppet at install
     Add the following lines to Vagrantfile:
     ```
     config.vm.provision :puppet do |puppet|
       puppet.manifests_path = 'puppet/manifests'
       puppet.module_path = 'puppet/modules'
       puppet.manifest_file = 'init.pp'
     end
     ```
     
     It should look like this now:
     ```
     Vagrant.configure("2") do |config|
       config.vm.box = "puphpet/ubuntu1404-x64"
       config.vm.network :forwarded_port, host: 5555, guest: 80
       config.vm.provision :puppet do |puppet|
         puppet.manifests_path = 'puppet/manifests'
         puppet.module_path = 'puppet/modules'
         puppet.manifest_file = 'init.pp'
       end
     end
     ```
     
     Now we can reload the box and force Vagrant to run Puppet:
     ```
     vagrant reload --provision
     ```
     
  + Installing Nginx and Puppet
    * Create a directory structure to save different dependencies:
      ```
      cd puppet/modules
      mkdir -p nginx/{files,manifests}
      mkdir -p php/{files,manifests}
      ```
      
      And we should add the following line to puppet/manifests/init.pp:
      ```
      include nginx, php
      ```
      This will ensure our nginx and php manifests are included during the Vagrant provision.
    * Initialize Nginx configuration
      Edit puppet/modules/nginx/manifests/init.pp to look like this:
      ```
      class nginx {
       # Install the nginx package. This relies on apt-get update
       package { 'nginx':
         ensure => 'present',
         require => Exec['apt-get update'];
       }
       # Make sure that the nginx service is running
       service { 'nginx':
         ensure => running,
         require => Package['nginx'],
     
       }
     
       
       # Add vhost template
       file { 'vagrant-nginx':
           path => '/etc/nginx/sites-available/127.0.0.1',
           ensure => file,
           require => Package['nginx'],
           source => 'puppet:///modules/nginx/127.0.0.1',
       }
     
       # Disable default nginx vhost
       file { 'default-nginx-disable':
           path => '/etc/nginx/sites-enabled/default',
           ensure => absent,
           require => Package['nginx'],
       }
     
       # Symlink our vhost in sites-enabled
       file { 'vagrant-nginx-enable':
           path => '/etc/nginx/sites-enabled/127.0.0.1',
           target => '/etc/nginx/sites-available/127.0.0.1',
           ensure => link,
           notify => Service['nginx'],
           require => [
               File['vagrant-nginx'],
               File['default-nginx-disable'],
           ],
       }
     }
      ```
      
      We basically install and run Nginx. Then we create and enable a vhost based on a template we will create next.       Note that puppet:///modules/nginx/127.0.0.1 will reference puppet/modules/nginx/files/127.0.0.1 on the host.
    * Configure our Nginx vhost:
    ```
    # puppet-demo/puppet/modules/nginx/files/127.0.0.1
    server {
     listen 80;
     server_name _;
     root /var/www/app;
     index index.php index.html;
   
     location / {
       try_files $uri /index.php;
     }
   
     location ~ \.php$ {
            try_files $uri =404;
            fastcgi_pass unix:/var/run/php5-fpm.sock;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
 
     }
    }
    ```
    Make sure Nginx is listenning on port 80
    * Configure PHP:
    ```
    # puppet-demo/puppet/modules/php/manifests/init.pp
    class php {
    
      # Install the php5-fpm and php5-cli packages
      package { ['php5-fpm',
                 'php5-cli']:
        ensure => present,
        require => Exec['apt-get update'],
      }
    
      # Make sure php5-fpm is running
      service { 'php5-fpm':
        ensure => running,
        require => Package['php5-fpm'],
      }
    }
    ```
    
    At this point, run `vagrant reload --provision`. Hopefully, everything should work out as expected.
  + Create a simple PHP script:
    Keep the application code within /puppet-demo/app/, and because we forwarded incoming Vagrant requests on port 5555 to port 80 on the guest machine, it means we can hit the app folder through a standard web server request. Therefore, we can create a simple PHP script inside `/puppet-demo/app/` called index.php:
    ```
    <?php
    print("Hello World");
    ?>
    ```
  + Run a simple test to see if Nginx is listening on port 80
    Add a line to Vagrantfile to use Vagrant's shell provisioner to ensure that nginx is listening on port 80:
    ```
    config.vm.provision :shell, path: "test_port.sh"
    ```
    
    In `test_port.sh`, we parse all occupied ports to see if Nginx is listenning on the right port. The bash looks like:
    ```
    port=$(sudo netstat -taupen | grep nginx | grep -v tcp6| awk '{print $4}' | awk -F ":" '{print $2}')
    if [ "$port"=="80" ]; then
    	echo "Nginx is listening on port 80"
    else 
    	echo "Nginx fails to listen on port 80"
    fi
    ```
    Run `vagrant provision`, it is expected to see "==> default: Nginx is listening on port 80" on the terminal output.
  + Manage the contents of /etc/sudoers file
    * Add one more dependency on puppet/manifests by doing:
    ```
    cd puppet/modules
    mkdir -p sudoers/{files,manifests}
    ```
    * Edit puppet/manifests/init.pp to include `sudoers` as well. Now it should look like:
    ```
    #Run apt-get update;
     exec { 'apt-get update':
       path => '/usr/bin',
     }
     #Ensure the Vim package is installed and present; It is optional.
     package { 'vim':
       ensure => present,
     }
     #Ensure the /var/www directory is present.
     file { '/var/www/':
       ensure => 'directory',
     }
     
    include nginx, php, sudoers
    ```
    * Create the file puppet/modules/sudoers/manifests/init.pp with the following contents:
    ```
    # Manage the sudoers file
    class sudoers {
      file { '/etc/sudoers':
        source => 'puppet:///modules/sudoers/sudoers',
        mode => '0440', 
        owner => 'root',
        group => 'root',
      }
    }
    ```
    This suggests that /etc/sudoers on the guest machine would be copied from puppet/modules/sudoers/files/sudoers from the host machine.
    * Create puppet/modules/sudoers/files/sudoers
    ```
    # User privilege specification
    root    ALL=(ALL) ALL
    #vagrant user can sudo without a password
    vagrant ALL=(ALL) NOPASSWD:ALL
    # users in admin group can sudo with a password
    %admin  ALL=(ALL) ALL

    ```
    Ensure that Vagrant user can sudo without a password and that anyone in the admin group can sudo with a password.
    * Check the syntax of the sudoers file:
    In `puppet/`, run `visudo -c -f modules/sudoers/files/sudoers`, and it should return `modules/sudoers/files/sudoers: parsed OK`
    
    * Test sudoers file
    Run `vagrant provision` and `vagrant ssh` to ssh into the virtual machine. 
    Firstly, try if vagrant can sudo without a password by runing `$ sudo -s`. It should be switched to root user without a password.
    Then, add a user `foo` in the `admin` group by running the following code:
    ```
    sudo useradd foo
    sudo passwd foo
    sudo groupadd admin
    sudo adduser foo admin
    ```
    At this point, foo should be in admin group. Now if you run `su foo`, it would ask for a password to switch to root user.
  + Make sure Nginx will not restart unless changes made
  + 
