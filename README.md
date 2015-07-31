# VagrantTest
##Install [Vagrant] (https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.4.dmg)
##To run the solution:

  * Inside folder `puppet-demo`, run
  ```
  vagrant up
  ```
  
  * At this time, running 127.0.0.1:5555 in the browser may return a 502 Bad Gateway. (This can happen when the php5-fpm package reconfigures itself to listen on a different socket.)
  * To solve the problem, ssh into the guest machine:
  ```
  vagrant ssh
  ```
  
  * Go to `/etc/php5/fpm/pool.d/www.conf` and change the listen value to match the `fastcgi_pass` location in your Nginx configuration. In this example, change `listen = /var/run/php5-fpm.sock` to `listen = 127.0.0.1:9000`. 
  * Run `sudo service php5-fpm restart` afterwards.
  * Exit the guest machine and run `vagrant reload --provision`. The browser should return a hello world page.
