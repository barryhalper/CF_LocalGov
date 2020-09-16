<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/COMPONENTS/ApplicationObjects/Admin.cfc $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 8/08/07 10:06 $

--->

<cfcomponent displayname="Admin" hint="Admin-related functions">

	<!--- -------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR -------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Admin" hint="">
	
		<cfquery name="qry_UserGroups" datasource="HIS_Websites">
		EXEC spGetSiteAdimGroups
		</cfquery>
		
		<cfset this.qry_UserGroups = qry_UserGroups>
		
		<cfreturn this>
	
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions --------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="validateLogin" access="public" output="false" returntype="query" hint="">
		<cfargument name="email" type="string" required="yes">
		<cfargument name="password" type="string" required="yes">
		
		<!--- * Move to DAO layer * --->
		<cfquery name="qry_UserDetails" datasource="HIS_Websites">
		EXEC sp_GetAdminUser
			'#arguments.email#',
			'#Hash(arguments.password)#'
		</cfquery>

		<cfreturn qry_UserDetails>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->

	<!--- -------------------------------------------------------------------------------------------------->
	<!--- PRIAVTE Functions -------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->

	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->

</cfcomponent>