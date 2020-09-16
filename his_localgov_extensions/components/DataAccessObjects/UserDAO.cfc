<!--- 
	
	$Archive: /localgov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/DataAccessObjects/UserDAO.cfc $
	$Author: Ohilton $
	$Revision: 16 $
	$Date: 25/01/10 16:05 $

--->

<cfcomponent displayname="UserDAO" hint="Data Access function related to a user" extends="his_Localgov_Extends.components.DAOManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="UserDAO" hint="Pseudo-constructor">
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
			StructAppend(variables, Super.init(arguments.strConfig));
	
			return this;
		</cfscript>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="updateCorporateAdministrator" access="public" output="false" returntype="void" hint="">
		
		<cfargument name="p_user_id" type="numeric" required="yes">
		<cfargument name="p_subscription_id" type="numeric" required="yes">
		
		<cfset var qryUpdateCorpAdmin = "">
		
		<cfquery name="qryUpdateCorpAdmin" datasource="#variables.DSN5#">
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
		
		<cfquery name="qryUserDetails" datasource="#variables.DSN5#" >
			EXEC usp_GetUserByID
				@UserID = #arguments.id#
		</cfquery>
		
		<cfreturn qryUserDetails>
	
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="deleteUserByID" access="public" output="false" returntype="void" hint="Deletes a user and userdetail record from the db">
		<cfargument name="id" type="numeric" required="yes">
		
		<cfset var qryTemp = "">
		
		<cfquery name="qryTemp" datasource="#variables.DSN5#" >
			EXEC usp_deleteUser
				@userID = #arguments.id#
		</cfquery>
		
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getUserDetailsByTypeID" access="public" output="false" returntype="query" hint="return query of all deatils about specific users">
		<cfargument name="id" type="numeric" required="yes">

		<cfset var qryUserDetails = "">
		
		<cfquery name="qryUserDetails" datasource="#variables.DSN5#" >
			EXEC usp_getUserDetailsByTypeID
				@userTypeID = #arguments.id#
		</cfquery>
		
		<cfreturn qryUserDetails>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getUsernameFromUserID" access="public" output="false" returntype="string" hint="return query of all deatils about specific user">
		<cfargument name="id" type="numeric" required="yes">

		<cfset var qryUserDetails = "">
		
		<cfquery name="qryUserDetails" datasource="#variables.DSN5#" >
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
		
		<cfquery name="qryAccessCode" datasource="#variables.DSN5#" >
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
		
		<cfquery name="qryUserDetails" datasource="#variables.DSN5#">
			EXEC sp_GetUserDetailsByID_Admin
				@UserID = #arguments.id#
		</cfquery>
		
		<cfreturn qryUserDetails>
	
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getCorpRegistrants" access="public" output="false" returntype="query" hint="returns a query containing all registrants to the corporate subscription">
		<cfargument name="CorpSubscriptionID" 	type="numeric" required="yes">
		
		<cfset var qryCorpRegs ="">

		<cfquery name="qryCorpRegs" datasource="#variables.DSN5#">
			EXEC usp_GetCorpRegistrants
				@SubscriptionID = '#CorpSubscriptionID#'
		</cfquery>

		<cfreturn qryCorpRegs>

	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getActiveCorpRegistrantsCount" access="public" output="false" returntype="query" hint="returns a query containing all active registrants to the corporate subscription">
		<cfargument name="CorpSubscriptionID" 	type="numeric" required="yes">
		
		<cfset var qryActiveCorpRegs ="">

		<cfquery name="qryActiveCorpRegs" datasource="#variables.DSN5#">
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

		<cfquery name="qryDelete" datasource="#variables.DSN5#">
			EXEC usp_DeleteCorpRegistrant
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

		<cfquery name="qryUnDelete" datasource="#variables.DSN5#">
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

		<cfquery name="qryNotifyAdmin" datasource="#variables.DSN5#">
			EXEC usp_GetSubscriptionDetailsByID
			@userid = '#arguments.user_id#'
		</cfquery>
		
		<cfreturn qryNotifyAdmin>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getUserIDFromUsername" access="public" output="false" returntype="numeric" hint="returns the userid for a given username">
		<cfargument name="Username" type="string" required="yes">

		<cfset var qryUser = "">
		
		<cfquery name="qryUser" datasource="#variables.DSN5#">
			EXEC usp_GetUserID
				@username = '#trim(arguments.Username)#'
		</cfquery>
		
		<cfreturn qryUser.UserID>
		
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getUserTypeFromID" access="public" output="false" returntype="string" hint="Return a string containing the user type, based on the user type id">
		<cfargument name="UserTypeID" required="yes" type="numeric" hint="">
		
		<cfset var qry = "">
		
		<cfquery name="qry" datasource="#variables.DSN5#">
			EXEC usp_GetUserTypeFromID
				@UserTypeID = #arguments.UserTypeID#
		</cfquery>
		
		<cfreturn qry.Name>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getUserTypeID" access="public" output="false" returntype="string" hint="Return user type id">	
		<cfargument name="UserID" required="yes" type="numeric" hint="">
		
		<cfset var qry = "">
		
		<cfquery name="qry" datasource="#variables.DSN5#">
			EXEC usp_GetUserTypeID 
				@UserID = #arguments.UserID#
		</cfquery>
		
		<cfreturn qry.UserTypeID>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getUserSectorIDs" access="public" output="false" returntype="string" hint="Return the user's sector ids">	
		<cfargument name="UserID" required="yes" type="numeric" hint="">
		
		<cfset var qry = "">
		<cfset var sectors = "">
		
		<cfquery name="qry" datasource="#variables.DSN5#">
			EXEC usp_GetUserSectorIDs
				@UserID = #arguments.UserID#
		</cfquery>
		
		<cfset sectors = ValueList(qry.SectorID)>
		
		<cfreturn sectors>
		
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
		
		<cfquery name="qryUsers" datasource="#variables.DSN5#">
			EXEC usp_GetLocalGovUsers4Newsletter
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
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="CheckLogin" access="public" output="true" returntype="query" hint="Retrieve password matching matching username entered and compare to password entered by user">
		<cfargument name="username" required="yes" type="string">
		
		<cfset var qryUserLogin = queryNew("temp")>

		<cfquery name="qryUserLogin" datasource="#variables.DSN5#">
			EXEC usp_GetLogin '#arguments.userName#'
		</cfquery>	
		
		<cfreturn qryUserLogin>

	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="ValidateLogin" access="public" output="true" returntype="query" hint="pass in login details and return session structre from db">
		<cfargument name="UserID" required="yes" type="numeric">
		
		<cfset var qryLogin = queryNew("temp")>

		<cfquery name="qryLogin" datasource="#variables.DSN5#">
			EXEC usp_ValidateLogin #arguments.UserID#
		</cfquery>	
		
		<cfreturn qryLogin>

	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="GetSavedUserSession" access="public" output="false" returntype="query" hint="Get saved user session from db">
		<cfargument name="UserID" required="yes" type="numeric">
		
		<cfset var qryGetUserSession = queryNew("temp")>

		<cfquery name="qryGetUserSession" datasource="#variables.DSN5#">
			EXEC usp_GetUserSession #arguments.UserID#
		</cfquery>
		
		<!--- If a saved session for that user is found, return it
		<cfif qryGetUserSession.recordCount> --->
			<cfreturn qryGetUserSession>
		<!--- Otherwise return an "error" code
		<cfelse>
			<cfreturn 0>			
		</cfif> --->
		
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="updatePassword" access="public" output="false" returntype="boolean" hint="Update the user's password">
		<cfargument name="UserID" 		required="yes" type="string" hint="the user's id">
		<cfargument name="NewPassword" 	required="yes" type="string" hint="the new password">

		<cfquery name="qryUpdateUserPW" datasource="#variables.DSN5#">
			EXEC usp_UpdatePassword
				@UserID= 		'#arguments.UserID#',
				@NewPassword= 	'#arguments.NewPassword#'
		</cfquery>
		
		<cfreturn true>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="updateUsername" access="public" output="false" returntype="boolean" hint="Update the user's username">
		<cfargument name="UserID" 		required="yes" type="string" hint="the user's id">
		<cfargument name="NewUsername" 	required="yes" type="string" hint="the new password">

		<cfquery name="qryUpdateUserUN" datasource="#variables.DSN5#">
			EXEC usp_UpdateUsername
				@UserID		 = 	'#arguments.UserID#',
				@NewUsername =	'#arguments.NewUsername#'
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

		<cfquery name="qryUpdateUserUN" datasource="#variables.DSN5#">
		EXEC usp_UpdateUserType
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
	<cffunction name="saveUserSession" access="public" output="false" returntype="boolean" hint="Save User's session to database in WDDX format">
		<cfargument name="userSessionDetails" 	type="string" required="yes">
		<cfargument name="userID" 				type="numeric" required="yes">
	
		<cfset var qryUserDetails = "">
		
		<cfquery name="qryUserDetails" datasource="#variables.DSN5#">
			EXEC usp_SaveSession
				@UserID 			= #arguments.UserID#,
				@UserSessionDetails = '#arguments.userSessionDetails#'
		</cfquery>
		
		<cfreturn true>
				
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- <cffunction name="loadUserSession" access="public" output="false" returntype="query" hint="">

		<cfargument name="UserID" type="numeric" required="yes">
	
		<cfset var qryUserSessionDetails = "">
		
		<cfquery name="qryUserSessionDetails" datasource="#variables.DSN1#">
		EXEC sp_GetUserSessionDetails
			@UserID = #arguments.UserID#
		</cfquery>
		
		<cfreturn qryUserSessionDetails>
				
	</cffunction> --->
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="updateUserDetails" access="public" output="false" returntype="Numeric" hint="Updates the user details">
		
		<!--- <cfargument name="strAttr" 		required="yes" type="struct" hint="qry of attribute data">
		<cfargument name="strSession" 	required="yes" type="struct" hint="str of the session scope">

		<cfquery name="qryUpdateUserDetails" datasource="#variables.DSN1#">
			EXEC sp_UpdateUserDetails
			@p_user_id = '#arguments.strAttr.p_user_id#',
			@sectors= '#arguments.strAttr.sectors#',
			@ReceiveNewsletter= '#arguments.strAttr.ReceiveNewsletter#'
		</cfquery>
		<cfreturn true> --->
		
		<cfargument name="UserID" 				required="yes"  	type="numeric" 	hint="UserID of user">
		<cfargument name="contactSalutationID" 	required="yes" 	type="string" 	hint="">
		<cfargument name="emailAddress" 		required="yes" 	type="string" 	hint="email address of new user">
		<cfargument name="forename" 			required="yes" 	type="string" 	hint="first name of new user">
		<cfargument name="surname" 				required="yes" 	type="string" 	hint="last name of new user">
		<cfargument name="address1" 			required="yes" 	type="string" 	hint="address 1 of new user">
		<cfargument name="address2" 			required="yes" 	type="string" 	hint="address 2 of new user">
		<cfargument name="address3" 			required="yes" 	type="string" 	hint="address 3 of new user">
		<cfargument name="town" 				required="yes" 	type="string" 	hint="town of address of new user">
		<cfargument name="countyID" 			required="yes" 	type="numeric" 	hint="county id of address of new user">
		<cfargument name="postcode" 			required="yes" 	type="string" 	hint="postcode of address of new user">
		<cfargument name="countryID" 			required="yes" 	type="numeric" 	hint="country id of address of new user">
		<cfargument name="telephone" 			required="yes" 	type="string" 	hint="telephone number of new user">
		<cfargument name="fax" 					required="yes" 	type="string" 	hint="fax number of new user">
		<cfargument name="jobTitle" 			required="yes" 	type="string" 	hint="Job title of user">
		<cfargument name="companyName" 			required="yes" 	type="string" 	hint="Company name">
		<cfargument name="jobFunctionID" 		required="yes" 	type="numeric" 	hint="Job Function ID of user">
		<cfargument name="orgTypeID" 			required="yes" 	type="numeric" 	hint="Company Type ID">
		<cfargument name="budgetID" 			required="yes" 	type="numeric" 	hint="Budget Range ID">
		<cfargument name="sectors" 				required="yes" 	type="string" 	hint="">
		<cfargument name="confirm1" 			required="yes" 	type="numeric" 	hint="">
		<cfargument name="confirm2" 			required="yes" 	type="numeric" 	hint="">
		<cfargument name="countyborn" 			required="yes" 	type="string" 	hint="">
		<cfargument name="strSession" 			required="yes" 	type="struct" 	hint="structure of the session scope">
		<!--- <cfargument name="PasswordEncrypted" 	required="yes" 	type="string" 	hint="new user password"> --->
		<cfargument name="UserTypeID" 			required="yes" 	type="numeric" 	hint="stored procedure needs this value even though it cannot be changed in a user update">
		
		<!--- Perform Insert/Update --->
		<cfstoredproc datasource="#variables.DSN5#" procedure="usp_SaveUser">

			<cfprocparam dbvarname="@UserID" 				cfsqltype="cf_sql_integer" 		type="in"	value="#arguments.UserID#">
			<cfprocparam dbvarname="@Username" 	 			cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.emailAddress#">
			<cfprocparam dbvarname="@Password" 	 			cfsqltype="cf_sql_varchar" 		type="in" 	value="">	
			<cfprocparam dbvarname="@Forename" 				cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.forename#">  
			<cfprocparam dbvarname="@Surname" 				cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.surname#">  
			<cfprocparam dbvarname="@Email" 				cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.emailAddress#">
			 
			<cfprocparam dbvarname="@Address1" 				cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.address1#">
			<cfprocparam dbvarname="@Address2" 				cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.address2#">
			<cfprocparam dbvarname="@Address3" 				cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.address3#">
			<cfprocparam dbvarname="@Town" 					cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.town#"> 
			<cfif arguments.countyID eq "">
				<cfprocparam dbvarname="@CountyID" 		cfsqltype="cf_sql_integer" 		type="in" 	value="0">  
			<cfelse>
				<cfprocparam dbvarname="@CountyID" 		cfsqltype="cf_sql_integer" 		type="in" 	value="#arguments.countyID#"> 
			</cfif>
			<cfprocparam dbvarname="@Postcode" 				cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.postcode#"> 
			<cfprocparam dbvarname="@CountryID" 			cfsqltype="cf_sql_integer" 		type="in" 	value="#arguments.countryID#">    
			<cfprocparam dbvarname="@Tel" 					cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.telephone#">  
			<cfprocparam dbvarname="@Fax" 					cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.fax#">
			<cfprocparam dbvarname="@JobTitle" 				cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.jobTitle#">  
			<cfprocparam dbvarname="@CompanyName" 			cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.companyName#">   
			<cfprocparam dbvarname="@UserTypeID" 	 		cfsqltype="cf_sql_integer" 		type="in" 	value="#trim(arguments.UserTypeID)#">

			<cfprocparam dbvarname="@ContactSalutationID" 	cfsqltype="cf_sql_integer" 		type="in" 	value="#contactSalutationID#">  
			<cfprocparam dbvarname="@JobFunctionID" 		cfsqltype="cf_sql_integer" 		type="in" 	value="#arguments.jobFunctionID#">
			<cfprocparam dbvarname="@OrgTypeID" 			cfsqltype="cf_sql_integer" 		type="in" 	value="#arguments.orgTypeID#">
			<cfprocparam dbvarname="@BudgetID"	 			cfsqltype="cf_sql_integer" 		type="in" 	value="#arguments.budgetID#">
			
			<cfif arguments.sectors EQ "0">
				<cfprocparam dbvarname="@Sectors" 			cfsqltype="cf_sql_varchar" 		type="in" 	value="" null="yes">
			<cfelse>
				<cfprocparam dbvarname="@Sectors" 			cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.sectors#">
			</cfif>
			
			<cfprocparam dbvarname="@Confirm1" 				cfsqltype="cf_sql_bit"	 		type="in" 	value="#arguments.confirm1#">
			<cfprocparam dbvarname="@Confirm2" 				cfsqltype="cf_sql_bit" 			type="in" 	value="#arguments.confirm2#">
			<cfprocparam dbvarname="@CountyBorn"			cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.countyBorn#">
			<cfprocparam dbvarname="@UserSessionDetails"	cfsqltype="cf_sql_varchar"		type="in" 	value=""><!--- #wddxUserDetails# --->
				
			<cfprocparam dbvarname="@UserID" 	 			cfsqltype="cf_sql_integer" 		type="out" 	variable="UserID">
		
		 </cfstoredproc>
		
		<!--- Return the user id --->
		<cfreturn UserID>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="registerUser" access="public" output="false" returntype="numeric" hint="Commit user details to db, returns it's ID">
		<cfargument name="UserID" 				required="no"  	type="numeric" 	hint="UserID of new user" default="0">
		<cfargument name="contactSalutationID" 	required="yes" 	type="string" 	hint="">
		<cfargument name="emailAddress" 		required="yes" 	type="string" 	hint="email address of new user">
		<cfargument name="forename" 			required="yes" 	type="string" 	hint="first name of new user">
		<cfargument name="surname" 				required="yes" 	type="string" 	hint="last name of new user">
		<cfargument name="address1" 			required="yes" 	type="string" 	hint="address 1 of new user">
		<cfargument name="address2" 			required="yes" 	type="string" 	hint="address 2 of new user">
		<cfargument name="address3" 			required="yes" 	type="string" 	hint="address 3 of new user">
		<cfargument name="town" 				required="yes" 	type="string" 	hint="town of address of new user">
		<cfargument name="countyID" 			required="yes" 	type="numeric" 	hint="county id of address of new user">
		<cfargument name="postcode" 			required="yes" 	type="string" 	hint="postcode of address of new user">
		<cfargument name="countryID" 			required="yes" 	type="numeric" 	hint="country id of address of new user">
		<cfargument name="telephone" 			required="yes" 	type="string" 	hint="telephone number of new user">
		<cfargument name="fax" 					required="yes" 	type="string" 	hint="fax number of new user">
		<cfargument name="jobTitle" 			required="yes" 	type="string" 	hint="Job title of user">
		<cfargument name="companyName" 			required="yes" 	type="string" 	hint="Company name">
		<cfargument name="jobFunctionID" 		required="yes" 	type="numeric" 	hint="Job Function ID of user">
		<cfargument name="orgTypeID" 			required="yes" 	type="numeric" 	hint="Company Type ID">
		<cfargument name="budgetID" 			required="yes" 	type="numeric" 	hint="Budget Range ID">
		<cfargument name="sectors" 				required="yes" 	type="string" 	hint="">
		<cfargument name="confirm1" 			required="yes" 	type="numeric" 	hint="">
		<cfargument name="confirm2" 			required="yes" 	type="numeric" 	hint="">
		<cfargument name="countyborn" 			required="yes" 	type="string" 	hint="">
		<cfargument name="strSession" 			required="yes" 	type="struct" 	hint="structure of the session scope">
		<cfargument name="PasswordEncrypted" 	required="yes" 	type="string" 	hint="new user password">
		<cfargument name="UserTypeID" 			required="yes" 	type="numeric" 	hint="">
		
		
		<!--- <cfset var UserID=0> --->
		<cfset var strUserDetails=StructNew()>
		<cfset var wddxUserDetails="">
		<!--- <cfif not StructKeyExists(arguments, "confirm2")>
			<cfset arguments.confirm2 = 0>
		</cfif> --->

		<!--- Perform Insert/Update --->
		<cfstoredproc datasource="#variables.DSN5#" procedure="usp_SaveUser">
			
			<cfif arguments.UserID EQ "0">
				<cfprocparam dbvarname="@UserID" 			cfsqltype="cf_sql_integer"  	type="in"	value="" null="true">
			<cfelse>
				<cfprocparam dbvarname="@UserID" 			cfsqltype="cf_sql_integer" 		type="in"	value="#arguments.UserID#">
			</cfif>	
			<cfprocparam dbvarname="@Username" 	 			cfsqltype="cf_sql_varchar" 		type="in" 	value="#trim(arguments.emailAddress)#">
			<cfprocparam dbvarname="@Password" 	 			cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.PasswordEncrypted#">	
			<cfprocparam dbvarname="@Forename" 				cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.forename#">  
			<cfprocparam dbvarname="@Surname" 				cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.surname#">  
			<cfprocparam dbvarname="@Email" 				cfsqltype="cf_sql_varchar" 		type="in" 	value="#trim(arguments.emailAddress)#">
			 
			<cfprocparam dbvarname="@Address1" 				cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.address1#">
			<cfprocparam dbvarname="@Address2" 				cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.address2#">
			<cfprocparam dbvarname="@Address3" 				cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.address3#">
			<cfprocparam dbvarname="@Town" 					cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.town#"> 
			<cfif arguments.countyID eq "">
				<cfprocparam dbvarname="@CountyID" 			cfsqltype="cf_sql_integer" 		type="in" 	value="0">  
			<cfelse>
				<cfprocparam dbvarname="@CountyID" 			cfsqltype="cf_sql_integer" 		type="in" 	value="#arguments.countyID#"> 
			</cfif>
			<cfprocparam dbvarname="@Postcode" 				cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.postcode#"> 
			<cfprocparam dbvarname="@CountryID" 			cfsqltype="cf_sql_integer" 		type="in" 	value="#arguments.countryID#">    
			<cfprocparam dbvarname="@Tel" 					cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.telephone#">  
			<cfprocparam dbvarname="@Fax" 					cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.fax#">
			<cfprocparam dbvarname="@JobTitle" 				cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.jobTitle#">  
			<cfprocparam dbvarname="@CompanyName" 			cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.companyName#">   
			<cfprocparam dbvarname="@UserTypeID" 	 		cfsqltype="cf_sql_integer" 		type="in" 	value="#trim(arguments.UserTypeID)#">

			<cfprocparam dbvarname="@ContactSalutationID" 	cfsqltype="cf_sql_integer" 		type="in" 	value="#contactSalutationID#">  
			<cfprocparam dbvarname="@JobFunctionID" 		cfsqltype="cf_sql_integer" 		type="in" 	value="#arguments.jobFunctionID#">
			<cfprocparam dbvarname="@OrgTypeID" 			cfsqltype="cf_sql_integer" 		type="in" 	value="#arguments.orgTypeID#">
			<cfprocparam dbvarname="@BudgetID"	 			cfsqltype="cf_sql_integer" 		type="in" 	value="#arguments.budgetID#">
			
			<cfif arguments.sectors EQ "0">
				<cfprocparam dbvarname="@Sectors" 			cfsqltype="cf_sql_varchar" 		type="in" 	value="" null="yes">
			<cfelse>
				<cfprocparam dbvarname="@Sectors" 			cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.sectors#">
			</cfif>
			
			<cfprocparam dbvarname="@Confirm1" 				cfsqltype="cf_sql_bit"	 		type="in" 	value="#arguments.confirm1#">
			<cfprocparam dbvarname="@Confirm2" 				cfsqltype="cf_sql_bit" 			type="in" 	value="#arguments.confirm2#">
			<cfprocparam dbvarname="@CountyBorn"			cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.countyBorn#">
			<cfprocparam dbvarname="@UserSessionDetails"	cfsqltype="cf_sql_varchar"		type="in" 	value="#wddxUserDetails#">
				
			<cfprocparam dbvarname="@UserID" 	 			cfsqltype="cf_sql_integer" 		type="out" 	variable="UserID">
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
		<cfquery datasource="#variables.DSN5#">
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
	<cffunction name="checkUsername" access="public" output="false" returntype="numeric" hint="">
		<cfargument name="Email" required="yes" type="string" hint="">
		
		<cfset var qryCheckUsername = "">

		<cfquery name="qryCheckUsername" datasource="#variables.dsn5#">
			EXEC usp_CheckUsername
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
		<!--- <cfargument name="UserTypeID" 	 type="numeric"  required="no" default="0">
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
		<cfargument name="DateEnd"   	 type="string"    required="no" default=""> --->
		<cfargument name="UserTypeID" 	 type="numeric"  required="no" default="0">
		<cfargument name="Surname" 		 type="string"  required="no" default="">
		<cfargument name="Email"   		 type="string"  required="no" default="">
		<cfargument name="PostCode"   	 type="string"  required="no" default="">
		<cfargument name="DateStart"     type="string"    required="no" default="">
		<cfargument name="DateEnd"   	 type="string"    required="no" default="">
		<cfargument name="Company" 		 type="string"  required="no" default="">
		<!---<cfargument name="IsSO" 	 	type="numeric"  required="no" default="0">--->
       <!--- <cfargument name="jobtitle" 	 type="string"  required="no" default="">--->
         <cfargument name="jobfunctionID"  type="numeric"  required="no" default="0">
         <cfargument name="BudgetID" 	 type="numeric"  required="no" default="0">
         <cfargument name="OrgTypeID" 	 type="numeric"  required="no" default="0">
		 <cfargument name="sectorid" 	 type="string"  required="no" default="">
		<cfset var qrySearchUsers = queryNew("temp")>
		
		<!--- Setup date variables to be used in search --->
		<cfset var DateTimeStart = DateFormat(arguments.DateStart, 'dd/mm/yyyy')>
		
		<!--- Make the end date one day later than that specified by user so that we can search
		for all records registered BEFORE the end date --->
		<cfset var DateTimeEnd = DateAdd('d', 1, DateFormat(arguments.DateEnd, 'dd/mm/yyyy'))>

		<cfquery name="qrySearchUsers" datasource="#variables.dsn5#">
			EXEC usp_SearchUsers 
				@UserTypeID = 	<cfif arguments.UserTypeID NEQ 0>'#arguments.UserTypeID#'<cfelse>NULL</cfif>
				, @Surname 		= 	<cfif Len(arguments.Surname)>'#arguments.Surname#'<cfelse>NULL</cfif>
				, @Email 		= 	<cfif Len(arguments.Email)>'#arguments.Email#'<cfelse>NULL</cfif>
				, @Postcode 	= 	<cfif Len(arguments.Postcode)>'#arguments.Postcode#'<cfelse>NULL</cfif>
				, @DateStart 	= 	#CreateODBCDateTime(DateTimeStart)#
				, @DateEnd 		= 	#CreateODBCDateTime(DateTimeEnd)#
				, @CompanyName 	= 	<cfif Len(arguments.Company)>'#arguments.Company#'<cfelse>NULL</cfif>
				
              <!---  , @jobtitle = 		<cfif LEN(arguments.jobtitle)>#arguments.jobtitle#'<cfelse>NULL</cfif>--->
                , @jobfunctionID = 		<cfif arguments.jobfunctionID neq 0>#arguments.jobfunctionID#<cfelse>NULL</cfif>
                , @BudgetID = 		<cfif arguments.BudgetID neq 0>#arguments.BudgetID#<cfelse>NULL</cfif>
                 , @OrgTypeID = 		<cfif arguments.OrgTypeID neq 0>#arguments.OrgTypeID#<cfelse>NULL</cfif>
                  , @sectorid = 		<cfif LEN(arguments.sectorid)>'#arguments.sectorid#'<cfelse>NULL</cfif>
		</cfquery>	
		
		
