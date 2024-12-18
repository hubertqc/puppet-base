#####################################################
#
## Common mail filtering rules
#
#####################################################

require [ "variables", "imap4flags" , "editheader" ];

if header :contains "X-Virus-found" "Yes"
{

    # Match the entire subject ...
    if header :matches "Subject" "*" {
        # ... to get it in a match group that can then be stored in a variable:
        set "subject" "${1}";
    }

    # We can't "replace" a header, but we can delete (all instances of) it and
    # re-add (a single instance of) it:
    deleteheader "Subject";
    # Append/prepend as you see fit
    addheader :last "Subject" "[WARNING: potential virus found] ${subject}";
    # Note that the header is added ":last" (so it won't appear before possible
    # "Received" headers).

    addflag [ "PotentialVirus" ];
}
