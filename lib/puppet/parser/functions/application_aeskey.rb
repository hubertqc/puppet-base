module Puppet::Parser::Functions
  newfunction(:application_aeskey, :type => :rvalue, :doc => <<-EOS
      Returns a generated AES key for an upstream ecosystem
         Arg1( mandatory ) : Non computed key, will be used if not empty
         Arg2( mandatory ) : key usage string
         Arg3( mandatory ) : key part must be key1 or key2 string
         Arg4( mandatory ) : key hash length integer : 128 (default if no or bad value), 256 or 512)
         Arg5( mandatory ) : salt (128 characters long) to allow the function to be executed on DownStream hosts
    EOS
  ) do |arguments|

      raise(Puppet::ParseError, "application_aeskey(): Wrong number of arguments, given (#{arguments.size} for exactly 1 or 5)") if ( arguments.size != 1 and arguments.size != 5 )

      fixed_key = arguments[0]

      if ( fixed_key.nil? or fixed_key.empty? )
        stream     = lookupvar('stream')
        purpose    = lookupvar('purpose')
        ecosystem  = lookupvar('ecosystem')

        key_usage  = arguments[1].downcase.gsub(/[^a-z0-9]+/, '-')
        key_part   = arguments[2]
        key_length = arguments[3].to_i
        salt       = arguments[4]

        unless key_length == 128 or key_length == 256 or key_length == 512
          raise(Puppet::ParseError, "application_aeskey(): The key length argument must be one of 128, 256 or 512.")
        end

        if ( salt.size < ( key_length / 4 )  )
          raise(Puppet::ParseError, "application_aeskey(): The salt character length MUST be equal or greater than the desired key length (128/256/512 bit).")
        end

        if ( ecosystem.nil? or ecosystem.empty? )
          raise(Puppet::ParseError, "application_aeskey(): Cannot compute Key, ecosystem fact not set for this host")
        end

        if ( key_usage.empty? )
          raise(Puppet::ParseError, "application_aeskey(): Cannot compute Key, second argument must contain key usage string")
        end

        if ( key_part.empty? or key_part !~ /^key[12]$/ )
          raise(Puppet::ParseError, "application_aeskey():  Third argument must be key1 or key2 string")
        end

        #
        ## All lights are green, let's compute a key...
        #

        key_to_hash = key_usage + ecosystem + key_part + salt + purpose

        if ( key_length > 256 )
          key_sha = Digest::SHA512.hexdigest( key_to_hash )
        else
          key_sha = Digest::SHA256.hexdigest( key_to_hash )
        end

        return key_sha.slice(0, (key_length / 4) )
      else
        return fixed_key
      end
    end
end
