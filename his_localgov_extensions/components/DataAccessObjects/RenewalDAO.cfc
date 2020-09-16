<cfcomponent displayname="RenewalDAO" hint="Letter-related data access methods" extends="his_Localgov_Extends.components.DAOManager">
	
	<!--- ------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="RenewalDAO" hint="Pseudo-constructor">
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		StructAppend( variables, Super.init( arguments.strConfig ) );

		return this;
		</cfscript>
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="GetEmailByID" access="public" output="false" returntype="Query" hint="Return a single Email">
		<cfargument name="EmailID" 		type="numeric" 	required="yes">
		<cfargument name="EmailType" 	type="string" 	required="yes">
	
		<cfset qryGetEmailByID = queryNew("temp")>
		
		<cfquery name="qryGetEmailByID" datasource="#variables.dsn5#">
			EXEC usp_GetEmailByID 
				@EmailID = #arguments.EmailID#
				, @EmailType = '#arguments.EmailType#'
		</cfquery>
		
		<cfreturn qryGetEmailByID>
	
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="SaveEmail" access="public" output="false" returntype="numeric" hint="Save letter to db and return the LetterID">
		<cfargument name="EmailID" 		type="numeric" 	required="no" default="0">
		<cfargument name="EmailSubject" type="string" 	required="yes">
		<cfargument name="LetterID" 	type="numeric" 	required="yes">
		<cfargument name="DaysPrior"	type="numeric"	required="yes">
		<cfargument name="EmailType"	type="string"	required="yes">
		<cfargument name="IsActive"		type="numeric"	required="yes">
		
		<cfset var RetEmailID = 0>
		
		<cfstoredproc procedure="usp_SaveEmail" datasource="#variables.dsn5#" returncode="yes">
			
			<cfif arguments.EmailID EQ 0>
				<cfprocparam type="in"  cfsqltype="cf_sql_integer" 		dbvarname="@EmailID"		value="" null="true">
			<cfelse>
				<cfprocparam type="in"  cfsqltype="cf_sql_integer" 		dbvarname="@EmailID"		value="#arguments.EmailID#">
			</cfif>
			<cfprocparam type="in"  	cfsqltype="cf_sql_varchar" 		dbvarname="@EmailSubject" 	value="#arguments.EmailSubject#">
			<cfprocparam type="in"  	cfsqltype="cf_sql_integer"  	dbvarname="@LetterID"		value="#arguments.LetterID#">
			<cfprocparam type="in"  	cfsqltype="cf_sql_integer"  	dbvarname="@DaysPrior"		value="#arguments.DaysPrior#">
			<cfprocparam type="in"  	cfsqltype="cf_sql_varchar"  	dbvarname="@EmailType"		value="#arguments.EmailType#">
			<cfprocparam type="in"  	cfsqltype="cf_sql_integer"  	dbvarname="@IsActive"		value="#arguments.IsActive#">

			<cfprocparam type="out" 	cfsqltype="cf_sql_integer" 		dbvarname="@NewID" 			variable="RetEmailID">

		</cfstoredproc>
	 
		<cfreturn RetEmailID>
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="DeleteEmail" access="public" output="false" returntype="void" hint="Delete Email from db">
		<cfargument name="EmailID" type="numeric" 	required="no">
		
		<cfset var qryDeleteEmail = queryNew("temp")>
		
		<cfquery name="qryDeleteEmail" datasource="#variables.dsn5#">
			EXEC usp_DeleteEmail #arguments.EmailID#
		</cfquery>	
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="GetLookups" access="public" output="false" returntype="struct" hint="return all keywords and Organisations">
		<cfset var strLookUps=StructNew()>
		
		<cfstoredproc datasource="#variables.dsn5#" procedure="usp_GetArticleLookups">
			<cfprocresult resultset="1" name="strLookUps.qryKeywords">
			<cfprocresult resultset="2" name="strLookUps.qryAuthors">
			<cfprocresult resultset="3" name="strLookUps.qryArticleTypes">
			<cfprocresult resultset="4" name="strLookUps.qryArticlePositions">
		</cfstoredproc>
		
		<cfreturn strLookUps>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="GetAllEmails" access="public" output="false" returntype="query" hint="Return all Emails">
		
		<cfset var qryGetAllEmails = queryNew("temp")>
		
		<cfquery name="qryGetAllEmails" datasource="#variables.dsn5#">
			EXEC usp_GetAllEmails
		</cfquery>	
		
		<cfreturn qryGetAllEmails>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="GetAllEmailsByType" access="public" output="false" returntype="query" hint="Return all emails of a specific type">
		<cfargument name="emailType" type="string" required="true">
		
		<cfset var qryGetAllEmailsByType = queryNew("temp")>
		
		<cfquery name="qryGetAllEmailsByType" datasource="#variables.dsn5#">
			EXEC usp_GetAllEmailsByType @EmailType = '#arguments.EmailType#'
		</cfquery>	
		
		<cfreturn qryGetAllEmailsByType>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="GetRenewalUsers" access="public" output="false" returntype="query" hint="Return all users within the renewal series time period">
		<cfargument name="renewalDate" type="String" required="true">
		
		<cfset var qryGetRenewalUsers = queryNew("temp")>
		
		<cfquery name="qryGetRenewalUsers" datasource="#variables.dsn5#">
			EXEC usp_GetRenewalUsers 
				@RenewalDate = #CreateODBCDate(DateFormat(arguments.renewalDate, "dd/mmm/yyyy"))#
		</cfquery>	
		
		<cfreturn qryGetRenewalUsers>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
</cfcomponent>