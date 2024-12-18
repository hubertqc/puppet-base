require 'digest'

Puppet::Type.type(:selinux_module).provide(:semodule) do
  desc "Manage SELinux policy modules using the semodule binary."

  defaultfor  :kernel                    => :linux
  defaultfor  :osfamily                  => 'RedHat'

  confine     :osfamily                  => 'RedHat'

  commands    :semodule => '/usr/sbin/semodule'

  mk_resource_methods

  # The self.instances allows us to list all resources of that kind that are
  # present on the system (OS)
  def self.instances
    selinux_module = []

    begin
      out = semodule('--list')
    rescue Puppet::ExecutionFailure => e
      raise Puppet::Error, "Failed to run `semodule --list`"
    end

    out.lines.each do |line|
      semodule,version   = line.strip.squeeze(' ').split(' ')
      base_policy_module = true

      if ( version.nil? or version.empty? ) and File.exist?("/var/lib/selinux/targeted/active/modules/400/#{semodule}/hll")
        cwd         = Dir.pwd
        module_file = "#{cwd}/#{semodule}.pp"
        File.delete(module_file) if File.exist?(module_file)

        current_module_out = semodule('-H', '-E', semodule)

        if File.exist?(module_file)
          version = Digest::SHA256.file(module_file)
        end
        base_policy_module = false
      end

      selinux_module << new(
          :name        => "#{semodule}",
          :version     => "#{version}",
          :base        => base_policy_module,
          :ensure      => :present,
          :needsync    => false,
          :needcompile => false,
      )

    end
    selinux_module
  end


  # Try to map the resource from the catalog with and instance of the Puppet type
  def self.prefetch(resources)

    instances.each do |prov|
      if found_resource = resources[prov.name]
        Puppet.debug "selinux_module provider #prefetch: found a provider for resource #{ prov.name }"
	
        #If the element is present on both system and resources (catalog), we ensure that needsync is set to yes
        found_resource[:needsync] = true

        found_resource.provider = prov
      end
    end
  end

  def create
    self.debug "Create"
    @property_hash[:ensure] = :present
    :true
  end

  # Method called when a resource must be cleaned (ensure absent)
  def destroy
    self.debug "destroy"
  end

  # Method called to check if a resource already exists
  def exists?
    self.debug "Checking for module #{@resource[:name]}"
    return @property_hash[:ensure] == :present
  end
end
