#
class base::core::services (
) {
  #
  ## Make this class private
  #

  assert_private()

  #
  ## Defaults
  #

  Service {
    ensure => 'running',
    enable => true,
  }

  #
  ##
  #

  service { 'gpm.service':
    require => Package['gpm'],
  }

  case $::facts['os']['family'] {
    'Debian': { $sshd = 'ssh' }
    default:  { $sshd = 'sshd' }
  }
  service { $sshd: }

  service { 'setroubleshootd':
    ensure => 'stopped',
    enable => false,
  }

  if $::is_virtual == true {
    unless $::hostname == 'chaos' {
      service {'qemu-guest-agent.service':
        require => Package['qemu-guest-agent'],
      }
    }
  }
}
