
exec { 'apt-get update':
  path => '/usr/bin',
}
file{ '/var/www/app/':
  ensure => 'directory',
  
}

file{ '/var/www/app/previous.html':
    ensure  => present,
    source => ["/var/www/app/index.html","/vagrant/Vagrantfile"],
    #subscribe => Exec['restart nginx'],
  }


file{ '/var/www/app/index.html':
    ensure => present, 
    source => "/vagrant/app/index.html",
    require => File['/var/www/app/previous.html'],    
    notify  => Exec['restart nginx'],
    #audit => 'content',
    #content => file('/var/www/app/previous.html'),
}


exec {
    'restart nginx':
      command     => '/usr/sbin/service nginx restart',
      #subscribe => File["/var/www/app/index.html"],
      require => File['/var/www/app/index.html'],
      refreshonly => true;
}

package { 'vim':
  ensure => present,
}





include nginx, php
