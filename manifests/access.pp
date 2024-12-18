#
class base::access {
  #
  ## Defaults
  #

  File {
    ensure   => file,
    owner    => 'root',
    group    => 'root',
    mode     => '0644',
    seluser  => 'system_u',
    selrole  => 'object_r',
    seltype  => 'etc_t',
    selrange => 's0',
  }

  File_line {
    ensure  => present,
    path    => '/etc/login.defs',
    replace => true,
  }

  #
  ## Resources
  #
  file { '/etc/security/faillock.conf':
    source => 'puppet:///modules/base/access/faillock.conf',
  }

  file { '/etc/security/pwquality.conf':
    source => 'puppet:///modules/base/access/pwquality.conf',
  }

  file { '/etc/pam.d/system-auth':
    ensure => link,
    target => '/etc/authselect/system-auth',
  }

  file { '/etc/pam.d/password-auth':
    ensure => link,
    target => '/etc/authselect/password-auth',
  }

  file { '/etc/pam.d/sshd':
    source => 'puppet:///modules/base/access/pam.d/sshd',
  }

  file { '/etc/authselect':
    ensure  => directory,
    recurse => true,
    purge   => false,
    source  => 'puppet:///modules/base/access/authselect',
  }

  file_line { 'Set default UMASK in /etc/login.defs':
    match   => '^UMASK',
    line    => 'UMASK	027',
  }
  file_line { 'Set password min length in /etc/login.defs':
    match   => '^PASS_MIN_LEN',
    line    => 'PASS_MIN_LEN	12',
  }
  file_line { 'Set password maximum life time in /etc/login.defs':
    match   => '^PASS_MAX_DAYS',
    line    => 'PASS_MAX_DAYS	180',
  }
  file_line { 'Set password hash rounds in /etc/login.defs':
    match   => '^SHA_CRYPT_MAX_ROUNDS',
    line    => 'SHA_CRYPT_MAX_ROUNDS	6000',
  }

  file {'/var/tmp/tmp-inst':
    ensure   => directory,
    owner    => 'root',
    group    => 'root',
    mode     => '0000',
    seluser  => 'system_u',
    selrole  => 'object_r',
    seltype  => 'tmp_t',
    selrange => 's0',
    recurse  => false,
    purge    => false,
  }
  file_line { 'Activate poly-instanciation for /var/tmp':
    path    => '/etc/security/namespace.conf',
    match   => '^#*/var/tmp',
    line    => '/var/tmp	/var/tmp/tmp-inst/	level	root,adm',
    require => File['/var/tmp/tmp-inst'],
  }

}
