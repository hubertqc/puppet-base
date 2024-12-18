#
class base::vpnserver (

  Stdlib::IP::Address::V4::Nosubnet			$clients_subnet,
  Stdlib::IP::Address::V4::Nosubnet			$clients_mask,

  Array[Struct[{
    name => String,
    ip   => Stdlib::IP::Address::V4::Nosubnet,
  }]]							$clients_persistent_ips = [],

  Integer[4096,8192]    				$dhparam_numbits = 4096,
) {
  #
  ## Defaults
  #

  File {
    ensure  => file,
    owner   => 'root',
    group   => 'openvpn',
    seluser => 'system_u',
    selrole => 'object_r',
    seltype => 'openvpn_etc_t',
    mode    => '0640',
    require => Package['openvpn'],
    notify  => Service['openvpn-server@vpn.service'],
  }

  #
  ## Resources
  #

  service {'openvpn-server@vpn.service':
    ensure => running,
    enable => true,
  }

  file {'/etc/openvpn/server/vpn.conf':
    content => template('base/vpnserver/vpnserver.conf.erb'),
  }

  file {'/etc/openvpn/vpn-server.persist-ip-client.txt':
    seltype => 'openvpn_etc_rw_t',
    replace => false,
    content => template('base/vpnserver/persist-ip-client.txt.erb'),
  }

  file {'/etc/openvpn/vpn-server.dh.pem':
    replace => false,
  }

  exec {'Generate DH params for openvpn-server@vpn.service':
    path        => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
    command     => "openssl dhparam -outform PEM -out /etc/openvpn/vpn-server.dh.pem ${dhparam_numbits}",
    refreshonly => true,
    unless      => 'test -s /etc/openvpn/vpn-server.dh.pem',
    subscribe   => File['/etc/openvpn/vpn-server.dh.pem'],
    notify      => Service['openvpn-server@vpn.service'],
  }
}
