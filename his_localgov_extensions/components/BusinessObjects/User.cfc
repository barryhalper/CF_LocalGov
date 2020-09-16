<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/BusinessObjects/User.cfc $
	$Author: Bhalper $
	$Revision: 27 $
	$Date: 24/08/10 9:36 $

--->

<cfcomponent displayname="User" hint="Functions related to a user" extends="his_Localgov_Extends.components.BusinessObjectsManager">

	<!--- -------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR -------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="User" hint="Pseudo-constructor">
	 
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
	<cffunction name="getUserDetailsByID" access="public" output="false" returntype="query" hint="returns a query of specified user details">
		<cfargument name="id" type="numeric" required="yes">
		
		<cfreturn objDAO.getUserDetailsByID(arguments.id)>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getUserDetailsByTypeID" access="public" output="false" returntype="query" hint="returns a query of specified user types">
		<cfargument name="id" type="numeric" required="yes">
		
		<cfreturn objDAO.getUserDetailsByTypeID(arguments.id)>
		
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="deleteUserByID" access="public" output="false" returntype="void" hint="Deletes a user and userdetail record from the db">
		<cfargument name="id" type="numeric" required="yes">
		
		<cfset objDAO.deleteUserByID(arguments.id)>
		
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
			Arguments.strAttr.userid = 0;
			//set new password
			Arguments.strAttr.Password = GeneratePassword();
		}
		else {
			//corp admin user is editing an existing subscriber
			Arguments.strAttr.Password = '';
			Arguments.strAttr.UserType = 4;
		}
		//request.objApp.objUtils.dumpabort(arguments.strAttr);
		// Attempt to update the corporate user, passing the form attributes, email and password...
		strUserDetails.UserID = objDAO.registerUser( 
			Arguments.strAttr.UserID,
			Arguments.strAttr.contactSalutationID,
			Arguments.strAttr.email,
			Arguments.strAttr.forename,
			Arguments.strAttr.surname,
			Arguments.strAttr.address1,
			Arguments.strAttr.address2,
			Arguments.strAttr.address3,
			Arguments.strAttr.town,
			Arguments.strAttr.countyID,
			Arguments.strAttr.postcode,
			Arguments.strAttr.countryID,
			Arguments.strAttr.tel,
			Arguments.strAttr.fax,
			Arguments.strAttr.jobTitle,
			Arguments.strAttr.companyName,
			Arguments.strAttr.jobFunctionID,
			Arguments.strAttr.orgTypeID,
			Arguments.strAttr.budgetID,
			Arguments.strAttr.sectors,
			Arguments.strAttr.confirm1,
			Arguments.strAttr.confirm2,
			Arguments.strAttr.countyborn,
			Arguments.strSession,
			hash(trim(Arguments.strAttr.Password)),
			Arguments.strAttr.UserType
		);
		
		strUserDetails.Username= 			trim(Arguments.strAttr.Email);
		strUserDetails.UserTypeID= 			Arguments.strAttr.UserType; // 2 = Registered User, 4 = Corporate Subscriber
		strUserDetails.CountryID= 			Arguments.strAttr.countryid;
		
		// If a user id was returned, hence a successful registration...
		if ( StructKeyExists(strUserDetails,"UserID") ) {
			StructInsert(Arguments.strAttr, "CorpUserName", Arguments.strSession.userdetails.USERNAME);
			// The business object checks if the Corp Admin has opted to receive email notifications
			notifyAdmin = GetSubscriptionDetailsByID( Arguments.strSession.userdetails.UserID );

			// Send out an email confirmation...
			// If the corporate admin user is replacing an existing user
			if (Arguments.strAttr.radio_clicked eq 1){
				objDAO.DeleteCorpRegistrant( Arguments.strAttr.HID_USERID );
				//variables.objSubscriptions.CommitCorporateSubscriber(strUserDetails.userid, Arguments.strAttr.HID_SUBID);
				variables.objEmail.SendEmailConfirmation( 
														emailAddress		= Arguments.strAttr.email
														, forename 			= Arguments.strAttr.forename
														, surname			= Arguments.strAttr.surname
														, password			= Arguments.strAttr.Password
														, strUserDetails	= strUserDetails 
														);
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
					if (subscriptionQuery.recordcount gte 1){
					variables.objSubscriptions.CommitCorporateSubscriber(strUserDetails.UserID, subscriptionQuery.subscriptionid);
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
	<cffunction name="getUserIDFromUsername" access="public" output="false" returntype="string" hint="returns the userid for a given username">
		<cfargument name="Username" type="string" required="yes">
		
		<cfreturn objDAO.getUserIDFromUsername(arguments.Username)>
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
	<cffunction name="loggedIn" access="public" output="false" returntype="boolean" hint="returns true if user is logged in">	
		<cfargument name="strSession" required="yes" type="struct">   
		
		<cfset var status = false>
		
		<cfif StructKeyExists(arguments.strSession.UserDetails, "UserID" ) AND arguments.strSession.UserDetails.UserID NEQ 0>
			<cfset status = true>
		</cfif>
		
		<cfreturn status>
		<!--- <cfreturn StructKeyExists(arguments.strSession.UserDetails, "UserID" )> --->
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="isConcurrent" access="public" output="false" returntype="boolean" hint="returns true if userid is logged in">	
		<cfargument name="userid" required="yes" type="numeric">   
		
		<cfscript>
			var bl = false;
			var i = 0;
			//get all sessions from java class
			var strSessions = objUtils.getAllSessions(variables.strConfig.strVars.appname);
			//loop over all sessions
			for (i in strSessions){
				 //check if user structure is present in session strcuture
				 if (StructKeyExists(strSessions[i], "UserDetails") AND NOT StructIsEmpty(strSessions[i].userdetails) AND StructKeyExists(strSessions[i].userdetails, "UserID") and strSessions[i].userdetails.userID neq "0"){
						//check user id
						if (strSessions[i].userdetails.userid eq arguments.userid AND strSessions[i].userdetails.username NEQ variables.strConfig.strVars.superuser){
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
				 if (StructKeyExists(strSessions[i], "userdetails") AND NOT StructIsEmpty(strSessions[i].userdetails) AND StructKeyExists(strSessions[i].userdetails, "userid") and strSessions[i].userdetails.user neq "0"){
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
			var StrSessions = structNew();
			//set return qry object
			var qry = QueryNew("forename,surname,username,userid");
			var qryuserdeatils="";
			//loop over all session
			for (i in StrSessions){
			 // check if user is logged in
			 if (StructKeyExists(strSessions[i], "userdetails") AND NOT StructIsEmpty(strSessions[i].userdetails) AND StructKeyExists(strSessions[i].userdetails, "userid")){
			 	//get user's login details
		    	If (IsNumeric(StrSessions[i].userdetails.userid) and StrSessions[i].userdetails.userid neq "0"){
					qryuserdeatils = getUserDetailsByID(StrSessions[i].userdetails.userid);
					//set user details into return qry
					QueryAddRow(qry);
					QuerySetCell(qry, "forename", qryuserdeatils.forename);	
					QuerySetCell(qry, "surname", qryuserdeatils.surname);	
					QuerySetCell(qry, "username", qryuserdeatils.username);	
					QuerySetCell(qry, "userid", StrSessions[i].userdetails.userid);			
					}
				}
			}
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
	<cffunction name="clearStoreArticles" access="public" output="false" returntype="void" hint="">
		<cfargument name="strSession" 	type="struct" required="yes">

		<cfset arguments.strSession.userDetails.articles = "">
		<cfset arguments.strSession.userDetails.articlesTitle = "">
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="storeSearches" access="public" output="false" returntype="void" hint="Stores the search term into the session scope.">	
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
	<cffunction name="clearStoreSearches" access="public" output="false" returntype="void" hint="">
		<cfargument name="strSession" 	type="struct" required="yes">
		<cfset arguments.strSession.UserDetails.Searches = "">
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getRegistrationSelects" access="public" output="false" returntype="struct" hint="returns a structure of queries used to populate the form's select boxes">
	
		<cfif NOT StructKeyExists(variables, "strRegistrationSelects")>
			<cfreturn objDAO.getRegistrationSelects()>
		<cfelse>
			<cfreturn variables.strRegistrationSelects>
		</cfif>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="saveUserSession" access="public" output="false" returntype="boolean" hint="Saved the users details structure, converting it to a wddx packet first.">
		<cfargument name="strUserSessionDetails" type="struct" required="yes">
		
		<cfset var wddxUserSessionDetails = "" >

		<cfwddx action="cfml2wddx" input="#arguments.strUserSessionDetails#" output="wddxUserSessionDetails">
		
		<cfreturn objDAO.saveUserSession(wddxUserSessionDetails, arguments.strUserSessionDetails.UserID )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="loadUserSession" access="public" output="false" returntype="struct" 
		hint="Loads the user details wddx packet and converts it to a ColdFusion structure.">

		<cfargument name="UserID" type="string" required="yes">

		<cfset var wddxUserSessionDetails = objDAO.loadUserSession(arguments.UserID).userSessionDetails >
		<cfset var strUserSessionDetails = "" >

		<cfwddx action="wddx2cfml" input="#wddxUserSessionDetails#" output="strUserSessionDetails">
		
		<cfreturn strUserSessionDetails >
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="UpdateUserDetails" access="public" output="false" returntype="numeric" hint="Updates the user details">	
		<cfargument name="UserID" 				required="yes"  type="numeric" 	hint="UserID of user">
		<cfargument name="contactSalutationID" 	required="yes" 	type="string" 	hint="">
		<cfargument name="emailAddress" 		required="yes" 	type="string" 	hint="email address of user">
		<cfargument name="forename" 			required="yes" 	type="string" 	hint="first name of user">
		<cfargument name="surname" 				required="yes" 	type="string" 	hint="last name of user">
		<cfargument name="address1" 			required="yes" 	type="string" 	hint="address 1 of user">
		<cfargument name="address2" 			required="yes" 	type="string" 	hint="address 2 of user">
		<cfargument name="address3" 			required="yes" 	type="string" 	hint="address 3 of user">
		<cfargument name="town" 				required="yes" 	type="string" 	hint="town of address of user">
		<cfargument name="countyID" 			required="yes" 	type="numeric" 	hint="county id of address of user">
		<cfargument name="postcode" 			required="yes" 	type="string" 	hint="postcode of address of user">
		<cfargument name="countryID" 			required="yes" 	type="numeric" 	hint="country id of address of user">
		<cfargument name="telephone" 			required="yes" 	type="string" 	hint="telephone number of user">
		<cfargument name="fax" 					required="yes" 	type="string" 	hint="fax number of user">
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
		<cfargument name="UserTypeID" 			required="no" 	type="numeric" 	hint="" default="2">
		
		
		<cfscript>
			var ID = "";
			var strUserDetails = StructNew();
			
			if (NOT StructKeyExists(arguments, "ReceiveNewsletter"))
			{
				arguments.ReceiveNewsletter = 0;
			}
			
			/**
				Call function to check whether user has changed their password and send 
				confirmation email if necessary
			**/
			/*if(Len(arguments.newPassword))
			{
				changePasswordConfirmation(UserID=arguments.UserID, UserEmail=arguments.userEmail, newPassword=arguments.newPassword);//, objEmail = arguments.objEmail
			}*/
			
			ID = objDAO.UpdateUserDetails(argumentCollection=arguments);
			
			//If the user changes were saved successfully, then retrieve user's saved
			//session from their DB record and update variables inside it
			if(ID)
			{
				qryUser = objDAO.GetSavedUserSession(arguments.UserID);
				//strUserDetails = request.objBus.objUsers.loadUserSession(arguments.userid);
				if (qryUser.recordCount AND Len(trim(qryUser.SessionData)))
				{
					strUserDetails 				= objUtils.wddx('wddx2cfml', qryUser.SessionData);
					
					//UserDetails.email 		= arguments.userEmail;
					strUserDetails.address1 	= arguments.address1;
					strUserDetails.address2 	= arguments.address2;
					strUserDetails.address3 	= arguments.address3;
					strUserDetails.town 		= arguments.town;
					strUserDetails.postcode 	= arguments.postcode;
					strUserDetails.countyID 	= arguments.countyID;
					strUserDetails.countryID 	= arguments.countryID;
					strUserDetails.forename 	= arguments.forename;
					strUserDetails.surname 		= arguments.surname;
					strUserDetails.jobTitle 	= arguments.jobTitle;
					strUserDetails.companyName 	= arguments.companyName;
					strUserDetails.tel 			= arguments.telephone;
					strUserDetails.fax 			= arguments.fax;
					
					saveUserSession(strUserDetails);
				}
			}
			
			//Now also update user's session
			if (StructKeyExists(arguments.strSession, "strUser")) 
			{		
				//WriteOutput('Yes');
				//strSession.strUser.email 		= arguments.userEmail;
				strSession.strUser.address1 	= arguments.address1;
				strSession.strUser.address2 	= arguments.address2;
				strSession.strUser.address3 	= arguments.address3;
				strSession.strUser.town 		= arguments.town;
				strSession.strUser.postcode		= arguments.postcode;
				strSession.strUser.countyID 	= arguments.countyID;
				strSession.strUser.countryID 	= arguments.countryID;
				strSession.strUser.forename 	= arguments.forename;
				strSession.strUser.surname 		= arguments.surname;
				strSession.strUser.jobTitle 	= arguments.jobTitle;
				strSession.strUser.companyName 	= arguments.companyName;
				strSession.strUser.tel 			= arguments.telephone;
				strSession.strUser.fax 			= arguments.fax;
			}
			//WriteOutput('Yes');
		</cfscript>
		
		<!--- Save User's updated session --->
		<!--- <cfset saveUserSession(strUserDetails)> --->
		
		<cfreturn ID>
	
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="registerUser" access="public" output="false" returntype="boolean" 
		hint="Register the user with the system, sending out email confirmation and logs the user in if successful.  Returns FALSE if unsuccessful.">
		
		<cfargument name="UserID" 				required="no"  	type="numeric" 	hint="UserID of new user">
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
		
		<cfscript>
			var strUserSessionDetails		=	StructNew();
			var bSuccessfullRegistration	= 	false;
				
			//Set user's type. Everyone by default is a registered user
			arguments.userTypeID = 2;
			
			///generate user password
			arguments.newPassword 		= generatePassword();
			arguments.PasswordEncrypted = hash(trim(arguments.newPassword));
			
			// Attempt to register the user, passing the form attributes, email and a system generated password...
			strUserSessionDetails.userID 		= objDAO.registerUser(argumentCollection=arguments);
			
			strUserSessionDetails.username		= trim(arguments.emailAddress);
			
			// 2 = Registered User, 4 = Corporate Subscriber
			strUserSessionDetails.userTypeID	= arguments.userTypeID;
			 
			strUserSessionDetails.countryID		= arguments.countryID;
			strUserSessionDetails.articles		= "";
			strUserSessionDetails.articlesTitle	= "";
		
			// If a user id was returned, hence a successful registration...
			if ( strUserSessionDetails.userID ) 
			{
				// Send out an email confirmation and log the user in...
				variables.objEmail.sendEmailConfirmation
									(
										emailAddress		= arguments.emailAddress
										, forename 			= arguments.forename
										, surname			= arguments.surname
									  	, password			= arguments.newPassword
										, strUserDetails	= strUserSessionDetails 
									);
				loginUser(strUserSessionDetails, arguments.strSession);
			
				bSuccessfullRegistration = true;
			}
				
		</cfscript>
		
		<!--- Save User's updated session --->
		<cfset saveUserSession(strUserSessionDetails)>
		
		<cfreturn bSuccessfullRegistration>
	</cffunction>
		
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- <cffunction name="registerMaximUser" access="public" output="false" returntype="boolean" hint="Generate a password and email notification.  Returns FALSE if unsuccessful.">
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
				variables.objEmail.sendEmailConfirmation( strAttr, strUser );
				
				successfullReg = true;
			}
			
			return successfullReg;
		</cfscript>
		
	</cffunction> --->
		
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="checkUsername" access="public" output="false" returntype="numeric" hint="Check whether the supplied username/email exists">
		<cfargument name="Email" required="yes" type="string" hint="">
		
		<cfreturn objDAO.checkUsername(arguments.email)>
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
	<cffunction name="updatePassword" access="public" output="true" returntype="string" hint="Update the user's password">
		<cfargument name="newPassword"	required="yes" type="string" hint="the new password">
		<cfargument name="username" 	required="yes" type="string" hint="the username/email">
		<cfargument name="strSession" 	required="yes" type="struct" hint="the session scope">

		<cfscript>		
			bSuccess	=	false;
			userID		= 	0;
	
			// Obtain the User's ID...
			if (StructKeyExists(arguments.strSession.userDetails, "userID") And UserID NEQ 0)
				userID = arguments.strSession.userDetails.userID;
			else
				userID = getUserIDFromUsername( arguments.Username );
				
			// If a user id was found...
			if (UserID NEQ 0 AND len(UserID)) 
			{
				//Encrypt user's chosen password
				arguments.PasswordEncrypted = hash(trim(arguments.newPassword));
				
				// Save User's chosen password in encrypted format 
				bSuccess = objDAO.updatePassword(userID, arguments.PasswordEncrypted);
		
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
	<cffunction name="adminUpdatePassword" access="public" output="true" returntype="string" hint="Update the user's password">
		<cfargument name="UserID" 	    required="yes" type="numeric"hint="">
		<cfargument name="username" 	required="yes" type="string" hint="the username/email">
		
		<cfscript>
		var pw = generatePassword();
		if (UserID NEQ 0 AND len(UserID)) 
			{
				//Encrypt user's chosen password
				arguments.PasswordEncrypted = hash(trim(pw));
				
				// Save User's chosen password in encrypted format 
				bSuccess = objDAO.updatePassword(userID, arguments.PasswordEncrypted);
		
				//  Update the session details and email out the new password...
				if (bSuccess) 
					variables.objEmail.emailNewPassword( arguments.username, pw );
			}
		return pw;
		</cfscript>
			
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- <cffunction name="ChangePasswordConfirmation" access="public" returntype="void" hint="Check whether user has changed their password and send confirmation email if they have">
		<cfargument name="UserID"		type="numeric"	required="true">
		<cfargument name="UserEmail"  	type="string"	required="true">
		<cfargument name="newPassword"  type="string"	required="true">
		<!--- <cfargument name="objEmail" 	type="his_rd.library.components.utils.email" required="true"> --->
		
		<cfset var qryUserLogin = objDAO.CheckLogin(arguments.UserEmail)>
		<cfset var from = request.strConfig.strVars.mailsender>
		<cfset var bcc	= "">
		<cfset var subject = "LocalGov.co.uk: New Password">		
			
		<cfsavecontent variable="passwordConfirmation">
			<cfinclude template="#application.strConfig.strPaths.includepath#/fusebox/circuits/user/view/inc_passwordConfirmation_email.cfm">
		</cfsavecontent>
		
		<cfset objEmail.send(arguments.UserEmail,passwordConfirmation,subject,from,bcc)>

	</cffunction> --->
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="updateUsername" access="public" output="true" returntype="string" hint="Update the user's username">
		<cfargument name="newUsername" 		required="yes" type="string" hint="the new password">
		<cfargument name="currentUsername" 	required="yes" type="string" hint="the username/email">
		<cfargument name="strSession" 		required="yes" type="struct" hint="the session scope">

		<cfscript>		
			var bSuccess	= 	false;
			var UserID		= 	0;
							
			// Obtain the User's ID...
			if (StructKeyExists(arguments.strSession.UserDetails, "UserID"))
				UserID = arguments.strSession.UserDetails.UserID;
			else
				UserID = getUserIDFromUsername(trim(arguments.CurrentUsername));
			
			// If a user id was found...
			if (UserID NEQ 0 AND UserID NEQ "") 
			{
				//Check whether new username already exists
				userExists = checkUsername(trim(arguments.NewUsername) );
				
				// Attempt to update the user's password....
				if (userExists EQ 0)
					bSuccess = objDAO.updateUsername(UserID, trim(arguments.NewUsername));
		
				//  Update the session details and email out the new password...
				if (bSuccess) 
				{
					arguments.strSession.UserDetails.Username = NewUsername;
					variables.objEmail.emailNewUsername(arguments.NewUsername );
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
		case 0: { userTypeID = 2; break;}
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
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="CheckLogin" access="public" output="false" returntype="struct" hint="Retrieve password matching matching username entered and compare to password entered by user">
		<cfargument name="strSession"	required="yes" type="struct">
		<cfargument name="Username" 	required="yes" type="string">
		<cfargument name="Password" 	required="yes" type="string">
		
		<cfscript>
			var qryUserLogin = objDAO.CheckLogin(arguments.username);
			var strLoginDetails	= StructNew();
			 
			if (qryUserLogin.recordCount)
			{
				//WriteOutput('xx#trim(arguments.password)#xx = xx#Decrypt(qryUserLogin.Password, variables.strConfig.strVars.Encrypt_key)#xx');
				if (hash(trim(arguments.password)) EQ qryUserLogin.Password)
				{
					//WriteOutput('#arguments.password# = #Decrypt(qryUserLogin.Password, variables.strConfig.strVars.Encrypt_key)#');
					arguments.UserID = qryUserLogin.UserID;
					strLoginDetails = ValidateLogin(argumentCollection=arguments);
					//status = ValidateLogin(argumentCollection=arguments);
				}
				else
				{
					strLoginDetails.status = "invalid";
					strLoginDetails.alreadyLoggedIn	= false;
				}
			}
			
			else
			{
				strLoginDetails.status = "invalid";
				strLoginDetails.alreadyLoggedIn	= false;
			}
			
			//return status;
			return strLoginDetails;
		</cfscript>
		
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="validateLogin" access="public" output="false" returntype="struct" hint="Validate login">
	  	<cfargument name="strSession"	required="yes" 	type="struct">
		<cfargument name="UserID" 		required="yes" 	type="numeric">
		
		<cfscript>
			var status 			= "invalid";
			var strLoginDetails	= StructNew();
		
			//Validate user login
			qryLogin =  objDAO.ValidateLogin(arguments.UserID);
			
			strLoginDetails.alreadyLoggedIn	= false;
		
			//1. If Login has been validated
			if (qryLogin.recordCount)
			{
				/*if (NOT isConcurrent(qryLogin.UserID)) 
				{*/
					//Lower the relevant flag
					strLoginDetails.alreadyLoggedIn = false;
					
					if (Len(qryLogin.SessionData))	
						//Attempt to Login the user...	
						loginUser(wddx2cfml(qryLogin.SessionData), arguments.strSession);
					else
					{
						strUserSessionDetails.userid=qryLogin.UserID;
						loginUser(strUserSessionDetails, arguments.strSession );
					}
				/*}
				//Already logged in...
				else 
				{
					// 2.2.1 Raise the relevant flag
					strLoginDetails.alreadyLoggedIn = true;
				}	*/	
				status = "valid";
			}
		</cfscript>
		
		<!--- 
			If the user has been successfully logged in, set their access levels into their session
		--->
		<cfif status EQ "valid">
			<cfset request.objBus.objAccess.setAccess(strSession=session, UserID=arguments.UserID)>
		</cfif>
		
		<cfset strLoginDetails.status = status>
			
		<cfreturn strLoginDetails>
		
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- <cffunction name="SetLogin" access="public" output="false" returntype="void" hint="set up login structure">
		<cfargument name="strSession"		required="yes" type="struct">
		<cfargument name="qrylogin" 		required="yes" type="query" >
		
		<cfscript>
			if (NOT Len(qrylogin.sessionData))
				//set up session structure
				arguments.strSession.strUser = variables.objUtils.queryRowToStruct(qryLogin);
		
			else	
				arguments.strSession.strUser =  variables.objUtils.wddx('wddx2cfml', arguments.qryLogin.sessionData);
		
			//Setup other variables in user structure
			arguments.strSession.strUser.Isloggedin = true;
			arguments.strSession.strUser.Username = qryLogin.Username;
			arguments.strSession.strUser.Password = Decrypt(qryLogin.Password, variables.strConfig.strVars.encrypt_key);
			
		</cfscript>
		
	</cffunction> --->
		
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
			structDelete(arguments.strSession, "strAccess");	
			structDelete(arguments.strSession, "strSubscribe");		
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
			
		<cfset objEmail.sendEmailConfirmation( strAttr, strUserDetails )>
		
	</cffunction>
			
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- PRIVATE Functions -------------------------------------------------------------------------------->
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
	<cffunction name="loginUser" access="private" output="false" returntype="void" hint="Log the user in by populating the session.UserDetails structure">
	  	<cfargument name="strUserDetails" 	required="yes" type="struct" hint="str of user details">
		<cfargument name="strSession" 		required="yes" type="struct" hint="str of the session scope">
		
		<cfset var qryUser = ''>
		
		<cflock scope="session" type="exclusive" timeout="1">
			<cfscript>	
				// Simulate a login --->
				arguments.strSession.userDetails				= 	arguments.strUserDetails;
				arguments.strSession.redirect					= 	false; // used in app.cfc as a safe gaurd
				
				// Get the user type id from the user id and added it to the session structure... 
				arguments.strSession.userDetails.userTypeID		= 	objDAO.getUserTypeID(arguments.strSession.userDetails.userID );
				arguments.strSession.userDetails.lstSectorIDs	= 	objDAO.getUserSectorIDs(arguments.strSession.userDetails.userID );
				
				qryUser = objDAO.getUserDetailsByID(arguments.strSession.userDetails.userID );
				
				arguments.strSession.userDetails.forename		= 	qryUser.forename;
				arguments.strSession.userDetails.surname		= 	qryUser.surname;
				arguments.strSession.userDetails.fullName		= 	qryUser.fullName;
				arguments.strSession.userDetails.company		= 	qryUser.companyName;
				arguments.strSession.userDetails.jobtitle		= 	qryUser.jobtitle;
				arguments.strSession.userDetails.address1		= 	qryUser.address1;
				arguments.strSession.userDetails.address2		= 	qryUser.address2;
				arguments.strSession.userDetails.address3		= 	qryUser.address3;
				arguments.strSession.userDetails.postcode		= 	qryUser.postcode;
				arguments.strSession.userDetails.tel			= 	qryUser.tel;
				arguments.strSession.userDetails.fax			= 	qryUser.fax;
				arguments.strSession.userDetails.county			= 	qryUser.county;
				arguments.strSession.userDetails.username		= 	qryUser.username;
				arguments.strSession.userDetails.countryid		= 	qryUser.CountryID;
				arguments.strSession.userDetails.salutation		= 	qryUser.salutation;
				// New check to try and prevent session swapping
				arguments.strSession.userDetails.loginIP		= 	CGI.REMOTE_ADDR;
			</cfscript>
		</cflock>
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
				if (arguments.accesstype eq 3 AND arguments.StrSession.UserDetails.usertypeid lt 3) 
				{
					strReturn.IsAllowed = false;
					strReturn.sReason 	= "NotSubs"; 
				}
				
				//accces type of Corporate Admin: users must be logged in and have usertype of at least Corporate Subscriber Administrator
				else if (arguments.accesstype eq 5 and arguments.StrSession.UserDetails.usertypeid neq 5) 
				{
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
		<!--- <cfargument name="UserStatusID"  type="numeric"  required="no" default="0">
		<cfargument name="OrderStatusID" type="numeric"  required="no" default="0"> --->
		<cfargument name="Surname" 		 type="string"  required="no" default="">
		<cfargument name="Email"   		 type="string"  required="no" default="">
		<cfargument name="PostCode"   	 type="string"  required="no" default="">
		<cfargument name="DateStart"     type="string"    required="no" default="">
		<cfargument name="DateEnd"   	 type="string"    required="no" default="">
		<cfargument name="Company" 		 type="string"  required="no" default="">
		<cfargument name="IsSO" 	 	type="numeric"  required="no" default="0">
      <!---   <cfargument name="jobtitle" 	 type="string"  required="no" default="">--->
	 	<cfargument name="jobfunctionID"  type="numeric"  required="no" default="0">
         <cfargument name="BudgetID" 	 type="numeric"  required="no" default="0">
         <cfargument name="OrgTypeID" 	 type="numeric"  required="no" default="0">
         <cfargument name="sectorid" 	 type="string"  required="no" default="">
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
		var strPacket = request.objBus.objUser.loadUserSession(arguments.userid);
		
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
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetUserSearchLookups" access="public" output="false" returntype="struct" hint="returns data to populate select menus on user search page">
		<cfreturn objDAO.GetUserSearchLookups()>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="articleLog" access="public" output="false" returntype="void" hint="log the id of article stored for this user">
		<cfargument name="strSession" 			required="yes" type="struct" 	hint="session structure">
		<cfargument name="articleid" 			required="yes" type="numeric" 	hint="article id">
		<cfargument name="IpAddress" 			required="yes" type="string" 	hint="">
			
			<cfscript>
			var userid = 0;
			if (LoggedIn(arguments.StrSession)){
				userid=StrSession.userdetails.Userid;
			}
					objDAO.articleLog(userid, arguments.articleid, arguments.IpAddress);
			
			</cfscript>
		
	</cffunction>
    
    <!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
     <cffunction name="RequestLog" access="public" output="false" returntype="void" hint="log the request of a user">
		<cfargument name="StrSession" 			required="yes" type="struct" 	hint="session">
		<cfargument name="cgi_scope" 			required="yes" type="struct" 	hint="cgi scope">

			<cfscript>
			var userid = 0;
			if (LoggedIn(arguments.StrSession)){
				userid=StrSession.userdetails.Userid;
				if (arguments.strSession.userdetails.usertypeid gt 2)
					objDAO.RequestLog(userid, arguments.cgi_scope.PATH_INFO & "?" & arguments.cgi_scope.query_string);
			}
						 
		</cfscript>
	</cffunction>
    
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getUsersByArticle" access="public" output="false" returntype="query" hint="get all users for a particular article">
		<cfargument name="articleid" 			required="yes" type="numeric" 	hint="article id">
		<cfreturn objDAO.getUsersByArticle(arguments.articleid)>
	</cffunction>
</cfcomponent>