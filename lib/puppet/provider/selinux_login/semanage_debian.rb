Puppet::Type.type(:selinux_login).provide(:semanage_debian) do
  desc "Manage SELinux login mapping definitions"

  confine	:osfamily                  => 'Debian'

  commands  :semanage => 'semanage'
  commands  :sestatus => 'sestatus'

  mk_resource_methods

  def self.instances
    policy_name = 'targeted'
    logins      = []
    out         = semanage('login', '--extract')

    out.lines.each do |line|
      garb1, garb2, garb3, seluser, garb4, selrange, selogin = line.strip.squeeze(' ').split(' ')

      unless selogin.nil? or selogin.empty?
        logins << new(
            :name     => selogin,
            :ensure   => :present,
            :seluser  => seluser,
            :login    => selogin,
            :selrange => selrange.gsub(/'/, ''),
            :service  => '*',
        )
      end
    end

    if Dir.exists?("/etc/selinux/#{ policy_name }/logins")
      logins_dir = Dir.new("/etc/selinux/#{ policy_name }/logins")

      logins_dir.each do |login_file|
        login_file_name = "/etc/selinux/#{ policy_name }/logins/#{ login_file }"
        if File.file?(login_file_name)
          selogin = login_file_name

          File.foreach(login_file_name) do |login_file_line|
            service, seluser, selrange = login_file_line.split(':')

            logins << new(
              :name     => "#{selogin}/#{service}",
              :ensure   => :present,
              :seluser  => seluser,
              :login    => selogin,
              :selrange => selrange,
              :service  => service,
            )
          end
        end
      end
    end

    logins
  end

  def self.prefetch(resources)
    logins = instances
    resources.keys.each do |name|
      if provider = logins.find{ |foo| foo.name == name }
        resources[name].provider = provider
      end
    end
  end

  # create the SELinux login mapping
  def create
    fail "Semanage login #{resource[:name]} requires seluser parameter" unless resource[:seluser]

    if resource[:service] != '*'
      line = "#{ resource[:service] }:#{ resource[:seluser] }:#{ resource[:selrange] }\n"

      login_file = File.open(cust_login_file, 'a')
      login_file.write(line)
      login_file.close
    else
      action = '--add'
      if ['root', '__default__'].include?(resource[:login])
        action = '--modify'
      end
      semanage 'login', action, '--range', resource[:selrange], '--seuser', resource[:seluser], resource[:login]
    end

    @property_hash[:ensure] = :present
  end

  # remove a SELinux login mapping
  def destroy
    if resource[:service] != '*'
      f = File.open(cust_login_file, 'r')
      lines = f.readlines
      f.close

      f = File.open(cust_login_file, 'w')
      lines.each do |line|
        service, rest = line.split(':')
        unless service == resource[:service]
          f.write(line)
        end
      end
      f.close

    else
      semanage 'login', '--delete', resource[:login]
    end

    @property_hash.clear
  end

  # Test if a SELinux login mapping is present
  def exists?
    @property_hash[:ensure] == :present
  end

  # change the SELinux user property
  def seluser=(value)
    if resource[:service] != '*'
      f = File.open(cust_login_file, 'r')
      lines = f.readlines
      f.close

      f = File.open(cust_login_file, 'w')
      lines.each do |line|
        service, seluser, selrange = line.split(':')
        if service == resource[:service]
          f.write("#{ service }:#{ value }:#{ selrange }\n")
        else
          f.write(line)
        end
      end
      f.close
    else
      semanage 'login', '--modify', '--seuser', value, '--range', resource[:selrange], resource[:login]
    end

    @property_hash[:seluser] = value
  end

  # change the SELinux range property
  def selrange=(value)
    if resource[:service] != '*'
      f = File.open(cust_login_file, 'r')
      lines = f.readlines
      f.close

      f = File.open(cust_login_file, 'w')
      lines.each do |line|
        service, seluser, selrange = line.split(':')
        if service == resource[:service]
          f.write("#{ service }:#{ seluser }:#{ value }\n")
        else
          f.write(line)
        end
      end
      f.close
    else
      semanage 'login', '--modify', '--seuser', resource[:seluser], '--range', value, resource[:login]
    end

    @property_hash[:selrange] = value
  end

  # return the local service customisation file name
  def cust_login_file
    policy_name     = 'targeted'
    logins_dir_name = "/etc/selinux/#{ policy_name }/logins"

    login_file_name = "#{ logins_dir_name }/#{ resource[:login] }"

    login_file_name
  end

end
