# Implement before/after stages
stage { 'first':
  before => Stage['main'],
}
stage { 'last': }
Stage['main'] -> Stage['last']


# Execute yum repos before any package
Yumrepo <| |> -> Package <| |>


# Yum manifest - full hiera support
# hiera_hash: yum_*
class { '::yum': } ->
class { '::yum::repo::repoforge': } ->
class { '::yum::repo::epel': } ->
class { '::yum::repo::remi': }


# Firewall manifest
# notify {"Firewall rules: ${firewall_rules}":}
resources { 'firewall': purge => true }
Firewall {
  before  => Class['::rhel::firewall::post'],
  require => Class['::rhel::firewall::pre'],
}
class { '::rhel::firewall': }

$firewall_rules = hiera_hash('firewall::rules', false)
if is_hash($firewall_rules) and count($firewall_rules) > 0 {
  create_resources('firewall', $firewall_rules)
}


# Nginx manifest
# hiera_hash: nginx::nginx_vhosts
# hiera_hash: nginx::nginx_locations
class { '::nginx': }


# Php manifest
class { '::yum::repo::remi_php56': } ->
class { '::php': }


# MongoDB manifest - partial hiera support
# notify {"Mongo databases: ${mongodb_databases}":}
# notify {"Mongo globals: ${mongodb_globals}":}
$mongodb_globals = hiera_hash('mongodb::globals', false)
class { '::mongodb::globals':
  manage_package_repo => $mongodb_globals['manage_package_repo'],
  use_enterprise_repo => $mongodb_globals['use_enterprise_repo'],
  repo_location       => $mongodb_globals['repo_location'],
  server_package_name => $mongodb_globals['server_package_name'],
  mongos_package_name => $mongodb_globals['mongos_package_name'],
  client_package_name => $mongodb_globals['client_package_name'],
  version             => $mongodb_globals['version'],
  user                => $mongodb_globals['user'],
  group               => $mongodb_globals['group'],
} ->
class { '::mongodb::server': } ->
class { '::mongodb::client': }

$mongodb_databases = hiera('mongodb::databases', false)
if is_hash($mongodb_databases) and count($mongodb_databases) > 0 {
  create_resources('mongodb::db', $mongodb_databases)
}


# Mysql manifest
# notify {"Mariadb settings: ${mysql_server}":}
# notify {"Mariadb databases: ${mysql_dbs}":}
$mysql_server = hiera_hash('mysql::server', false)
$mysql_dbs = hiera_hash('mysql::databases', false)
# @TODO: sanitize hashes
if has_key($mysql_server, 'root_password') and $mysql_server['root_password'] {
  file { "/var/log/mariadb":
    ensure => "directory"
  } ->
  yum::managed_yumrepo { 'mariadb':
    descr          => 'MariaDB',
    baseurl        => 'http://yum.mariadb.org/10.1/centos7-amd64',
    failovermethod => 'priority',
    enabled        => 1,
    gpgcheck       => 1,
    gpgkey         => 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB',
    priority       => 2,
  } ->
  class { '::mysql::server':
    service_name            => $mysql_server['service_name'],
    service_enabled         => $mysql_server['service_enabled'],
    service_manage          => $mysql_server['service_manage'],
    remove_default_accounts => $mysql_server['remove_default_accounts'],
    manage_config_file      => $mysql_server['manage_config_file'],
    override_options        => $mysql_server['override_options'],
    package_name            => $mysql_server['server_package_name'],
    root_password           => $mysql_server['root_password'],
  } ->
  class { '::mysql::client':
    package_name => $mysql_server['client_package_name'],
  }

  if is_hash($mysql_dbs) and count($mysql_dbs) > 0 {
    create_resources('::mysql::db', $mysql_dbs)
  }
}


# NodeJS manifest
# notify {"NodeJS settings: ${nodejs_settings}":}
# notify {"NPM packages: ${nodejs_packages}":}
$nodejs_settings = hiera_hash('nodejs::settings', false)
class { '::nodejs':
  version      => $nodejs_settings['version'],
  target_dir   => $nodejs_settings['target_dir'],
  make_install => $nodejs_settings['make_install']
}

$nodejs_packages = hiera_hash('nodejs::packages', false)
if is_hash($nodejs_packages) and count($nodejs_packages) > 0 {
  create_resources(package, $nodejs_packages)
}


# Redis manifest
# notify {"Redis settings: ${redis_settings}":}
# @TODO: sanitize hashes
$redis_settings = hiera_hash('redis::settings', false)
class { '::redis':
  bind           => $redis_settings['bind'],
  port           => $redis_settings['port'],
  service_group  => $redis_settings['service_group'],
  service_user   => $redis_settings['service_user'],
  manage_repo    => $redis_settings['manage_repo'],
  service_enable => $redis_settings['service_enable'],
  config_owner   => $redis_settings['config_owner']
}


# Go manifest
# hiera_hash: golang::parameter
class { '::golang': }


# Erlang/RabbitMQ manifest
# hiera_hash: erlang::parameter
# hiera_hash: rabbitmq::parameter
class { "::erlang": } ->
class { "::rabbitmq": }


# Docker manifest
# hiera_hash: erlang::parameter
# notify {"Docker images: ${docker_images}":}
group { 'docker':
  ensure => present
} ->
class { '::docker': }

$docker_images = hiera_hash('docker::images')
if is_hash($docker_images) and count($docker_images) > 0 {
  create_resources(docker::image, $docker_images)
}


# Teamspeak manifest
class { 'teamspeak':
  version => '3.0.11.3',
}
