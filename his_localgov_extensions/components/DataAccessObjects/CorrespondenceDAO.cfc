<cfcomponent displayname="CorrespondenceDAO" hint="Correspondence-related data access methods" extends="his_Localgov_Extends.components.DAOManager">
	
	<!--- ------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="CorrespondenceDAO" hint="Pseudo-constructor">
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		StructAppend( variables, Super.init( arguments.strConfig ) );

		return this;
		</cfscript>
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="GetCorrespondenceByID" access="public" output="false" returntype="Query" hint="Return a single Correspondence">
		<cfargument name="CorrespondenceID" type="numeric" 	required="yes">
	
		<cfset qryGetCorrespondenceByID = queryNew("temp")>
		
		<cfquery name="qryGetCorrespondenceByID" datasource="#variables.dsn5#">
			EXEC usp_GetCorrespondenceByID 
				@CorrespondenceID = #arguments.CorrespondenceID#
		</cfquery>
		
		<cfreturn qryGetCorrespondenceByID>
	
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="GetInfoCorrespondenceByUser" access="public" output="false" returntype="Query" hint="Return all Info Correspondence for user">
		<cfargument name="userID" type="numeric" 	required="yes">
	
		<cfset qryGetCorrespondenceByID = queryNew("temp")>
		
		<cfquery name="GetInfoCorrespondenceByUser" datasource="#variables.dsn5#">
			EXEC usp_GetInfoCorrespondenceByUser
				@userID = #arguments.userID#
		</cfquery>
		
		<cfreturn GetInfoCorrespondenceByUser>
	
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="SaveCorrespondence" access="public" output="false" returntype="numeric" hint="Save letter to db and return the LetterID">
		<cfargument name="CorrespondenceID"		type="Numeric"	required="no" default="0">
		<cfargument name="UserID" 				type="Numeric" 	required="yes">
		<cfargument name="ToAddress" 			type="String" 	required="yes">
		<cfargument name="SubscriptionID" 		type="Numeric" 	required="yes">
		<cfargument name="SubscriptionPeriodID" type="Numeric" 	required="yes">
		<cfargument name="EmailID"				type="Numeric"	required="yes">
		<cfargument name="HTMLEmail"			type="String"	required="yes">
		<cfargument name="DateSent"				type="String"	required="yes">
		
		<cfset var RetCorrespondenceID = 0>
		
		<cfstoredproc procedure="usp_SaveCorrespondence" datasource="#variables.dsn5#" returncode="yes">
			
			<cfif arguments.CorrespondenceID EQ 0>
				<cfprocparam type="in"  cfsqltype="cf_sql_integer" 		dbvarname="@CorrespondenceID"		value="" null="true">
			<cfelse>
				<cfprocparam type="in"  cfsqltype="cf_sql_integer" 		dbvarname="@CorrespondenceID"		value="#arguments.CorrespondenceID#">
			</cfif>
			<cfprocparam type="in"  	cfsqltype="cf_sql_integer" 		dbvarname="@UserID"					value="#arguments.UserID#">
			<cfprocparam type="in"  	cfsqltype="cf_sql_varchar" 		dbvarname="@ToAddress" 				value="#arguments.ToAddress#">
			<cfprocparam type="in"  	cfsqltype="cf_sql_integer"  	dbvarname="@SubscriptionID"			value="#arguments.SubscriptionID#">
			<cfprocparam type="in"  	cfsqltype="cf_sql_integer"  	dbvarname="@SubscriptionPeriodID"	value="#arguments.SubscriptionPeriodID#">
			<cfprocparam type="in"  	cfsqltype="cf_sql_integer"  	dbvarname="@EmailID"				value="#arguments.EmailID#">
			<cfprocparam type="in"  	cfsqltype="cf_sql_longvarchar"  dbvarname="@HTMLEmail"				value="#arguments.HTMLEmail#">
			<cfprocparam type="in"  	cfsqltype="cf_sql_date"  		dbvarname="@DateSent"				value="#DateFormat(arguments.DateSent, 'dd/mmm/yyyy')#">

			<cfprocparam type="out" 	cfsqltype="cf_sql_integer" 		dbvarname="@NewID" 			variable="RetCorrespondenceID">

		</cfstoredproc>
	 
		<cfreturn RetCorrespondenceID>
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="DeleteCorrespondence" access="public" output="false" returntype="void" hint="Delete Correspondence from db">
		<cfargument name="CorrespondenceID" type="numeric" 	required="no">
		
		<cfset var qryDeleteCorrespondence = queryNew("temp")>
		
		<cfquery name="qryDeleteCorrespondence" datasource="#variables.dsn5#">
			EXEC usp_DeleteCorrespondence #arguments.CorrespondenceID#
		</cfquery>	
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="GetAllCorrespondence" access="public" output="false" returntype="query" hint="Return all Correspondence">
		
		<cfset var qryGetAllCorrespondence = queryNew("temp")>
		
		<cfquery name="qryGetAllCorrespondence" datasource="#variables.dsn5#">
			EXEC usp_GetAllCorrespondence
		</cfquery>	
		
		<cfreturn qryGetAllCorrespondence>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
</cfcomponent>