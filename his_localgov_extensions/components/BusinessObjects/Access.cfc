<cfcomponent displayname="Access" hint="subscription -related business functions" extends="his_Localgov_Extends.components.BusinessObjectsManager">
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------>
	<!--- CONSTRUCTOR ------------------------------------------------------------------------------------------------------------------------------------------------------------------>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------>
	<cffunction name="init" access="public" output="false" returntype="Access" hint="Pseudo-constructor">
		<cfargument name="objAppObjs" type="any" required="yes" hint="The application manager object">
		<cfargument name="objBusObjs" type="any" required="yes" hint="The business objects">
		
		<cfscript>
			// Call the genric init function, placing business, app, and dao objects into a local scope...
			structAppend(variables, super.initChild( arguments.objAppObjs, this, arguments.objBusObjs ) );
		
			return this;
		</cfscript>
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getVariables" access="public" output="false" returntype="struct" hint="return local scope to caller">
		<cfreturn variables>
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="GetUserSubscription" access="public" output="false" returntype="query" hint="Return user's subscription info">
		<cfargument name="UserID" type="string"  required="yes">
		
		<cfreturn objDAO.GetUserSubscription(arguments.UserID)>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="setAccess" access="public" returntype="void" hint="set acccess based on sub data into session structure">
		<cfargument name="strSession"	required="yes" 	type="struct" hint="pass in strUser struct in session to store access in "> 
		<cfargument name="UserID"		required="yes"	type="numeric">
		
		<cfscript>
			//Retrieve user's subscription info from DB
			var qrySub 		= objDAO.getUserSubscription(arguments.UserID);
			var strAccess	= StructNew();
			
			//If user has a valid subscription, set info into their session
			if (qrySub.recordCount)
			{
				strAccess.type 					= qrySub.Product;
				strAccess.startDate				= qrySub.StartDate;
				strAccess.endDate 				= qrySub.EndDate;
				strAccess.status 				= qrySub.SubscriptionStatus;
				strAccess.productid 			= qrySub.ProductID;
				strAccess.subscriptionID 		= qrySub.SubscriptionID;
				//strAccess.username				= qrySub.Username;
				//strAccess.password				= Decrypt(qrySub.Password, instance.strConfig.strVars.Encrypt_key);
				strAccess.subscriptionPeriodID 	= qrySub.SubscriptionPeriodID;
				arguments.strSession.strAccess  = strAccess;
				
				//Need to update the usertypeID in userDetail structure
				arguments.strSession.userDetails.userTypeID = qrySub.UserTypeID;
				hasAccess(arguments.strSession);				
			}
		</cfscript>
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="hasAccess" access="public" returntype="boolean" hint="return true if user has access">
		<!--- <cfargument name="objUser" 		  required="yes" type="struct" hint="pass in strUser struct in session to store access in ">  --->
		<cfargument name="strSession" required="yes" type="struct" hint="session struct "> 
		
		<cfscript>
			var bl = false;
			//check is user is logged in
			if (objUser.LoggedIn(arguments.strSession) )
			{
				//now check that user has access
				if (StructKeyExists(arguments.strSession, "strAccess")) 
				{
					if (StructKeyExists(arguments.strSession.strAccess, "status") AND arguments.strSession.strAccess.status EQ "active")
					{
						if (DateCompare(DateFormat(arguments.strSession.strAccess.endDate, 'dd/mmm/yyyy'), DateFormat(Now(), 'dd/mmm/yyyy'), 'd') GTE "0")
						{
							bl = true;
						}
						else
						{
							arguments.strSession.strAccess.status = "Expired";
							request.objBus.objUser.updateUserType(arguments.strSession.userDetails.userid, 0, arguments.strSession);
							arguments.strSession.userDetails.userTypeID = 2;
						}
					}
					else if (StructKeyExists(arguments.strSession.strAccess, "status") AND ListFind("Expired Subscription,Suspended", arguments.strSession.strAccess.status)
						and StructKeyExists(arguments.strSession.userdetails, "usertypeid") AND arguments.strSession.userdetails.usertypeid gt 2)
					{
						arguments.strSession.strAccess.status = "Expired";
						request.objBus.objUser.updateUserType(arguments.strSession.userDetails.userid, 0, arguments.strSession);
						arguments.strSession.userDetails.userTypeID = 2;
					}
				}
			}
			return bl;
		</cfscript>
		
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="ClearAccess" access="public" returntype="void" hint="clear the user's access details in their session. Usually used as part of logout process">
		<cfargument name="strSession" 	  required="yes" type="struct" hint="session struct"> 
		
		<cfset arguments.strSession = StructDelete(arguments.strsession, "strAccess")>
		
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="GetSubscriptionByID" output="false" returntype="query" access="public" hint="Return user's subscription info">
		<cfargument name="SubscriptionID" type="string"  required="yes">
		
		<cfreturn objDAO.GetSubscriptionByID(arguments.SubscriptionID)>
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="getSubSearchLookups" output="false" returntype="Struct" access="public" hint="Return data for lookups needed for subscription search/modification forms">
		<cfreturn objDAO.getSubSearchLookups()>
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
		
		<cfreturn objDAO.SearchSubscriptions(argumentCollection=arguments)>
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="DailySubscriptionUpdate" output="false" returntype="void" access="public" hint="Return data for lookups needed for subscription search/modification forms">
		<cfset objDAO.UpdateAllSubscriptions()>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="setFunctionByProduct" access="public" output="false" returntype="void" hint="get all functions by product">
		<cfargument name="refresh" type="boolean" required="no" default="0" hint="Use this argument to refresh the ads query object from memory">
		<cfscript>
			if (NOT StructKeyExists(instance, "qryFunctions") OR arguments.refresh)	
				instance.qryFunctions =  objDAO.getFunctionByProduct();	
		</cfscript>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getFunctionByProduct" access="public" output="false" returntype="query" hint="get all functions by product">
		<cfargument name="refresh" type="boolean" required="no" default="0" hint="Use this argument to refresh the ads query object from memory">
		<cfset setFunctionByProduct(arguments.refresh)>
		<cfreturn instance.qryFunctions>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="GetAllSubscribers" output="false" returntype="query" access="public" hint="Return data for lookups needed for subscription search/modification forms">
		<cfreturn objDAO.GetAllSubscribers()>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="GetTypes" output="false" returntype="query" access="public" hint="Return access types">
		<cfreturn objDAO.GetTypes()>
	</cffunction>
</cfcomponent>