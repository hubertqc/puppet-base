
module Puppet::Parser::Functions

  require_relative '../../util/crypto'
  include Base_crypto

  newfunction(:application_crypto_password, :type => :rvalue, :doc => <<-EOS
      Returns an encrypted password 
         Arg1( mandatory )  : key string
         Arg2( mandatory )  : payload, string to encrypt
         Arg3( cipher algo) : cipher suite algorithm default to aes-cbc-256
    EOS
  ) do |arguments|

      raise(Puppet::ParseError, "application_crypto_password(): Wrong number of arguments, given (#{arguments.size} for exactly 3)") if ( arguments.size != 3 )

      private_key = arguments[0]
      payload = arguments[1]
      cipher = arguments[2]

      if ( cipher.nil? or cipher.empty? )
        raise(Puppet::ParseError, "application_crypto_password(): Cannot compute password - empty cipher suite!")
      end

      if ( payload.nil? or payload.empty? )
        raise(Puppet::ParseError, "application_crypto_password():Cannot compute password - empty string!.")
      end

      if ( private_key.nil? or private_key.empty? )
        raise(Puppet::ParseError, "application_crypto_password(): Cannot compute password, first argument must contain private key.")
      end

      s = Crypto.new(private_key, cipher)
      return s.encrypt(payload)
    end
end
