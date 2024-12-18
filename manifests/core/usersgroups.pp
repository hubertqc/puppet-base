#
class base::core::usersgroups () {
  #
  ## Make this class private
  #

  assert_private()

  #
  ## Defaults
  #

  User {
    ensure         => present,
    shell          => '/bin/bash',
    managehome     => false,
    purge_ssh_keys => true,
    membership     => 'inclusive',
  }

  Group {
    ensure => present,
  }

  Ssh_authorized_key {
    ensure => present,
  }

  #
  ## Resources
  #

  class {'base::core::usersgroups::groups': }
  class {'base::core::usersgroups::hubert': }
  class {'base::core::usersgroups::root': }
  class {'base::core::usersgroups::mailtasks': }

  file {'/etc/security/access.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    seluser => 'system_u',
    selrole => 'object_r',
    seltype => 'etc_t',
    mode    => '0444',
    source  => 'puppet:///modules/base/core/usersgroups/access.conf',
  }
}
