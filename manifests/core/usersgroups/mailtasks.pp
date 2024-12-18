#
class base::core::usersgroups::mailtasks () {
  #
  ## Make this class private
  #

  assert_private()

  #
  ## Defaults
  #

  #
  ## Resources
  #

  user { 'mailtasks':
    uid            => 1500,
    gid            => 'mail',
    groups         => ['mail', 'mailtasks', 'sa-milt'],
    home           => '/home/mailtasks',
    managehome     => true,
    purge_ssh_keys => true,
    require        =>  Group['mailtasks'],
  }
}
