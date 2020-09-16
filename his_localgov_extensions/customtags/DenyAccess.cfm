<!--
	
	$Archive: /localgov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/customtags/DenyAccess.cfm $
	$Author: Bhalper $
	$Revision: 2 $
	$Date: 18/05/09 16:35 $

-->

<!--- OUTPUT MESSAGE BASED ON USER STATTUS --->
<cfparam name="attributes.AccessType" 		default="1"><!---string of which status a user will required to view content ---> 
<cfparam name="attributes.displayContent" 	default="">
<cfparam name="attributes.strSession" 	 	default="">
<cfparam name="attributes.NumRecords" 	 	default="0">
<!---user type id --->



<cfscript>
sMessage = "You must be ";
strStatus=request.objBus.objuser.CheckPageAccess(attributes.AccessType, attributes.strSession);
if (strStatus.IsAllowed)
	writeoutput(attributes.displayContent);
else{
	switch (strStatus.sReason){
	case "NotLoggedIn":
		sMessage = sMessage & "logged in to view these ";
	break;
	case "NotSubs":
		sMessage = sMessage & "logged in as a subscriber to view these ";
	break;
	case "NotCorpSubs":
		sMessage = sMessage & "logged in as a corporate administartor to view these ";
	break;
	}
	writeoutput(sMessage & "<p><strong>#attributes.NumRecords#</strong> records</p>");
}

	//writeoutput("<p>you need to be logged in to view <strong>#attributes.NumRecords#</strong> records</p>");
</cfscript>

