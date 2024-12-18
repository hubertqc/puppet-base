Puppet::Type.type(:selinux_user).provide(:semanage_rhel8) do
  desc "Manage SELinux user roles mapping definitions"

  confine :osfamily                  => 'RedHat'
  confine :operatingsystemmajrelease => '8'

  commands :semanage => 'semanage'
  commands :seinfo   => 'seinfo'

  mk_resource_methods

  def self.instances
    users          = []
    selabel_prefix = {}

    out = seinfo('-u', '-x')
    out.lines.each do |line|
      user_data = line.strip.squeeze(' ').split(' ')
      unless user_data.nil? or user_data.empty?
        if user_data[0] == 'user'
          seuser        = user_data[1]
          selroles      = []
          label_prefix  = 'user'
          sellevel      = ''
          selrange      = ''

          in_roles = false

          user_data.each_index do |i|
            if user_data[i] == 'roles'
              in_roles = true
            end

            if user_data[i] == 'level'
              in_roles = false

              sellevel = user_data[i+1]
            end

            if user_data[i] == 'range'
              if user_data[i+2].nil? or user_data[i+2].empty? or user_data[i+2] != '-'
                selrange = user_data[i+1].sub(/;$/, '')
              else
                selrange = "#{user_data[i+1]}-#{user_data[i+3].sub(/;$/, '')}"
              end
            end

            if in_roles and user_data[i] !~ /^[{}]$/ and user_data[i] != 'roles'
              selroles.push(user_data[i])
            end
          end

          users << new(
              :name     => seuser,
              :ensure   => :present,
              :selroles => selroles,
              :user     => seuser,
              :sellevel => sellevel,
              :selrange => selrange,
              :prefix   => label_prefix,
          )
        end
      end
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
