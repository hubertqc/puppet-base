#!/bin/bash

debug_file=/var/run/dovecot/sieve-pipe/sa-copy.$(date +%Yw%V).trc

echo "======================================================" >> ${debug_file}
echo "[$(date -Iseconds)] - $@" >> ${debug_file}
id >> ${debug_file}

echo "${2}" | /usr/bin/egrep -q '^(ham|spam|flags)$'
if [ $? -eq 0 -a -n "${1}" ]
then
	user=$( echo "${1}" | tr /A-Z/ /a-z/ )
	[ -d "/var/spool/mail/imapsieve/${user}" ] || mkdir -m 2770 "/var/spool/mail/imapsieve/${user}" 

	msgid=$( echo "$3" | sed -e "s/^.*:'\(.*\)'$/\1/" )
	if [ -z "$msgid" ]
	then
		msgid=$$
	fi
	id=$( echo "$msgid" | sha256sum | sed -e 's/  *.*$//' )

	TS=$( date +%Y%m%d%H%M%S%N | cut -b 1-17 )
	file="/var/spool/mail/imapsieve/${user}/${TS}.$id.${2}"

	if [ "${2}" = "flags" -a $# -ge 9 ]
	then
		touch "${file}.${9}"
	fi

	cat > "${file}" < /dev/stdin 2>> ${debug_file}
	RC=$?
	chmod g+r "${file}"

	[ $RC -eq 0 ] && echo "Wrote to ${file}" >> ${debug_file}
	[ $RC -ne 0 ] && echo "Failed to write to ${file}" >> ${debug_file}
else
	RC=127
fi

exit $RC
