
exec { 'apt-get update':
  path => '/usr/bin',
}
file{ '/var/www/app/':
  ensure => 'directory',
  
}

file{ '/var/www/app/previous.php':
    ensure  => present,
    source => ["/var/www/app/index.php","/vagrant/Vagrantfile"],
    #subscribe => Exec['restart nginx'],
  }


file{ '/var/www/app/index.php':
    ensure => present, 
    source => "/vagrant/app/index.php",
    require => File['/var/www/app/previous.php'],    
    notify  => Exec['restart nginx'],
    #audit => 'content',
    #content => file('/var/www/app/previous.php'),
}


exec {
    'restart nginx':
      command     => '/usr/sbin/service nginx restart',
      #subscribe => File["/var/www/app/index.php"],
      require => File['/var/www/app/index.php'],
      refreshonly => true;
}

package { 'vim':
  ensure => present,
}





include nginx, php, sudoers
