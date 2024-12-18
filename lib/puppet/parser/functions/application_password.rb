module Puppet::Parser::Functions
  newfunction(:application_password, :type => :rvalue, :doc => <<-EOS
      Returns a generated password 
         Arg1( mandatory ) : Non computed password, will be used if not empty
         Arg2( mandatory ) : application name string
         Arg3( mandatory ) : salt, 32 characters minimum long for UpStream / 256 for DownStream hosts
    EOS
  ) do |arguments|

      raise(Puppet::ParseError, "application_password(): Wrong number of arguments, given (#{arguments.size} for exactly 3)") if ( arguments.size != 1 and arguments.size != 3 )

      fixed_password = arguments[0]

      if ( fixed_password.nil? or fixed_password.empty? )
        stream   = lookupvar('stream')
        purpose  = lookupvar('purpose')

        app_name = arguments[1]
        salt     = arguments[2]

        if ( stream.nil? or stream.empty? )
          raise(Puppet::ParseError, "application_password(): Cannot compute password, stream fact not set for this host")
        end

        if ( purpose.nil? or purpose.empty? )
          raise(Puppet::ParseError, "application_password(): Cannot compute password, purpose fact not set for this host")
        end

        if ( salt.nil? or salt.empty? or ( salt.size < 32 and stream == 'upstream' ) or ( salt.size < 256 and stream == 'downstream' ) )
          raise(Puppet::ParseError, "application_password(): The salt length must be at least 32 for UpStream, 256 for DownStream.")
        end

        if ( app_name.nil? or app_name.empty? )
          raise(Puppet::ParseError, "application_password(): Cannot compute password, first argument must contain an application name.")
        end

        #
        ## All lights are green, let's compute a key...
        #

        passw_to_hash = salt + app_name.downcase + purpose
        passw_sha = Digest::SHA256.hexdigest( passw_to_hash )

        return passw_sha
      else
        return fixed_password
      end

    end
end
