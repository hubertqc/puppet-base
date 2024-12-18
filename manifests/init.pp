#
class base (
) {

  #
  ## Puppet agent
  #
  unless $::facts['networking']['fqdn'] =~ /^nyx/
  {
    class {'::puppet':
      runmode                   => 'service',
      server                    => false,
      splay                     => true,
      agent_noop                => false,
      agent_additional_settings => { stringify_facts => false },
    }
  }

  #
  ## NTP/Chrony
  #
  if $::facts['os']['name'] == 'RedHat'
  {
    $ntp_pool = '2.rhel.pool.ntp.org'
  } else {
    $ntp_pool = '2.centos.pool.ntp.org'
  }

  class {'chrony':
    config_keys_owner => 'chrony',
    config_keys_group => 'root',
    config_keys_mode  => '0600',
    pools             => { $ntp_pool => ['iburst'], },
  }

  #
  ##
  #

  if $::facts['os']['family'] == 'RedHat' and $::facts['os']['name'] != 'Fedora' and $::hostname != 'liamone' {
    class {'base::core::netlabel': }
  }
  class {'base::core::packages': }
  class {'base::core::services': }
  class {'base::core::config': }
  class {'base::core::selinux': }
  class {'base::core::firewalld':}

  if $::facts['os']['family'] == 'RedHat' and ( $::hosname in ['nyx'] or $::location != 'NAS Synology - Paris' ) {
    class {'base::core::openvpn': }

    class {'node_exporter':
      node_exporter_activate_ssl => false,
    }
  }

  class {'base::core::refresh': }
  class {'base::core::usersgroups': }

  class {'base::scripts': }
  if $::facts['os']['family'] == 'RedHat' and $::facts['os']['name'] != 'Fedora' and $::hostname != 'liamone' {
    class {'base::ipsec': }
  }
  class {'base::selinux': }
  class {'base::sudo': }

  if $::facts['os']['family'] == 'RedHat' and ( ( $::hosname != ['nyx'] and $::location == 'NAS Synology - Paris' ) or $::hostname in [ 'chaos', 'promethee', 'ouranos' ] ) {
    mount { '/home':
      options => 'defaults,nodev,noexec,nosuid',
    }
    class { 'anssi_compliance': }
  } else {
    class {'anssi_compliance::dnf':
      updates_type => 'default',
    }

    class {'anssi_compliance::jobs': }
  }

  if $::hostname in ['ouranos', 'promethee']
  {
    class {'base::vpnserver': }
  }

  #
  ## Postfix and milters
  #

  if $::facts['os']['family'] == 'RedHat' {
    if $::location != 'NAS Synology - Paris' {
      class {'base::mailtasks': }

      include ::opendkim

      User <| name == 'opendkim' |> {
        groups +> ['mail'],
      }
      file { '/var/spool/opendkim':
        ensure   => directory,
        owner    => 'opendkim',
        group    => 'opendkim',
        seluser  => 'system_u',
        selrole  => 'object_r',
        seltype  => 'dkim_milter_data_t',
        selrange => 's0',
        mode     => '2755',
      }
      class {'base::opendmarc':
        uid => 801,
        gid => 801,
      }
      User <| name == 'opendmarc' |> {
        groups +> ['mail'],
      }
    }

    class {'postfix': }
    class {'base::postfix': }
    class {'base::saslauth': }
    class {'base::policyd_spf': }
  }

  class {'base::clamav': }
  class {'base::spamassassin': }

  class {'base::synology': }

  if $::facts['os']['family'] == 'RedHat' and $::facts['os']['name'] != 'Fedora' {
    class{'base::fail2ban': }
  }


  unless $::hostname in ['rhodani', 'ligeria', 'garona', 'liamone', 'golu' ] {
    class {'base::autofs': }
  }


  if $::facts['os']['family'] == 'RedHat' and $::location != 'NAS Synology - Paris' {
    class {'base::services': }

    $dovecot_active = ( $::hostname in ['ouranos','chaos'] )
    class {'base::dovecot':
      active_service => $dovecot_active,
    }

    if $::hostname in ['chaos', 'promethee','ouranos'] {
      class {'httpd': }
    }
    if $::hostname in ['chaos'] {
      class {'base::dnsserver': }
    }
  }


  if $::hostname == 'rhodani' {
    class { 'springboot':
      springboot_uid => 860,
      springboot_gid => 860,
      opt_vg         => 'app_vg',
      srv_vg         => 'app_vg',
      log_vg         => 'app_vg',
    }
    springboot::app {'dummy':
      listen_port => 8443,
    }
  }
}
