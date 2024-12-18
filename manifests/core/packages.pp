#
class base::core::packages (
) {
  #
  ## Make this class private
  #

  assert_private()

  #
  ## Defaults
  #

  Package {
    ensure => installed,
  }

  #
  ##
  #

  if $::facts['os']['family'] == 'RedHat' {
    package { ['htop', 'vim-enhanced', 'xorg-x11-xauth', 'selinux-policy-devel', 'setools-console', 'policycoreutils-newrole', 'wireguard-tools']: }
    package { 'fprintd-pam': }
  }

  if $::facts['os']['family'] == 'Debian' {
    package { ['vim', 'xauth', 'selinux-policy-dev', 'setools', 'policycoreutils', 'selinux-utils', 'selinux-basics']: }
  }

  package { ['gpm', 'logwatch']: }

  package { ['setroubleshoot-server','setroubleshoot-plugins']:
    ensure => 'purged',
  }

  if $::is_virtual == true {
    package {'qemu-guest-agent': }
  }
}
