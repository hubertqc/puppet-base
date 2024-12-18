#####################################################
#
## Common mail filtering rules
#
#####################################################

require [ "fileinto", "mailbox" ];

#if anyof ( header :contains "X-Spam-Flag" "YES" , header :contains "X-Spam-Status" "Yes," )
if header :contains "X-Spam-Flag" "YES"
{
	fileinto :create "Spam";
	stop;
}
