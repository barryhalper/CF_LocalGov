<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/DataAccessObjects/SiteAdminDAO.cfc $
	$Author: Bhalper $
	$Revision: 2 $
	$Date: 8/04/09 11:42 $

--->

<cfcomponent displayname="Admin" hint="function for localgov adminstrator" extends="his_Localgov_Extends.components.DAOManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="SiteAdminDAO" hint="Pseudo-constructor">
		
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		StructAppend( variables, Super.init( arguments.strConfig ) );

		return this;
		</cfscript>
						
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions --------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="validateLogin" access="public" output="false" returntype="query" hint="">
		<cfargument name="email" type="string" required="yes">
		<cfargument name="password" type="string" required="yes">
		
		<cfset var qry_UserDetails="">
		
		<!--- * Move to DAO layer * --->
		<cfquery name="qry_UserDetails" datasource="#variables.DSN1#">
		EXEC sp_GetAdminUser
			'#arguments.email#',
			'#Hash(arguments.password)#'
		</cfquery>

		<cfreturn qry_UserDetails>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PRIAVTE Functions ----------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getUserGroup" access="public" output="false" returntype="query" hint="">
		
		<cfset var qry_UserGroups="">
		
		<cfquery name="qry_UserGroups" datasource="#variables.DSN1#">
		EXEC spGetSiteAdimGroups
		</cfquery>
		
		<cfreturn qry_UserGroups>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getUsersSinceLaunch" access="public" output="false" returntype="query" hint="">
		
		<cfset var qryUsersSinceLaunch="">
		
		<cfquery name="qryUsersSinceLaunch" datasource="#variables.DSN1#">
			SELECT     COUNT(*) AS count
			FROM         tblLocalGov_User
			WHERE     (p_user_id > 4786)
		</cfquery>
		<cfreturn qryUsersSinceLaunch>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getTotalUsers" access="public" output="false" returntype="query" hint="">
		<cfset var qryTotalUsers="">
		
			<cfquery name="qryTotalUsers" datasource="#variables.DSN1#">
			SELECT     COUNT(*) AS count
			FROM         tblLocalGov_User
			</cfquery>
		<cfreturn qryTotalUsers>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetUsers" returntype="query" access="public" hint="return result set of Admin Users" output="no">
		<cfset var qryUsers ="">
	
			<cfquery datasource="#variables.dsn1#" name="qryUsers">
				EXEC spGetSiteAdminUsers
			</cfquery>
	
		<cfreturn qryUsers>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getTracking" access="public" output="false" returntype="query" hint="">
		
		<cfset var qryTracking="">
		<cfquery name="qryTracking" datasource="#variables.DSN1#">
			SELECT * FROM tblTracking 
			ORDER BY Priority ASC, DateCreated DESC
		</cfquery>
		<cfreturn qryTracking>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getAdminUser" access="public" output="false" returntype="query" hint="">
		<cfargument name="userid" required="yes" type="numeric" >
		
		<cfset var qryAdminUser="">
		<cfquery name="qryAdminUser" datasource="#variables.DSN1#">
			EXEC sp_GetLocalGovSiteAdminUser #arguments.userid#
		</cfquery>
		<cfreturn qryAdminUser>
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- COMMITT ------------------------------------------------------------------------------------------>
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="CommitUser" access="public" output="false" returntype="numeric" hint="">
		<cfargument name="UserID" 			type="numeric" required="no" default="0">
		<cfargument name="forename" 		type="string" required="yes">
		<cfargument name="surname" 			type="string" required="yes">
		<cfargument name="username" 		type="string" required="yes">
		<cfargument name="password" 		type="string" required="yes">
		<cfargument name="lstGroups" 		type="string" required="yes">
		<cfargument name="partnerid" 		type="numeric" required="no" default="0">
		
		
		<cfset var newid=0>
		
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_CommitLocalGovSiteAdminUser">
				<cfif arguments.UserID>
					<cfprocparam dbvarname="@UserID" 	 cfsqltype="cf_sql_integer" 	type="in" value="#arguments.UserID#" >
				<cfelse>	
					<cfprocparam dbvarname="@UserID" 	 cfsqltype="cf_sql_integer" 	type="in" value="" null="yes" >
				</cfif>
				<cfprocparam dbvarname="@forename" cfsqltype="cf_sql_varchar"  	type="in" value="#trim(arguments.forename)#">
				<cfprocparam dbvarname="@surname" cfsqltype="cf_sql_varchar"  	type="in" value="#trim(arguments.surname)#">
				<cfprocparam dbvarname="@username" cfsqltype="cf_sql_varchar"  	type="in" value="#trim(arguments.username)#">
				<cfprocparam dbvarname="@password" cfsqltype="cf_sql_varchar"  	type="in" value="#trim(arguments.password)#">
				<cfprocparam dbvarname="@lstGroups" cfsqltype="cf_sql_varchar"  	type="in" value="#trim(arguments.lstGroups)#">
				<cfprocparam dbvarname="@partnerid" cfsqltype="cf_sql_varchar"  	type="in" value="#trim(arguments.partnerid)#">
				<cfprocparam dbvarname="@@NewUserID" 	 cfsqltype="cf_sql_integer" 	type="out" variable="newid">
			</cfstoredproc>
		<cfreturn newid>	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="DeleteUser" access="public" output="false" returntype="boolean" hint="">
		<cfargument name="UserID" 			type="numeric" required="yes">
			<cfquery  datasource="#variables.DSN1#">
			EXEC sp_DeleteLocalGovSiteAdminUser #arguments.userid#
		</cfquery>
		<cfreturn true>	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->

	<cffunction name="gethome" access="public" output="false" returntype="struct" hint="">
		
		<cfset var strHome = structnew()>
		<cfstoredproc datasource="#variables.dsn5#" procedure="usp_GetAdminStats">
			<cfprocresult resultset="1" name="strHome.qryUserStats">
			<cfprocresult resultset="2" name="strHome.qryOrderStats">
			<cfprocresult resultset="3" name="strHome.qryVisitsStats">
		</cfstoredproc> 	
		
		<cfreturn strHome>
	</cffunction>
</cfcomponent>