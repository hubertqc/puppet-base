#
# Special module for managing SELinux policy modules
#

Puppet::Type.newtype(:selinux_module) do
  @doc = "Manages loading and unloading of SELinux policy modules
    on the system.  Requires SELinux support.  See man semodule(8)
    for more information on SELinux policy modules."

  # Put it ensure
  ensurable

  newparam(:name) do
    desc "The name of the SELinux policy to be managed.  You should not
      include the customary trailing .pp extension."
    isnamevar
  end

  newparam(:source) do
    validate do |value|
      raise ArgumentError, _('PP (compiled module) source must be a String') unless value.is_a?(String)
    end
  end

  newparam(:te_content) do
    validate do |value|
      raise ArgumentError, _('TE content must be a String') unless value.is_a?(String)
    end
  end
  newparam(:te_source) do
    validate do |value|
      raise ArgumentError, _('TE source must be a String') unless value.is_a?(String)
    end
  end

  newparam(:if_content) do
    validate do |value|
      raise ArgumentError, _('IF content must be a String') unless value.is_a?(String)
    end
  end
  newparam(:if_source) do
    validate do |value|
      raise ArgumentError, _('IF source must be a String') unless value.is_a?(String)
    end
  end

  newparam(:fc_content) do
    validate do |value|
      raise ArgumentError, _('FC content must be a String') unless value.is_a?(String)
    end
  end
  newparam(:fc_source) do
    validate do |value|
      raise ArgumentError, _('FC source must be a String') unless value.is_a?(String)
    end
  end

  newproperty(:base) do
    desc "Tells wether module is part of base policy (true) or custom (false)"
    newvalue(:true)
    newvalue(:false)
    defaultto(:false)

    # Changing this boolean has no meaning
    def insync?(is)
      true
    end
  end

  newproperty(:version) do
    desc "Version of policy module if already installed on OS"

    # Changing the version has no meaning
    def insync?(is)
      true
    end
  end

  newproperty(:needsync) do
    desc "Property to check is the SELinux module must be syncronized (i.e. version change)"
    newvalue(:true)
    newvalue(:false)
    defaultto(:false)

    #Check if the "is" value is in sync with the wanted ("should") value
    def insync?(is)
      true
    end
  end

  newproperty(:needcompile) do
    desc "Property to check is the SELinux module must be compiled from sources (i.e. version change)"
    newvalue(:true)
    newvalue(:false)
    defaultto(:false)

    #Check if the "is" value is in sync with the wanted ("should") value
    def insync?(is)
      true
    end
  end

  newproperty(:syncversion) do
  ##  desc "If set to `true`, the policy will be reloaded if the
  ##  version found in the on-disk file differs from the loaded
  ##  version.  If set to `false` (the default) the only check
  ##  that will be made is if the policy is loaded at all or not."

    newvalue(:true)
    newvalue(:false)
    defaultto(:true)
  end

  # Autorequire the file we are generating below
  # Why is this necessary ?
  autorequire(:file) do
    ["#{selinux_module_dir}/#{self[:name]}.pp"]
  end

  validate do
    unless self[:base]
      raise Puppet::ParseError, _("Set either 'source' or 'te_content' or 'te_source'") if self[:source].nil? and self[:te_content].nil? and self[:te_source].nil?
      raise Puppet::ParseError, _("Set either 'source' or 'te_content' or 'te_source'") if !self[:source].nil? and !(self[:te_content].nil? and self[:te_source].nil?)

      raise Puppet::ParseError, _("Set either 'te_content' or 'te_source' but not both") if !self[:te_content].nil? and !self[:te_source].nil?
      raise Puppet::ParseError, _("Set either 'if_content' or 'if_source' but not both") if !self[:if_content].nil? and !self[:if_source].nil?
      raise Puppet::ParseError, _("Set either 'fc_content' or 'fc_source' but not both") if !self[:fc_content].nil? and !self[:fc_source].nil?

      raise Puppet::ParseError, _("Set either 'te_content' or 'te_source' along with IF source/content") if self[:te_content].nil? and self[:te_source].nil? and !(self[:if_content].nil? and self[:if_source].nil?)
      raise Puppet::ParseError, _("Set either 'te_content' or 'te_source' along with FC source/content") if self[:te_content].nil? and self[:te_source].nil? and !(self[:fc_content].nil? and self[:fc_source].nil?)
    end
  end

  def selinux_module_dir
    Facter.value('puppet_vardir') + '/selinux_modules'
  end

  def generate
    files_opts = {
      :ensure   => (self[:ensure] == :absent) ? :absent : :file,
      :owner    => 'root',
      :group    => 'root',
      :seluser  => 'system_u',
      :selrole  => 'object_r',
      :seltype  => 'lib_t',
      :selrange => 's0',
      :mode     => '0440',
    }
    excluded_metaparams = [:before, :notify, :require, :subscribe, :tag]

    generated_resources = []

    unless catalog.resource("File[#{selinux_module_dir}]")
      dir_opts           = files_opts
      dir_opts[:path]    = selinux_module_dir
      dir_opts[:ensure]  = :directory
      dir_opts[:recurse] = true
      dir_opts[:purge]   = true
      dir_opts[:backup]  = false

      Puppet::Type.metaparams.each do |metaparam|
        unless self[metaparam].nil? || excluded_metaparams.include?(metaparam)
          dir_opts[metaparam] = self[metaparam]
        end
      end

      generated_resources |= [ Puppet::Type.type(:file).new(dir_opts) ]
    end

    files_opts[:replace] = true

    pp_file_opts           = files_opts
    pp_file_opts[:path]    = "#{selinux_module_dir}/#{self[:name]}.pp"
    Puppet::Type.metaparams.each do |metaparam|
      unless self[metaparam].nil? || excluded_metaparams.include?(metaparam)
        pp_file_opts[metaparam] = self[metaparam]
      end
    end

    if self[:source].nil?
      pp_file_opts[:replace] = false

      generated_resources |= [ Puppet::Type.type(:file).new(pp_file_opts) ]

      te_file_opts           = files_opts
      te_file_opts[:path]    = "#{selinux_module_dir}/#{self[:name]}.te"
      te_file_opts[:source]  = self[:te_source]  unless self[:te_source].nil?
      te_file_opts[:content] = self[:te_content] unless self[:te_content].nil?

      Puppet::Type.metaparams.each do |metaparam|
        unless self[metaparam].nil? || excluded_metaparams.include?(metaparam)
          te_file_opts[metaparam] = self[metaparam]
        end
      end

      generated_resources |= [ Puppet::Type.type(:file).new(te_file_opts) ]

      unless self[:fc_source].nil? and self[:fc_content].nil?
        fc_file_opts           = files_opts
        fc_file_opts[:path]    = "#{selinux_module_dir}/#{self[:name]}.fc"
        fc_file_opts[:source]  = self[:fc_source]  unless self[:fc_source].nil?
        fc_file_opts[:content] = self[:fc_content] unless self[:fc_content].nil?

        Puppet::Type.metaparams.each do |metaparam|
          unless self[metaparam].nil? || excluded_metaparams.include?(metaparam)
            fc_file_opts[metaparam] = self[metaparam]
          end
        end
        generated_resources |= [ Puppet::Type.type(:file).new(fc_file_opts) ]
      end

      unless self[:if_source].nil? and self[:if_content].nil?
        if_file_opts           = files_opts
        if_file_opts[:path]    = "#{selinux_module_dir}/#{self[:name]}.if"
        if_file_opts[:source]  = self[:if_source]  unless self[:if_source].nil?
        if_file_opts[:content] = self[:if_content] unless self[:if_content].nil?

        Puppet::Type.metaparams.each do |metaparam|
          unless self[metaparam].nil? || excluded_metaparams.include?(metaparam)
            if_file_opts[metaparam] = self[metaparam]
          end
        end
        generated_resources |= [ Puppet::Type.type(:file).new(if_file_opts) ]
      end

      compile_exec = {
        :name        => "Compile SELinux souce code for #{self[:name]} module",
        :path        => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
	:command     => "make --makefile /usr/share/selinux/devel/Makefile --directory #{selinux_module_dir} #{self[:name]}.pp",
	:refreshonly => true,
      }
      generated_resources |= [ Puppet::Type.type(:exec).new(compile_exec) ]

    else
      pp_file_opts[:source] = self[:source]

      generated_resources |= [ Puppet::Type.type(:file).new(pp_file_opts) ]
    end

    install_exec = {
        :name        => "Install SELinux #{self[:name]} module",
        :path        => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
	:command     => "semodule --install #{selinux_module_dir}/#{self[:name]}.pp",
	:refreshonly => true,
    }
    generated_resources |= [ Puppet::Type.type(:exec).new(install_exec) ]

    generated_resources

  end

  def eval_generate
    catalog.resource("Selinux_module[#{self[:name]}]")[:require] = "File[#{selinux_module_dir}/#{self[:name]}.pp]"

    if !self[:te_source].nil? or !self[:te_content].nil?
      catalog.resource("File[#{selinux_module_dir}/#{self[:name]}.pp]")[:require] = "Exec[Compile SELinux souce code for #{self[:name]} module]"
      catalog.resource("Exec[Compile SELinux souce code for #{self[:name]} module]")[:subscribe] = [ "File[#{selinux_module_dir}/#{self[:name]}.te]" ]
      if !self[:fc_source].nil? or !self[:fc_content].nil?
        catalog.resource("Exec[Compile SELinux souce code for #{self[:name]} module]")[:subscribe] |= [ "File[#{selinux_module_dir}/#{self[:name]}.fc]" ]
      end
      if !self[:if_source].nil? or !self[:if_content].nil?
        catalog.resource("Exec[Compile SELinux souce code for #{self[:name]} module]")[:subscribe] |= [ "File[#{selinux_module_dir}/#{self[:name]}.if]" ]
        catalog.resource("Exec[Compile SELinux souce code for #{self[:name]} module]")[:notify] |= [ "Exec[Install SELinux #{self[:name]} module]" ]
      end
      [
	catalog.resource("File[#{selinux_module_dir}/#{self[:name]}.pp]"),
	catalog.resource("Exec[Compile SELinux souce code for #{self[:name]} module]"),
	catalog.resource("Exec[Install SELinux #{self[:name]} module]")
      ]
    else
      catalog.resource("Exec[Compile SELinux souce code for #{self[:name]} module]")[:subscribe] |= [ "File[#{selinux_module_dir}/#{self[:name]}.pp]" ]
      [ catalog.resource("File[#{selinux_module_dir}/#{self[:name]}.pp]"), catalog.resource("Exec[Install SELinux #{self[:name]} module]") ]
    end
  end
end
