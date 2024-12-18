#
class base::core::netlabel (
  Array[String]	$interfaces,
) {
  #
  ## Make this class private
  #

  assert_private()

  #
  ## Defaults
  #

  File {
    owner   => 'root',
    group   => 'root',
    seluser => 'system_u',
    selrole => 'object_r',
  }

  package {'netlabel_tools':
    ensure => installed,
  }

  file {'/etc/netlabel.rules':
    ensure  => file,
    seltype => 'etc_t',
    mode    => '0444',
    content => template('base/core/netlabel/netlabel.rules.erb'),
    notify  => Service['netlabel'],
  }

  service {'netlabel':
    ensure  => 'running',
    enable  => true,
    require => File['/etc/systemd/system/netlabel.service.d/override.conf'],
  }

  file {'/etc/systemd/system/netlabel.service.d':
    ensure  => directory,
    seltype => 'netlabel_mgmt_unit_file_t',
    mode    => '0755',
    purge   => true,
    require => Package['netlabel_tools'],
  }

  file {'/etc/systemd/system/netlabel.service.d/override.conf':
    ensure  => file,
    seltype => 'netlabel_mgmt_unit_file_t',
    mode    => '0644',
    content => template('base/core/netlabel/systemd-override.conf.erb'),
    require => File['/etc/systemd/system/netlabel.service.d'],
    notify  => Exec['Refresh systemd'],
  }
}
