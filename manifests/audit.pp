#
class base::audit (
  Integer $audit_files_size_mb  = 96,
  Integer $audit_files_pool     = 10,
) {

  #
  ## Defaults
  #

  File {
    owner    => 'root',
    group    => 'root',
    seluser  => 'system_u',
    seltype  => 'object_r',
    selrange => 's0',
    require  => Package['audit'],
  }

  #
  ## Resources
  #

  package { 'audit':
    ensure => installed,
  }

  service { 'auditd':
    ensure  => running,
    enable  => true,
    require => Package['audit'],
  }

  file { '/etc/audisp':
    ensure  => directory,
    mode    => '0750',
    seltype => 'etc_t',
  }

  file { '/etc/audit':
    ensure  => directory,
    mode    => '0750',
    seltype => 'auditd_etc_t',
  }

  file { '/etc/audisp/plugins.d':
    ensure  => directory,
    mode    => '0750',
    seltype => 'etc_t',
    require => File['/etc/audisp'],
  }

  file { '/etc/audisp/plugins.d/syslog.conf':
    ensure  => present,
    mode    => '0640',
    seltype => 'etc_t',
    source  => 'puppet:///modules/base/audit/syslog.conf',
    require => File['/etc/audisp/plugins.d'],
    notify  => Service['auditd'],
  }

  file { '/etc/systemd/system/auditd.service':
    ensure => absent,
    notify => Exec['Refresh systemd'],
  }

  file { '/etc/systemd/system/auditd.service.d':
    ensure  => directory,
    mode    => '0555',
    seltype => 'auditd_unit_file_t',
    purge   => true,
  }

  file { '/etc/systemd/system/auditd.service.d/override.conf':
    ensure  => present,
    mode    => '0444',
    seltype => 'auditd_unit_file_t',
    source  => 'puppet:///modules/base/audit/auditd.service-override.conf',
    require => File['/etc/systemd/system/auditd.service.d'],
    notify  => Exec['Refresh systemd'],
  }

  file { '/etc/audit/rules.d':
    ensure  => directory,
    mode    => '0640',
    seltype => 'auditd_etc_t',
    recurse => true,
    purge   => true,
    force   => true,
    source  => 'puppet:///modules/base/audit/rules',
    require => [ File['/etc/audit'], Package['audit'], ],
    notify  => Service['auditd'],
  }

  file { '/etc/audit/auditd.conf':
    ensure  => present,
    mode    => '0440',
    seltype => 'auditd_etc_t',
    content => template('base/audit/auditd.conf.erb'),
    require => File['/etc/audit'],
    notify  => Service['auditd'],
  }


  concat { '/etc/audit/rules.d/89-LHQG.rules':
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    seluser => 'system_u',
    selrole => 'object_r',
    seltype => 'auditd_etc_t',
    notify  => Service['auditd'],
  }

  concat::fragment { '/etc/audit/rules.d/89-LHQG.rules header':
    target  => '/etc/audit/rules.d/89-LHQG.rules',
    order   => '00',
    content => template('base/audit/89-syscalls.rules.erb'),
  }

  exec { 'Force audit rules refresh for syscalls':
    path        => ['/sbin', '/bin', '/usr/sbin', '/usr/bin'],
    cwd         => '/var/tmp',
    command     => '/sbin/augenrules --load',
    refreshonly => true,
  }

  Concat::Fragment <| target == '/etc/audit/rules.d/89-LHQG.rules' |>
  {
    notify => Exec['Force audit rules refresh for syscalls'],
  }

}
