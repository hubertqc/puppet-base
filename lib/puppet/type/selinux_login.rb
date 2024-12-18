Puppet::Type.newtype(:selinux_login) do
  @doc = 'Manage SELinux login to SELinux user mappings'

  ensurable

  # Break the Puppet resource title into parts
  def self.title_patterns
    [
      [
        /^((.+))$/m,
        [
          [ :name ],
          [ :login ],
        ]
      ],
      [
        /^(([^\/]+)(\/(.+))?)$/m,
        [
          [ :name ],
          [ :login ],
          [ :service ],
        ]
      ],
    ]
  end

  newparam(:name) do
    desc "The name of the SELinux login to be managed along with its service."
  end

  newproperty(:login) do
    isnamevar
    desc 'The name of the SELinux login to be managed.'

    # changing this property doesn't make any sense
    def insync?(is)
      true
    end
  end

  newproperty(:service) do
    isnamevar
    desc 'PAM service'
    defaultto '*'

    # changing this property doesn't make any sense
    def insync?(is)
      true
    end
  end

  newproperty(:seluser, :required => true) do
    desc 'The SELinux user to map the login to'
    newvalues(/_u$/)
  end

  newproperty(:selrange) do
    desc 'The SELinux range to map the login to'
    defaultto 's0-s0:c0.c1023'
  end
end
