#
class base::mailtasks (
  Boolean $opendmarc_report_server,
  Boolean $dovecot_server,
  Boolean $dovecot_active_server,
) {

  #
  ## Dependencies
  #

  User['mailtasks']            -> Class['base::mailtasks']
  Class['base::core::selinux'] -> Class['base::mailtasks']

  #
  ## Defaults
  #

  File {
    ensure   => file,
    owner    => 'root',
    group    => 'mailtasks',
    seluser  => 'system_u',
    selrole  => 'object_r',
    selrange => 's0',
    mode     => '0644',
    notify   => Exec['Restore SELinux fcontexts on /opt/mailtasks'],
  }

  Exec {
    refreshonly => true,
    path        => ['/bin', '/sbin' ]
  }

  $dovecot_dirs = [ 'imapsieve', 'sieve.after.d', 'sieve.before.d', 'sieve-execute', 'sieve-filter', 'sieve.global.d' ]
  $imapsieve_scripts = [ 'sa-copy.sh' ]
  $mailtasks_scripts = [ 'sa-learn.sh' ]

  #
  ## Resources
  #

  file { '/opt/mailtasks':
    ensure  => directory,
    seltype => 'usr_t',
    mode    => '0755',
    recurse => true,
    purge   => true,
    source  => 'puppet:///modules/base/mailtasks/scripts',
  }

  file { '/opt/mailtasks/dovecot':
    ensure  => directory,
    group   => 'dovecot',
    mode    => '2755',
    recurse => true,
    purge   => true,
    require => File['/opt/mailtasks'],
  }
  file { '/opt/mailtasks/dovecot/Makefile':
    group   => 'dovecot',
    mode    => '0644',
    source  => 'puppet:///modules/base/mailtasks/dovecot-scripts/Makefile',
    require => File['/opt/mailtasks/dovecot'],
  }

  if $dovecot_server {
    $dovecot_dirs.each |$dovecot_sieve_dir|
    {
      file { "/opt/mailtasks/dovecot/${dovecot_sieve_dir}":
        ensure  => directory,
        group   => 'dovecot',
        mode    => '0644',
        recurse => true,
        source  => "puppet:///modules/base/mailtasks/dovecot-scripts/${dovecot_sieve_dir}",
        require => File['/opt/mailtasks/dovecot'],
        notify  => Exec["Compile /opt/mailtasks/dovecot/${dovecot_sieve_dir} sieve scripts"],
      }

      file { "/opt/mailtasks/dovecot/${dovecot_sieve_dir}/Makefile":
        ensure  => link,
        target  => '/opt/mailtasks/dovecot/Makefile',
        force   => true,
        require => File["/opt/mailtasks/dovecot/${dovecot_sieve_dir}", '/opt/mailtasks/dovecot/Makefile'],
        notify  => Exec["Compile /opt/mailtasks/dovecot/${dovecot_sieve_dir} sieve scripts"],
      }

      exec {"Compile /opt/mailtasks/dovecot/${dovecot_sieve_dir} sieve scripts":
        cwd     => "/opt/mailtasks/dovecot/${dovecot_sieve_dir}",
        command => 'make',
        notify  => Exec["Fix perms on/opt/mailtasks/dovecot/${dovecot_sieve_dir}"],
      }
      exec {"Fix perms on/opt/mailtasks/dovecot/${dovecot_sieve_dir}":
        cwd     => "/opt/mailtasks/dovecot/${dovecot_sieve_dir}",
        command => 'chown root:dovecot *.svbin ; chmod 0644 *.svbin',
        notify  => Exec["Restore SELinux fcontexts on /opt/mailtasks/dovecot/${dovecot_sieve_dir}"],
      }
      exec {"Restore SELinux fcontexts on /opt/mailtasks/dovecot/${dovecot_sieve_dir}":
        command => "restorecon -RFi /opt/mailtasks/dovecot/${dovecot_sieve_dir}",
      }
    }

    file { '/opt/mailtasks/dovecot/sieve-pipe':
      ensure  => directory,
      group   => 'dovecot',
      seltype => 'imapsieve_tmp_t',
      mode    => '2775',
      require => File['/opt/mailtasks/dovecot'],
    }

    $imapsieve_scripts.each |$script|
    {
      file { "/opt/mailtasks/dovecot/imapsieve/${script}":
        group   => 'dovecot',
        seltype => 'imapsieve_exec_t',
        mode    => '0555',
        source  => "puppet:///modules/base/mailtasks/dovecot-scripts/${script}",
        require => File['/opt/mailtasks/dovecot/imapsieve'],
      }
    }

    $mailtasks_scripts.each |$script|
    {
      file { "/opt/mailtasks/${script}":
        group   => 'mailtasks',
        seltype => 'mailtasks_exec_t',
        mode    => '0555',
        content => template("base/mailtasks/scripts/${script}.erb"),
        require => File['/opt/mailtasks/dovecot/imapsieve'],
      }
    }
  }

  file { '/opt/mailtasks/MailTasksCONFIG':
    mode    => '0444',
    content => template('base/mailtasks/MailTasksCONFIG.erb'),
    require => File['/opt/mailtasks'],
  }

  file { '/opt/mailtasks/OpenDmarc-ImportToDB':
    owner   => 'opendmarc',
    mode    => '0550',
    source  => 'puppet:///modules/base/mailtasks/OpenDmarc-ImportToDB',
    require => File['/opt/mailtasks'],
  }

  file { '/etc/tmpfiles.d/mailtasks.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    seltype => 'etc_t',
    source  => 'puppet:///modules/base/mailtasks/tmpfiles.conf',
    notify  => Exec['Apply tmpfiles mailtasks.conf'],
  }

  file { '/var/log/MailTasks':
    ensure  => directory,
    mode    => '2775',
    seltype => 'mailtasks_log_t',
    notify  => Exec['Restore SELinux fcontexts on /var/log/Mailtasks'],
  }
  file { '/var/lock/MailTasks':
    ensure  => directory,
    mode    => '2775',
    seltype => 'mailtasks_lock_t',
    notify  => Exec['Restore SELinux fcontexts on /var/lock/Mailtasks'],
  }

  file { '/etc/cron.d/MailTasks':
    group   => 'root',
    seltype => 'system_cron_spool_t',
    content => template('base/mailtasks/MailTasks.cron.erb'),
  }

  exec {'Restore SELinux fcontexts on /opt/mailtasks':
    command => 'restorecon -RFi /opt/mailtasks',
  }
  exec {'Restore SELinux fcontexts on /var/log/Mailtasks':
    command => 'restorecon -RFi /var/log/Mailtasks',
  }
  exec {'Restore SELinux fcontexts on /var/lock/Mailtasks':
    command => 'restorecon -RFi /var/lock/Mailtasks',
  }
  exec {'Apply tmpfiles mailtasks.conf':
    command => 'systemd-tmpfiles --create --clean --remove mailtasks.conf',
  }
}
