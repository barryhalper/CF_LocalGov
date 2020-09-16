<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/customtags/JavaScripts.cfm $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 14/08/07 14:53 $

--->

<cfparam name="attributes.scripts"	default="">
<cfparam name="attributes.path"  	default="">

<!--- Include appropriate javascript function... --->
<cfsavecontent variable="js">
<cfoutput><cfloop list="#trim(attributes.scripts)#" index="script">
	<script type="text/javascript" language="javascript" src="<cfoutput>#attributes.path##trim(script)#.js</cfoutput>" >
	</script>
</cfloop></cfoutput>
</cfsavecontent>
<cfhtmlhead text="#js#">