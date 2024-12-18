#!/usr/bin/ruby
#

require 'pg'
require 'open3'
require 'ipaddr'
require 'socket'

#
## Configuration
#

from_systemd		= false

pg_host			= 'postgres.ip6.tartar.lurenzu.org'
pg_host_ro		= 'postgres-all.ip6.tartar.lurenzu.org'
pg_db			= 'fail2ban_db'
pg_user			= 'fail2ban'
pg_password		= '4F42563M842741a4ab3169hda0401c6f6f2fc44.79aAd61a3a3b84d4cea2e8ce'

fw_zone			= 'public'

insert_query_stmt	= 'insert into f2b_banned (reporting_host, ip_family, ip, prefix, protocol, port, rule_name) values ($1, $2, $3, $4, $5, $6, $7)'
retrieve_query_stmt	= 'select id, reporting_host, ip_family, ip, prefix, protocol, port, service, rule_name from  f2b_banned where id > $1 order by 1'
update_query_stmt	= 'update f2b_banned set ip=$1, prefix=$2 where id=$3'

exit_code		= 0



#
## Initialisation
#

if Process.ppid == 1
	from_systemd	= true
end

if from_systemd
	begin
		pg_conn_ro		= PG::Connection.new( :host => pg_host_ro, :dbname => pg_db, :user => pg_user, :password => pg_password )
		pg_conn			= PG::Connection.new( :host => pg_host,    :dbname => pg_db, :user => pg_user, :password => pg_password )
		hostname		= Socket.gethostname

		applied_rules		= [ 0 ]
		last_applied_rule_id	= 0
		ip_sets			= { }

		unless pg_conn.nil? and pg_conn_ro.nil?
			puts "Local reporting host is #{ hostname }"
			puts "Listening on #{ socket_path }" 	unless from_systemd
			puts "Listening on SystemD socket"	if from_systemd

			unless pg_conn.nil?
				pg_conn.prepare('stmt_insert_banned',	insert_query_stmt)
				pg_conn.prepare('stmt_update_banned',	update_query_stmt)
			end
			unless pg_conn_ro.nil?
				pg_conn_ro.prepare('stmt_retrieve_banned',	retrieve_query_stmt)
			end

			time_to_quit = false

			#
			## Main work
			#

			id	= 0
			ip	= ""
			prefix	= ""

			firewall_cmd	= "firewall-cmd --get-ipsets"
			fw_out		= %x[ #{firewall_cmd} ]
			fw_out.chomp.squeeze(' ').split(/[[:blank:]]/).each do |ip_set|
				if ip_set =~ /^[A-Z]+_denied/
					unless ip_sets.has_key?(ip_set)
						ip_sets[ip_set]			= {}
						ip_sets[ip_set]["applied"]	= false
					end

					firewall_cmd	= "firewall-cmd --ipset=#{ip_set} --get-entries"
					fw_out		= %x[ #{firewall_cmd} ]
					ip_sets[ip_set]["entries"] = fw_out.lines.map(&:chomp)
				end
			end


			loop_count = 0

			until time_to_quit
				begin
					if loop_count > 5
						loop_count = 0

						ip_sets.keys.each do |ip_set|
							unless ip_sets[ip_set]["applied"]
								ip_sets[ip_set]["applied"]	= true
							end

							firewall_cmd	= "firewall-cmd --ipset=#{ip_set} --get-entries"
							fw_out		= %x[ #{firewall_cmd} ]
							ip_sets[ip_set]["entries"] = fw_out.lines.map(&:chomp)
						end
					end
					loop_count += 1

					res_banned = pg_conn_ro.exec_prepared('stmt_retrieve_banned', [ last_applied_rule_id ])

					unless res_banned.nil?
						res_banned.each do |banned|
							id		= banned["id"].to_i
							ip_family	= banned["ip_family"]
							ip		= banned["ip"]
							prefix		= banned["prefix"].to_i
							proto		= banned["protocol"]
							service		= banned["service"]
							port		= banned["port"].to_i
							reporting_host	= banned["reporting_host"]
							rule_name	= banned["rule_name"]

							ipaddr = IPAddr.new("#{ ip }/#{ prefix }")

							unless applied_rules.include?( id ) or prefix < 4
								if service.nil? or service.empty?
									if port.nil? or port < 1
										rule	= "family=#{ ip_family } source address=#{ ipaddr.to_string }/#{ ipaddr.prefix } protocol value=#{ proto } reject"
									else
										rule	= "family=#{ ip_family } source address=#{ ipaddr.to_string }/#{ ipaddr.prefix } port protocol=#{ proto } port=#{ port } reject"
									end

									firewall_cmd	= "firewall-cmd --zone=#{ fw_zone } --add-rich-rule='rule #{ rule }'"
									puts "+ [DB reader]: adding rich rule '#{ rule }' to FirewallD (zone #{ fw_zone })."
								else
									if ip_sets.has_key?( "#{ service.upcase }_denied" ) 
										firewall_cmd	= "firewall-cmd --ipset=#{ service.upcase }_denied --add-entry=#{ ipaddr.to_string }/#{ ipaddr.prefix }"
										puts "+ [DB reader]: adding #{ ipaddr.to_string }/#{ ipaddr.prefix } to ipset #{ service.upcase }_denied."
									else
										rule	= "family=#{ ip_family } source address=#{ ipaddr.to_string }/#{ ipaddr.prefix } service name=#{ service } reject"
										firewall_cmd	= "firewall-cmd --zone=#{ fw_zone } --add-rich-rule='rule #{ rule }'"
										puts "+ [DB reader]: adding rich rule '#{ rule }' to FirewallD (zone #{ fw_zone })."
									end
								end


								fw_out = %x[ #{firewall_cmd} ]

								if fw_out.chomp == 'success'
									applied_rules.push(id)

									last_applied_rule_id = id

								else
									puts "+ [DB reader] failed to add rule, firewall-cmd output: #{ fw_out }."
								end

								unless ip == ipaddr.to_string or pg_conn.nil?
									puts "+ [DB reader]: Updating DB with canonical form for IP address #{ip}/#{prefix}."

									ip	= ipaddr.to_string
									prefix	= ipaddr.prefix

									res_banned = pg_conn.exec_prepared('stmt_update_banned', [ ip, prefix, id ])
								end
							end
						end

						puts "+ [DB reader] Last applied rule ID is now #{ last_applied_rule_id }."  unless last_applied_rule_id == applied_rules.sort.last
					end
				rescue PG::Error => e
					puts "+ [DB reader] unhandled PG exception: #{ $! }."
					e.inspect
					time_to_quit = true
				rescue IPAddr::InvalidAddressError => e
					puts "+ [DB reader] Rule id #{id}, #{ip}/#{prefix} invalid IP address specification: #{ $! }."
				end

				sleep 1
			end

			puts "+ Exiting."

		else
			puts "FATAL: Unable to connect to PostgreSQL database."
			exit_code = 1
		end
	ensure
		
	end
else
	puts "FATAL: cann only run from systemd."
	exit_code = 127
end

exit exit_code
