<cfparam name="attributes.rtncode"  default="">

<cfswitch expression="#attributes.rtncode#">
	<cfcase value="-3"><cfset Message = "<strong>Your subscription has expired or is invalid, please resubscribe.</strong>"></cfcase>
	
	<cfcase value="-4"><cfset Message = "<strong>Your account is currently not active, please contact us for more information.</strong>"></cfcase>
	
	<cfcase value="-5"><cfset Message = "<strong>Your subscription has expired.</strong><br><br><a href='javascript:window.location.reload()'>Click here to log into the site as a normal registered user</a>."></cfcase>
	
	<cfcase value="-6"><cfset Message = "<strong>We have not yet received payment for your subscription.</strong>"></cfcase>
	
	<cfdefaultcase>	   <cfset Message = "<strong>Your login has failed, please check your details and try again.</strong>"></cfdefaultcase>
</cfswitch>

<cfoutput><span style="color:##FF0000">#Message#</span></cfoutput>