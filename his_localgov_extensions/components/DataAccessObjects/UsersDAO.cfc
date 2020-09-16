<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/DataAccessObjects/UsersDAO.cfc $
	$Author: Hbehnia $
	$Revision: 4 $
	$Date: 22/12/08 15:10 $

--->

<cfcomponent displayname="UsersDAO" hint="<component description here>" extends="his_Localgov_Extends.components.DAOManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="UsersDAO" hint="Pseudo-constructor">
	
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		StructAppend( variables, Super.init( arguments.strConfig ) );

		return this;
		</cfscript>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="updateCorporateAdministrator" access="public" output="false" returntype="void" 
		hint="">
		
		<cfargument name="p_user_id" type="numeric" required="yes">
		<cfargument name="p_subscription_id" type="numeric" required="yes">
		
		<cfset var qryUpdateCorpAdmin = "">
		
		<cfquery name="qryUpdateCorpAdmin" datasource="#variables.DSN1#">
		EXEC sp_UpdateCorporateAdministrator
			@UserID = #arguments.p_user_id#,
			@SubscriptionID = #arguments.p_subscription_id#
		</cfquery>
				
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getRegistrationSelects" returntype="struct" access="public" hint="returns mutilple result sets to be used in the various registration selects" output="no">
		
		<cfscript>
		var strReturn = StructNew();
		</cfscript>

		<!-- return select list from using SQL stored procedure --->
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_GetRegistrationSelects">
			<cfprocresult resultset="1" name="strReturn.qrySalutations">
			<cfprocresult resultset="2" name="strReturn.qryCounties">
			<cfprocresult resultset="3" name="strReturn.qryCountries">
			<cfprocresult resultset="4" name="strReturn.qryJobFunctions">
			<cfprocresult resultset="5" name="strReturn.qryOrgTypes">
			<cfprocresult resultset="6" name="strReturn.qryBudgets">
			<cfprocresult resultset="7" name="strReturn.qrySectors">
		</cfstoredproc>
	
		<cfreturn strReturn>
	
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getUserDetailsByID" access="public" output="false" returntype="query" hint="return query of all deatils about specific user">
		<cfargument name="id" type="numeric" required="yes">

		<cfset var qryUserDetails = "">
		
		<cfquery name="qryUserDetails" datasource="#variables.DSN1#" >
		EXEC sp_GetUserDetailsByID
			@UserID = #arguments.id#
		</cfquery>
		
		<cfreturn qryUserDetails>
	
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getUsernameFromUserID" access="public" output="false" returntype="string" hint="return query of all deatils about specific user">
		<cfargument name="id" type="numeric" required="yes">

		<cfset var qryUserDetails = "">
		
		<cfquery name="qryUserDetails" datasource="#variables.DSN1#" >
		EXEC sp_GetUsernameFromUserID
			@UserID = #arguments.id#
		</cfquery>
		
		<cfreturn qryUserDetails.username>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getAccessCode" access="public" output="false" returntype="string" hint="returns the accesscode for a specified subscription">
		<cfargument name="SubscriptionID" type="numeric" required="yes">

		<cfset var qryAccessCode = "">
		
		<cfquery name="qryAccessCode" datasource="#variables.DSN1#" >
		EXEC sp_GetAccessCode
			@SubscriptionID = #arguments.SubscriptionID#
		</cfquery>
		
		<cfreturn qryAccessCode.f_accesscode_id>
	
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getUserDetailsAdmin" access="public" output="false" returntype="query" hint="return query of all deatils about specific user for the CMS">
		<cfargument name="id" type="numeric" required="yes">

		<cfset var qryUserDetails = "">
		
		<cfquery name="qryUserDetails" datasource="#variables.DSN1#">
		EXEC sp_GetUserDetailsByID_Admin
			@UserID = #arguments.id#
		</cfquery>
		
		<cfreturn qryUserDetails>
	
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getCorpRegistrants" access="public" output="false" returntype="query" 
		hint="returns a query containing all registrants to the corporate subscription">
		<cfargument name="CorpSubscriptionID" 	type="numeric" required="yes">
		
		<cfset var qryCorpRegs ="">

		<cfquery name="qryCorpRegs" datasource="#variables.DSN1#">
			EXEC sp_GetCorpRegistrants
			@SubscriptionID = '#CorpSubscriptionID#'
		</cfquery>

		<cfreturn qryCorpRegs>

	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getActiveCorpRegistrantsCount" access="public" output="false" returntype="query" 
		hint="returns a query containing all active registrants to the corporate subscription">
		<cfargument name="CorpSubscriptionID" 	type="numeric" required="yes">
		
		<cfset var qryActiveCorpRegs ="">

		<cfquery name="qryActiveCorpRegs" datasource="#variables.DSN1#">
			EXEC sp_GetActiveCorpRegistrantsCount
			@SubscriptionID = '#CorpSubscriptionID#'
		</cfquery>

		<cfreturn qryActiveCorpRegs>

	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="deleteCorpRegistrant" access="public" output="false" returntype="void" 
		hint="deletes the corporate subscriber (the record is stored in the database)">
		
		<cfargument name="user_id" required="yes" type="numeric" hint="corp user id">
		
		<cfset var qryDelete ="">

		<cfquery name="qryDelete" datasource="#variables.DSN1#">
			EXEC sp_DeleteCorpRegistrant
			@userid = '#arguments.user_id#'
		</cfquery>

	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="reactivateCorpUser" access="public" output="false" returntype="void" 
		hint="reactivates the corporate subscriber">
		
		<cfargument name="user_id" required="yes" type="numeric" hint="corp user id">
		
		<cfset var qryUnDelete ="">

		<cfquery name="qryUnDelete" datasource="#variables.DSN1#">
			EXEC sp_ReactivateCorpRegistrant
			@userid = '#arguments.user_id#'
		</cfquery>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getSubscriptionDetailsByID" access="public" output="false" returntype="query" 
		hint="Checks if the Corp Admin has opted to receive email notifications">
		
		<cfargument name="user_id" required="yes" type="numeric" hint="subscriber id">

		<cfquery name="qryNotifyAdmin" datasource="#variables.DSN1#">
			EXEC sp_GetSubscriptionDetailsByID
			@userid = '#arguments.user_id#'
		</cfquery>
		
		<cfreturn qryNotifyAdmin>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getUserIDFromUsername" access="public" output="false" returntype="query" 
		hint="returns the userid for a given username">
		
		<cfargument name="Username" type="string" required="yes">

		<cfset var qryUser = "">
		
		<cfquery name="qryUser" datasource="#variables.DSN1#">
		EXEC sp_GetUserID
			@username = '#trim(arguments.Username)#'
		</cfquery>
		
		<cfreturn qryUser>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getUserTypeFromID" access="public" output="false" returntype="string" 
		hint="Return a string containing the user type, based on the user type id">
		
		<cfargument name="UserTypeID" required="yes" type="numeric" hint="">
		
		<cfset var qry = "">
		
		<cfquery name="qry" datasource="#variables.DSN1#">
		EXEC sp_GetUserTypeFromID
			@UserTypeID = #arguments.UserTypeID#
		</cfquery>
		
		<cfreturn qry.Name>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getUserTypeID" access="public" output="false" returntype="string" 
		hint="Return user type id">
		
		<cfargument name="UserID" required="yes" type="numeric" hint="">
		
		<cfset var qry = "">
		
		<cfquery name="qry" datasource="#variables.DSN1#">
		EXEC sp_GetUserTypeID
			@UserID = #arguments.UserID#
		</cfquery>
		
		<cfreturn qry.f_usertype_id>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getUserSectorIDs" access="public" output="false" returntype="string" 
		hint="Return the user's sector ids">
		
		<cfargument name="UserID" required="yes" type="numeric" hint="">
		
		<cfset var qry = "">
		
		<cfquery name="qry" datasource="#variables.DSN1#">
		EXEC sp_GetUserSectorIDs
			@UserID = #arguments.UserID#
		</cfquery>
		
		<cfreturn qry.Sectors>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getUsername" access="public" output="false" returntype="query" hint="return query of all deatils about specific user">
		<cfargument name="un" type="string" required="yes">

		<cfset var qryUsernames = "">
		
		<cfquery name="qryUsernames" datasource="#variables.DSN1#">
		EXEC sp_GetUsernames
			@username = '#trim(arguments.un)#'
		</cfquery>
		
		<cfreturn qryUsernames>
	
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getUserDetails" access="public" output="false" returntype="query" hint="return query of all deatils about specific user">
		<cfargument name="strAttributes" type="struct" required="yes">
		<cfargument name="bHashPassword" type="boolean" required="no" default="true">

		<cfscript>
		var qryUserDetails = "";
		var Password = trim(arguments.strAttributes.Password);
		
		if (arguments.bHashPassword)
			Password = hash(Password);		
		</cfscript>
		
		<cfquery name="qryUserDetails" datasource="#variables.DSN1#">
		EXEC sp_GetUserDetails
			@username = '#trim(arguments.strAttributes.username)#',
			@password = '#Password#'
		</cfquery>
		
		<cfreturn qryUserDetails>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getNewsletterSubs" access="public" output="false" returntype="query" 
		hint="returns all user who have are subscribing to newsletter">
		
		<cfset var qryUsers="">
		
		<cfquery name="qryUsers" datasource="#variables.DSN1#">
		EXEC sp_GetLocalGovUsers4Newsletter
		</cfquery>
	
		<cfreturn qryUsers>	
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getTopicNewsletterSubs" access="public" output="false" returntype="query" 
		hint="returns all user who have are subscribing to topic newsletter">
		<cfargument name="topicid" required="yes" type="numeric">  
		
		<cfset var qryUsers="">
		
		<cfquery name="qryUsers" datasource="#variables.DSN1#">
		EXEC sp_GetLocalGovUsers4TopicNewsletter #arguments.topicid#
		</cfquery>
	
		<cfreturn qryUsers>	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="validateLogin" access="public" output="false" returntype="struct" 
		hint="Validates a login (and subscription) based on the username and password">
		
		<cfargument name="strAttributes" type="struct" required="yes">
		<!---todo: split this strcu into required arguments so one can see what is required when debugging--->
		<cfargument name="bHashPassword" type="boolean" required="no" default="false">

		<cfscript>
		// Local variable initialisation...
		var strLogin = StructNew();
		var Password = trim(arguments.strAttributes.Password);

		strLoginDetails.rtnCode 		= 0;
		strLoginDetails.rtnMessage 		= "";
		strLoginDetails.qryUserDetails	= "";
		
		/*/ todo: remove when we go-live, dev code...*/
		if (arguments.bHashPassword)
			Password = hash(Password);
		</cfscript>
		
		<!--- Call the validate login store procedure, obtaining the user's details and return code & message... --->
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_ValidateLogin">
			<cfprocparam dbvarname="@Username" 	 cfsqltype="cf_sql_varchar" type="in" value="#trim(arguments.strAttributes.username)#" >
			<cfprocparam dbvarname="@Password" 	 cfsqltype="cf_sql_varchar" type="in" value="#Password#" >
			
			<cfprocparam dbvarname="@rtnCode" 	 cfsqltype="cf_sql_integer" type="out" variable="strLoginDetails.rtnCode" >
			<cfprocparam dbvarname="@rtnMessage" cfsqltype="cf_sql_varchar" type="out" variable="strLoginDetails.rtnMessage" >

			<cfprocresult resultset="1" name="strLoginDetails.qryUserDetails">
		</cfstoredproc>
		
		<!--- Return the structure...
		 <cfdump var="#strLoginDetails#"><cfabort>--->
		 <cfreturn strLoginDetails>
	
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="updatePassword" access="public" output="false" returntype="boolean" 
		hint="Update the user's password">
		
		<cfargument name="UserID" required="yes" type="string" hint="the user's id">
		<cfargument name="NewPassword" required="yes" type="string" hint="the new password">

		<cfquery name="qryUpdateUserPW" datasource="#variables.DSN1#">
		EXEC sp_UpdatePassword
			@UserID= 		'#arguments.UserID#',
			@NewPassword= 	'#arguments.NewPassword#'
		</cfquery>
		
		<cfreturn true>
				
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="updateUsername" access="public" output="false" returntype="boolean" 
		hint="Update the user's username">
		
		<cfargument name="UserID" required="yes" type="string" hint="the user's id">
		<cfargument name="NewUsername" required="yes" type="string" hint="the new password">

		<cfquery name="qryUpdateUserUN" datasource="#variables.DSN1#">
		EXEC sp_UpdateUsername
			@UserID= 		'#arguments.UserID#',
			@NewUsername=	'#arguments.NewUsername#'
		</cfquery>
		
		<cfreturn true>
				
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="updateUserType" access="public" output="true" returntype="string" 
		hint="Update the user's type">
		
		<cfargument name="userID"		required="yes" type="string" hint="the user id">
		<cfargument name="userTypeID" 	required="yes" type="string" hint="the user type id">

		<cfquery name="qryUpdateUserUN" datasource="#variables.DSN1#">
		EXEC sp_UpdateUserType
			@UserID= 		#arguments.userID#,
			@UserTypeID=	#arguments.userTypeID#
		</cfquery>
		
		<cfreturn true>
			
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="updateUserStatus" access="public" output="true" returntype="string" 
		hint="Update the user's status">
		
		<cfargument name="userID"		required="yes" type="string" hint="the user id">
		<cfargument name="userStatusID" 	required="yes" type="string" hint="the user type id">

		<cfquery name="qryUpdateUserStatus" datasource="#variables.DSN1#">
		EXEC sp_UpdateUserStatus
			@UserID= 		#arguments.userID#,
			@UserStatusID=	#arguments.userStatusID#
		</cfquery>
		
		<cfreturn true>
			
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="saveUserSession" access="public" output="false" returntype="boolean" hint="">

		<cfargument name="userSessionDetails" 	type="string" required="yes">
		<cfargument name="userID" 				type="numeric" required="yes">
	
		<cfset var qryUserDetails = "">
		
		<cfquery name="qryUserDetails" datasource="#variables.DSN1#">
		EXEC sp_WriteUserSessionDetails
			@UserID = #arguments.UserID#,
			@UserSessionDetails = '#arguments.userSessionDetails#'
		</cfquery>
		
		<cfreturn true>
				
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="loadUserSession" access="public" output="false" returntype="query" hint="">

		<cfargument name="UserID" type="numeric" required="yes">
	
		<cfset var qryUserSessionDetails = "">
		
		<cfquery name="qryUserSessionDetails" datasource="#variables.DSN1#">
		EXEC sp_GetUserSessionDetails
			@UserID = #arguments.UserID#
		</cfquery>
		
		<cfreturn qryUserSessionDetails>
				
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="updateUserDetails" access="public" output="false" returntype="boolean" 
		hint="Updates the user details">
		
		<cfargument name="strAttr" 		required="yes" type="struct" hint="qry of attribute data">
		<cfargument name="strSession" 	required="yes" type="struct" hint="str of the session scope">

		<cfquery name="qryUpdateUserDetails" datasource="#variables.DSN1#">
			EXEC sp_UpdateUserDetails
			@p_user_id = '#arguments.strAttr.p_user_id#',
			@sectors= '#arguments.strAttr.sectors#',
			@ReceiveNewsletter= '#arguments.strAttr.ReceiveNewsletter#'
		</cfquery>
		<cfreturn true>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions: *COMMIT* -------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="registerUser" access="public" output="false" returntype="numeric" hint="Commit user details to db, returns it's ID">
			
		<cfargument name="strDataSet" 		type="struct" 	required="yes">
		<cfargument name="Username" 		type="string" 	required="yes">
		<cfargument name="Password" 		type="string" 	required="yes">
		
		<cfset var UserID=0>
		<cfset var strUserDetails=StructNew()>
		<cfset var wddxUserDetails="">
		<cfif not StructKeyExists(arguments.strDataSet, "confirm2")>
			<cfset arguments.strDataSet.confirm2 = 0>
		</cfif>

		<!--- Perform Insert/Update --->
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_CommitUser">
			<cfif arguments.strDataSet.p_user_id eq 0>
				<cfprocparam dbvarname="@p_user_id" 	 cfsqltype="cf_sql_integer" 	type="in" 	value="0">
			<cfelse>	
				<cfprocparam dbvarname="@p_user_id" 	 cfsqltype="cf_sql_integer" 	type="in" 	value="#arguments.strDataSet.p_user_id#" >
			</cfif>
			
			<cfprocparam dbvarname="@Username" 	 		cfsqltype="cf_sql_varchar" 		type="in" 	value="#trim(arguments.Username)#">
			<cfprocparam dbvarname="@Password" 	 		cfsqltype="cf_sql_varchar" 		type="in" 	value="#hash(trim(arguments.Password))#">
			<cfprocparam dbvarname="@email" 			cfsqltype="cf_sql_varchar" 		type="in" 	value="#trim(arguments.strDataSet.email)#">
			
			<cfprocparam dbvarname="@UserTypeID" 	 	cfsqltype="cf_sql_integer" 		type="in" 	value="#trim(arguments.strDataSet.UserType)#">

			<cfprocparam dbvarname="@f_contact_salutationID" cfsqltype="cf_sql_integer" type="in" 	value="#arguments.strDataSet.f_contact_salutationID#">  
			<cfprocparam dbvarname="@forename" 			cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.forename#">  
			<cfprocparam dbvarname="@surname" 			cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.surname#">  
			<cfprocparam dbvarname="@postcode" 			cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.postcode#">  
			<cfprocparam dbvarname="@address1" 			cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.address1#">
			<cfprocparam dbvarname="@address2" 			cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.address2#">
			<cfprocparam dbvarname="@address3" 			cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.address3#">
			<cfprocparam dbvarname="@town" 				cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.town#"> 
			<cfif arguments.strDataSet.f_county_id eq "">
				<cfprocparam dbvarname="@f_county_id" 		cfsqltype="cf_sql_integer" 		type="in" 	value="0">  
			<cfelse>
				<cfprocparam dbvarname="@f_county_id" 		cfsqltype="cf_sql_integer" 		type="in" 	value="#arguments.strDataSet.f_county_id#"> 
			</cfif>
			<cfprocparam dbvarname="@f_country_id" 		cfsqltype="cf_sql_integer" 		type="in" 	value="#arguments.strDataSet.f_country_id#">    
			<cfprocparam dbvarname="@tel" 				cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.tel#">  
			<cfprocparam dbvarname="@fax" 				cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.fax#">   
			<cfprocparam dbvarname="@jobtitle" 			cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.jobtitle#">
			<cfprocparam dbvarname="@company" 			cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.company#">
			<cfprocparam dbvarname="@f_jobfunction_id" 	cfsqltype="cf_sql_integer" 		type="in" 	value="#arguments.strDataSet.f_jobfunction_id#">
			<cfprocparam dbvarname="@f_orgtype_id" 		cfsqltype="cf_sql_integer" 		type="in" 	value="#arguments.strDataSet.f_orgtype_id#">
			<cfprocparam dbvarname="@f_budget_id"	 	cfsqltype="cf_sql_integer" 		type="in" 	value="#arguments.strDataSet.f_budget_id#">
			<cfif NOT StructKeyExists(arguments.strDataSet, "sectors")>
				<cfprocparam dbvarname="@sectors" 			cfsqltype="cf_sql_varchar" 		type="in" 	value="" null="yes">
			<cfelse>
				<cfprocparam dbvarname="@sectors" 			cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.sectors#">
			</cfif>
			<cfprocparam dbvarname="@confirm1" 			cfsqltype="cf_sql_bit"	 		type="in" 	value="#arguments.strDataSet.confirm1#">
			<cfprocparam dbvarname="@confirm2" 			cfsqltype="cf_sql_bit" 			type="in" 	value="#arguments.strDataSet.confirm2#">
			<cfprocparam dbvarname="@countyborn"		cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.countyBorn#">
			<cfprocparam dbvarname="@UserSessionDetails"	cfsqltype="cf_sql_varchar"	type="in" 	value="#wddxUserDetails#">
				
			<cfprocparam dbvarname="@UserID" 	 		cfsqltype="cf_sql_integer" 		type="out" 	variable="UserID">
		 </cfstoredproc>
		
		<!--- Return the user id --->
		<cfreturn UserID>
				
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="adminEditUser" access="public" output="false" returntype="numeric" hint="Commit user details to db, returns it's ID">
			
		<cfargument name="userid" 	 	type="numeric" 	required="yes">
		<cfargument name="Username"  	type="string" 	required="yes">
		<cfargument name="Statusid"  	type="numeric" 	required="yes">
		<cfargument name="salID" 	 	type="numeric" 	required="yes">
		<cfargument name="forename"  	type="string" 	required="yes">
		<cfargument name="surname" 	 	type="string" 	required="yes">
		<cfargument name="postcode"  	type="string" 	required="yes">
		<cfargument name="address1"  	type="string" 	required="yes">
		<cfargument name="address2"  	type="string" 	required="yes">
		<cfargument name="town" 	 	type="string" 	required="yes">
		<cfargument name="countyid"  	type="numeric" 	required="yes">
		<cfargument name="countryid" 	type="numeric" 	required="yes">
		<cfargument name="tel" 		 	type="string" 	required="yes">
		<cfargument name="fax" 		 	type="string" 	required="yes">
		<cfargument name="jobtitle" 	type="string" 	required="yes">
		<cfargument name="jobfunctionid" type="numeric" required="yes">
		<cfargument name="orgtypeid" 	type="numeric" 	required="yes">
		<cfargument name="budgetid" 	type="numeric" 	required="yes">
		<cfargument name="sectors" 		type="string" 	required="yes">
		
		<!--- Perform Update --->
		<cfquery datasource="#variables.DSN1#">
				exec sp_EditUser_Admin
					@userid 				=#arguments.userid#,
					@Username 				='#arguments.Username#',
					@Statusid				=#arguments.Statusid#,
					@f_contact_salutationID =#arguments.salID#,
					@forename 				='#arguments.forename#',
					@surname 				='#arguments.surname#', 
					@postcode 				='#arguments.postcode#',
					@address1 				='#arguments.address1#',
					@address2 				='#arguments.address2#',
					@town 					='#arguments.town#',
					@f_county_id 			=#arguments.countyid#,
					@f_country_id 			=#arguments.countryid#,
					@tel 					='#arguments.tel#',
					@fax					='#arguments.fax#',
					@jobtitle 				='#arguments.jobtitle#',
					@company 				='#arguments.company#',
					@f_jobfunction_id 		=#arguments.jobfunctionid#,
					@f_orgtype_id 			=#arguments.orgtypeid#,
					@f_budget_id 			=#arguments.budgetid#,
					@sectors 				='#arguments.sectors#' 
		 </cfquery>
		
		<cfreturn arguments.userid>		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="checkUsername" access="public" output="false" returntype="numeric" 
		hint="">
		
		<cfargument name="Email" required="yes" type="string" hint="">
		
		<cfset var qryCheckUsername = "">

		<cfquery name="qryCheckUsername" datasource="#variables.dsn1#">
			EXEC sp_CheckUsername
				@Email = "#arguments.Email#"
		</cfquery>
		
		<cfreturn qryCheckUsername.RecordCount>
				
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="CheckUserHasSubscription" access="public" output="false" returntype="numeric" 
		hint="">
		
		<cfargument name="Email" required="yes" type="string" hint="">
		
		<cfset var qryCheckUsername = "">

		<cfquery name="qryCheckUsername" datasource="#variables.dsn1#">
			EXEC sp_CheckUserHasSubscription
				@Email = '#arguments.Email#'
		</cfquery>
		
		<cfreturn qryCheckUsername.RecordCount>
				
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="searchUsers" access="public" output="false" returntype="query" hint="search user based on form input">
		<cfargument name="UserTypeID" 	 type="numeric"  required="no" default="0">
		<cfargument name="UserStatusID"  type="numeric"  required="no" default="0">
		<cfargument name="OrderStatusID" type="numeric"  required="no" default="0">
		<cfargument name="Surname" 		 type="string"  required="no" default="">
		<cfargument name="Email"   		 type="string"  required="no" default="">
		<cfargument name="Company" 		 type="string"  required="no" default="">
		<cfargument name="maximID" 		 type="numeric" required="no" default="0">
		<cfargument name="UserID"  		 type="numeric" required="no" default="0">
		<cfargument name="AccessCode"    type="string"  required="no" default="">
		<cfargument name="PostCode"   	 type="string"  required="no" default="">
		<cfargument name="DateStart"     type="string"    required="no" default="">
		<cfargument name="DateEnd"   	 type="string"    required="no" default="">
		
		
		<cfset var qrySearch = "">
		<!--- Execute the stored procedure --->	
		<cfquery name="qrySearch" datasource="#variables.dsn1#" cachedwithin="#CreateTimeSpan(0,0,0,25)#">
			EXEC sp_GetUserSearch
			@UserTypeID = 	<cfif arguments.UserTypeID>#arguments.UserTypeID#<cfelse>NULL</cfif>,
			@UserStatusID = <cfif arguments.UserStatusID>#arguments.UserStatusID#<cfelse>NULL</cfif>,
			@OrderStatusID = <cfif arguments.OrderStatusID>#arguments.OrderStatusID#<cfelse>NULL</cfif>,
			@Surname = 		<cfif Len(arguments.Surname)>'#arguments.Surname#'<cfelse>NULL</cfif>,
			@Email = 		<cfif Len(arguments.Email)>'#arguments.Email#'<cfelse>NULL</cfif>,
			@Company = 		<cfif Len(arguments.Company)>'#arguments.Company#'<cfelse>NULL</cfif>,
			@maximID = 		<cfif arguments.maximID>#arguments.maximID#<cfelse>NULL</cfif>,
			@UserID = 		<cfif arguments.UserID>#arguments.UserID#<cfelse>NULL</cfif>,
			@AccessCode = 	<cfif Len(arguments.AccessCode)>'#arguments.AccessCode#'<cfelse>NULL</cfif>,
			@PostCode = 	<cfif Len(arguments.PostCode)>'#arguments.PostCode#'<cfelse>NULL</cfif>,
			@DateStart = 	<cfif IsDate(arguments.DateStart)>#CreateODBCDate(LsDateFormat(arguments.DateStart))#<cfelse>NULL</cfif>,
			@DateEnd = 		<cfif IsDate(arguments.DateEnd)>#CreateODBCDate(LsDateFormat(arguments.DateEnd))#<cfelse>NULL</cfif>
		</cfquery>
		
		<cfreturn qrySearch>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getUserSelects" access="public" output="false" returntype="struct" hint="returns user types and status">
		<cfset var strSelects = StructNew()>
		<cfstoredproc datasource="#variables.dsn1#" procedure="sp_GetUserTypesAndStatus">
			<cfprocresult resultset="1" name="strSelects.qryUserTypes">
			<cfprocresult resultset="2" name="strSelects.qryUserStatus">
			<cfprocresult resultset="3" name="strSelects.qryOrderStatus">
		</cfstoredproc>
		<cfreturn strSelects>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="commitKeywords" access="public" output="false" returntype="boolean" hint="Commits the user's searched keywords to the database">
		<cfargument name="xmldoc" type="xml"required="yes">
		<cfset var qryCommit = "">
		<!--- Execute the stored procedure --->	
		<cfquery name="qryCommit" datasource="#variables.dsn1#">
			EXEC sp_CommitKeywords '#toString(Arguments.xmldoc)#'
		</cfquery>
		
		<cfreturn true>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="updateEmailNotification" access="public" output="false" returntype="boolean" 
		hint="Updates the corporate users email notification preference">
		
		<cfargument name="subscriptionID" 	required="yes" type="numeric">
		<cfargument name="notification" 	required="yes" type="numeric">
		
		<cfset var qryUpdateEmailNotification="">
		
		<cfquery datasource="#variables.DSN1#" name="qryUpdateEmailNotification" >
		EXEC sp_UpdateEmailNotification
			@SubsID = '#arguments.subscriptionID#',
			@EmailNotification = '#arguments.notification#'
		</cfquery>
		
		<cfreturn true>
			
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="unsubscribeUserFromNewsletter" access="public" output="false" returntype="boolean" hint="set user's details to not recive newsletter">
		<cfargument name="userid" 		required="yes" type="numeric">
		<cfargument name="Username" 	required="yes" type="string">
	
	 <cfstoredproc datasource="#variables.DSN1#" procedure="sp_UnsubscribeUserFromNewsletter" returncode="yes">
	 	<cfprocparam cfsqltype="cf_sql_integer"  type="in" dbvarname="@userid" value="#arguments.userid#">
		<cfprocparam  cfsqltype="cf_sql_varchar" type="in" dbvarname="@Username" value="#arguments.Username#">
	 </cfstoredproc>
		<cfreturn cfstoredproc.statusCode>
		 	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="uyeValidateLogin" access="public" output="false" returntype="struct" hint="Validates a login (and subscription) based on the username and password">
		
		<cfargument name="Username" 	required="yes" type="string">
		<cfargument name="Password" 	required="yes" type="string">
		
		<cfset var strReturn = structNew()>
			
		<cfstoredproc datasource="#variables.DSN2#" procedure="sp_UYE_Login" returncode="yes">
	 		<cfprocparam cfsqltype="cf_sql_varchar"  type="in" dbvarname="@Username" value="#arguments.Username#">
			<cfprocparam  cfsqltype="cf_sql_varchar" type="in" dbvarname="@Password" value="#arguments.Password#">
				<cfprocresult resultset="1" name="strReturn.qryLogin">
	 </cfstoredproc>
	 
	 	<cfset strReturn.IsLoginValid =cfstoredproc.statusCode>
		<cfreturn strReturn>
			
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="CommitUser2Topic" access="public" output="false" returntype="boolean" hint="add user to newsleter topic and return boolean of whether a user is already in topic. True|sucessfully added : False|Already in topic ">
		
		<cfargument name="Userid" 	required="yes" type="numeric">
		<cfargument name="TopicId" 	required="yes" type="numeric">
		
		
			<cfstoredproc datasource="#variables.DSN1#" procedure="sp_CommitUser2Topic" returncode="yes">
				<cfprocparam cfsqltype="cf_sql_integer"  type="in" dbvarname="@Userid" value="#arguments.Userid#">
				<cfprocparam  cfsqltype="cf_sql_integer" type="in" dbvarname="@TopicId" value="#arguments.TopicId#">
			 </cfstoredproc>
	 
		<cfreturn cfstoredproc.StatusCode>
			
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="DeleteUserFromTopic" access="public" output="false" returntype="boolean" hint="add user to newsleter topic and return boolean of whether a user is already in topic. True|sucessfully added : False|Already in topic ">
		
		<cfargument name="Userid" 	required="yes" type="numeric">
		<cfargument name="Username" required="yes" type="string">
		<cfargument name="TopicId" 	required="yes" type="numeric">
		
		
			<cfstoredproc datasource="#variables.DSN1#" procedure="sp_UnsubscribeUserFromTopic" returncode="yes">
				<cfprocparam cfsqltype="cf_sql_integer"  type="in" dbvarname="@Userid" value="#arguments.Userid#">
				<cfprocparam cfsqltype="cf_sql_varchar"  type="in" dbvarname="@Username" value="#arguments.Username#">
				<cfprocparam  cfsqltype="cf_sql_integer" type="in" dbvarname="@TopicId" value="#arguments.TopicId#">
			 </cfstoredproc>
	 
		<cfreturn cfstoredproc.StatusCode>
			
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="LogOpenDay" access="public" output="false" returntype="void" hint="log registered user who visit directory org/person item pages">
		<cfargument name="Userid" 	required="yes" type="numeric">
		<cfargument name="fuseaction" 	required="yes" type="string" hint="">
		
		
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_LogOpenDay" returncode="yes">
			<cfprocparam cfsqltype="cf_sql_integer"  type="in" dbvarname="@Userid"   value="#arguments.Userid#">
			<cfprocparam cfsqltype="cf_sql_varchar"  type="in" dbvarname="@PageName" value="#arguments.fuseaction#">
		 </cfstoredproc>
	 
	</cffunction>
	
</cfcomponent>