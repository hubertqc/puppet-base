require ["vnd.dovecot.pipe", "copy", "imapsieve", "environment", "variables", "imap4flags", "vnd.dovecot.debug" ];

#
## Executed when the mail has its flags changed
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

if environment :matches "imap.changedflags" "*" {
	set "changed_flags" "${0}";
}

if hasflag :matches "*" {
	set "flags" "${0}";
}

removeflag [ "JunkRecorded" ];

## Don't do anything if the mail is moved to the Trash folder
if string "${mailbox}" "Trash" {
	stop;
}
if string "${mailbox}" "Deleted Messages" {
	stop;
}
if string "${mailbox}" "SpamControl.Learnt-as-Spam" {
	stop;
}

debug_log "=========================================================";
debug_log "       Changed flags: ${changed_flags}";
debug_log "---------------------------------------------------------";

if environment :contains "imap.changedflags" "Junk" { debug_log "Flag Junk changed"; }
if environment :contains "imap.changedflags" "$Junk" { debug_log "Flag $Junk changed"; }
if environment :contains "imap.changedflags" "$NotJunk" { debug_log "Flag $NotJunk changed"; }
if environment :contains "imap.changedflags" "NotJunk" { debug_log "Flag NotJunk changed"; }
if environment :contains "imap.changedflags" "NonJunk" { debug_log "Flag NonJunk changed"; }

debug_log "---------------------------------------------------------";

if hasflag "Junk"	{ debug_log "Msg has flags Junk"; }
if hasflag "$Junk"	{ debug_log "Msg has flags $Junk"; }
if hasflag "$NotJunk"	{ debug_log "Msg has flags $NotJunk"; }
if hasflag "NotJunk"	{ debug_log "Msg has flags NotJunk"; }
if hasflag "NonJunk"	{ debug_log "Msg has flags NonJunk"; }

debug_log "---------------------------------------------------------";

if anyof(
	allof( hasflag "Junk" , environment :contains "imap.changedflags" "Junk" ),
	allof( hasflag "$Junk" , environment :contains "imap.changedflags" "$Junk" )
	) {

	debug_log "---------------------------------------------------------";
	debug_log "This message was marked as SPAM";
	debug_log "---------------------------------------------------------";

	stop;
}


if anyof(
	allof( hasflag "NonJunk" , environment :contains "imap.changedflags" "NonJunk" ),
	allof( hasflag "NotJunk" , environment :contains "imap.changedflags" "NotJunk" ),
	allof( hasflag "$JNotunk" , environment :contains "imap.changedflags" "$NotJunk" )
	) {

	debug_log "---------------------------------------------------------";
	debug_log "This message was marked as HAM";
	debug_log "---------------------------------------------------------";

	stop;
}


debug_log "---------------------------------------------------------";

stop;

if string "${mailbox}" "Spam" {
	if environment :contains "imap.changedflags" [ "\Seen" ] {
		if hasflag :contains [ "\Seen" ] {

			debug_log "Executing changed-flags for seen message in ${mailbox} folder";

			#addflag [ "$Junk", "Junk" ];
			#removeflag [ "$NotJunk", "NotJunk", "NonJunk" ];

			pipe :copy "sa-copy.sh" [ "${username}", "flags", "msgid:'${message_id}'", "imapuser:${imapuser}", "cause:${cause}", "mailbox:${mailbox}", "phase:${phase}", "changedflags:'${changed_flags}'", "Seen" ];
			stop;
		}
	}
}


## Check if the Junk/NotJunk flags were changed

if environment :contains "imap.changedflags" [ "\$Junk", "Junk", "\$NotJunk", "NotJunk", "NonJunk" ] {

	#if hasflag :contains [ "JunkRecorded" ] {
	#	stop;
	#}

	debug_log "Executing changed-flags in ${mailbox} folder";

#	if hasflag :contains [ "$Junk", "Junk" ] {
#
#		addflag [ "$Junk", "Junk" ];
#		removeflag [ "$NotJunk", "NotJunk", "NonJunk" ];
#
#		pipe :copy "sa-copy.sh" [ "${username}", "flags", "msgid:'${message_id}'", "imapuser:${imapuser}", "cause:${cause}", "mailbox:${mailbox}", "phase:${phase}", "changedflags:'${changed_flags}'", "Junk" ];
#
#		stop;
#	}

	if hasflag :contains [ "$NotJunk", "NotJunk", "NonJunk" ] {
		removeflag [ "$Junk", "Junk" ];
		addflag [ "$NotJunk", "NotJunk", "NonJunk" ];

		pipe :copy "sa-copy.sh" [ "${username}", "flags", "msgid:'${message_id}'", "imapuser:${imapuser}", "cause:${cause}", "mailbox:${mailbox}", "phase:${phase}", "changedflags:'${changed_flags}'", "NotJunk" ];
	}
}
