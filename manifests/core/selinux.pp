#
class base::core::selinux {
  #
  ## Make this class private
  #

  assert_private()

  #
  ## Defaults
  #

  File {
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    seluser => 'system_u',
    selrole => 'object_r',
    seltype => 'usr_t',
    mode    => '0444',
  }

  Selinux_module {
    ensure      => present,
    syncversion => true,
  }

  Exec {
    refreshonly => true,
    path        => ['/bin', '/sbin'],
  }

  #
  ## Resources
  #

  case $::facts['os']['family'] {
    'Debian': {
                $selinux_policy_pkg     = 'selinux-policy-default'
                $selinux_policy_dev_pkg = 'selinux-policy-dev'
              }
    default:  {
                $selinux_policy_pkg     = 'selinux-policy-targeted'
                $selinux_policy_dev_pkg = 'selinux-policy-devel'
              }
  }

  package { $selinux_policy_pkg:
    ensure => installed,
  }

  file { '/usr/share/selinux/devel/local':
    ensure  => directory,
    require => Package[$selinux_policy_dev_pkg],
  }

  file { '/opt/selinux':
    ensure  => directory,
    mode    => '0644',
    purge   => false,
    recurse => true,
    source  => 'puppet:///modules/base/core/selinux/common',
    notify  => Exec['Restore SELinux fcontexts on /opt/selinux', 'Compile SElinux modules'],
  }

  if $::facts['os']['family'] == 'Debian' {
    file { '/etc/selinux/targeted':
      ensure  => link,
      target  => '/etc/selinux/default',
      require => Package[$selinux_policy_dev_pkg],
      before  => File['/etc/selinux/targeted/contexts/sepgsql_contexts'],
    }
  }

  file { '/etc/selinux/targeted/contexts/sepgsql_contexts':
    seltype => 'default_context_t',
    source  => 'puppet:///modules/base/core/selinux/sepgsql_contexts',
  }

  unless $::hostname in ['ligeria','rhodani','liamone','taravu','garona'] or $::facts['os']['family'] != 'RedHat'
  {
    file { '/opt/selinux/foreman_ext.te':
      mode    => '0644',
      source  => 'puppet:///modules/base/core/selinux/foreman_ext/foreman_ext.te',
      notify  => Exec['Restore SELinux fcontexts on /opt/selinux', 'Compile SElinux modules'],
    }
    file { '/opt/selinux/foreman_ext.fc':
      mode    => '0644',
      source  => 'puppet:///modules/base/core/selinux/foreman_ext/foreman_ext.fc',
      notify  => Exec['Restore SELinux fcontexts on /opt/selinux', 'Compile SElinux modules'],
    }
    file { '/opt/selinux/foreman_ext.if':
      mode    => '0644',
      source  => 'puppet:///modules/base/core/selinux/foreman_ext/foreman_ext.if',
      notify  => Exec['Restore SELinux fcontexts on /opt/selinux', 'Compile SElinux modules'],
    }
  } else {
    file { ['/opt/selinux/foreman_ext.te', '/opt/selinux/foreman_ext.fc', '/opt/selinux/foreman_ext.if', '/opt/selinux/foreman_ext.pp']:
      ensure  => absent,
      notify  => Exec['Compile SElinux modules'],
    }
  }

  file { '/opt/selinux/Makefile':
    ensure  => link,
    target  => '/usr/share/selinux/devel/Makefile',
    force   => false,
    require => File['/opt/selinux'],
  }

  exec { 'Restore SELinux fcontexts on /opt/selinux':
    command => 'restorecon -RFi /opt/selinux',
  }

  exec { 'Compile SElinux modules':
    command => 'make -C /opt/selinux/ clean ; make -C /opt/selinux/ ; restorecon -RFi /opt/selinux/',
    notify  => Exec['Load SELinux modules'],
  }

  exec { 'Load SELinux modules':
    command => 'semodule -i /opt/selinux/*.pp',
  }
}
