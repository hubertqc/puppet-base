#
class base::core::openvpn (
  String $log_vg,
) {
  #
  ## Make this class private
  #

  assert_private()

  #
  ## Defaults
  #
  #
  File {
    ensure   => directory,
    owner    => 'root',
    group    => 'openvpn',
    seluser  => 'system_u',
    selrole  => 'object_r',
    selrange => 's0',
    require  => Package['openvpn'],
  }

  #
  ## Resources
  #
  group {'openvpn':
    ensure => present,
    gid    => 810,
  }

  package { ['openvpn']:
    ensure => installed,
    require => Group['openvpn'],
  }

  file {'/etc/openvpn':
    mode    => '2755',
    seltype => 'openvpn_etc_t',
  }

  file {'/var/lib/openvpn':
    mode    => '2770',
    seltype => 'openvpn_var_lib_t',
  }

  unless empty($log_vg)
  {
    mountpoint {'/var/log/openvpn':
      ensure => present,
    }
    logical_volume {'lv_openvpn_log':
      ensure       => present,
      volume_group => $log_vg,
      initial_size => '512M',
    }
    filesystem {"/dev/mapper/${log_vg}-lv_openvpn_log":
      ensure  => present,
      fs_type => 'xfs',
      require => Logical_volume['lv_openvpn_log'],
    }
    mount {'/var/log/openvpn':
      ensure  => mounted,
      device  => "/dev/mapper/${log_vg}-lv_openvpn_log",
      atboot  => true,
      fstype  => 'xfs',
      options => 'defaults,noatime,nodiratime,noexec,nosuid,nodev',
      dump    => '0',
      pass    => '0', 
      require => [Mountpoint['/var/log/openvpn'], Filesystem["/dev/mapper/${log_vg}-lv_openvpn_log"]],
      notify  => File['/var/log/openvpn'],
    }
  }

  file {'/var/log/openvpn':
    mode    => '2755',
    seltype => 'openvpn_var_log_t',
  }

  file { ['/etc/systemd/system/openvpn-client@.service.d', '/etc/systemd/system/openvpn-server@.service.d']:
    ensure  => directory,
    group   => 'root',
    seltype => 'systemd_unit_file_t',
    mode    => '0755',
    purge   => true,
    recurse => true,
  }

  file { '/etc/systemd/system/openvpn-client@.service.d/override.conf':
    ensure  => file,
    group   => 'root',
    seltype => 'systemd_unit_file_t',
    mode    => '0644',
    content => template('base/core/openvpn/client-systemd.conf.erb'),
    require => File['/etc/systemd/system/openvpn-client@.service.d'],
    notify  => Exec['Refresh systemd'],
  }

  file { '/etc/systemd/system/openvpn-server@.service.d/override.conf':
    ensure  => file,
    group   => 'root',
    seltype => 'systemd_unit_file_t',
    mode    => '0644',
    content => template('base/core/openvpn/server-systemd.conf.erb'),
    require => File['/etc/systemd/system/openvpn-server@.service.d'],
    notify  => Exec['Refresh systemd'],
  }

  file { '/etc/logrotate.d/openvpn':
    ensure  => file,
    group   => 'root',
    mode    => '0444',
    seltype => 'etc_t',
    source  => 'puppet:///modules/base/core/openvpn/logrotate.conf',
  }

  file { '/etc/openvpn/static.key':
    ensure  => file,
    mode    => '0440',
    seltype => 'openvpn_etc_t',
    source  => 'puppet:///modules/base/core/openvpn/static.key',
  }

  if $::location == 'NAS Synology - Paris' and $hostname != 'nyx' {
    file { '/etc/openvpn/client/tap61.conf':
      ensure  => file,
      mode    => '0440',
      seltype => 'openvpn_etc_t',
      source  => 'puppet:///modules/base/core/openvpn/tap61.conf',
    }
    file { '/etc/openvpn/client/tap62.conf':
      ensure  => file,
      mode    => '0440',
      seltype => 'openvpn_etc_t',
      source  => 'puppet:///modules/base/core/openvpn/tap62.conf',
    }
    file { '/etc/openvpn/client/tap63.conf':
      ensure  => file,
      mode    => '0440',
      seltype => 'openvpn_etc_t',
      source  => 'puppet:///modules/base/core/openvpn/tap63.conf',
    }
    file { '/etc/openvpn/client/tap64.conf':
      ensure  => file,
      mode    => '0440',
      seltype => 'openvpn_etc_t',
      source  => 'puppet:///modules/base/core/openvpn/tap64.conf',
    }
  }
}
