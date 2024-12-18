#
class base::kernel {
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

  # Require authentication for single user mode + Disable Interactive Boot
#  augeas { 'Require pw auth for single user mode + disable interactive boot':
#    incl    => '/etc/sysconfig/init',
#    lens    => 'Shellvars.lns',
#    changes => [
#      'set /files/etc/sysconfig/init/SINGLE /sbin/sulogin',
#      'set /files/etc/sysconfig/init/PROMPT no',
#    ],
#  }

  file {'/etc/modules-load.d':
    ensure  => directory,
    recurse => true,
    purge   => true,
    source  => 'puppet:///modules/base/kernel/modules-load.d',
  }

  #
  # Kernel parameters
  #
  kernel_parameter { 'quiet': }

  kernel_parameter { 'selinux':
    value => '1',
  }
  kernel_parameter { 'audit':
    value => '1',
  }
  kernel_parameter { 'l1tf':
    value => '',
  }
  kernel_parameter { 'spec_store_bypass_disable':
    value => '',
  }
  kernel_parameter { 'rng_core.default_quality':
    value => '',
  }
  kernel_parameter { 'pti':
    value => 'on',
  }
  kernel_parameter { 'iommu':
    value => 'force',
  }
  kernel_parameter { 'spectre_v2':
    value => 'on',
  }
  kernel_parameter { 'mce':
    value => '0',
  }
  kernel_parameter { 'slub_debug':
    value => '',
  }
  kernel_parameter { 'page_poison':
    value => '1',
  }
  kernel_parameter { 'slab_nomerge':
    value => 'yes',
  }

  if versioncmp($::facts['os']['release']['major'], '9') >= 0 {
    kernel_parameter { 'mds':
      value => '',
    }
    kernel_parameter { 'page_alloc.shuffle':
      value => '1',
    }
  }

  #
  # Setting SYSCTL parameters
  #

  $sysctl_params = {
    'fs.protected_fifos' => {
      'value' => '2',
    },
    'fs.protected_regular' => {
      'value' => '2',
    },

    'vm.mmap_min_addr' => {
      'value' => '65536',
    },

    'kernel.randomize_va_space' => {
      'value' => '2',
    },
    'kernel.unprivileged_bpf_disabled' => {
      'value' => '1',
    },
    'kernel.panic_on_oops' => {
      'value' => '1',
    },
    'kernel.yama.ptrace_scope' => {
      'value' => '1',
    },
    'kernel.modules_disabled' => {
      'value' => '1',
    },
    'kernel.perf_cpu_time_max_percent' => {
      'value' => '1',
    },
    'kernel.perf_event_max_sample_rate' => {
      'value' => '1',
    },
    'kernel.pid_max' => {
      'value' => '65536',
    },
    'kernel.sysrq' => {
      'value' => '0',
    },
    'kernel.dmesg_restrict' => {
      'value' => '1',
    },
    'kernel.perf_event_paranoid' => {
      'value' => '2',
    },
    'fs.suid_dumpable' => {
      'value' => '0',
    },




    'net.core.bpf_jit_harden'  => {
      'value' => '2',
    },

    'net.ipv4.conf.all.send_redirects'  => {
      'value' => '0',
    },
    'net.ipv4.conf.default.send_redirects'  => {
      'value' => '0',
    },

    'net.ipv4.conf.all.accept_source_route' => {
      'value' => '0',
    },
    'net.ipv4.conf.default.accept_source_route' => {
      'value' => '0',
    },

    'net.ipv4.conf.all.accept_redirects'  => {
      'value' => '0',
    },
    'net.ipv4.conf.default.accept_redirects'  => {
      'value' => '0',
    },

    'net.ipv4.conf.all.secure_redirects'  => {
      'value' => '0',
    },
    'net.ipv4.conf.default.secure_redirects'  => {
      'value' => '0',
    },

    'net.ipv4.conf.all.log_martians'  => {
      'value' => '1',
    },
    'net.ipv4.conf.default.log_martians'  => {
      'value' => '1',
    },

    'net.ipv4.icmp_echo_ignore_broadcasts'  => {
      'value' => '1',
    },
    'net.ipv4.icmp_ignore_bogus_error_responses'  => {
      'value' => '1',
    },

    'net.ipv4.conf.all.rp_filter' => {
      'value' => '1',
    },
    'net.ipv4.conf.default.rp_filter' => {
      'value' => '1',
    },

    #'net.ipv4.conf.all.arp_filter' => {
    #  'value' => '',
    #},

    'net.ipv4.tcp_syncookies' => {
      'value' => '1',
    },

    'net.ipv4.tcp_rfc1337' => {
      'value' => '1',
    },

    'net.ipv4.conf.all.drop_gratuitous_arp' => {
      'value' => '1',
    },



    'net.ipv6.conf.all.accept_source_route' => {
      'value' => '0',
    },
    'net.ipv6.conf.default.accept_source_route' => {
      'value' => '0',
    },

    'net.ipv6.conf.all.accept_ra_rtr_pref' => {
      'value' => '0',
    },
    'net.ipv6.conf.default.accept_ra_rtr_pref' => {
      'value' => '0',
    },

    'net.ipv6.conf.all.accept_ra_pinfo' => {
      'value' => '0',
    },
    'net.ipv6.conf.default.accept_ra_pinfo' => {
      'value' => '0',
    },

    'net.ipv6.conf.all.autoconf' => {
      'value' => '0',
    },

    'net.ipv6.conf.all.max_addresses' => {
      'value' => '1',
    },

    'net.ipv6.conf.all.router_solicitations' => {
      'value' => '0',
    },

    'net.ipv6.conf.all.disable_ipv6' => {
      'value' => '0',
    },

  }

  create_resources('sysctl', $sysctl_params)

}