<!--- 		<cfset var qrySearch = "">
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
 --->		
		<cfreturn qrySearchUsers>
		
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
		
		<cfquery datasource="#variables.DSN5#" name="qryUpdateEmailNotification" >
		EXEC usp_UpdateEmailNotification
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
	
	 <cfstoredproc datasource="#variables.DSN5#" procedure="usp_UnsubscribeNewsletter" returncode="yes">
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
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetUserSearchLookups" access="public" output="false" returntype="struct" hint="returns data to populate select menus on user search page">
		<cfset var strUserSearchLookups = StructNew()>

		<cfstoredproc datasource="#variables.DSN5#" procedure="usp_GetUserSearchLookups">
			<cfprocresult resultset="1" name="strUserSearchLookups.qryUserTypes">
            <cfprocresult resultset="2" name="strUserSearchLookups.qryjobFunction">
            <cfprocresult resultset="3" name="strUserSearchLookups.qryOrgTypes">
            <cfprocresult resultset="4" name="strUserSearchLookups.qryBudget">
             <cfprocresult resultset="5" name="strUserSearchLookups.qrySector">
		</cfstoredproc>
		
		<cfreturn strUserSearchLookups>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="articleLog" access="public" output="false" returntype="void" hint="log the id of article stored for this user">
		<cfargument name="Userid" 				required="yes" type="numeric" 	hint="id of user">
		<cfargument name="articleid" 			required="yes" type="numeric" 	hint="article id">
		<cfargument name="IpAddress" 			required="yes" type="string" 	hint="">
			
			<cfquery datasource="#variables.DSN5#"  >
			EXEC usp_LogUserArticle
			@UserID = <cfif arguments.Userid> #arguments.Userid#<cfelse>NULL</cfif>,
			@ArticleID = #arguments.articleid#,
			@IpAddress = '#arguments.IpAddress#'
			
		</cfquery>
		
	</cffunction>
    
    <cffunction name="RequestLog" access="public" output="false" returntype="void" hint="log the request of a user">
		<cfargument name="Userid" 				required="yes" type="numeric" 	hint="id of user">
		<cfargument name="urlPath" 				required="yes" type="string" 	hint="article id">

			<cfquery datasource="#variables.DSN5#" >
			EXEC usp_SaveLogUserRequest
			@UserID =  #arguments.Userid#,
			@url= '#arguments.urlPath#'	
		</cfquery>
		
	</cffunction>
    
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getUsersByArticle" access="public" output="false" returntype="query" hint="get all users for a particular article">
		
		<cfargument name="articleid" 			required="yes" type="numeric" 	hint="article id">
			
			<cfset var qry = querynew("temp")>
			<cfquery datasource="#variables.DSN5#" name="qry" >
			EXEC usp_GetUsersFromArticle
			@ArticleID = #arguments.articleid#
		</cfquery>
		<cfreturn qry>
	</cffunction>
	
</cfcomponent>