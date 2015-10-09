Yumrepo <| |> -> Package <| |>

# Yum manifest
include ::yum
class { 'yum::repo::repoforge': }
class { 'yum::repo::epel': }
class { 'yum::repo::remi': }

# Firewall manifest
# notify {"Test: ${firewall_rules}":} to debug ::fqdn/environment variables
resources { 'firewall': purge => true }
Firewall {
  before  => Class['::rhel::firewall::post'],
  require => Class['::rhel::firewall::pre'],
}
include ::rhel::firewall
$firewall_rules = hiera('firewall_rules', false)
create_resources('firewall', $firewall_rules)

# Nginx manifest
include ::nginx

# Php manifest
class { 'yum::repo::remi_php56': }
include ::php

# MongoDB manifest
# notify {"Test: ${mongodb_databases}":} to dump databases
$mongodb_globals = hiera('mongodb_globals', false)
class { '::mongodb::globals':
  manage_package_repo => $mongodb_globals['manage_package_repo'],
  use_enterprise_repo => $mongodb_globals['use_enterprise_repo'],
  server_package_name => $mongodb_globals['server_package_name'],
  mongos_package_name => $mongodb_globals['mongos_package_name'],
  client_package_name => $mongodb_globals['client_package_name'],
  version => $mongodb_globals['version'],
  user => $mongodb_globals['user'],
  group => $mongodb_globals['group'],
}
class { '::mongodb::server': }
class { '::mongodb::client': }
$mongodb_databases = hiera('mongodb_databases', false)
create_resources('mongodb::db', $mongodb_databases)
