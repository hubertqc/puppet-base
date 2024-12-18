#!/bin/bash 

if [ -r  /opt/scripts/IP-blacklist-CONFIG ]
then
	. /opt/scripts/IP-blacklist-CONFIG
else
	exit 127
fi

unset LANG
RC=0

if [ -f ${SOURCE_FILE_ssh} -o -f ${SOURCE_FILE_smtp} -o -f ${LOCKFILE} ]
then
	echo "Already running, aborting..."
	exit 127
else

	touch ${LOCKFILE}

	#
	## Parse the SSHd journal to scan for failed log in attempts
	#

	journalctl -u sshd --since yesterday | awk '/ sshd\[[0-9]+]: Failed password for .* from / { print $(NF-3) }' > ${SOURCE_FILE_ssh} 

	for IP in $( sort -u  ${SOURCE_FILE_ssh} )
	do
		FAIL_COUNT=$( egrep -c "^$IP$" ${SOURCE_FILE_ssh} )

		if [ $FAIL_COUNT -ge ${FAIL_LIMIT_ssh} ]
		then
			SUBNET_IP=$( ipcalc -s -n ${IP}/${SUBNET_MASK} | cut -d = -f 2)

			# If the IP is not already in the IP blacklisted IP file, then add it
			grep -q "^${IP}$" ${BLACKLIST_FILE}

			if [ $? -ne 0 ]
			then
				echo "${IP}" >> ${BLACKLIST_FILE}
					
				iptables -C ${IPTABLES_RULE_ips} --source ${SUBNET_IP}/${SUBNET_MASK} -j ${IPTABLE_BLOCKING} > /dev/null 2>&1
				rci=$?
				iptables -C ${IPTABLES_RULE_nets} --source ${SUBNET_IP}/${SUBNET_MASK} -j ${IPTABLE_BLOCKING} > /dev/null 2>&1
				rci=$(( $rci + $? ))
					
				if [ $rci -eq 2 ]
				then
					logger -t "Blacklister" -p daemon.notice "Adding ${SUBNET_IP}/${SUBNET_MASK} to backlist after $FAIL_COUNT failed SSH attempts from $IP"
					iptables -A ${IPTABLES_RULE_ips} --source ${SUBNET_IP}/${SUBNET_MASK} -j ${IPTABLE_BLOCKING}
				fi
			fi
		fi
	done

	#
	## Parse the Postfix journal to scan for attacks
	#

	journalctl -u postfix --since yesterday | awk '
/SASL LOGIN authentication failed: [^[:blank:]]+$/ { f=$(NF-5) }
/SASL LOGIN authentication failed: Invalid authentication mechanism/ { f=$(NF-7) }
/NOQUEUE: reject: .* Relay access denied/ { f=$(NF-10) }
{
	sub("^[^[]*[[]", "", f)
	sub("]:$", "", f)
	print f
}' | uniq > ${SOURCE_FILE_smtp}

	for IP in $( sort -u ${SOURCE_FILE_smtp} )
	do
		FAIL_COUNT=$( egrep -c "^$IP$" ${SOURCE_FILE_smtp} )

		if [ $FAIL_COUNT -ge ${FAIL_LIMIT_smtp} ]
		then
			SUBNET_IP=$( ipcalc -s -n ${IP}/${SUBNET_MASK} | cut -d = -f 2)

			# If the IP is not already in the IP blacklisted IP file, then add it
			grep -q "^${IP}$" ${BLACKLIST_FILE}

			if [ $? -ne 0 ]
			then
				echo "${IP}" >> ${BLACKLIST_FILE}
					
				iptables -C ${IPTABLES_RULE_ips} --source ${SUBNET_IP}/${SUBNET_MASK} -j ${IPTABLE_BLOCKING} > /dev/null 2>&1
				rci=$?
				iptables -C ${IPTABLES_RULE_nets} --source ${SUBNET_IP}/${SUBNET_MASK} -j ${IPTABLE_BLOCKING} > /dev/null 2>&1
				rci=$(( $rci + $? ))
					
				if [ $rci -eq 2 ]
				then
					logger -t "Blacklister" -p daemon.notice "Adding ${SUBNET_IP}/${SUBNET_MASK} to backlist after $FAIL_COUNT failed SMTP attempts from $IP"
					iptables -A ${IPTABLES_RULE_ips} --source ${SUBNET_IP}/${SUBNET_MASK} -j ${IPTABLE_BLOCKING}
				fi
			fi
		fi
	done

	rm -f ${SOURCE_FILE_smtp}
	rm -f ${SOURCE_FILE_ssh}
	rm -f ${LOCKFILE}
fi
