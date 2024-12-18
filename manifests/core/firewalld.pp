#
class base::core::firewalld {
  #
  ## Make this class private
  #

  assert_private()

  #
  ## Defaults


  Firewalld_ipset {
    ensure         => present,
    type           => 'hash:net',
    family         => 'inet',
    manage_entries => false,
    notify         => Service['firewalld'],
  }

  Firewalld_rich_rule {
    ensure  => present,
    zone    => 'public',
    family  => 'ipv4',
    action  => 'reject',
    notify  => Service['firewalld'],
  }

  #
  ## Resources
  #

  unless $::hostname == 'nyx' {
    class { 'firewalld':
      service_ensure => running,
      service_enable => true,
    }

    firewalld_ipset { 'SMTP_denied': }
    firewalld_ipset { 'SSH_denied': }
    firewalld_ipset { 'HTTP_denied': }
    firewalld_ipset { 'SSH_ip6_denied':
      family => 'inet6',
    }

    firewalld_rich_rule { 'Deny SMTP from malicious sources':
      source  => {'ipset' => 'SMTP_denied' },
      service => 'smtp',
    }

    firewalld_rich_rule { 'Deny SMTPS from malicious sources':
      source  => {'ipset' => 'SMTP_denied' },
      service => 'smtps',
    }

    firewalld_rich_rule { 'Deny SMTP-submission from malicious sources':
      source  => {'ipset' => 'SMTP_denied' },
      service => 'smtp-submission',
    }

    firewalld_rich_rule { 'Deny SSH from malicious sources':
      source  => {'ipset' => 'SSH_denied' },
      service => 'ssh',
    }

    firewalld_rich_rule { 'Deny SSH from malicious IPv6 sources':
      family  => 'ipv6',
      source  => {'ipset' => 'SSH_ip6_denied' },
      service => 'ssh',
    }

    firewalld_rich_rule { 'Deny HTTP from malicious sources':
      source  => {'ipset' => 'HTTP_denied' },
      service => 'http',
    }

    firewalld_rich_rule { 'Deny HTTPS from malicious sources':
      source  => {'ipset' => 'HTTP_denied' },
      service => 'https',
    }
  }
}
