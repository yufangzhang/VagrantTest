# VagrantTest
##Install [Vagrant] (https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.4.dmg)
##To run the solution:

  * Inside folder `puppet-demo`, run
  ```
  vagrant up
  ```
  
  * At this time, run 127.0.0.1:5555 in the browser may return a 502 Bad Gateway. To solve the problem, ssh into the guest machine:
  ```
  vagrant ssh
  ```
  
  * Go to `/etc/php5/fpm/pool.d/www.conf` and edit the line `listen = /var/run/php5-fpm.sock` to `listen = 127.0.0.1:9000`. Run `sudo service php5-fpm restart` afterwards
