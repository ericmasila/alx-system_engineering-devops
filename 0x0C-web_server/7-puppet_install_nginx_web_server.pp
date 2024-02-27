# Install Nginx package
package { 'nginx':
  ensure => installed,
}

# Ensure Nginx service is running and enabled
service { 'nginx':
  ensure  => running,
  enable  => true,
  require => Package['nginx'],
}

# Configure Nginx server
file { '/etc/nginx/sites-available/default':
  ensure  => present,
  content => "
server {
    listen 80;
    server_name _;
    
    location / {
        return 200 'Hello World!';
    }

    location /redirect_me {
        return 301 https://www.example.com;
    }
}
  ",
  require => Package['nginx'],
  notify  => Service['nginx'],
}

# Ensure the symlink to enable the default site is present
file { '/etc/nginx/sites-enabled/default':
  ensure  => link,
  target  => '/etc/nginx/sites-available/default',
  require => File['/etc/nginx/sites-available/default'],
  notify  => Service['nginx'],
}

