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
#anchor { 'mongodb::db::start': }->
#class { 'mongodb::server::config': }->
#class { 'mongodb::db': }->
#anchor { 'mongodb::db::end': }
include ::mongodb
class { 'mongodb::client': }
$mongodb_databases = hiera('mongodb_databases', false)
create_resources('mongodb::db', $mongodb_databases)
