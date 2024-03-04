# 2-puppet_custom_http_response_header.pp

# Run apt-get update
exec { 'apt-update':
  command => '/usr/bin/apt-get update'
}

# Install nginx package
package { 'nginx':
  ensure => installed,
}

# Define a custom fact to retrieve the hostname
# This custom fact will be used to obtain the hostname of the server
# Nginx is running on and set it as the value for the custom HTTP header
file { '/etc/facter/facts.d/hostname.txt':
  ensure  => present,
  content => "hostname=${::hostname}\n",
}

# Notify Puppet to reload facts after the custom fact is created
exec { 'reload_facts':
  command     => '/opt/puppetlabs/puppet/bin/puppet facts upload',
  refreshonly => true,
  subscribe   => File['/etc/facter/facts.d/hostname.txt'],
}

# Define the custom HTTP header configuration for Nginx
file { '/etc/nginx/conf.d/custom_headers.conf':
  ensure  => present,
  content => "add_header X-Served-By ${::hostname};\n",
  notify  => Service['nginx'],
}

# Restart Nginx to apply the changes
service { 'nginx':
  ensure     => running,
  enable     => true,
  subscribe  => File['/etc/nginx/conf.d/custom_headers.conf'],
}

