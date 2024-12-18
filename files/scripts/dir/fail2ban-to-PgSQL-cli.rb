#!/usr/bin/ruby
#

require 'socket'
require 'ipaddr'
require 'optparse'

#
## Configuration
#

socket_path		= '/var/run/fail2ban-to-PgSQL/socket'

#
## Initialisation
#

options			= {}

options[:ipfmly]	= 0
options[:ipaddr]	= ''
options[:proto]		= ''
options[:port]		= 0
options[:mask]		= 32
options[:rulename]	= 'unnamed rule'

optparse = OptionParser.new do |opts|
	opts.banner = "Usage:"

	opts.on( '-f', '--family IPfamily', 'Report IPADDRESS' ) do |ipfmly|
		case ipfmly.downcase
			when "ipv4"	then	options[:ipfmly] = 4
			when "ipv6"	then	options[:ipfmly] = 6
			else			options[:ipfmly] = ipfmly.to_i
		end
	end

	opts.on( '-a', '--address IPADDRESS', 'Report IPADDRESS' ) do |ipaddr|
		options[:ipaddr] = ipaddr.downcase
	end

	opts.on( '-m', '--mask IPMASK', 'Report IP address prefix length (mask)' ) do |mask|
		options[:mask] = mask.to_i
	end

	opts.on( '-P', '--protocol PROTO', 'Report protocol' ) do |proto|
		options[:proto] = proto.downcase
	end

	opts.on( '-p', '--port PORT', 'Report port number' ) do |port|
		options[:port] = port.to_i
	end

	opts.on( '-n', '--rulename "rule name or description"', 'Report IPADDRESS' ) do |rulename|
		options[:rulename] = rulename
	end
end

optparse.parse!

begin
	ip = IPAddr.new("#{ options[:ipaddr] }/#{ options[:mask] }")

	if [4, 6].include?(options[:ipfmly]) and ['udp', 'tcp'].include?(options[:proto]) and options[:port] > 0
		begin
			socket	= UNIXSocket.open(socket_path)

			socket.puts "ipv#{ options[:ipfmly] }|#{ options[:ipaddr] }|#{ options[:mask] }|#{ options[:proto] }|#{ options[:port] }|#{ options[:rulename] }"
		end
	else
		puts "Wrong usage."
		puts options

		exit 127
	end
rescue IPAddr::InvalidAddressError => e
	puts "Wrong IP address specification: #{ options[:ipaddr] }/#{ options[:mask] }."
	puts options

	exit 127
end
