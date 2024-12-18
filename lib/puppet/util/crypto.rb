
require 'openssl'
require 'digest/sha1'
require 'digest/sha2'
require 'json'

module base_crypto

class  Crypto

  def initialize(key=nil, 
                 ciphersuite='aes-256-cbc')
    @key = key
    @ciphersuite = ciphersuite
  end

  def hex2bin(s)
    s = '0' + s if((s.length & 1) != 0)
    return s.scan(/../).map{ |b| b.to_i(16) }.pack('C*')
  end

  def bin2hex(s)
    return s.unpack('C*').map{ |b| "%02X" % b }.join('')
  end

  def encrypt(data)
    cipher = OpenSSL::Cipher.new(@ciphersuite)
    cipher.encrypt
    cipher.key = key = Digest::SHA256.digest(@key)
    random_iv = cipher.random_iv
    cipher.iv = Digest::SHA256.digest(random_iv + key)[0..15]
    encrypted = cipher.update(data)
    encrypted << cipher.final
    encrypted_str = bin2hex(random_iv + encrypted)
    return encrypted_str
  end

  def decrypt(data)
    data   = hex2bin(data)
    cipher = OpenSSL::Cipher.new(@ciphersuite)
    cipher.decrypt
    cipher.key = cipher_key = Digest::SHA256.digest(@key)
    random_iv = data[0..15]
    data = data[16..data.size-1]
    cipher.iv = Digest::SHA256.digest(random_iv + cipher_key)[0..15]
    begin
      decrypted = cipher.update(data)
      decrypted << cipher.final
    rescue OpenSSL::Cipher::CipherError, TypeError
      return nil
    end

    return decrypted
  end
end

class CryptoFile
  def initialize(filepath, 
                 keyword='password', 
                 separator='=', 
                 key=nil, 
                 ciphersuite='aes-256-cbc'
                 )

   @cipher = Crypto.new(key, ciphersuite)
   @filepath = filepath
   @separator = separator
   @separateword = keyword

  end

  def encipherfile
      cipherfile(true)
  end

  def decipherfile
      cipherfile(false)
  end

  def cipherfile(mode=nil)
    
    if File.exists?(@filepath)
     
       arrpass = Hash.new
       file = File.open(@filepath)
       file_data = file.readlines.map(&:chomp).grep(/#{@separateword}#{@separator}/)
       file_data.each do |value|
       
       keyvar  = value.split(/#{@separator}/)[0].strip
       keypass = value.split(/#{@separator}/)[1]

       if (keypass.nil? != nil and keyvar.nil? != nil)
        
        if (mode == true)
          if (keypass !~ /^[\dA-F]+$/)
            arrpass[keyvar] = @cipher.encrypt(keypass)
          else
            arrpass[keyvar] = keypass
          end
        else
          arrpass[keyvar.strip]  = @cipher.decrypt(keypass)
        end
       
       end
 
     end

     file.close()

      IO.write(@filepath, File.open(@filepath) do |f|
      f.read.gsub(/^(.*#{@separateword})#{@separator}(.*)/) do |m|
        
        keyvar = m.split('=')[0]
       
        if keyvar.nil? != nil or arrpass[keyvar].nil? != nil
         keyvar+@separator+arrpass.fetch(keyvar, 'NOPASS')
        end

      end 
     end
     )

   end

  end

end

end
