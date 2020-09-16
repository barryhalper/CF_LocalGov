<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/BusinessObjects/Subscriptions.cfc $
	$Author: Bhalper $
	$Revision: 18 $
	$Date: 10/08/09 17:00 $

--->

<cfcomponent displayname="Subscriptions" hint="<component description here>" extends="his_Localgov_Extends.components.BusinessObjectsManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Subscriptions" hint="Pseudo-constructor">

		<cfargument name="objAppObjs" type="any" required="yes" hint="The application manager object">
		<cfargument name="objBusObjs" type="any" required="yes" hint="The business objects">
		
		<cfscript>
		// Call the generic init function, placing business, app, and dao objects into a local scope...
		structAppend( variables, super.initChild( arguments.objAppObjs, this, arguments.objBusObjs ) );
		
		return this;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions ------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getOrders" access="public" output="true" returntype="query" >	
		<cfreturn objDAO.getOrders()>
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="generateAccessCodes" access="public" output="true" returntype="void" 
		hint="Generates the access codes for corporate subscriptions">
		<cfargument name="NoOfCodes" type="numeric" required="no" default="2000">
		
		<cfscript>
		var qryAccessCodes = objDAO.getAllAccessCodes();
		var AccessCode = "";
		var i = 0;
		var j = 0;
		var k = 0;
		///todo: place this into display fn
		writeOutput("<h2>Generating Access Codes</h2><font style='font-size:12px; font-family=Courier New'");
		
		while (qryAccessCodes.recordCount LT arguments.NoOfCodes) {
		
			AccessCode = objString.createRandomString();
			
			if (qryAccessCodes.recordCount) {
				for (k=1; k LTE qryAccessCodes.recordCount; k=k+1) {
					if (qryAccessCodes.p_accesscode_id NEQ AccessCode) {
					
						objDAO.commitCreatedAccessCode( AccessCode );
						
						writeOutput(AccessCode & "<br /><script>window.scrollBy(0,100);</script>");
						objUtils.flush();
						break;
					}
				}
			} else {
				objDAO.commitCreatedAccessCode( AccessCode );
				
				writeOutput("<strong>#AccessCode#</strong><br />");
				objUtils.flush();
			}
		
			qryAccessCodes = objDAO.getAllAccessCodes();
			
		}
		if (qryAccessCodes.recordCount gt arguments.NoOfCodes)
			writeOutput("<br />There are already over #arguments.NoOfCodes# access codes");
			
		writeOutput("</font><br /><h2>AccessCodes generated.</h2><script>window.scrollBy(0,100);</script>");
		objUtils.flush();
		</cfscript>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getCorpUserDetailsByID" access="public" output="false" returntype="query" 
		hint="returns a query of specified corporate user details">
		
		<cfargument name="id" type="numeric" required="yes">
		
		<cfreturn objDAO.getCorpUserDetailsByID( arguments.id )>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getAllAccessCodes" access="public" output="false" returntype="query" 
		hint="Returns all access codes">
		<cfreturn objDAO.getAllAccessCodes()>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getProducts" access="public" output="false" returntype="query" hint="Returns a recordset with all the subscriptions">
		
		<cfscript>
			//call and return dao method
			return objDAO.getProducts();
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getProductsWithCCode" access="public" output="false" returntype="query" hint="Returns a recordset with all the subscriptions">
		<cfargument name="CCode" type="string" required="no" default="DM1000">
		
		<cfscript>
			//call and return dao method
			return objDAO.getProductsWithCCode(CCode= arguments.CCode);
		</cfscript>
		
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getMaximSubscriptions" access="public" output="false" returntype="query" 
		hint="Gets subscriptions that were initiated through Maxim">

		<cfreturn objDAO.getMaximSubscriptions()>
				
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="commitOrder" output="false" returntype="struct" 
			hint="Commits subscription order (single/corporate) taken by either online OR direct mail/telephone/e-mail">
		
		<cfargument name="strAttr" 		type="struct" required="yes">
		<cfargument name="strSession" 	type="struct" required="yes">
				
		<cfscript>
		var strRtn=			StructNew();
		var bCommitOrder= 	true;
		var StatusCode= 	'';
		var userID= 		0;
		
		//SET UP OFRDER STRUCTURE AND POPULATE	
		if (not StructKeyExists( arguments.strSession.UserDetails, "Order" ))
			arguments.strSession.UserDetails.Order = StructNew();

		if (StructKeyExists(arguments.strSession.UserDetails.Order, "StatusID"))
			if (arguments.strSession.UserDetails.Order.StatusID eq 1)
				variables.bCommitOrder = false;			
		
		/* Set the subscription status code according to the payment method (rules laid out my DBA: MC)... 
		switch (arguments.strAttr.payment_method) {
			case 1:  variables.StatusCode = 'A'; break;  // ...1=credit card, therefore A for Active
			default: variables.StatusCode = 'O'; break; // ...default to O for order
		} */
		
		
		// Status code set to Active immediately if paying by Invoice - at the request of the business September 2006!
		if (arguments.strAttr.payment_method eq 2)
			variables.statusCode = 'A';
		else
			variables.statusCode = 'O';
				
		if (bCommitOrder) {
			// If the user placing the order is not the admin user, get the corp admin user id from the username and if exists, update the user details and subscription.
			if (arguments.strAttr.ADMIN_USER EQ 0)
			userID = variables.objUser.getUserIDFromUsername( arguments.strAttr.CORP_EMAIL );
			// If a user id was found...
			if ( not (userID eq 0 or userID eq "") )
				userIDToInsert = userID;
			else
				userIDToInsert = arguments.strSession.userDetails.userID;
			//call commit fn	
			strRtn = objDAO.commitOrder( 
									userID=						userIDToInsert,
									productID= 					arguments.strAttr.productID,	
									quantity= 					arguments.strAttr.quantity,
									totalAllowableSubscribers= 	arguments.strAttr.totalAllowableSubscribers,
									orderLineStatus=			1,
									paymentMethod=				arguments.strAttr.payment_method,
									statusCode=					variables.statusCode
								);
			//reset var in session scope (as ref)					
			arguments.strSession.userDetails.order.statusID=		1;
			arguments.strSession.userDetails.order.subscriptionID=	strRtn.subscriptionID;
			
			arguments.strAttr.subject = "New Subscription Order";
			//variables.objEmail.sendEmailToSubsDept("Subscription", arguments.strAttr, arguments.strSession );

		} else {
			strRtn.subscriptionID = arguments.strSession.userDetails.order.subscriptionID;
		}
		
		// If this is a Corporate Subscription, commit and get the AccessCode / key...
		if (arguments.strAttr.ProductID eq 2){
				strRtn.accessCode = objDAO.commitAccessCode( subscriptionID = strRtn.subscriptionID );
				//email access code to user
				//objEmail.sendHemmingAccessCode( strRtn.subscriptionID, )
				//objutils.dumpabort(arguments);
				objEmail.SendCorporateAccessCode(arguments.strSession.userDetails.username, strRtn.accessCode,  arguments.strSession.userDetails.fullname );
				
			}
		else
			strRtn.accessCode = '';

		arguments.strSession.userDetails.order.accessCode= strRtn.accessCode;
		
		return strRtn;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="commitTopUpOrder" output="false" returntype="struct" 
			hint="Updates subscription order (corporate), updating the subscription and inserting a new order.">
		
		<cfargument name="strAttr" 		type="struct" required="yes">
		<cfargument name="strSession" 	type="struct" required="yes">
				
		<cfscript>
		var strRtn=			StructNew();
		var bCommitOrder= 	true;
		var StatusCode= 	'';
		
		//SET UP OFRDER STRUCTURE AND POPULATE		
		if (not StructKeyExists( Arguments.strSession.UserDetails, "Order" ))
			Arguments.strSession.UserDetails.Order = StructNew();

		if (StructKeyExists(Arguments.strSession.UserDetails.Order, "StatusID"))
			if (arguments.strSession.UserDetails.Order.StatusID eq 1)
				variables.bCommitOrder = false;			
		
		variables.StatusCode = 'O';
				
		if (bCommitOrder) {
			strRtn = objDAO.CommitTopUpOrder( 
											UserID=								arguments.strSession.userDetails.userID,
											ProductID= 							arguments.strAttr.ProductID,	
											Quantity= 							arguments.strAttr.Quantity,
											GrandTotal_AllowableSubscribers=	arguments.strAttr.GrandTotal_AllowableSubscribers,
											OrderLineStatus=					2,
											PaymentMethod=						arguments.strAttr.payment_method,
											CorpSubscriptionID=					arguments.strAttr.hid_CorpSubscriptionID
										);
			Arguments.strSession.UserDetails.Order.StatusID=			1;
			Arguments.strSession.UserDetails.Order.SubscriptionID=	strRtn.SubscriptionID;
			Arguments.strAttr.Subject = "Top Up Ordered";
			//variables.objEmail.sendEmailToSubsDept("Top Up", Arguments.strAttr, Arguments.strSession );

		} else {
			strRtn.SubscriptionID = arguments.strSession.UserDetails.Order.SubscriptionID;
		}
		
		return strRtn;
		</cfscript>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="commitResubscriptionOrder" output="false" returntype="struct" 
			hint="Updates subscription order (corporate), updating the subscription and inserting a new order.">
		
		<cfargument name="strAttr" 		type="struct" required="yes">
		<cfargument name="strSession" 	type="struct" required="yes">
				
		<cfscript>
		var strRtn=			StructNew();
		var bCommitOrder= 	true;
		var StatusCode= 	'';
		var userID= 		0;
		//SET UP OFRDER STRUCTURE AND POPULATE		
		if (not StructKeyExists( Arguments.strSession.UserDetails, "Order" ))
			Arguments.strSession.UserDetails.Order = StructNew();

		if (StructKeyExists(Arguments.strSession.UserDetails.Order, "StatusID"))
			if (arguments.strSession.UserDetails.Order.StatusID eq 1)
				variables.bCommitOrder = false;			
		
		variables.StatusCode = 'O';
				
		if (bCommitOrder) {
			// If the user placing the order is not the admin user, get the corp admin user id from the username and if exists, update the user details and subscription.
			if (arguments.strAttr.ADMIN_USER EQ 0)
			userID = variables.objUser.getUserIDFromUsername( arguments.strAttr.CORP_EMAIL );
			// If a user id was found...
			if ( not (userID eq 0 or userID eq "") )
				userIDToInsert = userID;
			else
				userIDToInsert = arguments.strSession.userDetails.userID;
				
			strRtn = objDAO.CommitResubscriptionOrder( 
											UserID=						userIDToInsert,
											ProductID= 					arguments.strAttr.ProductID,	
											Quantity= 					arguments.strAttr.Quantity,
											OrderLineStatus=			2,
											PaymentMethod=				arguments.strAttr.payment_method,
											CorpSubscriptionID=			arguments.strAttr.hid_CorpReSubscriptionID,
											CorpSubEndDate=				arguments.strAttr.NewCorpSubEndDate
										);
			Arguments.strSession.UserDetails.Order.StatusID=			1;
			Arguments.strSession.UserDetails.Order.SubscriptionID=	strRtn.SubscriptionID;
			strRtn.SubsRenewal = 1;
			//variables.objEmail.sendEmailToSubsDept("Subscription Renewal", Arguments.strAttr, Arguments.strSession );

		} else {
			strRtn.SubscriptionID = arguments.strSession.UserDetails.Order.SubscriptionID;
		}
		
		return strRtn;
		</cfscript>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getAllSubsTopUps" access="public" output="false" returntype="query" 
		hint="Returns all the top-ups ordered by the corporate admin">
		
		<cfargument name="CorpSubscriptionID" type="numeric" required="yes">
		
		<cfreturn objDAO.getAllSubsTopUps( arguments.CorpSubscriptionID )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="updateTrialUsersEndDate" access="public" output="false" returntype="boolean" 
		hint="Updates the corp trial users end date">
		
		<cfargument name="TrialSubEndDate" 	required="yes" type="date">
		<cfargument name="UserID" 			required="yes" type="numeric">

		<cfreturn objDAO.UpdateTrialUsersEndDate( arguments.TrialSubEndDate, arguments.UserID )>
			
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getSubFromAccessCode" access="public" output="false" returntype="query" 
		hint="Checks if the access code entered is valid">
		
		<cfargument name="AccessCode" required="yes" type="string" hint="">
		
		<cfreturn objDAO.getSubFromAccessCode( arguments.AccessCode )>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- <cffunction name="GetSubscriptionID" access="public" output="false" returntype="numeric" 
		hint="returns the subscription id">
		
		<cfargument name="AccessCode" required="yes" type="string" hint="">
		
		<cfreturn objDAO.GetSubscriptionID( arguments.AccessCode )>
		
	</cffunction> --->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="commitCorporateSubscriber" access="public" output="false" returntype="void" 
		hint="Commits the Subscription ID and User ID in the Subscriber table. This function only ever gets called if the subscriber has left and is being replaced.">
		<cfargument name="UserID" 	type="numeric" required="yes">
		<cfargument name="SubID" 	type="numeric" required="yes">
		
		<cfscript>
		objDAO.commitCorporateSubscriber( arguments.UserID, arguments.SubID );
		</cfscript>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="subscribe_RegisteredUser" access="public" output="false" returntype="void" hint="Adds the user to the corporate subscription. This function only ever gets called when a logged in registered user enters the accesscode. This method is called inside the Subscribe_RegisteredUser fuseaction.">
		
		<cfargument name="strAttr" 		type="struct" required="yes">
		<cfargument name="strSession" 	type="struct" required="yes">
		
		<cfscript>
		var strCorpAdmin = "";
		var subscriptionQuery="";
		
		//check that access code is present
		if (Len(arguments.strAttr.ACCESSCODE)){
			strCorpAdmin = StructNew();
			subscriptionQuery = getSubFromAccessCode( Arguments.strAttr.ACCESSCODE );
			// Insert the userid and subscription id in the localgov_subscriber table.
			variables.objUser.updateUserType( Arguments.strSession.userdetails.UserID, subscriptionQuery.ProductID, session, 0 );
			//db committ
			commitCorporateSubscriber( Arguments.strSession.userdetails.UserID, subscriptionQuery.p_subscription_id );
			//update key sin sctruc to pass into email object
			StructInsert( Arguments.strAttr, "CorpUserName", subscriptionQuery.USERNAME );
			StructInsert( strCorpAdmin, "UserName", Arguments.strSession.userdetails.USERNAME );
			if ( subscriptionQuery.email_notification )
				//send email
				variables.objEmail.sendEmailToCorpAdmin("subscribed", Arguments.strAttr, strCorpAdmin );
		}
		</cfscript>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="updateOrderStatus" output="false" returntype="boolean" hint="">
		
		<cfargument name="SubscriptionID" 	type="numeric" required="yes">
		<cfargument name="StatusID" 		type="numeric" required="yes">
		<cfargument name="strSession"		type="struct" required="yes">
		
		<cfscript>
		//call and return dao method
		var bSuccess = false;
		
		bSuccess = objDAO.updateOrderStatus( arguments.SubscriptionID, arguments.StatusID );
		
		arguments.strSession.UserDetails.Order.StatusID = arguments.StatusID;
		
		return bSuccess;
		</cfscript>
	
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="updateSubscriptionStatus" output="false" returntype="boolean" hint="">
		
		<cfargument name="SubscriptionID" 	type="numeric" required="yes">
		<cfargument name="StatusCode" 		type="string" required="yes">
	
		<cfreturn objDAO.updateSubscriptionStatus( arguments.SubscriptionID, arguments.StatusCode )>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="updateSubscriptionDates" output="false" returntype="boolean" hint="">
		
		<cfargument name="SubscriptionID" 	type="numeric" required="yes">
		
		<cfreturn objDAO.updateSubscriptionDates( arguments.SubscriptionID )>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="generateSteps" output="true" returntype="string" 
		hint="Generates the step-by-step banner for the registration and subscription pages.">
		
		<!--- todo: is this now redundant?? --->
		<cfargument name="lstSteps" 	type="string" required="yes">
		<cfargument name="nCurrentStep" type="numeric" required="yes">

		<cfscript>
		// todo: rationalise and possibly move to dsp??

		var steps=			"";
		var l=				arguments.lstSteps;	
		var c=				arguments.nCurrentStep; 
		var scrollLeft=		"<input type=button class=smtext onmousedown=""scrollSteps('stepTable', 'left');"" value=""<"" >";
		var scrollRight= 	"<input type=button class=smtext onmousedown=""scrollSteps('stepTable', 'right');"" value="">"">";
		var tick= 			"<img src=""#request.sImgPath#tick.gif"" width=13 height=13>";
		var arrow= 			"<img src=""#request.sImgPath#forward.gif"" width=4 height=8>";
		var arrowBold= 		"<img src=""#request.sImgPath#forward_bold.gif"" width=4 height=8>";
		
		left = evaluate( -(c*100) );
		left = evaluate(left + 100);
				
		steps=steps&'<div align=center style="width: 660px; height: 21px; overflow:hidden; border: 1px solid ##dec687; background-color:##EEEEEE">';
		steps=steps&'<table onmousdown="this.left=''500px;''" id=stepTable style="position:relative; left:#left#px;" align="center" width="1200" class="text"><tr><td>';
		
		for (i=1; i LTE ListLen(l); i=i+1) {
			if (i eq c)	steps=steps&'<strong>';
			if (i lt c)
				steps = steps & ListGetAt(l, i) & ' ' & tick & '&nbsp;';
			else
				steps = steps & ListGetAt(l, i) & '&nbsp;';
			if (i eq c)	steps=steps&'</strong>';
			if (i neq ListLen(l))
				if (i eq c-1)
					steps = steps & ' #arrowBold# ';
				else
					steps = steps & ' #arrow# ';
		}
		
		steps=steps&"</td></tr></table>";
		steps=steps&"</div>";
		steps=steps&scrollLeft&scrollRight;
		return steps;
		</cfscript>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetCorrespondence" access="public" output="false" returntype="query" hint="">
		<cfreturn objDAO.GetCorrespondence()>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="CommittCorrespondence" output="false" returntype="boolean" hint="">
		
		<cfargument name="correspondenceid" 	type="numeric" 	required="yes">
		<cfargument name="sentDate" 			type="date" 	required="yes">
	
		<cfreturn objDAO.CommittCorrespondence(arguments.correspondenceid, arguments.sentDate)>
		
		<cfreturn true>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetPageLookups" access="public" output="false" returntype="struct" hint="get all data required for subscription form">
		<cfargument name="strSession" type="struct" required="yes">
			
		<cfscript>
			var strLookUps 					= StructNew();
			
			strLookUps.qryProducts 			= getProducts(); //Get query of available products
			strLookUps.strSelects 			= objUser.getRegistrationSelects(); //Get registeration Selects data
			
			//get info about default campaign code
			strLookUps.qryDefaultCampaignCode = request.objBus.objOrders.GetCampaignInfo(CampaignID=0,DefaultCode=1);
			
			//If user is logged in, get user's details
			if (StructKeyExists(arguments.strSession.userDetails, 'userID'))
			{
				strLookUps.qryUserDetails = objUser.getUserDetailsByID(arguments.strSession.userDetails.UserID);
			}
					
			return 	strLookUps;
		</cfscript>
		
		
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- NEW Functions --------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetRenewedSubscription" output="false" returntype="Query" access="public" hint="Get any renewed subscription periods for specified subscription">
		<cfargument name="SubscriptionID" 	type="numeric" required="true">
		<cfargument name="UserID" 			type="numeric" required="true">
		
		<cfreturn objDAO.GetRenewedSubscription(argumentCollection=arguments)>

	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="CommitAccessCode" access="public" output="false" returntype="string" hint="Get/Commit Access Code for Corporate Subscription">
		<cfargument name="SubscriptionID" type="numeric" required="true">
		
		<cfreturn objDAO.CommitAccessCode(arguments.SubscriptionID)>
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="CheckAccessCode" access="public" output="false" returntype="query" hint="Checks if the access code entered is valid">
		<cfargument name="AccessCode" required="yes" type="string" hint="">
		
		<cfreturn objDAO.CheckAccessCode(arguments.AccessCode)>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="AddCorporateSubscriber" access="public" output="false" returntype="void" hint="Commits the Subscription ID and User ID in the Subscriber table">
		<cfargument name="UserID" 			type="numeric" 	required="yes">
		<cfargument name="SubscriptionID" 	type="numeric" 	required="yes">
		<cfargument name="strSession" 		type="struct" 	required="yes">
		
		<cfscript>
			//Add User to Corporate Subscription in database
			objDAO.AddCorporateSubscriber(argumentCollection=arguments);
			
			//Update Users Usertype in their session
			arguments.strSession.userDetails.userTypeID=4;
			
			//3. Update user access after processing of order
			request.objBus.objAccess.setAccess(arguments.strSession, arguments.UserID);
			
			//Email Corporate admin
			//request.objBus.objEmail.sendEmailToCorpAdmin('Subscribed', attributes, session.userdetails );
		</cfscript>
	
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="getSubSearchLookups" output="false" returntype="struct" access="public" hint="Return data for lookups needed for subscription search/modification forms">
		<cfreturn objDAO.getSubSearchLookups()>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="getHemmingProducts" output="false" returntype="query" access="public" hint="Return data for various hemmimg products to which one may subscribe">
		<cfreturn objDAO.getHemmingProducts()>		
	</cffunction>
</cfcomponent>