<cfcomponent displayname="WebinarDAO" hint="Webinar-related data access methods" extends="his_Localgov_Extends.components.DAOManager">

	<!--- ------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="WebinarDAO" hint="Pseudo-constructor">
	
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		StructAppend( variables, Super.init( arguments.strConfig ) );
		
		return this;
		</cfscript>
		
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="GetDetails" access="public" output="false" returntype="query" hint="return details of specified Webinar">
		<cfargument name="WebinarID" type="numeric" required="yes">
		
		<cfset var qryWebinar = "">
		
		<cfquery name="qryWebinar" datasource="#variables.DSN1#">
			EXEC sp_LocalGov_GetWebinarDetails 
				@WebinarID = #arguments.WebinarID#
		</cfquery>
		
		<cfreturn qryWebinar> 
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="GetRegistrations" access="public" output="false" returntype="query" hint="Get details of all the Webinars the User has registered for">
		<cfargument name="UserID" type="numeric" required="yes">
		<cfargument name="WebinarID" type="numeric" required="yes">
		
		<cfset var qryGetUserWebinarRegistrations = "">
		
		<cfquery name="qryGetUserWebinarRegistrations" datasource="#variables.DSN5#">
			EXEC usp_GetUserWebinarRegistrations 
				@UserID = #arguments.UserID#,
				@WebinarID = #arguments.WebinarID#  
		</cfquery>
		
		<cfreturn qryGetUserWebinarRegistrations>  
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="SaveInterest" access="public" output="false" returntype="void" hint="Save User Interest in Specified Webinar">
		<cfargument name="WebinarID" 	type="numeric" 	required="yes">
		<cfargument name="UserID" 		type="numeric" 	required="yes">
		
		<cfset var qrySaveWebinarInterest = "">
		
		<cfquery name="qrySaveWebinarInterest" datasource="#variables.DSN5#">
			EXEC usp_SaveWebinarInterest
				@WebinarID = #arguments.WebinarID#
				, @UserID = #arguments.UserID#
		</cfquery>
		
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="Commit" access="public" output="false" returntype="numeric" hint="Save User Interest in Specified Webinar">
		<cfargument name="Id" 		type="numeric" 	required="no" default="0">
		<cfargument name="webinarName" 		type="string" 	required="yes">
		<cfargument name="WebinarDate" 		type="date" 	required="yes">
		<cfargument name="organisation" 	type="string" 	required="yes">
		<cfargument name="urlID" 			type="numeric" 	required="yes">
		<cfargument name="newsid" 			type="numeric" 	required="yes">
	
			<cfset var sRtnValue = 0>
		
		
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_LocalGov_CommitWebinar">
		 	<cfif arguments.Id EQ 0>
				<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@WebinarID"		value="" null="true">
			<cfelse>
				<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@WebinarID"		value="#arguments.id#">
			</cfif>
		 	<cfprocparam type="in"	cfsqltype="cf_sql_varchar" 	dbvarname="@webinarName" 		value="#arguments.webinarName#">
		 	<cfprocparam type="in"	cfsqltype="cf_sql_date" 	dbvarname="@WebinarDate" 		value="#LSParseDateTime(arguments.WebinarDate)#">
			<cfprocparam type="in"  cfsqlType="cf_sql_varchar" 	dbvarname="@organisation" 	   	value="#arguments.organisation#">
			<cfprocparam type="in"  cfsqlType="cf_sql_integer" 	dbvarname="@urlID" 	   			value="#arguments.urlID#">
			<cfprocparam type="in"  cfsqlType="cf_sql_integer" 	dbvarname="@newsid" 	   		value="#arguments.newsid#">
			<cfprocparam type="out" cfsqltype="cf_sql_integer" 	dbvarname="@newid"	 			variable="sRtnValue">
		</cfstoredproc>

		
		<cfreturn sRtnValue>
	</cffunction>

	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="list" access="public" output="false" returntype="query" hint="list all webinars">
			
		<cfset var qrylist = "">
		
		<cfquery name="qrylist" datasource="#variables.DSN1#">
			sp_LocalGov_GetWebinars
		</cfquery>
		<cfreturn qrylist>  
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getUsers" access="public" output="false" returntype="query" hint="list all users by webinar">
		<cfargument name="WebinarID" 	type="numeric" 	required="yes">
		<cfset var qrylist = "">
		
		<cfquery name="qrylist" datasource="#variables.DSN5#">
			usp_getUserByWebinar #arguments.WebinarID#
		</cfquery>
		<cfreturn qrylist>  
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="saveDateVisited" access="public" output="false" returntype="void" hint="executed last visted date stamp for a user agais a webinar">
			<cfargument name="WebinarID" 	type="numeric" 	required="yes">
			<cfargument name="UserID" 		type="numeric" 	required="yes">
		
		<cfquery name="qrylist" datasource="#variables.DSN5#">
			usp_CommitUserWebinarVisist #arguments.UserID#, #arguments.WebinarID#
		</cfquery>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
</cfcomponent>