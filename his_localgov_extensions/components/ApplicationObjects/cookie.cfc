<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/COMPONENTS/ApplicationObjects/cookie.cfc $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 8/08/07 10:06 $

--->

<cfcomponent displayname="cookie" hint="Cookie-related functions." >

	<!--- ---------------------------------------------------------------------------------------------------------------->
	<cffunction name="CookiesEnabled" returntype="boolean" output="true">
	
		<cfscript>
		var bCookiesEnabled = true;
		
		// Determine whether Cookies are enabled or not... 
		try {	
			tmp = cookie.CookiesEnabled;
		} catch (Any except) {
			bCookiesEnabled = false;
		}
		
		return bCookiesEnabled;
		</cfscript>
		
	</cffunction>
	
	<!--- ---------------------------------------------------------------------------------------------------------------->
		
	<cffunction name="KillCookie" access="public" returntype="boolean" hint="Deletes any cookie">
	
		<cfargument name="cookiename" required="yes" type="string">
		<cfset var bKillCookie = 0>
		<cftry>
			<cfset "#cookiename#" = "">
			<cfcookie name="#cookiename#" expires="now">
			<cfset bKillCookie = 1>
			<cfcatch></cfcatch>
		</cftry>
		<cfreturn bKillCookie>
		
	</cffunction>
	
	<!--- ---------------------------------------------------------------------------------------------------------------->
	
</cfcomponent>