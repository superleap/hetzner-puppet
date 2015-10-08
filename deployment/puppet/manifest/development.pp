Yumrepo <| |> -> Package <| |>

# Yum manifest
include ::yum
class { 'yum::repo::repoforge': }
class { 'yum::repo::epel': }
class { 'yum::repo::remi': }

# Firewall manifest
resources { 'firewall': purge => true }
Firewall {
  before  => Class['::rhel::firewall::post'],
  require => Class['::rhel::firewall::pre'],
}
include ::rhel::firewall
firewall { '100 allow openssh':
  chain   => 'INPUT',
  state   => ['NEW'],
  dport   => '22',
  proto   => 'tcp',
  action  => 'accept',
}
firewall { '100 allow httpd':
  chain   => 'INPUT',
  state   => ['NEW'],
  dport   => '80',
  proto   => 'tcp',
  action  => 'accept',
}

# Nginx manifest
include ::nginx

# Php manifest
class { 'yum::repo::remi_php56': }
include ::php
