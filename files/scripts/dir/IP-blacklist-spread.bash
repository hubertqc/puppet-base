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



WHITELIST_FILE_work=$( basename ${WHITELIST_FILE})
BLACKLIST_FILE_work=$( basename ${BLACKLIST_FILE})

su - ${SPREAD_USER} > /dev/null  <<EOC
cat ${WHITELIST_FILE} > /var/tmp/${WHITELIST_FILE_work}
cat ${BLACKLIST_FILE} > /var/tmp/${BLACKLIST_FILE_work}
EOC

cw=$( cat ${WHITELIST_FILE} | wc -l )
cb=$( cat ${BLACKLIST_FILE} | wc -l )
logger -t "Blacklister" -p daemon.notice "Retrieving white and black lists from partners, currently $cw and $cb lines."


#
## Merge files from partners
#

for partner in ${PARTNERS}
do
	logger -t "Blacklister" -p daemon.notice "Retrieving white and black lists from partner ${partner}."
	su - ${SPREAD_USER} > /dev/null <<EOC
		scp -o ConnectTimeout=1 -q ${SPREAD_USER}@${partner}:${WHITELIST_FILE} /var/tmp/${WHITELIST_FILE_work}.${partner}
		scp -o ConnectTimeout=1 -q ${SPREAD_USER}@${partner}:${BLACKLIST_FILE} /var/tmp/${BLACKLIST_FILE_work}.${partner}
EOC
	cat /var/tmp/${WHITELIST_FILE_work}.${partner} >> /var/tmp/${WHITELIST_FILE_work}
	cat /var/tmp/${BLACKLIST_FILE_work}.${partner} >> /var/tmp/${BLACKLIST_FILE_work}

	rm -f /var/tmp/${WHITELIST_FILE_work}.${partner}
	rm -f /var/tmp/${BLACKLIST_FILE_work}.${partner}
done

#
##
#

sort -u /var/tmp/${WHITELIST_FILE_work} > ${WHITELIST_FILE}
sort -u /var/tmp/${BLACKLIST_FILE_work} > ${BLACKLIST_FILE}

cw=$( cat ${WHITELIST_FILE} | wc -l )
cb=$( cat ${BLACKLIST_FILE} | wc -l )
logger -t "Blacklister" -p daemon.notice "Now $cw and $cb lines."

#
##
#

rm -f ${LOCKFILE}

rm -f /var/tmp/${WHITELIST_FILE_work}
rm -f /var/tmp/${BLACKLIST_FILE_work}

exit $RC
