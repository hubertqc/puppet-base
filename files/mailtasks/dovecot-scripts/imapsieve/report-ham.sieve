require ["vnd.dovecot.pipe", "copy", "imapsieve", "environment", "variables", "imap4flags", "vnd.dovecot.debug" ];

#
## Execute when the mail is moved out of the Spam folder
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

## Stop doing anything if the mail is moved to Trash or to a Spam folder
if string "${mailbox}" "Trash" {
	stop;
}
if string "${mailbox}" "Deleted Messages" {
	stop;
}
if string "${mailbox}" "SpamControl.Learnt-as-Spam" {
	stop;
}
if string "${mailbox}" "Spam" {
	stop;
}

## Otherwise, flag the mail as not Junk and learn from it
debug_log "Executing report-ham on ${cause} to ${mailbox} folder";

removeflag [ "$Junk", "Junk" ];
addflag [ "$NotJunk", "NotJunk", "NonJunk" ];

pipe :copy "sa-copy.sh" [ "${username}", "ham", "msgid:'${message_id}'", "imapuser:${imapuser}", "cause:${cause}", "mailbox:${mailbox}", "phase:${phase}", "changedflags:'${changed_flags}'" ];
