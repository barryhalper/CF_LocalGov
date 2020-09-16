<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/DataAccessObjects/SubscriptionsDAO.cfc $
	$Author: Bhalper $
	$Revision: 2 $
	$Date: 11/03/08 16:23 $

--->

<cfcomponent displayname="SubscriptionsDAO" hint="<component description here>" extends="his_Localgov_Extends.components.DAOManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="SubscriptionsDAO" hint="Pseudo-constructor">
		
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		StructAppend( variables, Super.init( arguments.strConfig ) );

		return this;
		</cfscript>
				
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions: ----------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getOrders" access="public" output="true" returntype="query" >	
		<cfset var qry = "">
		
		<cfquery name="qry" datasource="#variables.DSN1#"  >
		EXEC sp_GetOrders
		</cfquery>		 
		 
		<cfreturn qry>
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getAllAccessCodes" access="public" output="false" returntype="query" 
		hint="Returns all access codes">
		<cfset var qry ="">		
		
		<cfquery name="qry" datasource="#variables.DSN1#">
		EXEC sp_GetAllAccessCodes
		</cfquery>
	
		<cfreturn qry>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getCorpUserDetailsByID" access="public" output="false" returntype="query" hint="returns a query of specified corporate user details">
		<cfargument name="id" type="numeric" required="yes">

		<cfset var qryUserDetails = "">
		
		<cfquery name="qryUserDetails" datasource="#variables.DSN1#" cachedwithin="#variables.CACHE_TIME#">
		EXEC sp_GetCorpUserDetailsByID
		@UserID = '#arguments.id#'
		</cfquery>
		
		<cfreturn qryUserDetails>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="commitCreatedAccessCode" access="public" output="false" returntype="void" 
		hint="Inserts access code">
		<cfargument name="accesscode" type="string" required="yes">
		
		<cfset var qry = "">		

		<cfquery name="qry" datasource="#variables.DSN1#">
		EXEC sp_CommitCreatedAccessCode 
			@AccessCode='#arguments.accesscode#'
		</cfquery>

	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getProducts" access="public" output="false" returntype="query" hint="Returns a recordset with all the products">
		<cfset var qry ="">		
		
		<cfquery name="qry" datasource="#variables.DSN1#">
		EXEC sp_GetProducts
		</cfquery>
	
		<cfreturn qry>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="commitOrder" output="false" returntype="struct" 
		hint="Commits subscription order (single/corporate) taken by either online OR direct mail/telephone/e-mail">
		
		<cfargument name="UserID" 						type="numeric" required="yes">
		<cfargument name="ProductID" 					type="numeric" required="yes">
		<cfargument name="Quantity" 					type="numeric" required="yes">
		<cfargument name="TotalAllowableSubscribers"	type="numeric" required="yes">
		<cfargument name="OrderLineStatus"				type="numeric" required="yes">
		<cfargument name="PaymentMethod"				type="numeric" required="yes">
		<cfargument name="StatusCode"					type="string"  required="yes">
		
		<cfset var strRtn = StructNew()>
		
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_CommitOrder" returncode="yes">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@UserId" 				value="#arguments.UserID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@ProductID" 				value="#arguments.ProductID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@Quantity" 				value="#arguments.Quantity#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@AllowableSubscribers" 	value="#arguments.TotalAllowableSubscribers#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@OrderLineStatus" 		value="#arguments.OrderLineStatus#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@PaymentMethod"	 		value="#arguments.PaymentMethod#">
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@StatusCode"	 			value="#arguments.StatusCode#">

	 		<cfprocparam type="out" cfsqltype="cf_sql_integer" 	dbvarname="@NewSubscriptionID" 		variable="strRtn.SubscriptionID"> 
			<cfprocparam type="out" cfsqltype="cf_sql_integer" 	dbvarname="@OrderID" 				variable="strRtn.OrderID"> 
		</cfstoredproc>
		
		<cfscript>
		if (cfstoredproc.statusCode NEQ 0)
			strRtn.SubscriptionID = 0;
		</cfscript>

		<cfreturn strRtn>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="commitTopUpOrder" output="false" returntype="struct" 
		hint="Updates subscription order (corporate), updating the subscription and inserting a new order.">
		
		<cfargument name="UserID" 							type="numeric" required="yes">
		<cfargument name="ProductID" 						type="numeric" required="yes">
		<cfargument name="Quantity" 						type="numeric" required="yes">
		<cfargument name="GrandTotal_AllowableSubscribers"	type="numeric" required="yes">
		<cfargument name="OrderLineStatus"					type="numeric" required="yes">
		<cfargument name="PaymentMethod"					type="numeric" required="yes">
		<cfargument name="CorpSubscriptionID" 				type="numeric" required="yes">
		
		<cfset var strRtn = StructNew()>
		
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_CommitTopUpOrder" returncode="yes">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@UserId" 							value="#arguments.UserID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@ProductID" 							value="#arguments.ProductID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@Quantity" 							value="#arguments.Quantity#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@GrandTotal_AllowableSubscribers" 	value="#arguments.GrandTotal_AllowableSubscribers#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@OrderLineStatus" 					value="#arguments.OrderLineStatus#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@PaymentMethod"	 					value="#arguments.PaymentMethod#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@CorpSubscriptionID" 				value="#arguments.CorpSubscriptionID#">

	 		<cfprocparam type="out" cfsqltype="cf_sql_integer" 	dbvarname="@NewSubscriptionID" 					variable="strRtn.SubscriptionID"> 
			<cfprocparam type="out" cfsqltype="cf_sql_integer" 	dbvarname="@OrderID" 							variable="strRtn.OrderID"> 
		</cfstoredproc>
		
		<cfscript>
		if (cfstoredproc.statusCode NEQ 0)
			strRtn.SubscriptionID = 0;
		</cfscript>
			
		<cfreturn strRtn>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="commitResubscriptionOrder" output="false" returntype="struct" 
		hint="Updates subscription order (corporate), updating the subscription and inserting a new order.">
		
		<cfargument name="UserID" 							type="numeric" 	required="yes">
		<cfargument name="ProductID" 						type="numeric" 	required="yes">
		<cfargument name="Quantity" 						type="numeric" 	required="yes">
		<cfargument name="OrderLineStatus"					type="numeric" 	required="yes">
		<cfargument name="PaymentMethod"					type="numeric" 	required="yes">
		<cfargument name="CorpSubscriptionID" 				type="numeric" 	required="yes">
		<cfargument name="CorpSubEndDate" 					type="date" 	required="yes">
		
		<cfset var strRtn = StructNew()>
		
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_CommitResubscriptionOrder" returncode="yes">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 		dbvarname="@UserId" 						value="#arguments.UserID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 		dbvarname="@ProductID" 						value="#arguments.ProductID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 		dbvarname="@Quantity" 						value="#arguments.Quantity#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 		dbvarname="@OrderLineStatus" 				value="#arguments.OrderLineStatus#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 		dbvarname="@PaymentMethod"	 				value="#arguments.PaymentMethod#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 		dbvarname="@CorpSubscriptionID" 			value="#arguments.CorpSubscriptionID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_timestamp" 	dbvarname="@CorpSubEndDate" 				value="#CreateODBCDateTime(DateAdd('yyyy', 1, LSDateFormat(arguments.CorpSubEndDate, 'dd/mm/yyyy') & ' ' & LSTimeFormat(arguments.CorpSubEndDate, 'HH:mm:ss')))#">

	 		<cfprocparam type="out" cfsqltype="cf_sql_integer" 	dbvarname="@NewSubscriptionID" 					Variable="strRtn.SubscriptionID"> 
			<cfprocparam type="out" cfsqltype="cf_sql_integer" 	dbvarname="@OrderID" 							variable="strRtn.OrderID"> 
		</cfstoredproc>
		
		<cfscript>
		if (cfstoredproc.statusCode NEQ 0)
			strRtn.SubscriptionID = 0;
		</cfscript>
			
		<cfreturn strRtn>
	
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getAllSubsTopUps" access="public" output="false" returntype="query" 
		hint="Returns all the top-ups ordered by the corporate admin">
		
		<cfargument name="CorpSubscriptionID" type="numeric" required="yes">
		
		<cfset var qryTopUps = "">

		<cfquery name="qryTopUps" datasource="#variables.dsn1#">
		EXEC sp_getAllSubsTopUps
			@CorpSubscriptionID = '#arguments.CorpSubscriptionID#'
		</cfquery>
		
		<cfreturn qryTopUps>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="updateTrialUsersEndDate" access="public" output="false" returntype="boolean" 
		hint="Updates the corp trial users end date">
		
		<cfargument name="TrialSubEndDate" 	required="yes" type="date">
		<cfargument name="UserID" 			required="yes" type="numeric">

		<cfquery name="qryUpdateTrialUsersEndDate" datasource="#variables.DSN1#">
		EXEC sp_UpdateTrialUsersEndDate
			@TrialEndDate 	= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#CreateODBCDateTime(LSDateFormat(arguments.TrialSubEndDate,'dd/mmm/yyyy') & ' ' & LSTimeFormat(Now(), 'HH:mm'))#">, 
			@UserID 		= '#arguments.UserID#'
		</cfquery>
		
		<cfreturn true>
			
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getSubFromAccessCode" access="public" output="false" returntype="query" 
		hint="Checks if the access code entered is valid">
		
		<cfargument name="AccessCode" required="yes" type="string" hint="">
		
		<cfset var qryAccessCode = "">

		<cfquery name="qryAccessCode" datasource="#variables.dsn1#">
		EXEC sp_GetSubFromAccessCode
			@AccessCode = '#arguments.AccessCode#'
		</cfquery>
		
		<cfreturn qryAccessCode>
				
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getMaximSubscriptions" access="public" output="false" returntype="query" 
		hint="Gets subscriptions that were initiated through Maxim">
				
		<cfset var qryMaximSubs = "">

		<cfquery name="qryMaximSubs" datasource="#variables.dsn1#">
		EXEC sp_GetMaximSubscriptions
		</cfquery>
		
		<cfreturn qryMaximSubs>
				
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- <cffunction name="getSubscriptionID" access="public" output="false" returntype="numeric" 
		hint="returns the subscription id">
		
		<cfargument name="AccessCode" required="yes" type="string" hint="">
		
		<cfset var qryGetSubscriptionID = "">

		<cfquery name="GetSubscriptionID" datasource="#variables.dsn1#">
			EXEC sp_GetSubscriptionID
				@AccessCode = '#arguments.AccessCode#'
		</cfquery>
		
		<cfreturn GetSubscriptionID.p_subscription_id>
		
	</cffunction> --->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="commitCorporateSubscriber" access="public" output="false" returntype="void" hint="Inserts the Subscription ID and User ID in the Subscriber table. This function only ever gets called if the subscriber has left and is being replaced.">
		
		<cfargument name="UserID" 	type="numeric" required="yes">
		<cfargument name="SubID" 	type="numeric" required="yes">
		
		<cfquery name="qry" datasource="#variables.DSN1#">
		EXEC sp_CommitCorporateSubscriber
			@UserID = '#arguments.UserID#',
			@SubID 	= '#arguments.SubID#'
		</cfquery>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="commitAccessCode" output="false" returntype="string" 
		hint="Commits accesscode">
		
		<cfargument name="SubscriptionID" type="numeric" required="yes">

		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_CommitAccessCode" returncode="yes">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@SubscriptionID" value=		"#arguments.SubscriptionID#">
	 		<cfprocparam type="out" cfsqltype="cf_sql_varchar" 	dbvarname="@AccessCode" 	variable=	"AccessCode"> 
		</cfstoredproc>
		
		<cfreturn AccessCode>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="updateOrderStatus" output="false" returntype="boolean" 
		hint="updates the order status">
		<cfargument name="SubscriptionID" 	type="numeric" required="yes">
		<cfargument name="StatusID" 		type="numeric" required="yes">

		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_UpdateOrderStatus" returncode="yes">
			 <cfprocparam type="in"  cfsqltype="cf_sql_integer" dbvarname="@SubscriptionID" value="#arguments.SubscriptionID#">
			 <cfprocparam type="in"  cfsqltype="cf_sql_integer" dbvarname="@StatusID" 		value="#arguments.StatusID#">
		</cfstoredproc>
		
		<cfreturn true>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="updateSubscriptionStatus" output="false" returntype="boolean" 
		hint="Updates the subscription status">
		
		<cfargument name="SubscriptionID" 	type="numeric" 	required="yes">
		<cfargument name="StatusCode" 		type="string" 	required="yes">
	
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_UpdateSubscriptionStatus" returncode="yes">
			 <cfprocparam type="in"  cfsqltype="cf_sql_integer" dbvarname="@SubscriptionID" value="#arguments.SubscriptionID#">
			 <cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@StatusCode" 	value="#arguments.StatusCode#">
		</cfstoredproc>
		
		<cfreturn true>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="updateSubscriptionDates" output="false" returntype="boolean" hint="">
		
		<cfargument name="SubscriptionID" 	type="numeric" 	required="yes">
	
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_UpdateSubscriptionDates" returncode="yes">
			 <cfprocparam type="in"  cfsqltype="cf_sql_integer" dbvarname="@SubscriptionID" value="#arguments.SubscriptionID#">
		</cfstoredproc>
		
		<cfreturn true>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetCorrespondence" access="public" output="false" returntype="query" hint="">
		
		<cfset var qryCorrespondence=queryNew("temp")>
		
		<cfquery name="qryCorrespondence" datasource="#variables.DSN1#">
			sp_GetCorrespondence 3
		</cfquery>
		
		<cfreturn qryCorrespondence>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="CommittCorrespondence" output="false" returntype="boolean" hint="">
		
		<cfargument name="correspondenceid" 	type="numeric" 	required="yes">
		<cfargument name="sentDate" 			type="date" 	required="yes">
	
		<cfquery datasource="#variables.DSN1#">
			sp_CommitCorrespondenceSent @correspondenceid=#arguments.correspondenceid#,
				                        @senddate = #arguments.sentDate#
		</cfquery>
		
		<cfreturn true>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
</cfcomponent>