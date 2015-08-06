#Run apt-get update;
exec { 'apt-get update':
 path => '/usr/bin',
}
#Ensure the Vim package is installed and present; It is optional.
package { 'vim':
 ensure => present,
}


file{ '/var/www/app/': 
    ensure => 'directory',
    source => "/vagrant/app/",
    recurse => true,
    #if the content of index.php has changed, notify exec['restart nginx']
    notify  => Exec['restart nginx'],
}


exec {
    'restart nginx':
      command     => '/usr/sbin/service nginx restart',
      #require the application file(s) to be copied to guest machine first.
      require => File['/var/www/app/'],
      #if it received a "notify", it would execute the "command".
      refreshonly => true;
}
#Ensure the /var/www directory is present.
file { '/var/www/':
 ensure => 'directory',
}
include nginx, php, sudoers
