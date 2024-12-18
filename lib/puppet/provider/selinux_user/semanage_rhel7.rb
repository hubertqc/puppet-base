Puppet::Type.type(:selinux_user).provide(:semanage_rhel7) do
  desc "Manage SELinux user roles mapping definitions"

  confine :osfamily                  => 'RedHat'
  confine :operatingsystemmajrelease => '7'

  commands :semanage => 'semanage'
  commands :seinfo   => 'seinfo'

  mk_resource_methods

  def self.instances
    users          = []
    selabel_prefix = {}

    out = semanage('user', '--list')
    out.lines.each do |line|
      user, prefix, garb = line.strip.squeeze(' ').split(' ', 3)
      selabel_prefix[user] = prefix unless user.nil? or prefix.nil? or user.empty? or prefix.empty?
    end

    out = semanage('user', '--extract')
    out.lines.each do |line|
      garb1, garb2, garb3, sellevel, garb4, selrange, garb5, selroles_seuser = line.strip.squeeze(' ').split(' ', 8)

      selroles_seuser_array = selroles_seuser.gsub(/'/, '').split(' ')
      selroles              = selroles_seuser_array.first(selroles_seuser_array.length - 1)
      seuser                = selroles_seuser_array.last
      label_prefix          = 'user'
      label_prefix          = selabel_prefix[seuser] unless selabel_prefix[seuser].nil?

      users << new(
          :name     => seuser,
          :ensure   => :present,
          :selroles => selroles,
          :user     => seuser,
          :sellevel => sellevel.gsub(/'/, ''),
          :selrange => selrange.gsub(/'/, ''),
          :prefix   => label_prefix,
      )
    end

    users
  end

  def self.prefetch(resources)
    users = instances
    resources.keys.each do |name|
      if provider = users.find{ |foo| foo.name == name }
        resources[name].provider = provider
      end
    end
  end

  def create
    fail "Semanage user #{resource[:name]} requires selroles parameter" unless resource[:selroles]
    semanage 'user', '--add', '--prefix', resource[:prefix], '--level', resource[:sellevel], '--range', resource[:selrange], '--roles', "#{resource[:selroles].join(' ')}", resource[:user]
    @property_hash[:ensure] = :present
  end

  def destroy
    semanage 'user', '--delete', resource[:user]
    @property_hash.clear
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def selroles=(value)
    semanage 'user', '--modify', '--prefix', resource[:prefix], '--level', resource[:sellevel], '--range', resource[:selrange], '--roles', "#{value.join(' ')}", resource[:user]
    @property_hash[:selroles] = value
  end

  def selrange=(value)
    semanage 'user', '--modify', '--prefix', resource[:prefix], '--level', resource[:sellevel], '--range', value, '--roles', "#{resource[:selroles].join(' ')}", resource[:user]
    @property_hash[:selrange] = value
  end

  def sellevel=(value)
    semanage 'user', '--modify', '--prefix', resource[:prefix], '--level', value, '--range', resource[:selrange], '--roles', "#{resource[:selroles].join(' ')}", resource[:user]
    @property_hash[:sellevel] = value
  end

  def prefix=(value)
    semanage 'user', '--modify', '--prefix', value, '--level', resource[:sellevel], '--range', resource[:selrange], '--roles', "#{resource[:selroles].join(' ')}", resource[:user]
    @property_hash[:prefix] = value
  end

end
