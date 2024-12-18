#
class base::dnsserver (
  String $service       = 'named-chroot',
  Hash   $keys          = {},
  Hash   $acls          = {},
  Hash   $public_zones  = {},
  Hash   $private_zones = {},
) {
  #
  ## Make this class private
  #

  assert_private()

  #
  ## Resources
  #

  class { 'dnsserver':
    keys          => $keys,
    acls          => $acls,
    public_zones  => $public_zones,
    private_zones => $private_zones,
  }
}
