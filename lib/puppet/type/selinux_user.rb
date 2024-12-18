Puppet::Type.newtype(:selinux_user) do
  @doc = 'Manage SELinux user to SELinux roles mappings'

  ensurable

  newparam(:user) do
    isnamevar
    desc 'The name of the SELinux user to be managed.'
    validate do |value|
      unless value =~ /^\w+_u$/ or value == 'root'
        raise ArgumentError, "%s is not a valid SELinux user name" % value
      end
    end
  end

  newproperty(:selroles, :required => true, :array_matching => :all) do
    desc 'The SELinux roles to map the user to'
    validate do |value|
      unless ( value.is_a?(Array) or value.is_a?(String) )
        raise ArgumentError, 'selroles attribute must be an array or a string'
      end

      value_arr = value.flatten                        if value.is_a?(Array)
      value_arr = value.strip.squeeze(' ').split(',')  if value.is_a?(String)

      value_arr.each do |role|
        unless role =~ /^\w+_r$/
          raise ArgumentError, "%s is not a valid SELinux role name" % role
        end
      end
    end

    #
    # Override the insync?() method in order to compare arrays regardless
    #   of the order of their elements
    def insync?(is)
      is_sorted     = is.flatten.sort.uniq
      should_sorted = @should.flatten.sort.uniq

      is_sorted == should_sorted
    end

  end

  newproperty(:sellevel) do
    desc 'The SELinux level to map the user to'
    defaultto 's0'
  end

  newproperty(:selrange) do
    desc 'The SELinux range to map the user to'
    defaultto 's0-s0:c0.c1023'
  end

  newproperty(:prefix) do
    desc 'The SELinux labelling prefix'
    defaultto 'user'
  end
end
