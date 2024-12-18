#
class base::clamav (
  #Stdlib::Port  $milter_port,
) {

  #
  ## Defaults
  #

  Group {
    ensure => present,
  }

  User {
    ensure => present,
    shell  => '/sbin/nologin',
  }

  File {
    ensure   => file,
    owner    => 'root',
    group    => 'root',
    seluser  => 'system_u',
    selrole  => 'object_r',
    selrange => 's0',
    mode     => '0644',
  }

  Service {
    ensure  => running,
    enable  => true,
    require => Exec['Refresh systemd'],
  }

  Package {
    ensure => installed,
  }

  #
  ## Resources
  #

  package { 'clamav': }

  case $::facts['os']['family'] {
    'Debian': {
      $clamd_pkg = 'clamav-daemon'
      $clamav_update_pkg = 'clamav-freshclam'
    }
    default:  {
      $clamd_pkg = 'clamd'
      $clamav_update_pkg = 'clamav-update'
    }
  }

  package { [$clamd_pkg, $clamav_update_pkg]: }

  file {'/etc/clamd.d/scan.conf':
    seltype => 'etc_t',
    source  => 'puppet:///modules/base/clamav/scan.conf',
    require => Package[$clamd_pkg],
  }

  file {'/etc/freshclam.conf':
    mode    => '0600',
    seltype => 'etc_t',
    source  => 'puppet:///modules/base/clamav/freshclam.conf',
    require => Package[$clamav_update_pkg],
  }

  file { '/var/log/clamav':
    ensure  => directory,
    group   => 'virusgroup',
    mode    => '2775',
    seltype => 'antivirus_log_t',
  }


  service { 'clamav-freshclam.service':
    subscribe => File['/etc/freshclam.conf'],
  }

  if $::facts['os']['family'] == 'RedHat' and $::facts['os']['name'] != 'Fedora' {
    file { '/etc/systemd/system/clamd@scan.service.d':
      ensure  => directory,
      mode    => '0755',
      seltype => 'systemd_unit_file_t',
      notify  => Exec['Refresh systemd'],
    }
    file { '/etc/systemd/system/clamd@scan.service.d/override.conf':
      seltype => 'antivirus_unit_file_t',
      source  => 'puppet:///modules/base/clamav/systemd-override-scan.conf',
      require => File['/etc/systemd/system/clamd@scan.service.d'],
      notify  => Exec['Refresh systemd'],
    }
    service { 'clamd@scan.service':
      subscribe => File['/etc/clamd.d/scan.conf'],
    }

    if $::location != 'NAS Synology - Paris' {
      package { ['clamav-milter' ]: }

      file {'/etc/mail/clamav-milter.conf':
        seltype => 'etc_mail_t',
        content => template('base/clamav/clamav-milter.conf.erb'),
        require => Package['clamav-milter'],
      }

      file { '/etc/systemd/system/clamav-milter.service.d':
        ensure  => directory,
        mode    => '0755',
        seltype => 'systemd_unit_file_t',
        notify  => Exec['Refresh systemd'],
      }

      file { '/etc/systemd/system/clamav-milter.service.d/override.conf':
        seltype => 'systemd_unit_file_t',
        source  => 'puppet:///modules/base/clamav/systemd-override-milter.conf',
        require => File['/etc/systemd/system/clamav-milter.service.d'],
        notify  => Exec['Refresh systemd'],
      }

      service { 'clamav-milter':
        require   => [ File['/var/log/clamav'], Service['clamd@scan.service'] ],
        subscribe => File['/etc/mail/clamav-milter.conf'],
      }

      if defined(Service['postfix'])
      {
        Service['clamav-milter']
        {
          before => Service['postfix'],
        }
      }
    }
  }
}
