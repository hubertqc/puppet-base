#
class base::core::usersgroups::groups () {
  #
  ## Make this class private
  #

  assert_private()

  #
  ## Resources
  #

  if $::facts['os']['name'] == 'CentOS' {
    group {'centos':
      gid => 1000,
    }
  }

  group {'mailtasks':
    gid => 1500,
  }
}
