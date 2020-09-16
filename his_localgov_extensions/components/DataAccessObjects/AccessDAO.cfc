<cfcomponent displayname="AccessDAO" hint="subscription-related data access methods" extends="his_Localgov_Extends.components.DAOManager">
	<!--- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ---------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="AccessDAO" hint="Pseudo-constructor">
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
			StructAppend( variables, Super.init( arguments.strConfig ) );
	
			return this;
		</cfscript>
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="GetUserSubscription" access="public" output="false" returntype="query" hint="Return user's subscription info">
		<cfargument name="UserID" type="string"  required="yes">
		
		<cfset var qryUserSub = queryNew("temp")>
		
		<cfquery name="qryUserSub" datasource="#variables.dsn5#">
			EXEC usp_GetUserSubscription
 				@UserID  = #arguments.UserID#
		</cfquery>
		
		<cfreturn qryUserSub>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="GetSubscriptionByID" access="public" output="false" returntype="query" hint="Return subscription info">
		<cfargument name="SubscriptionID" type="string"  required="yes">
		
		<cfset var qrySubInfo = queryNew("temp")>
		
		<cfquery name="qrySubInfo" datasource="#variables.dsn5#">
			EXEC usp_GetSubscriptionByID
 				@SubscriptionID  = #arguments.SubscriptionID#
		</cfquery>
		
		<cfreturn qrySubInfo>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="getSubSearchLookups" output="false" returntype="Struct" access="public" hint="Return data for lookups needed for subscription search/modification forms">
		<cfset var strSubLookups = StructNew()> 
		
		<cfstoredproc procedure="usp_GetSubSearchLookups" datasource="#variables.dsn5#">			
			<cfprocresult resultset="1" name="strSubLookups.qrySubStatus">
			<cfprocresult resultset="2" name="strSubLookups.qrySubType">
		</cfstoredproc>
		
		<cfreturn strSubLookups>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="SearchSubscriptions" output="false" returntype="query" access="public" hint="Return data for lookups needed for subscription search/modification forms">
		<cfargument name="Surname" 				required="yes" 	type="String">
		<cfargument name="Email"  				required="yes"	type="String">
		<cfargument name="Postcode" 			required="yes" 	type="String">	
		<cfargument name="DateStart"			required="yes"	type="String">
		<cfargument name="DateEnd"				required="yes"	type="String">
		<cfargument name="CompanyName"			required="yes"	type="String">
		<cfargument name="SubscriptionID" 		required="yes" 	type="String">
		<cfargument name="InvoiceNo" 			required="yes" 	type="String">
		<cfargument name="SubscriptionTypeID"	required="yes"	type="numeric">
		<cfargument name="SubscriptionStatusID"	required="yes"	type="numeric">
		<cfargument name="SubDateStart"			required="yes"	type="String">
		<cfargument name="SubDateEnd"			required="yes"	type="String">
		<cfargument name="UserID"				required="yes"	type="String">
		
		<cfset var SubDateTimeStart = "">
		<cfset var SubDateTimeEnd 	= "">
		<cfset var DateTimeEnd		= "">
		<cfset var DateTimeStart	= "">
		
		<cfset var qrySearchSubscriptions = queryNew("temp")>
		
		<!--- Setup date variables to be used in search --->
		<cfset DateTimeStart = DateFormat(arguments.DateStart, 'dd/mm/yyyy')> <!--- Start date for when user was REGISTERED --->
		
		<cfif Len(trim(arguments.SubDateStart))>
			<cfset SubDateTimeStart = DateFormat(arguments.SubDateStart, 'dd/mm/yyyy')> <!--- Start date for when user's subscription period starts --->
		</cfif>
		
		<!--- Make the end date one day later than that specified by user so that we can search
		for all users registered BEFORE the end date --->
		<cfset DateTimeEnd = DateAdd('d', 1, DateFormat(arguments.DateEnd, 'dd/mm/yyyy'))>
		
		<cfif Len(trim(arguments.SubDateEnd))>
			<cfset SubDateTimeEnd =  DateFormat(arguments.SubDateEnd, 'dd/mm/yyyy')>
		</cfif>

		<cfquery name="qrySearchSubscriptions" datasource="#variables.dsn5#">
			EXEC usp_SearchSubscriptions 
				@Surname 					= 	<cfif Len(arguments.Surname)>'#arguments.Surname#'<cfelse>NULL</cfif>
				, @Email 					= 	<cfif Len(arguments.Email)>'#arguments.Email#'<cfelse>NULL</cfif>
				, @Postcode 				= 	<cfif Len(arguments.Postcode)>'#arguments.Postcode#'<cfelse>NULL</cfif>
				, @DateStart 				= 	#CreateODBCDateTime(DateTimeStart)#
				, @DateEnd 					= 	#CreateODBCDateTime(DateTimeEnd)#
				, @CompanyName 				= 	<cfif Len(arguments.CompanyName)>'#arguments.CompanyName#'<cfelse>NULL</cfif>
				, @SubscriptionID 			= 	<cfif Len(arguments.SubscriptionID)>'#arguments.SubscriptionID#'<cfelse>NULL</cfif>
				, @invoiceNo	 			= 	<cfif Len(arguments.InvoiceNo)>'#arguments.InvoiceNo#'<cfelse>NULL</cfif>
				, @SubscriptionTypeID 		= 	<cfif arguments.SubscriptionTypeID NEQ 0>'#arguments.SubscriptionTypeID#'<cfelse>NULL</cfif>
				, @SubscriptionStatusID 	= 	<cfif arguments.SubscriptionStatusID NEQ 0>'#arguments.SubscriptionStatusID#'<cfelse>NULL</cfif>
				, @SubDateStart 			= 	<cfif Len(trim(arguments.SubDateStart))>#CreateODBCDateTime(SubDateTimeStart)#<cfelse>NULL</cfif>
				, @SubDateEnd 				= 	<cfif Len(trim(arguments.SubDateEnd))>#CreateODBCDateTime(SubDateTimeEnd)#<cfelse>NULL</cfif>
				, @UserID 					= 	<cfif Len(arguments.UserID)>'#arguments.UserID#'<cfelse>NULL</cfif>
		</cfquery>	
		
		<!--- <cfdump var="#qrySearchSubscriptions#"><cfabort> --->
		<cfreturn qrySearchSubscriptions>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="UpdateAllSubscriptions" access="public" output="false" returntype="void" hint="Update all subscriptions that may need to be activated/de-activated">
	
		<cfquery name="qryUpdateSubscriptions" datasource="#variables.dsn5#">
			EXEC usp_UpdateAllSubscriptions
		</cfquery>
	
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getFunctionByProduct" access="public" output="false" returntype="query" hint="get all functions by product">
		<cfset var qryFunction = queryNew("temp")>
		
		<cfquery name="qryFunction" datasource="#instance.strConfig.strVars.dsn1#">
			EXEC usp_getFunctionByProduct
		</cfquery>
	
		<cfreturn qryFunction>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="GetAllSubscribers" output="false" returntype="query" access="public" hint="Return data for lookups needed for subscription search/modification forms">
		<cfset var qryGetAllSubscribers = queryNew("temp")>
		
		<cfquery name="qryGetAllSubscribers" datasource="#variables.dsn5#">
			EXEC usp_GetAllSubscriptions
		</cfquery>
	
		<cfreturn qryGetAllSubscribers>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="GetTypes" output="false" returntype="query" access="public" hint="Return access types">
		<cfset var qry= queryNew("temp")>
		
		<cfquery name="qry" datasource="#variables.dsn5#">
			EXEC usp_GetAccessTypes
		</cfquery>
	
		<cfreturn qry>
	</cffunction>
</cfcomponent>