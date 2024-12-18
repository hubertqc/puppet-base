#
class base::synology {
  #
  ## Defaults
  #

  File {
    owner    => 'root',
    group    => 'root',
    mode     => '0644',
    seluser  => 'system_u',
    selrole  => 'object_r',
    seltype  => 'etc_t',
    selrange => 's0',
  }

  Sysctl {
    ensure  => present,
    comment => 'Managed by Puppet',
  }

  Kernel_parameter {
    ensure => present,
  }

  #
  ## Resources
  #

  if $::facts['hostname'] in ['nyx', 'gaia', 'ouranos'] {
    file { '/etc/modules-load.d/synosnap.conf':
      ensure  => 'file',
      content => '# Load dattobd at boot
synosnap
',
    }
  }


}
