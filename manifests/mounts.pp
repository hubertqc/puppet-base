#
class base::mounts {

  #
  ## Defaults
  #
  Mount {
    ensure  => mounted,
    options => 'defaults,nosuid,noexec,nodev',
  }

  #
  ## Resources
  #

  unless empty($::facts) or empty($::facts['mountpoints'])
  {
    unless empty($::facts['mountpoints']['/home']) or empty($::facts['mountpoints']['/home']['device'])
    {
      mount {'/home': }
    }

    unless empty($::facts['mountpoints']['/boot']) or empty($::facts['mountpoints']['/boot']['device'])
    {
      mount {'/boot': }
    }

    unless empty($::facts['mountpoints']['/var']) or empty($::facts['mountpoints']['/var']['device'])
    {
      mount {'/var': }
    }

    unless empty($::facts['mountpoints']['/tmp']) or empty($::facts['mountpoints']['/tmp']['device'])
    {
      mount {'/tmp': }
    }

    unless empty($::facts['mountpoints']['/var/log']) or empty($::facts['mountpoints']['/var/log']['device'])
    {
      mount {'/var/log': }
    }

    unless empty($::facts['mountpoints']['/opt']) or empty($::facts['mountpoints']['/opt']['device'])
    {
      mount {'/opt':
        options => 'defaults,nosuid,nodev',
      }
    }

  }
}
