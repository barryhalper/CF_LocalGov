<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/BusinessObjects/Users.cfc $
	$Author: Bhalper $
	$Revision: 13 $
	$Date: 22/04/09 16:46 $

--->

<cfcomponent displayname="Users" hint="Functions related to users" extends="his_Localgov_Extends.components.BusinessObjectsManager">

	<!--- -------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR -------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Users" hint="Pseudo-constructor">
	 
		<cfargument name="objAppObjs" type="any" required="yes" hint="The application objects">
		<cfargument name="objBusObjs" type="any" required="yes" hint="The business objects">

		<cfscript>
		// Call the genric init function, placing business, app, and dao objects into a local scope...
		StructAppend( variables, Super.initChild( arguments.objAppObjs, this, arguments.objBusObjs ) );	

		variables.strRegSelects=	getRegistrationSelects();
		variables.sitepath= 		variables.strConfig.strPaths.sitepath;
		
		return this;
		</cfscript>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions --------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getVariables" access="public" output="false" returntype="struct" 
		hint="return local scope to caller">
		
		<cfreturn variables>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="updateCorporateAdministrator" access="public" output="false" returntype="void" 
		hint="">
		
		<cfargument name="p_user_id" type="numeric" required="yes">
		<cfargument name="p_subscription_id" type="numeric" required="yes">
		
		<cfreturn objDAO.updateCorporateAdministrator( arguments.p_user_id, arguments.p_subscription_id  )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="emailCorporateAdministrator" access="public" output="false" returntype="void" 
		hint="">
		
		<cfargument name="p_user_id" 			type="numeric" required="yes">
		<cfargument name="p_subscription_id" 	type="numeric" required="yes">
	  	<cfargument name="subscribers_link" 	type="string" required="yes">

		<cfmail	to=		"#objDAO.getUsernameFromUserID( arguments.p_user_id )#" 
				from=	"#variables.strConfig.strVars.mailsender#"
				subject="#variables.strConfig.strVars.title#: Corporate Subscription Details"
				type=	"html">

			Thank you, your payment has been successfully authorised and your subscription will start immediately.
			<br /><br />
			Your subcription reference number is ###arguments.p_subscription_id#<br /><br />
			<br /><br />
			Your corporate access code is #objDAO.getAccessCode( arguments.p_subscription_id )#
			<br /><br />
			Please forward the access code and the following link to all your corporate subscribers.
			<br /><br />
			<div style="color:##FF0000">
			<a href="#arguments.subscribers_link#">#arguments.subscribers_link#</a>
			<br /><br />
			</div>

			<div style="font-size: 10px; color:##999999">
			#variables.strConfig.strVars.disclaimer#
			</div>
		</cfmail>
				
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getUserDetailsByID" access="public" output="false" returntype="query" 
		hint="returns a query of specified user details">
		
		<cfargument name="id" type="numeric" required="yes">
		
		<cfreturn objDAO.getUserDetailsByID( arguments.id )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getUserDetailsAdmin" access="public" output="false" returntype="query" 
		hint="returns a query of specified user details">
		
		<cfargument name="id" type="numeric" required="yes">
		
		<cfreturn objDAO.getUserDetailsAdmin( arguments.id )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getCorpRegistrants" access="public" output="false" returntype="query" 
		hint="returns a query containing all registrants to the corporate subscription">
		<cfargument name="CorpSubscriptionID" type="numeric" required="yes">
		
		<cfreturn objDAO.getCorpRegistrants( arguments.CorpSubscriptionID )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getActiveCorpRegistrantsCount" access="public" output="false" returntype="query" 
		hint="returns a query containing all active registrants to the corporate subscription">
		<cfargument name="CorpSubscriptionID" type="numeric" required="yes">
		
		<cfreturn objDAO.GetActiveCorpRegistrantsCount( arguments.CorpSubscriptionID )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="editCorpRegistrant" access="public" output="false" returntype="boolean" 
		hint="updates the corporate subscriber details">
		
		<cfargument name="strAttr" required="yes" type="struct" hint="qry of attribute data">
		<cfargument name="strSession" required="yes" type="struct">
		
		<cfscript>
		var bSuccessfullUpdate= false;
		
		if (Arguments.strAttr.radio_clicked eq 1){
			// corp admin user is replaceing an existing subscriber
			Arguments.strAttr.UserType = 2;
			Arguments.strAttr.p_user_id = 0;
			//set new password
			Arguments.strAttr.Password = GeneratePassword();
		}
		else {
			//corp admin user is editing an existing subscriber
			Arguments.strAttr.Password = '';
			Arguments.strAttr.UserType = 4;
		}

		// Attempt to update the corporate user, passing the form attributes, email and password...
		strUserDetails.UserID = objDAO.registerUser( 
			Arguments.strAttr, 
			Arguments.strAttr.Email,
			Arguments.strAttr.Password
		);
		
		strUserDetails.Username= 			trim(Arguments.strAttr.Email);
		strUserDetails.UserTypeID= 			Arguments.strAttr.UserType; // 2 = Registered User, 4 = Corporate Subscriber
		strUserDetails.CountryID= 			Arguments.strAttr.f_country_id;
		
		// If a user id was returned, hence a successful registration...
		if ( StructKeyExists(strUserDetails,"UserID") ) {
			StructInsert(Arguments.strAttr, "CorpUserName", Arguments.strSession.userdetails.USERNAME);
			// The business object checks if the Corp Admin has opted to receive email notifications
			notifyAdmin = GetSubscriptionDetailsByID( Arguments.strSession.userdetails.UserID );

			// Send out an email confirmation...
			// If the corporate admin user is replacing an existing user
			if (Arguments.strAttr.radio_clicked eq 1){
				objDAO.DeleteCorpRegistrant( Arguments.strAttr.HID_P_USER_ID );
				//variables.objSubscriptions.CommitCorporateSubscriber(strUserDetails.userid, Arguments.strAttr.HID_SUBID);
				variables.objEmail.SendEmailConfirmation( arguments.strAttr.email, arguments.strAttr.forename, arguments.strAttr.surname, arguments.strAttr.password, strUserDetails );
				//variables.objSubscriptions.SendEmailToSubsDept("replaced", Arguments.strAttr, strUserDetails );
				if (notifyAdmin.recordcount NEQ 0 AND notifyAdmin.email_notification EQ 1)
				variables.objEmail.SendEmailToCorpAdmin("Replaced", Arguments.strAttr, strUserDetails );
			}
			// if the corporate admin user is updating an existing user
			else if (Arguments.strAttr.radio_clicked eq 2){
				//variables.objSubscriptions.SendEmailToSubsDept("updated", Arguments.strAttr, strUserDetails );
				if (notifyAdmin.recordcount NEQ 0 AND notifyAdmin.email_notification EQ 1)
				variables.objEmail.SendEmailToCorpAdmin("Updated", Arguments.strAttr, strUserDetails );
			}
			// If a registered user subscribes to a corporate subscription.
			else
			{
				if (Len(Arguments.strAttr.ACCESSCODE)){
					//user is entering accces code to join corp sub
					subscriptionQuery = variables.objSubscriptions.getSubFromAccessCode( Arguments.strAttr.ACCESSCODE );
					// Insert the userid and subscription id in the localgov_subscriber table.
					if (subscriptionQuery.recordcount EQ 1){
					variables.objSubscriptions.CommitCorporateSubscriber(strUserDetails.UserID, subscriptionQuery.p_subscription_id);
					StructUpdate(Arguments.strAttr, "CorpUserName", subscriptionQuery.USERNAME);
					UpdateUserType( strUserDetails.UserID, subscriptionQuery.ProductID, session, 0 );
					//variables.objSubscriptions.SendEmailToSubsDept("registered", Arguments.strAttr, strUserDetails );
					if (notifyAdmin.recordcount AND notifyAdmin.email_notification EQ 1)
					variables.objEmail.SendEmailToCorpAdmin("Subscribed", Arguments.strAttr, strUserDetails );
					}
				}
			}
			//LoginUser( strUserSessionDetails );
			bSuccessfullUpdate = true;
		}
		</cfscript>
		
		<!--- save login details into wddx packet for storage--->
		<cfwddx action="cfml2wddx" input="#strUserDetails#" output="wddxUserDetails">
		<!-- insert packet into db--->
		<cfset objDAO.SaveUserSession( wddxUserDetails, strUserDetails.UserID )>
		
		<cfreturn bSuccessfullUpdate>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getSubscriptionDetailsByID" access="public" output="false" returntype="query" 
		hint="Checks if the Corp Admin has opted to receive email notifications">
		
		<cfargument name="user_id" required="yes" type="numeric" hint="subscriber id">
		
		<cfreturn objDAO.GetSubscriptionDetailsByID( Arguments.user_id )>

	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="deleteCorpRegistrant" access="public" output="false" returntype="void" 
		hint="deletes the corporate subscriber (the record is stored in the database)">
		
		<cfargument name="user_id" required="yes" type="numeric" hint="corp user id">
		<cfset var strUserDetails=StructNew()>
		
		<cfset objDAO.DeleteCorpRegistrant( Arguments.user_id )>
		
		<cfset qryUserDetail = 					GetUserDetailsByID( Arguments.user_id )>
		<cfset strUserDetails.Username= 		qryUserDetail.Username>
		
		<!--- The business object checks if the Corp Admin has opted to receive email notifications --->
		<cfset notifyAdmin = GetSubscriptionDetailsByID( Arguments.user_id )>

		<cfif notifyAdmin.email_notification EQ 1>
			<cfset variables.objEmail.SendEmailToCorpAdmin("Deleted", strUserDetails, Session )>
		</cfif>
		<!--- <cfset variables.objSubscriptions.SendEmailToSubsDept("deleted", strUserDetails, Session )> --->
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="reactivateCorpUser" access="public" output="false" returntype="void" 
		hint="reactivates the corporate subscriber">
		
		<cfargument name="user_id" required="yes" type="numeric" hint="corp user id">
		<cfset var strUserDetails=StructNew()>
		
		<cfset objDAO.ReactivateCorpUser( Arguments.user_id )>
		
		<cfset qryUserDetail= GetUserDetailsByID( Arguments.user_id )>
		<cfset strUserDetails.Username= 		qryUserDetail.Username>
		
		<!--- The business object checks if the Corp Admin has opted to receive email notifications --->
		<cfset notifyAdmin = GetSubscriptionDetailsByID( Arguments.user_id )>
		<cfif notifyAdmin.email_notification EQ 1>
			<cfset variables.objEmail.SendEmailToCorpAdmin("Re-Activated", strUserDetails, Session )>
		</cfif>
		<!--- <cfset variables.objSubscriptions.SendEmailToSubsDept("re-activated", strUserDetails, Session )> --->
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getUserIDFromUsername" access="public" output="false" returntype="string" 
		hint="returns the userid for a given username">
		
		<cfargument name="Username" type="string" required="yes">
		
		<cfreturn objDAO.getUserIDFromUsername( arguments.Username ).p_user_id>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getNewsletterSubs" access="public" output="false" returntype="query" 
		hint="returns all user who have are subscribing to newsletter">
		
		<cfreturn objDAO.GetNewsletterSubs()>	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getTopicNewsletterSubs" access="public" output="false" returntype="query" 
		hint="returns all user who have are subscribing to topic newsletter">
		<cfargument name="topicid" required="yes" type="numeric">  
		
		<cfreturn  objDAO.getTopicNewsletterSubs(arguments.topicid)>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="loggedIn" access="public" output="false" returntype="boolean" 
		hint="returns true if user is logged in">	
		<cfargument name="strSession" required="yes" type="struct">   
		
		<cfscript>
		var bl = false;
		if (StructKeyExists( arguments.strSession.UserDetails, "UserID" )){
			If (arguments.strSession.UserDetails.UserID gt 0)
				bl = true;
			}
			
			//request.objApp.objutils.dumpabort(bl);
			
		return bl;	
		</cfscript>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	  <cffunction name="isConcurrent" access="public" output="false" returntype="boolean" 
		hint="returns true if userid is logged in">	
		<cfargument name="userid" required="yes" type="numeric">   
		
		<!--- <cfscript>
		var bl = false;
		var i = 0;
		//get all sessions from java class
		var strSessions = objUtils.getAllSessions(variables.strConfig.strVars.appname);
		//loop over all sessions
		for (i in strSessions){
			 //check if user structure is present in session strcuture
			 if (StructKeyExists(strSessions[i], "UserDetails") AND NOT StructIsEmpty(strSessions[i].userdetails) AND StructKeyExists(strSessions[i].userdetails, "UserID")){
					//check user id
					if (strSessions[i].userdetails.userid eq arguments.userid AND strSessions[i].userdetails.username NEQ variables.strConfig.strVars.superuser){
						bl=true;
						break;
					}
				}
		}
		return bl;
		</cfscript> --->
		<cfreturn false>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="kickOutUser" access="public" output="false" returntype="boolean" 
		hint="allows appp to remove user from a session">	
		<cfargument name="userid" required="yes" type="numeric">   
		
		<cfscript>
		var bl = false;
		var i = 0;
		//get all sessions from java class
		var strSessions = objUtils.getAllSessions(variables.strConfig.strVars.appname);
		//loop over all sessions
		for (i in strSessions){
			 //check if user structure is present in session strcuture
			 if (StructKeyExists(strSessions[i], "userdetails") AND NOT StructIsEmpty(strSessions[i].userdetails) AND StructKeyExists(strSessions[i].userdetails, "userid")){
					//check user id
					if (strSessions[i].userdetails.userid eq arguments.userid){
						Structclear(strSessions[i].userdetails);
						bl=true;
						break;
					}
				}
		}
		return bl;
		</cfscript>
		
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getCurrentLogins" access="public" returntype="query" output="false" hint="return a qry object of all users who are currently logged in">

	<cfscript>
		var i=0;
		//get struct all off sessions
		//var StrSessions = objUtils.getAllSessions(variables.strConfig.strVars.appname);
		//set return qry object
		var qry = QueryNew("forename,surname,username,userid");
		/*var qryuserdeatils="";
		//loop over all session
		for (i in StrSessions){
		 // check if user is logged in
		 if (StructKeyExists(strSessions[i], "userdetails") AND NOT StructIsEmpty(strSessions[i].userdetails) AND StructKeyExists(strSessions[i].userdetails, "userid")){
		 	//get user's login details
	    	If (IsNumeric(StrSessions[i].userdetails.userid)){
				qryuserdeatils = getUserDetailsByID(StrSessions[i].userdetails.userid);
				//set user details into return qry
				QueryAddRow(qry);
				QuerySetCell(qry, "forename", qryuserdeatils.forename);	
				QuerySetCell(qry, "surname", qryuserdeatils.surname);	
				QuerySetCell(qry, "username", qryuserdeatils.username);	
				QuerySetCell(qry, "userid", StrSessions[i].userdetails.userid);			
				}
			}
		}*/
		return qry;
	</cfscript>
	
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="insertKeyword" access="public" returntype="query" output="false" 
		hint="this function saves the user keyword and returns a query object.">
		
		<cfargument name="strSession" type="struct" required="yes">
		<cfargument name="keyword" type="string" required="yes">
		<cfargument name="circuit" type="string" required="no" default="">
		
		<!--- create a query--->
		<cfset var qryKeyword = "">
		<cfset var qrychkKeyword = "">
	
		<!--- add rows if the keyword doesn't already exist --->
		<cfif StructkeyExists(arguments.strSession, "qryKeyword") and arguments.strSession.qryKeyword.recordcount>
		
			<!---check to see if word is present --->
			<cfset qrychkKeyword = objUtils.QueryOfQuery(arguments.strSession.qryKeyword,"keyword","keyword = '#arguments.keyword#'")>
			
			<cfif qrychkKeyword.recordcount eq 0>
				<cfset newrow = queryaddrow(arguments.strSession.qryKeyword)>
				
				<!--- set values in cells --->
				<cfset querysetcell(arguments.strSession.qryKeyword, "keyword", arguments.keyword)>
				<cfset querysetcell(arguments.strSession.qryKeyword, "circuit", arguments.circuit)>
			</cfif>
		
		<cfelse>
			<cfset arguments.strSession.qryKeyword= queryNew("keyword,circuit")>
			
			<cfset queryaddrow(arguments.strSession.qryKeyword)>
			<!--- set values in cells --->
			<cfset querysetcell(arguments.strSession.qryKeyword, "keyword", arguments.keyword)>
			<cfset querysetcell(arguments.strSession.qryKeyword, "circuit", arguments.circuit)>
		</cfif>
		
		<cfreturn arguments.strSession.qryKeyword >
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="commitKeywords" access="public" output="false" returntype="boolean" 
		hint="Commits the user's searched keywords to the database">
		
		<cfargument name="xmldoc" type="xml" required="yes">
		
		<cfreturn objDAO.commitKeywords( arguments.xmldoc )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="storeArticleID" access="public" output="true" returntype="void" 
		hint="Stores the article ID in the session scope for My Local Gov page">
		
		<cfargument name="strSession" 	type="struct" required="yes">
		<cfargument name="id" 			type="numeric" required="yes">
		<cfargument name="howMany"		type="numeric" required="no" default="10">
		
		<cfscript>
		var lstArticles=	"";
		var lstArticlesTitle= "";
	
		if (structKeyExists(arguments.strSession, "userDetails")) {
			
			if (not structKeyExists(arguments.strSession.userDetails, "articles")) {
				arguments.strSession.userDetails.articles = "";
				arguments.strSession.userDetails.articlesTitle = "";
			}
			
			lstArticles= 		arguments.strSession.userDetails.articles;
			lstArticlesTitle= 	arguments.strSession.userDetails.articlesTitle;
			
			if (not listfindnocase(lstArticles, arguments.id)) {
				
				if (listLen(lstArticles) gte arguments.howMany) 
					lstArticles= 		arguments.id & "," & listDeleteAt(lstArticles, listLen(lstArticles));
				else 
				 	lstArticles= 		arguments.id & "," & lstArticles;
				
				if (listLen(lstArticlesTitle) gte arguments.howMany) 	
					lstArticlesTitle= 	objArticle.getHeadline(arguments.id) & "," & listDeleteAt(lstArticlesTitle, listLen(lstArticlesTitle));
				else	
					lstArticlesTitle= 	objArticle.getHeadline(arguments.id) & "," & lstArticlesTitle;
				
			}
			arguments.strSession.userDetails.articles= 			lstArticles;
			arguments.strSession.userDetails.articlesTitle= 	lstArticlesTitle;
		}
		</cfscript>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="clearStoreArticles" access="public" output="false" returntype="void" 
		hint="">
		<cfargument name="strSession" 	type="struct" required="yes">

		<cfset arguments.strSession.userDetails.articles = "">
		<cfset arguments.strSession.userDetails.articlesTitle = "">
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="storeSearches" access="public" output="false" returntype="void" 
		hint="Stores the search term into the session scope.">
		
		<cfargument name="strSession" 	type="struct" required="yes">
		<cfargument name="SearchTerm"	type="string" required="yes">
		<cfargument name="Context"		type="string" required="yes">
		<cfargument name="HowMany"		type="numeric" required="no" default="10">
		
		<cfscript>
		var lstSearches	= "";
		
		// Check if the user detail session structure exists...
		if (StructKeyExists(arguments.strSession, "UserDetails")) {
			
			// Check if the searches list exists...
			if (not StructKeyExists(arguments.strSession.UserDetails, "Searches"))
				arguments.strSession.UserDetails.Searches = "";
			
			// Set a local variable to the current stored searches...
			lstSearches = arguments.strSession.UserDetails.Searches;
			
			// Only store the search term if it does not already exist...
			if (not FindNoCase(arguments.SearchTerm, arguments.strSession.UserDetails.Searches)) {
				
				// Only store 'HowMany', if higher then push the last one out...
				if ( ListLen(lstSearches) GTE arguments.HowMany )
					lstSearches = arguments.SearchTerm  & "," & ListDeleteAt(lstSearches, ListLen(lstSearches));
				else
					lstSearches = arguments.SearchTerm & "[" & arguments.context & "]," & lstSearches;
				
			}
			// Update the session structure...
			arguments.strSession.UserDetails.Searches = lstSearches;
		}
		</cfscript>		
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="clearStoreSearches" access="public" output="false" returntype="void" 
		hint="">
		<cfargument name="strSession" 	type="struct" required="yes">
		<cfset arguments.strSession.UserDetails.Searches = "">
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getRegistrationSelects" access="public" output="false" returntype="struct" 
		hint="returns a structure of queries used to populate the form's select boxes">
	
		<cfif NOT StructKeyExists(variables, "strRegistrationSelects")>
			<cfreturn objDAO.getRegistrationSelects()>
		<cfelse>
			<cfreturn variables.strRegistrationSelects>
		</cfif>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="saveUserSession" access="public" output="false" returntype="boolean" 
		hint="Saved the users details structure, converting it to a wddx packet first.">

		<cfargument name="strUserSessionDetails" type="struct" required="yes">

		<cfset var wddxUserSessionDetails = "" >

		<cfwddx action="cfml2wddx" input="#arguments.strUserSessionDetails#" output="wddxUserSessionDetails">
		
		<cfreturn objDAO.saveUserSession( wddxUserSessionDetails, arguments.strUserSessionDetails.userID )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="loadUserSession" access="public" output="false" returntype="struct" 
		hint="Loads the user details wddx packet and converts it to a ColdFusion structure.">

		<cfargument name="UserID" type="string" required="yes">

		<cfset var wddxUserSessionDetails = objDAO.loadUserSession( arguments.UserID ).userSessionDetails >
		<cfset var strUserSessionDetails = "" >

		<cfwddx action="wddx2cfml" input="#wddxUserSessionDetails#" output="strUserSessionDetails">
		
		<cfreturn strUserSessionDetails >
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="UpdateUserDetails" access="public" output="false" returntype="boolean" 
		hint="Updates the user details">
		
		<cfargument name="strAttr" 		required="yes" type="struct" hint="qry of attribute data">
		<cfargument name="strSession" 	required="yes" type="struct" hint="str of the session scope">
		
		<cfif NOT StructKeyExists(arguments.strAttr, "ReceiveNewsletter")>
			<cfset arguments.strAttr.ReceiveNewsletter = 0>
		</cfif>
		
		<cfreturn objDAO.updateUserDetails( arguments.strAttr, arguments.strSession )>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="registerUser" access="public" output="false" returntype="boolean" 
		hint="Register the user with the system, sending out email confirmation and logs the user in if successful.  Returns FALSE if unsuccessful.">
		
		<cfargument name="strAttr" 		required="yes" type="struct" hint="qry of attribute data">
		<cfargument name="strSession" 	required="yes" type="struct" hint="str of the session scope">
		
		<cfscript>
		var strUserSessionDetails	=	StructNew();
		var bSuccessfullRegistraion	= 	false;
		
		//If AccessCode is entered and is validated, we know the user is a corporate subscriber i.e usertype = 4, else usertype = 2.
		if (arguments.strAttr.accessCode neq '' and arguments.strAttr.accessCode neq 0)
			arguments.strAttr.userType = 4;
		else
			arguments.strAttr.userType = 2;
		
		newPassword = generatePassword();
		// Attempt to register the user, passing the form attributes, email and a system generated password...
		strUserSessionDetails.userID = objDAO.registerUser( 
			arguments.strAttr, 
			arguments.strAttr.email,
			newPassword
		);
		
		arguments.strAttr.password 			= newPassword;
		
		strUserSessionDetails.username		= trim(arguments.strAttr.email);
		strUserSessionDetails.userTypeID	= arguments.strAttr.userType; // 2 = Registered User, 4 = Corporate Subscriber
		strUserSessionDetails.countryID		= arguments.strAttr.f_country_id;
		strUserSessionDetails.articles		= "";
		strUserSessionDetails.articlesTitle	= "";
		
		// If a user id was returned, hence a successful registration...
		if ( strUserSessionDetails.userID ) {
		
			// Get the Subscription ID if Access Code is not empty (i.e the user registering to the site is a corporate subscriber)
			if (arguments.strAttr.accessCode neq '' and arguments.strAttr.accessCode neq 0){
				subscriptionQuery = objSubscriptions.getSubFromAccessCode( arguments.strAttr.accessCode );
				
				// Insert the userid and subscription id in the localgov_subscriber table.
				if (subscriptionQuery.recordcount eq 1) {
					objSubscriptions.commitCorporateSubscriber(strUserSessionDetails.userID, subscriptionQuery.p_subscription_id);
					StructInsert(arguments.strAttr, "CorpUserName", subscriptionQuery.userName);
					//variables.objSubscriptions.SendEmailToSubsDept("registered", Arguments.strAttr, strUserSessionDetails );
					if (subscriptionQuery.email_notification eq 1)
						variables.objEmail.sendEmailToCorpAdmin("Subscribed", arguments.strAttr, strUserSessionDetails );
				}
			}
			
			// Send out an email confirmation and log the user in...
			variables.objEmail.sendEmailConfirmation(arguments.strAttr.email, arguments.strAttr.forename, arguments.strAttr.surname, arguments.strAttr.password,strUserSessionDetails );
			loginUser( strUserSessionDetails, arguments.strSession );
			
			bSuccessfullRegistraion = true;
		}
				
		</cfscript>
		
		<!--- todo: replace with call to local saveUserSession() rather than DAO's... --->
		<cfwddx action="cfml2wddx" input="#strUserSessionDetails#" output="wddxUserDetails">
		<cfset objDAO.saveUserSession( wddxUserDetails, strUserSessionDetails.UserID )>
		
		<cfreturn bSuccessfullRegistraion>
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="registerMaximUser" access="public" output="false" returntype="boolean" 
		hint="Generate a password and email notification.  Returns FALSE if unsuccessful.">
		
		<cfargument name="userID" 		required="yes" type="numeric" hint="">
		
		<cfscript>
		var successfullReg= 	false;
		var strAttr= 			structNew();
		var strUser= 			structNew();
		var qryUserDetails= 	objDAO.getUserDetailsByID( arguments.userID );
		
		strUser.password=  		generatePassword();

		// If a user id was returned, hence a successful registration...
		if ( objDAO.updatePassword( arguments.userID, hash(strUser.password) ) ) {			
			
			strAttr.userID=		arguments.userID;
			strAttr.forename=	qryUserDetails.forename;
			strAttr.surname= 	qryUserDetails.surname;
			strAttr.email= 		qryUserDetails.email;
			strAttr.userTypeID= qryUserDetails.f_usertype_id;
			strAttr.countryID= 	qryUserDetails.f_country_id;
			strUser.username=	qryUserDetails.email;
			strAttr.password=	strUser.password;
			
			saveUserSession( strAttr, arguments.userID );
			
			// Send out an email confirmation and log the user in...
			variables.objEmail.sendEmailConfirmation( arguments.strAttr.email, arguments.strAttr.forename, arguments.strAttr.surname, arguments.strAttr.password, strUser );
			
			successfullReg = true;
		}
		
		return successfullReg;
		</cfscript>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -----------------------------------------------------------------------------------------------
	<cffunction name="createWDDXpacket" access="public" output="false" returntype="numeric" 
		hint="Check whether the supplied username/email exists">
		
		<cfargument name="Email" required="yes" type="string" hint="">
		
		<cfreturn objDAO.checkUsername( arguments.email )>
		
	</cffunction>		--->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="checkUsername" access="public" output="false" returntype="numeric" 
		hint="Check whether the supplied username/email exists">
		
		<cfargument name="Email" required="yes" type="string" hint="">
		
		<cfreturn objDAO.checkUsername( arguments.email )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="CheckUserHasSubscription" access="public" output="false" returntype="numeric" 
		hint="Check whetehr the email/username is already a corporate admin">
		
		<cfargument name="Email" required="yes" type="string" hint="">
		
		<cfreturn objDAO.CheckUserHasSubscription( arguments.email )>
		
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getUserTypeFromID" access="public" output="false" returntype="string" 
		hint="Return a string containing the user type, based on the user type id">
		
		<cfargument name="UserTypeID" required="yes" type="numeric" hint="">
		
		<cfreturn objDAO.getUserTypeFromID( arguments.UserTypeID )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getUserTypeID" access="public" output="false" returntype="string" 
		hint="Return user type id">
		
		<cfargument name="UserID" required="yes" type="numeric" hint="">
		
		<cfreturn objDAO.getUserTypeID( arguments.UserID )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="resendPassword" access="public" output="true" returntype="string" 
		hint="Update the user's password">
		
		<cfargument name="newPassword"	required="yes" type="string" hint="the new password">
		<cfargument name="username" 	required="yes" type="string" hint="the username/email">
		<cfargument name="strSession" 	required="yes" type="struct" hint="the session scope">

		<cfscript>		
		bSuccess	=	false;
		userID		= 	0;

		// Obtain the User's ID...
		if ( StructKeyExists(arguments.strSession.userDetails, "userID") )
			userID = arguments.strSession.userDetails.userID;
		else
			userID = getUserIDFromUsername( arguments.Username );
			
		// If a user id was found...
		if ( not (userID eq 0 or userID eq "") ) {

			// Attempt to update the user's password, ensuring that it is HASHed before passing it over to the DAO....
			bSuccess = objDAO.updatePassword( userID, hash(trim(arguments.newPassword)) );
	
			//  Update the session details and email out the new password...
			if (bSuccess) 
				variables.objEmail.emailNewPassword( arguments.username, arguments.newPassword );
		}

		return bSuccess;
		</cfscript>	
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="updatePassword" access="public" output="true" returntype="string" 
		hint="Update the user's password">

		<cfargument name="UserID" 	    required="yes" type="numeric"hint="">

		<cfscript>
		var pw = generatePassword();
		objDAO.updatePassword( arguments.UserID, hash(trim(pw)) );
		return pw;
		</cfscript>
			
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="updateUsername" access="public" output="true" returntype="string" 
		hint="Update the user's username">
		
		<cfargument name="newUsername" 		required="yes" type="string" hint="the new password">
		<cfargument name="currentUsername" 	required="yes" type="string" hint="the username/email">
		<cfargument name="strSession" 		required="yes" type="struct" hint="the session scope">

		<cfscript>		
		var bSuccess	= 	false;
		var UserID		= 	0;
						
		// Obtain the User's ID...
		if ( StructKeyExists(arguments.strSession.UserDetails, "UserID") )
			UserID = arguments.strSession.UserDetails.UserID;
		else
			UserID = getUserIDFromUsername( trim(arguments.CurrentUsername) );
		
		// If a user id was found...
		if ( not (UserID eq 0 or UserID eq "") ) {
			
			userExists = checkUsername( trim(arguments.NewUsername) );
			// Attempt to update the user's password....
			if (userExists EQ 0)
			bSuccess = objDAO.updateUsername( UserID, trim(arguments.NewUsername) );
	
			//  Update the session details and email out the new password...
			if (bSuccess) {
				arguments.strSession.UserDetails.Username = NewUsername;
				variables.objEmail.emailNewUsername( arguments.NewUsername );
			}
		}
		
		return bSuccess;
		</cfscript>
			
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="updateUserType" access="public" output="true" returntype="string" 
		hint="Update the user's type both in the database and session scope">
		
		<cfargument name="userID"		 required="yes" type="string" hint="the user id">
		<cfargument name="productID" 	 required="yes" type="string" hint="the product id">
		<cfargument name="strSession" 	 required="yes" type="struct" hint="the session scope">
		<cfargument name="corpAdminUser" required="no" type="boolean" default="1" hint="the user type id">

		<cfscript>
		var userTypeID = 0;
		
		switch ( arguments.productID ) {
		case 1: { userTypeID = 3; break;}
		case 2:	{ if (arguments.corpAdminUser) userTypeID = 5; else userTypeID = 4; break;}
		}
		
		// Update session scope...
		if (userTypeID neq 0) {
			arguments.strSession.userDetails.userTypeID=userTypeID;
			// Attempt to update the user's type....
			objDAO.updateUserType( arguments.userID, userTypeID );
		}
		
		return true;
		</cfscript>
			
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="updateUserStatus" access="public" output="true" returntype="string" 
		hint="Update the user's type both in the database and session scope">
		
		<cfargument name="userID"	 required="yes" type="string" hint="the user id">
		<cfargument name="userStatusID"	 required="yes" type="string" hint="the user status id">
		
		<cfreturn objDAO.updateUserStatus( arguments.userID, variables.userStatusID )>
			
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="requestNewPassword" access="public" output="false" returntype="string" 
		hint="">
		
		<cfargument name="Email" required="yes" type="string" hint="">
		<cfargument name="strSession" required="yes" type="struct" hint="str of the session scope">
		
		<cfreturn updatePassword( generatePassword(), arguments.Email, arguments.strSession )>
			
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="validateLogin" access="public" output="false" returntype="struct" 
		hint="Validate login">
		
	  	<cfargument name="strAttr" 		required="yes" type="struct" hint="qry of attribute data">
		<!---todo: split this strcu into required arguments so one can see what is required when debugging--->
		<cfargument name="strSession" 	required="yes" type="struct" hint="str of the session scope">
		
		<cfscript>
			var strUserSessionDetails=			StructNew();
			var strLoginDetails=				StructNew();
	
			// 1. Consult the DAO to determine whether the login and subscription (if relevant) are valid...
		  	strLoginDetails = objDAO.validateLogin( arguments.strAttr, true );
	
			strLoginDetails.alreadyLoggedIn= 	false;
			
			// todo: remove when we go-live, for dev purposes only 
			//if there was no match found, perform a second check without HASHing the password...
			if (strLoginDetails.qryUserDetails.recordCount eq 0)
				strLoginDetails= objDAO.validateLogin( arguments.strAttr, false );
			
			// 2. If the login was valid and we were able to retrieve the user's details...
			if ( strLoginDetails.rtnCode gt 0 and strLoginDetails.qryUserDetails.recordCount ) 
			{
			
				// 2.1. If not already logged in...
				if ( not isConcurrent( strLoginDetails.qryUserDetails.p_user_id ) ) 
				{
				
					// 2.1.1 Lower the relevant flag
					strLoginDetails.alreadyLoggedIn = false;
					
					if 	(Len(strLoginDetails.qryUserDetails.userSessionDetails))	
					// 2.1.1 Attempt to Login the user...	
						loginUser( wddx2cfml( strLoginDetails.qryUserDetails.userSessionDetails ), arguments.strSession );
					else
					{
						strUserSessionDetails.userid=strLoginDetails.qryUserDetails.p_user_id;
						loginUser(strUserSessionDetails, arguments.strSession );
					}
				
				// 2.2 Already logged in...
				}
				
				else 
				{
					// 2.2.1 Raise the relevant flag
					strLoginDetails.alreadyLoggedIn = true;
				}		
			}
			
			return strLoginDetails;
		</cfscript>
		
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="wddx2cfml" access="private" output="false" returntype="struct">
		<cfargument name="input" type="xml" required="yes">
		<cfset var output = "">
			<cfwddx action="wddx2cfml" input="#arguments.input#" output="output">
		<cfreturn output>		 
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="cfml2wddx" access="private" output="false" returntype="any">
		<cfargument name="input" type="struct" required="yes">
		<cfset var output = "">
		<cfwddx action="cfml2wddx" input="#arguments.input#" output="output">
		<cfreturn output>		 
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="logoutUser" access="public" output="false" returntype="void" 
		hint="Log the user out by clear the UserDetails structure in the session scope, saving any session information first.">
		<cfargument name="strSession" 	required="yes" type="struct" hint="the session scope">
		
		<cfscript>
		var i = 0;
		//--- Attempt to save session details to persistent scope...
		if(StructKeyExists( arguments.strSession.UserDetails, "UserID" ))
			saveUserSession( arguments.strSession.UserDetails, arguments.strSession.UserDetails.UserID );
			
		structclear(arguments.strSession.userDetails);
		structDelete(arguments.strSession, "dataSalesLists");
		structDelete(arguments.strSession, "strDataSalesTotal");
		structDelete(arguments.strSession, "datasalepurchaser");
		structDelete(arguments.strSession, "qryuserdetails");
				
		</cfscript>
						
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="validateSubscription" access="public" output="false" returntype="boolean" 
		hint="Validates Subscription Order Form">
	  	
		<cfargument name="strAttr" required="yes" type="struct" hint="attribute data">
		<cfargument name="strSession" 	required="yes" type="struct" hint="the session scope">

		<cfscript>		
		arguments.strSession.errorMessage=			"";
		arguments.strSession.isValid=				"1";
		
		if (not StructKeyExists(arguments.strAttr, 'ProductID')) {
			arguments.strSession.errorMessage = 	arguments.strSession.errorMessage & "Please select a subscription type" & "<br />";
			arguments.strSession.isValid		=	"0";
		}
		
		if (not StructKeyExists(strSession.UserDetails, 'UserID')) {
			arguments.strSession.errorMessage = 	arguments.strSession.errorMessage & "Please login or register" & "<br />";
			arguments.strSession.isValid		=	"0";
		}
		
		return arguments.strSession.isValid;
		</cfscript>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="notifyByEmail" access="public" output="false" returntype="boolean" 
		hint="Updates the corporate users email notification preference">
		
		<cfargument name="subscriptionID" 	required="yes" type="numeric">
		<cfargument name="notification"		required="yes" type="numeric">

		<cfreturn objDAO.updateEmailNotification( arguments.subscriptionID, arguments.notification )>
			
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
 	<cffunction name="sendEmailConfirmation" access="public" output="false" returntype="void" 
		hint="Construct and send out an email confirmation with the user's login details">
		
	  	<cfargument name="strAttr" 			required="yes" type="struct" hint="qry of attribute data">
	  	<cfargument name="strUserDetails" 	required="yes" type="struct" hint="str of user details">
			
		<cfset objEmail.sendEmailConfirmation( arguments.strAttr.email, arguments.strAttr.forename, arguments.strAttr.surname, arguments.strAttr.password, strUserDetails )>
		
	</cffunction>		
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- PRIAVTE Functions -------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="setCookie" access="public" output="false" returntype="void" 
		hint="Construct a cookie to store the user's id and username">
		
	  	<cfargument name="strUserDetails" required="yes" type="struct" hint="str of user details">
		
		<cfcookie name=	"userid" 	value=	"#arguments.strUserDetails.UserID#" 	expires="never" >
		<cfcookie name=	"username" 	value=	"#arguments.strUserDetails.Username#"	expires="never">
		
	</cffunction>		
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="expireCookie" access="public" output="true" returntype="void" 
		hint="Expire the cookie">
		
		<cfset structdelete(cookie, "userid")>
		<cfset structdelete(cookie, "username")>
								
	</cffunction>		
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="loginUser" access="private" output="false" returntype="void" 
		hint="Log the user in by populating the session.UserDetails structure">
		
	  	<cfargument name="strUserDetails" required="yes" type="struct" hint="str of user details">
		<cfargument name="strSession" required="yes" type="struct" hint="str of the session scope">

		<cfscript>	
		var qryUser = "";	
		// Simulate a login --->
		arguments.strSession.userDetails= 	arguments.strUserDetails;
		arguments.strSession.redirect= 		false; // used in app.cfc as a safe gaurd
		
		// Get the user type id from the user id and added it to the session structure... 
		arguments.strSession.userDetails.userTypeID= 	objDAO.getUserTypeID( arguments.strSession.userDetails.userID );
		arguments.strSession.userDetails.lstSectorIDs= 	objDAO.getUserSectorIDs( arguments.strSession.userDetails.userID );
		
		qryUser =objDAO.getUserDetailsByID( arguments.strSession.userDetails.userID );
		arguments.strSession.userDetails.fullName= 		qryUser.fullName;
		arguments.strSession.userDetails.company= 		qryUser.company;
		arguments.strSession.userDetails.jobtitle= 		qryUser.jobtitle;
		arguments.strSession.userDetails.county= 		qryUser.county;
		arguments.strSession.userDetails.username= 		qryUser.username;
		arguments.strSession.userDetails.countryid= 	qryUser.f_country_id;
		</cfscript>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="checkPageAccess" access="public" returntype="struct" output="false" hint="Evaluates if a user can view a page return boolean of 'IsAllowed' and reason string">
	<cfargument name="accesstype" 	    type="numeric" required="yes">
	<cfargument name="strSession"       type="struct"  required="yes">
	
		<cfscript>
		var strReturn =StructNew();
		strReturn.IsAllowed = true;
		strReturn.sReason 	= "OK";
		
		if (arguments.accesstype eq 1)
			strReturn.IsAllowed = true;
		else	
		//users must be logged in
		if (NOT LoggedIn(arguments.StrSession) ){
		 	strReturn.IsAllowed = false;
		 	strReturn.sReason 	= "NotLoggedIn";
		 	}
		else {
			//accces type of subscribers: users must be logged in and have usertype of at least subscriber
			if (arguments.accesstype eq 3 AND arguments.StrSession.UserDetails.usertypeid lt 3) {
				strReturn.IsAllowed = false;
				strReturn.sReason 	= "NotSubs"; 
				}
			else
			//accces type of Corporate Admin: users must be logged in and have usertype of at least Corporate Subscriber Administrator
			if 	(arguments.accesstype eq 5 and arguments.StrSession.UserDetails.usertypeid neq 5) {
				strReturn.IsAllowed = false;
				strReturn.sReason 	= "NotCorpSubs";
				}
		}
		return strReturn;
	
		</cfscript>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="generatePassword" access="public" output="false" returntype="string" 
		hint="Generates and returns a alphanumeric password 'LengthOfPW' chars in length">

		<cfargument name="LengthOfPW" required="no" default="8">
				
		<cfscript>
		var pw = ""; var i=0; var j=0;

		// Algorithm to generation an alphanumeric string of length specifed...		
		for (i=1; i lte arguments.LengthOfPW * 100; i=i+1) {
			char = chr(randrange(48,90));
			if (not refind("\:|\;|\<|\=|\>|\?|\@", char)) {
				pw = pw & char;
				j=j+1;
			}
			if (j gte arguments.LengthOfPW) break;
		}
		
		return pw;	
		</cfscript>
		
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
		
		<cfreturn objDAO.SearchUsers(argumentcollection=arguments)>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getUserSelects" access="public" output="false" returntype="struct" hint="returns user types and status">
		<cfreturn objDAO.GetUserSelects()>
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="generateUsername" access="private" output="false" returntype="string" 
		hint="Generates and returns a username based on the provided company name.  Now Depreciated (08/08/06) ?">

		<cfargument name="CompanyName" required="yes" type="string">
				
		<cfscript>
		 var un = "";
		 var i=0; 
		 var j=0; 
		 var qryUsernames = "";

		  un = mid(arguments.companyname, 1, 6);
		
		  qryUsernames = objDAO.GetUsername( un );

		  return un & NumberFormat(qryUsernames.RecordCount+1, "0000");
		</cfscript>
		
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
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
		
		
		<cfscript>
		var nReturn =  objDAO.AdminEditUser(argumentCollection=arguments);
		updateUsersPacket(argumentCollection=arguments);
		return nReturn;
		</cfscript>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="unsubscribeUserFromNewsletter" access="public" output="false" returntype="boolean" hint="set user's details to not recive newsletter">
		<cfargument name="userid" 	required="yes" type="numeric">
		<cfargument name="Username" 	required="yes" type="string">
		<cfreturn objDAO.UnsubscribeUserFromNewsletter(arguments.userid,arguments.Username )>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="updateUsersPacket" returntype="void" access="public" hint="update data held in a user's wddx packet">
		<cfargument name="userid" 	 	type="numeric" 	required="yes">
		<cfargument name="Username"  	type="string" 	required="yes">
		<cfargument name="Statusid"  	type="numeric" 	required="yes">
		<cfargument name="forename"  	type="string" 	required="yes">
		<cfargument name="surname" 	 	type="string" 	required="yes">
		<cfargument name="countryid" 	type="numeric" 	required="yes">
		<cfargument name="jobtitle" 	type="string" 	required="yes">
	
		<cfargument name="sectors" 		type="string" 	required="yes">
		
		<cfscript>
		//retrieve wddx packet from db and update keys
		var strPacket = request.objBus.objUsers.loadUserSession(arguments.userid);
		
		strPacket.Username		 	= 	arguments.Username;
		strPacket.countryID		 	= 	arguments.countryid;
		strPacket.jobtitle		  	= 	arguments.jobtitle;
		strPacket.order.Statusid	= 	arguments.Statusid;
		strPacket.LSTSECTORIDS		=	arguments.sectors;
		if ( Len(arguments.forename) and Len(arguments.surname) )
			strPacket.fullname			=	arguments.forename & " " & arguments.surname;
		//put wddx packet back into db
		saveUserSession(strPacket, arguments.userID );	
		</cfscript>
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="uyeValidateLogin" access="public" output="false" returntype="boolean" hint="Validates a login (and subscription) based on the username and password">
		
		<cfargument name="Username" 	required="yes" type="string">
		<cfargument name="Password" 	required="yes" type="string">
		<cfargument name="StrSession" 	required="yes" type="struct" hint="session structure">
		
			<cfscript>
			var blreturn = true;
			var strReturn = objDao.uyeValidateLogin(argumentcollection=arguments);
			//set login details into session
			If (strReturn.IsLoginValid){
			//set session
			  StrSession.strUser.Userid = strReturn.qryLogin.PersonId;
			  StrSession.strUser.CouncilID = strReturn.qryLogin.OrganisationID;
			  }
			 else
			 	blreturn = false;
			 return blreturn;
			</cfscript>
	
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="CommitUser2Topic" access="public" output="false" returntype="boolean" hint="add user to newsleter topic and return boolean of whether a user is already in topic. True|sucessfully added : False|Already in topic ">
		
		<cfargument name="Userid" 	required="yes" type="numeric">
		<cfargument name="TopicId" 	required="yes" type="numeric">
		
		<cfreturn objDAO.CommitUser2Topic(arguments.userid,arguments.TopicId )>
			
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<cffunction name="DeleteUserFromTopic" access="public" output="false" returntype="boolean" hint="add user to newsleter topic and return boolean of whether a user is already in topic. True|sucessfully added : False|Already in topic ">
		
		<cfargument name="Userid" 	required="yes" type="numeric">
		<cfargument name="Username" required="yes" type="string">
		<cfargument name="TopicId" 	required="yes" type="numeric">
		
		
		<cfreturn objDAO.DeleteUserFromTopic(arguments.userid,arguments.Username,arguments.TopicId )>
			
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="LogOpenDay" access="public" returntype="void" output="false" hint="log registered user who visit directory org/person item pages">
		<cfargument name="strSession" 	required="yes" type="struct" hint="session structure">
		<cfargument name="fuseaction" 	required="yes" type="string" hint="">
		
			<cfscript>
			//check if user is logged in
			If (loggedIn(arguments.strSession)){
				//check if user is registered
				If (arguments.strSession.userdetails.usertypeid eq 2)	
						objDAO.LogOpenDay(arguments.strSession.userdetails.userid, arguments.fuseaction);
				}			
			</cfscript>
		
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="CommitUserDNS" access="public" returntype="void" output="false" hint="log registered user who visit directory org/person item pages">
		<cfargument name="strForm" 	required="yes" type="struct" hint="form structure">
		
			<cfscript>
			 var sql = "";
			 var i   = 0 ;
			  for (i in arguments.strForm){
			    if (i CONTAINS "dns")
			  		sql = sql & " BEGIN  UPDATE tblLocalGov_userDetail SET MarketingDNS = " & Evaluate(strForm[i]) & " WHERE p_userDetail_id  = (SELECT f_userDetail_id FROM tblLocalGov_user
WHERE p_user_Id = " &  ListGetAt(i, 2, "-") & ") END "; 			  
			  }
			 
			  //pass sql statement to db
		     	//objutils.dumpabort(sql);
			objDAO.query(PreserveSingleQuotes(sql), variables.strConfig.strVars.dsn1);
			</cfscript>
		
	</cffunction>
	
</cfcomponent>