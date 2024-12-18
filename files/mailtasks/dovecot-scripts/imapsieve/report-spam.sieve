require ["vnd.dovecot.pipe", "copy", "imapsieve", "environment", "variables", "imap4flags", "vnd.dovecot.debug" ];

#
## Executed when mail is moved to the Spam folder
#

if environment :matches "phase" "*" {
	set "phase" "${1}";
}
if environment :matches "imap.cause" "*" {
	set "cause" "${1}";
}
if environment :matches "imap.mailbox" "*" {
	set "mailbox" "${1}";
}
if environment :matches "imap.user" "*" {
	set "imapuser" "${1}";
}
if environment :matches "imap.user" "*/*" {
	set "recipient" "${0}";
	set "recip_domain" "${1}";
	set "user" "${2}";
	set "imapuser" "${2}@${1}";
}
if header :matches "Message-ID" "*" {
	set "message_id" "${1}";
}
if header :matches "Delivered-To" "*" {
	set "username" "${1}";
}

#
debug_log "Executing report-spam on ${cause} to ${mailbox} folder";

removeflag [ "$NotJunk", "NotJunk", "NonJunk" ];
addflag [ "$Junk", "Junk", "JunkRecorded" ];

pipe :copy "sa-copy.sh" [ "${username}", "spam", "msgid:'${message_id}'", "imapuser:${imapuser}", "cause:${cause}", "mailbox:${mailbox}", "phase:${phase}", "changedflags:'${changed_flags}'" ];
