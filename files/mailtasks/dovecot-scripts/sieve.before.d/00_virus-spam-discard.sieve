#####################################################
#
## Common mail filtering rules
#
#####################################################

require [ "fileinto" ];

#if anyof ( header :contains "X-Spam-Flag" "YES" , header :contains "X-Spam-Status" "Yes" )
if header :contains "X-Spam-Flag" "YES"
{
	if header :contains "X-Virus-found" "Yes"
	{
		discard;
		stop;
	}
}
