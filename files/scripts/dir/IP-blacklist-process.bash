#!/bin/bash 

if [ -r  /opt/scripts/IP-blacklist-CONFIG ]
then
	. /opt/scripts/IP-blacklist-CONFIG
else
	exit 127
fi

unset LANG
RC=0

if [ -f ${LOCKFILE} ]
then
        echo "Lock file found."
        exit 1
else
        touch ${LOCKFILE}
fi



#
## Refresh White List rule
#
logger -t "Blacklister" -p daemon.notice "Refreshing white list ${IPTABLES_RULE_white}"
iptables -F ${IPTABLES_RULE_white}
for IP in $( cat ${WHITELIST_FILE} )
do
	iptables -A ${IPTABLES_RULE_white} --source ${IP} -j ${IPTABLE_ACCEPT}
	iptables -A ${IPTABLES_RULE_white} --destination ${IP} -j ${IPTABLE_ACCEPT}
done



#
## Process single IP addresses to (larger) subnets
#

sort -u ${BLACKLIST_FILE} > ${BLACKLIST_FILE}.tmp

for IP in $( cat ${BLACKLIST_FILE}.tmp )
do
	ipcalc -n ${IP}/${SUBNET_MASK} 2>/dev/null
done | sort -u | awk -F '=' '/^NETWORK/ { print $NF }' > ${BLACKLIST_FILE}

awk -v sn=${SUBNET_MASK} '{ print $NF"/"sn }' ${BLACKLIST_FILE} > ${BLACKLIST_FILE}.net

rm -f ${BLACKLIST_FILE}.tmp

#
## Refresh Black list for subnets
#

logger -t "Blacklister" -p daemon.notice "Refreshing subnets black list ${IPTABLES_RULE_nets}"

iptables -F ${IPTABLES_RULE_nets}

i=0
for NET in $( cat ${BLACKLIST_FILE}.net )
do
	iptables -A ${IPTABLES_RULE_nets} --source ${NET} -j ${IPTABLE_BLOCKING}
	i=$(( $i + 1 ))
done
logger -t "Blacklister" -p daemon.notice "${i} subnets added to  ${IPTABLES_RULE_nets}"

iptables -F ${IPTABLES_RULE_ips}
logger -t "Blacklister" -p daemon.notice "Flushed single IP black list ${IPTABLES_RULE_ips}"

rm -f ${LOCKFILE}

exit $RC
