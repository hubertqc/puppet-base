#
class base::postfix (
) {

  #
  ## Defaults
  #

  File {
    owner    => 'root',
    group    => 'root',
    seluser  => 'system_u',
    selrole  => 'object_r',
    selrange => 's0',
  }

  #
  ## Resources
  #

  postfix::hashmap { 'transport':
    template => 'base/postfix/transport.erb',
  }

  file {'/etc/systemd/system/postfix.service.d':
    ensure  => directory,
    seltype => 'systemd_unit_file_t',
    mode    => '0755',
    purge   => true,
  }

  file {'/etc/systemd/system/postfix.service.d/override.conf':
    ensure  => file,
    seltype => 'systemd_unit_file_t',
    mode    => '0644',
    content => template('base/postfix/systemd-override.conf.erb'),
    require => File['/etc/systemd/system/postfix.service.d'],
    notify  => Exec['Refresh systemd'],
  }
}
