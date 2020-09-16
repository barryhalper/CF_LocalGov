<!--- 
	
	$Archive: /localgov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/BusinessObjects/Email.cfc $
	$Author: Ohilton $
	$Revision: 41 $
	$Date: 16/04/10 17:10 $

--->

<cfcomponent displayname="Email" hint="Send out email" extends="his_Localgov_Extends.components.BusinessObjectsManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Email" hint="Pseudo-constructor">

		<cfargument name="objAppObjs" type="any" required="yes" hint="The application manager object">
		<cfargument name="objBusObjs" type="any" required="yes" hint="The application manager object">
		
		<cfscript>
		// Call the genric init function, placing business, app, and dao objects into a local scope...
		StructAppend( variables, Super.initChild( arguments.objAppObjs, this, arguments.objBusObjs, false ) );
		//get header for emails
		variables.header = variables.objUtils.GetContentFromInclude(variables.strConfig.strPaths.includepath & variables.strConfig.strPaths.emailpath & "dsp_header.cfm");
		//get footer for emails
		variables.footer = variables.objUtils.GetContentFromInclude(variables.strConfig.strPaths.includepath & variables.strConfig.strPaths.emailpath & "dsp_footer.cfm");
		//set link path (mimics fbx var 'request.myself')
		
		variables.myself = variables.strConfig.strPaths.sitepath & "index.cfm?method=";
		return this;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions ------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getVariables" access="public" output="false" returntype="struct" hint="return local scope to caller">
		<cfreturn variables>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction  name="sendAccountsCSV" access="public" output="false"  returntype="boolean"
		hint="">
		
		<cfset var fileName = 'LG-' & dateformat(now(), 'ddmmyyyy') & '.csv'>
		
		<cfif fileExists( variables.strConfig.strPaths.accountsDir & fileName ) >
					
			<cfreturn send( to=			variables.strConfig.strVars.accounts, 
							body=		getCopy( 43043 ), 
							subject=	variables.strConfig.strVars.title & ": Daily CSV - " & fileName,
							attachment=	variables.strConfig.strPaths.accountsDir & fileName ) >	
		<cfelse>

			<cfreturn send( to=			variables.strConfig.strVars.accounts, 
							body=		'No CSV file has been generated today.', 
							subject=	variables.strConfig.strVars.title & ": Daily CSV - " & fileName) >	
		
		</cfif>

	</cffunction>		
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction  name="emailInvoice" access="public" output="false"  returntype="boolean"
		hint="">
		
		<cfargument name="invoiceID"		required="no" 	type="numeric"	hint="">
		<cfargument name="invoiceFilename" 	required="yes" 	type="string"	hint="">
		<cfargument name="invoiceDir" 		required="yes"	type="string">
		<cfargument name="email" 			required="yes"	type="string">
		<cfargument name="templateCopy" 	required="no"	type="string" default="">
		<cfargument name="subject" 			required="no"	type="string" default="#variables.strConfig.strVars.title#: Invoice - #arguments.email#">
		
		<cfscript>
		var copy = "";
		if (Len(arguments.templateCopy))
			copy=arguments.templateCopy;
		else
			copy  = getCopy( 43044 );
		
		return send( 	to=			arguments.email, 
						bcc=		trim(variables.strConfig.strVars.accounts),
						body=		copy, 
						subject=	arguments.subject,
						attachment=	arguments.invoiceDir & arguments.invoiceFilename );
		</cfscript>
		
		

	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction  name="emailCSV" access="public" output="false"  returntype="boolean"
		hint="">
		
		<cfargument name="invoiceID"	required="yes" 	type="numeric"	hint="">
		<cfargument name="csvFilename" 	required="yes" 	type="string"	hint="">
		<cfargument name="csvDir"		required="yes"	type="string">
		
		<cfreturn send( to=			variables.strConfig.strVars.accounts, 
						body=		getCopy( 43043 ), 
						subject=	variables.strConfig.strVars.title & ": CSV - InvoiceID " & arguments.invoiceID,
						attachment=	arguments.csvDir & arguments.csvFilename ) >
					
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions ------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->
	 <cffunction name="emailNewPassword" access="public" output="false" returntype="boolean" 
		hint="Email the new password to the supplied email address">
		
		<cfargument name="email" 		required="yes" type="string" hint="">
	  	<cfargument name="newPassword" 	required="yes" type="string" hint="">
		
		<cfscript>
		var bl = false;
		//get copy from db
		var copy = getCopy(42598);
		//replace vars with data
		copy = replace(copy, "|NewPassword|", trim(arguments.NewPassword), "all");
		copy = replace(copy, "|Sitepath|", trim(variables.strConfig.strPaths.sitepath), "all");
		//send email
		if (send(arguments.Email, copy, "#variables.strConfig.strVars.title#: New Password"))
			bl = true;
		return 	bl;
		</cfscript>
		
		</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="sendEmailConfirmation" access="public" output="false" returntype="boolean" hint="Email the registration details">
		<cfargument name="emailAddress" 		required="yes" 	type="string" 	hint="email address of new user">
		<cfargument name="forename" 			required="yes" 	type="string" 	hint="first name of new user">
		<cfargument name="surname" 				required="yes" 	type="string" 	hint="last name of new user">
	  	<cfargument name="password" 			required="yes" 	type="string" 	hint="new user password">
	  	<!--- <cfargument name="strAttr" 			required="yes" type="struct" hint="qry of attribute data"> --->
	  	<cfargument name="strUserDetails" 		required="yes" type="struct" hint="str of user details">

		<cfscript>
			//Get email copy
			var copy= getCopy(42609);
			
			copy= replacenocase(copy, "|forename|", trim(arguments.forename), "all");
			copy= replacenocase(copy, "|surname|", 	trim(arguments.surname), "all");
			copy= replacenocase(copy, "|title|", 	trim(variables.strConfig.strVars.title), "all");
			copy= replacenocase(copy, "|username|", trim(arguments.strUserDetails.Username), "all");
			copy= replacenocase(copy, "|password|", trim(arguments.password), "all");
			copy= replacenocase(copy, "|sitepath|", trim(variables.strConfig.strPaths.sitepath),"all");
			
			return send( to		=	arguments.emailAddress, 
						 bcc	=	variables.strConfig.strVars.registrations,
						 body	=	copy, 
						 subject= 	variables.strConfig.strVars.title & ": Registration - " & arguments.emailAddress 
						);

		</cfscript>

	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="emailCustomerServices" access="public" output="false" returntype="void" 
		hint="Sends an email to the Customer Services">
		
	  	<cfargument name="email" 	required="yes" type="string" hint="string containing the email_id">
	  	<cfargument name="comments" required="yes" type="string" hint="string containing the corporate user comments">
		
		<cfset send(	variables.strConfig.strVars.customerservices, 
						arguments.comments, 
						"#variables.strConfig.strVars.title#: Customer Feedback", 
						arguments.email )>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="emailCorpSubMembers" access="public" output="false" returntype="void" 
		hint="Sends an email to the Customer Services">
		
	  	<cfargument name="qryCorpRegistrants" 	required="yes" type="query" hint="query object of all subscription members">
	  	<cfargument name="mailMessage" required="yes" type="string" hint="string containing the message to send">
		<cfargument name="qryFromUser" 	required="yes" type="query" hint="query object of the administrator sending the message">
		<cfargument name="subject" required="yes" type="string" hint="string containing the subject">
		
		<cfloop query="arguments.qryCorpRegistrants">			
			<cfif arguments.qryCorpRegistrants.usertype neq 5>
				<cfset send(	arguments.qryCorpRegistrants.email, 
								arguments.mailMessage, 
								arguments.subject, 
								arguments.qryFromUser.email,
								false )>
			</cfif>
		</cfloop>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="emailCustomerServicesCorpAdmin" access="public" output="false" returntype="void" 
		hint="Email customer services with the corporate admin user details">
		
		<cfargument name="Action" 			required="yes" type="string" 	hint="">
	  	<cfargument name="strAttr" 			required="yes" 	type="struct" 	hint="">
		<cfargument name="strSession" 		required="yes" 	type="struct" 	hint="str of session data">

		<cfscript>
		var copy="";
		var subname="";
		var paymentmethod= "";
		var percentdiscount= "";
		
		if (Arguments.strAttr.productid EQ 1)
			subname = 'Single User Access Subscription';
		else if (Arguments.strAttr.productid EQ 2)
			subname = 'Corporate Subscription';
				
		if (Arguments.strAttr.PAYMENT_METHOD EQ 1)
			paymentmethod = 'Credit/Debit Card';
		else if (Arguments.strAttr.PAYMENT_METHOD EQ 3)
			paymentmethod = 'Invoice';
		else if (Arguments.strAttr.PAYMENT_METHOD EQ 4)
			paymentmethod = 'Purchase Order';
			
		if (Arguments.strAttr.DISCOUNT EQ 1)
			percentdiscount = '10%';
		else if (Arguments.strAttr.DISCOUNT EQ 2 OR Arguments.strAttr.DISCOUNT EQ 3)
			percentdiscount = '5%';
		
		if (NOT StructKeyExists(Arguments.strAttr, 'TRANSID'))
			transid = 'Offline Payment';
		else
			transid = Arguments.strAttr.TRANSID;
			
		copy =  getCopy(43229);
		copy = replace(copy, "|UserName|", 			trim(Arguments.strSession.userdetails.UserName), "all");	
		copy = replace(copy, "|transid|", 			trim(transid), "all");
		copy = replace(copy, "|subtype|", 			trim(Arguments.strAttr.TypeOfOrder), "all");
		copy = replace(copy, "|customerref|", 		trim(Arguments.strAttr.SUBSCRIPTIONID), "all");
		copy = replace(copy, "|paymentmethod|", 	trim(paymentmethod), "all");
		if (trim(Arguments.strAttr.purchase_order_no) NEQ '')
		copy = replace(copy, "|purchase_order_no|", "Purchase Order No: #Arguments.strAttr.purchase_order_no#", "all");
		else
		copy = replace(copy, "|purchase_order_no|", "", "all");
		copy = replace(copy, "|corpAdminEmail|", 	trim(Arguments.strAttr.CORP_EMAIL), "all");
		copy = replace(copy, "|corpAdminName|", 	trim(Arguments.strAttr.CORP_NAME), "all");
		copy = replace(copy, "|corpAdminTel|", 		trim(Arguments.strAttr.CORP_TELEPHONE), "all");
		copy = replace(copy, "|grandtotal|", 		trim(Arguments.strAttr.finaltotal), "all");
		
		// todo: replace this with the CMS mailbox id: #variables.strConfig.strVars.CustomServices#
		send(variables.strConfig.strVars.customerservices, copy, variables.strConfig.strVars.title & ": " & Arguments.action & " - " & Arguments.strAttr.CORP_EMAIL);
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="emailCSDataSales" access="public" output="false" returntype="void" 
		hint="Sends an email to the Customer Services alerting them taht an order has been placed for data">
		<cfargument name="OrderID" 				required="yes" type="numeric" hint="">
		<cfargument name="strSession" 			required="yes" type="struct"  hint="">
		<cfargument name="arrAttachment" 		required="yes" type="array"   hint="">
	  	
		
		<cfset var copy = "">
		<cfset var orderSummary = "">
		<!--- get copy from custom tag --->
		<cf_OrderSummary SiteVars="#variables.strConfig.strVars#"
				strSession="#arguments.strSession#" 
				ShowPrices="false"
				StrOrder="#structNew()#" 
				isEmail = true>
	
		<cfscript>
		copy = orderSummary;
		//send email
		send( to      	 =	strConfig.strVars.customerservices, 
			  body 	  	 =	copy, 
			  subject 	 =  variables.strConfig.strVars.title & ": Date Sales OrderID - " & arguments.OrderID,
			  attachment =  arguments.arrAttachment);
		</cfscript>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="emailCSBookOrder" access="public" output="false" returntype="void" 
		hint="Sends an email to the Customer Services alerting them that an order has been placed for a directory">
		<cfargument name="OrderID" 				required="yes" type="numeric" hint="">
		<cfargument name="strSession" 			required="yes" type="struct"  hint="">
		

		<cfset var copy = "">
		<cfset var orderSummary = "">
		
		<!--- get copy from custom tag 
		<cf_OrderSummary SiteVars="#variables.strConfig.strVars#"
				strSession="#arguments.strSession#" 
				ShowPrices="false"
				StrOrder="#structNew()#">--->
				
		<cfset copy = orderSummary>
		
		<cfscript>

		send( to      	 =	strConfig.strVars.customerservices, 
			  body 	  	 =	copy, 
			  subject 	 =  variables.strConfig.strVars.title & ": Date Sales OrderID - " & arguments.OrderID);
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="sendBookOrder" access="public" output="false" returntype="void" 
		hint="Email user and accounts their book order details">
		
		<cfargument name="to" 			required="yes" 	type="string" >
		<cfargument name="copy" 		required="yes" 	type="string" >
		<cfargument name="subject" 		required="yes" 	type="string" default="LocalGov.co.uk - MYB Hard Copy Purchase" >
		<cfargument name="attachment" required="yes" type="string">
		  		
		<cfset send(to=arguments.to, body=arguments.copy, subject=arguments.subject, bcc="#strConfig.strVars.customerservices#,#strConfig.strVars.accounts#", attachment=arguments.attachment)>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- --------------------------------------------------------------------------------------------------->
	<cffunction name="emailNotification" access="public" output="false" returntype="void" hint="Emails the order confirmation to the user">	
		<cfargument name="strUserDetails" 	required="yes" 	type="struct" 	hint="">
	  	<cfargument name="SubscriptionID" 	required="yes" 	type="string" 	hint="">
	  	<cfargument name="PaymentStatus"  	required="yes" 	type="string" 	hint="">
	  	<cfargument name="ProductID"  		required="yes" 	type="numeric" 	hint="">
	  	<cfargument name="CorpEmail"  		required="yes" 	type="string" 	hint="">
		<cfargument name="subscribers_link" required="no" 	type="string" 	hint="">
		<cfargument name="admin_user" 		required="no" 	type="string" 	hint="">
		<cfargument name="attachmentPath" 	required="no" 	type="string"	default="" 	hint="Path to invoice to be attached to email">
		

		<cfscript>
			var copy="";
			var Subject= "";
			
			switch (arguments.PaymentStatus)
			{
				// Payment Success
				case "2":
				{
					//Set Subject line
					Subject = variables.strConfig.strVars.title & ": Order Notification";
					
					// User placing the order is the Corp Admin.
					if (arguments.admin_user eq 1)
					{
						//Email User
						sendEmail
						(
							ArticleID 			= 45792
							, SubscriptionID 	= arguments.SubscriptionID
							, Username 			= arguments.strUserDetails.Username
							, Subject 			= Subject
							, attachmentPath	= arguments.attachmentPath
						);
						
						/*
							If a Corporate sub has been ordered, email Hemming access code 
							to the Corporate administrator so that he/she can forward it
							to any users who need to join the corporate subscription
						*/
						if (arguments.ProductID EQ 2)
						{
							sendHemmingAccessCode
							(
								articleID 			= 43406
								, subscriptionID 	= arguments.SubscriptionID
								, accessCode 		= 11111
								, subject 			= Subject
								, subscribers_link 	= arguments.subscribers_link
								, username 			= arguments.strUserDetails.Username
							);
						}
						
					}
					// Order submitted by a user on behalf of the Corp Admin.
					/*
						This condition is no longer possible as we are not allowing users to buy a corporate sub
						on behalf of anyone else any longer 12/02/2009 - HB
					*/
					else 
					{
						// Email Corp Admin
						copy =  getCopy(45861);
						copy = replace(copy, "|username|", trim(arguments.strUserDetails.Username), "all");
						copy = replace(copy, "|subscriptionid|", trim(arguments.SubscriptionID), "all");
							
						send(Arguments.CorpEmail, copy, Subject);
						
						//Email Hemming access code to invite corp sub
						if (arguments.ProductID EQ 2 AND trim(arguments.CorpEmail) NEQ "")
						{
							sendHemmingAccessCode
							(
								articleID 			= 43415
								, subscriptionID 	= arguments.SubscriptionID
								, accessCode 		= 11111
								, subject 			= Subject
								, subscribers_link 	= arguments.subscribers_link
								, username 			= arguments.CorpEmail
							);
						}
						
						// Email the user submitting the order on behalf of the corp admin
						sendEmail
						(
							ArticleID 			= 43404
							, SubscriptionID 	= arguments.SubscriptionID
							, Username 			= arguments.strUserDetails.Username
							, Subject 			= Subject
							, attachmentPath	= arguments.attachmentPath
						);
					}
					break;
				}
				
				// Payment Cancelled
				case "3":
				{
					//Set Subject line
					Subject = variables.strConfig.strVars.title & ": Order Notification - Payment Cancelled";
					
					sendEmail
					(
						ArticleID 			= 43405
						, SubscriptionID 	= arguments.SubscriptionID
						, Username 			= arguments.strUserDetails.Username
						, Subject 			= Subject
						, attachmentPath	= arguments.attachmentPath
					);
					break;
				}
				
				// Offline Order
				case "4":
				{
					//Set Subject line
					Subject = variables.strConfig.strVars.title & ": Order Notification - Order Received";
									
				 	// User placing the order is the Corp Admin.
					if (arguments.admin_user eq 1)
					{
						//Email User
						sendEmail
						(
							ArticleID 			= 45792
							, SubscriptionID 	= arguments.SubscriptionID
							, Username 			= arguments.strUserDetails.Username
							, Subject 			= Subject
							, attachmentPath	= arguments.attachmentPath
						);
						
						//Email Hemming access code to invite corp sub
						if (arguments.ProductID eq 2)
						{
							sendHemmingAccessCode
							(	
								articleID 			= 43406
								, subscriptionID 	= arguments.SubscriptionID
								, accessCode 		= 11111
								, subject 			= Subject
								, subscribers_link 	= arguments.subscribers_link
								, username 			= arguments.strUserDetails.Username
							);
						}
						
					}
					else 
					{
						// Order submitted by a user on behalf of the Corp Admin.
						// Email Corp Admin
						copy =  getCopy(45861);
						copy = replace(copy, "|username|", trim(arguments.strUserDetails.Username), "all");
						copy = replace(copy, "|subscriptionid|", trim(arguments.SubscriptionID), "all");
						
						send(arguments.CorpEmail, copy, Subject);
						
						//Email Hemming access code to invite corp sub
						if (arguments.ProductID EQ 2 AND trim(arguments.CorpEmail) NEQ "")
						{
							sendHemmingAccessCode
							(	
								articleID 			= 43415
								, subscriptionID 	= arguments.SubscriptionID
								, accessCode 		= 11111
								, subject 			= Subject
								, subscribers_link 	= arguments.subscribers_link
								, username 			= arguments.CorpEmail
							);
						}
						
						// Email the user submitting the order on behalf of the corp admin
						sendEmail
						(	
							ArticleID 			= 43407
							, SubscriptionID 	= arguments.SubscriptionID
							, Username 			= arguments.strUserDetails.Username
							, Subject 			= Subject
							, attachmentPath	= arguments.attachmentPath
						);
					}
					break;
				}
			}
			// todo: replace this with the CMS mailbox id: #variables.strConfig.strVars.CustomServices#
			
		</cfscript>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="sendHemmingAccessCode" access="public" output="false" returntype="void" 
		hint="Email to Hemming a copy  of invite to corp sub with access code">
		
		<cfargument name="ArticleID" 		required="yes" 	type="numeric" hint="">
	  	<cfargument name="SubscriptionID" 	required="yes" 	type="string" hint="">
	  	<cfargument name="accesscode"  		required="yes" 	type="string" hint="">
		<cfargument name="subject" 			required="yes" 	type="string" hint="">
		<cfargument name="subscribers_link" required="yes" 	type="string" hint="">
		<cfargument name="username" 		required="no" 	type="string" hint="" default="">

		<cfscript>
			var copy="";
			copy =  getCopy(arguments.ArticleID);
			copy = replace(copy, "|subscriptionid|", trim(arguments.SubscriptionID), "all");	
			copy = replace(copy, "|accesscode|", trim(arguments.accesscode), "all");	
			copy = replace(copy, "|subscribers_link|", trim(arguments.subscribers_link), "all");
			copy = replace(copy, "|username|", trim(arguments.username), "all");
			
			//Send the actual email
			send(variables.strConfig.strVars.hemming_accesscode_email, copy, arguments.subject);
			
		</cfscript>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="sendEmail" access="private" output="false" returntype="void" hint="Email the user placing the order">	
		<cfargument name="ArticleID" 		required="yes" 	type="numeric" 	hint="">
	  	<cfargument name="SubscriptionID" 	required="yes" 	type="string" 	hint="">
		<cfargument name="Username" 		required="yes" 	type="string" 	hint="">
		<cfargument name="Subject" 			required="yes" 	type="string" 	hint="">
		<cfargument name="attachmentPath" 	required="no" 	type="string"	default="" 	hint="Path to invoice to be attached to email">

		<cfscript>
			var copy="";
			var thebcc = "";
			copy =  getCopy(arguments.ArticleID);
			copy = replace(copy, "|subscriptionid|", trim(arguments.SubscriptionID), "all");
			
			if(len(arguments.attachmentPath))
			{
				thebcc = trim(variables.strConfig.strVars.accounts);
			}
			
			//Send the email	
			send
			(
				to = arguments.username
				, body = copy
				, subject = arguments.Subject
				, bcc = thebcc
				, attachment = arguments.attachmentPath
			);
		</cfscript>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="EmailAFriend" access="public" output="false" returntype="boolean" 
		hint="Sends an email to Friend">
		
	  	<cfargument name="strAttr" 			required="yes" 	type="struct" hint="">
		
		<!---<cfscript>
			var bl = false;
			//get copy from db
			var copy = getCopy(44502);
			//replace vars with data
			copy = replace(copy, "|from_name|", 	trim(arguments.strAttr.from_name), "all");
			copy = replace(copy, "|message|", 		trim(arguments.strAttr.message), "all");
			copy = replace(copy, "|article_link|", 	trim(arguments.strAttr.article_link), "all");
			
			//send email
			if (send(listgetat(arguments.strAttr.to_email,1,','), copy, "#variables.strConfig.strVars.title#: #arguments.strAttr.subject#", arguments.strAttr.from_email))
				bl = true;
			return 	bl;
		</cfscript>--->
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="emailNewUsername" access="public" output="false" returntype="void" 
		hint="Email the new username to the supplied username/email address">
		
	  	<cfargument name="Username" required="yes" type="string" hint="">
	  		
		<cfscript>
			var bl = false;
			//get copy from db
			var copy = getCopy(42613);
			//send email
			if (send(arguments.Username,copy,"#variables.strConfig.strVars.title#: New Username"))
				bl = true;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="sendEmailToCorpAdmin" access="public" output="false" returntype="void" 
		hint="Construct and send out an email to the Admin Corp User confirming any changes made to the corp account.">
		
		<cfargument name="Action" 		required="yes" type="string" hint="">
	  	<cfargument name="strAttr" 		required="yes" type="struct" hint="attribute data">
	  	<cfargument name="strSession" 	required="yes" type="struct" hint="str of session data">
		
		<cfscript>
			var bl = false;
			var copy ="";
			var UserNameInSubject = "";		
			switch (arguments.Action){
				case "Deleted":{
					copy =  getCopy(42624);
					Arguments.strAttr.CorpUserName = Arguments.strSession.userdetails.username;
					UserNameInSubject = Arguments.strAttr.UserName;
					//replace vars with data
					copy = replace(copy, "|UserName|", trim(Arguments.strAttr.UserName), "all");	
					break;
				}
				case "Re-Activated":{
					copy =  getCopy(42625);
					Arguments.strAttr.CorpUserName = Arguments.strSession.userdetails.username;
					UserNameInSubject = Arguments.strAttr.UserName;
					//replace vars with data
					copy = replace(copy, "|UserName|", trim(Arguments.strAttr.UserName), "all");	
					break;
				}
				 case "Replaced":{
					copy =  getCopy(42626);
					UserNameInSubject = Arguments.strAttr.HID_USERNAME;
					//replace vars with data
					copy = replace(copy, "|EMAIL|", trim(Arguments.strAttr.Email), "all");
					copy = replace(copy, "|HID_USERNAME|", trim(Arguments.strAttr.HID_USERNAME), "all");		
					break;
				}
				case "Updated":{
					copy =  getCopy(42627);
					UserNameInSubject = Arguments.strAttr.Email;
					//replace vars with data
					copy = replace(copy, "|EMAIL|", trim(Arguments.strAttr.Email), "all");		
					break;
				}	
				case "Subscribed":{
					copy =  getCopy(42629);
					UserNameInSubject = Arguments.strSession.UserName;
					//replace vars with data
					copy = replace(copy, "|UserName|", trim(Arguments.strSession.UserName), "all");		
					break;	
				}
			}
			if (send(Arguments.strAttr.CorpUserName,copy, variables.strConfig.strVars.title & ": " & Arguments.Action & " - " & UserNameInSubject))
				bl = true;
			//return 	bl;
		</cfscript>
			
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="sendEmailToSubsDept" access="public" output="false" returntype="boolean" 
		hint="Construct and send out an email confirmation to the Subscription Dept.">
		
		<cfargument name="Action" 			required="yes" type="string" 	hint="">
	  	<cfargument name="strAttr" 			required="yes" type="struct" 	hint="attribute data">
	  	<cfargument name="strSession" 		required="yes" type="struct" 	hint="str of session data">
		<cfargument name="qryUserDetails" 	required="yes" type="query" 	hint="str of session data">

		<cfscript>
		var bl = false;
		var copy="";
		var subname="";
		var paymentmethod= "";
		var percentdiscount= "";
		
		if (Arguments.strAttr.productid EQ 1)
			subname = 'Single User Access';
		else if (Arguments.strAttr.productid EQ 2)
			subname = 'Corporate';
				
		if (Arguments.strAttr.PAYMENT_METHOD EQ 1)
			paymentmethod = 'Credit/Debit Card';
		else if (Arguments.strAttr.PAYMENT_METHOD EQ 3)
			paymentmethod = 'Invoice';
		else if (Arguments.strAttr.PAYMENT_METHOD EQ 4)
			paymentmethod = 'Purchase Order';
			
		if (Arguments.strAttr.DISCOUNT EQ 1)
			percentdiscount = '10%';
		else if (Arguments.strAttr.DISCOUNT EQ 2 OR Arguments.strAttr.DISCOUNT EQ 3)
			percentdiscount = '5%';
		
		if (NOT StructKeyExists(Arguments.strAttr, 'TRANSID'))
			transid = 'Offline Payment';
		else
			transid = Arguments.strAttr.TRANSID;
			
		switch (arguments.Action){
			case "Top Up":{
				copy =  getCopy(43224);
				//replace vars with data
				copy = replace(copy, "|UserName|", 			trim(Arguments.strSession.userdetails.UserName), "all");	
				copy = replace(copy, "|subscriptionname|", 	trim(subname), "all");	
				copy = replace(copy, "|orderrequested|", 	trim(Arguments.strAttr.SUBJECT), "all");	
				copy = replace(copy, "|transid|", 			trim(transid), "all");
				copy = replace(copy, "|subtype|", 			trim(Arguments.strAttr.TypeOfOrder), "all");
				copy = replace(copy, "|customerref|", 		trim(Arguments.strAttr.HID_CORPSUBSCRIPTIONID), "all");
				copy = replace(copy, "|paymentmethod|", 	trim(paymentmethod), "all");
				if (Arguments.strAttr.purchase_order_no NEQ '')
				copy = replace(copy, "|purchase_order_no|", "Purchase Order No: #Arguments.strAttr.purchase_order_no#", "all");
				else
				copy = replace(copy, "|purchase_order_no|", "", "all");
				copy = replace(copy, "|forename|", 			trim(Arguments.qryUserDetails.FORENAME), "all");
				copy = replace(copy, "|surname|", 			trim(Arguments.qryUserDetails.SURNAME), "all");
				copy = replace(copy, "|jobtitle|", 			trim(Arguments.qryUserDetails.JOBTITLE), "all");
				copy = replace(copy, "|company|", 			trim(Arguments.qryUserDetails.COMPANY), "all");
				copy = replace(copy, "|address1|", 			trim(Arguments.qryUserDetails.ADDRESS1), "all");
				copy = replace(copy, "|address2|", 			trim(Arguments.qryUserDetails.ADDRESS2), "all");
				copy = replace(copy, "|town|", 				trim(Arguments.qryUserDetails.TOWN), "all");
				copy = replace(copy, "|postcode|", 			trim(Arguments.qryUserDetails.POSTCODE), "all");
				copy = replace(copy, "|country|", 			trim(Arguments.strAttr.COUNTRY), "all");
				copy = replace(copy, "|telephone|", 		trim(Arguments.qryUserDetails.TEL), "all");
				copy = replace(copy, "|fax|", 				trim(Arguments.qryUserDetails.FAX), "all");
				copy = replace(copy, "|email|", 			trim(Arguments.qryUserDetails.EMAIL), "all");
				copy = replace(copy, "|grandtotal|", 		trim(Arguments.strAttr.finaltotal), "all");
				
				break;
			}
			case "Subscription Renewal":{
				copy =  getCopy(43221);
				//replace vars with data
				copy = replace(copy, "|UserName|", 			trim(Arguments.strSession.userdetails.UserName), "all");	
				copy = replace(copy, "|subscriptionname|", 	trim(subname), "all");	
				copy = replace(copy, "|orderrequested|", 	trim(Arguments.strAttr.SUBJECT), "all");
				copy = replace(copy, "|transid|", 			trim(transid), "all");
				copy = replace(copy, "|subtype|", 			trim(Arguments.strAttr.TypeOfOrder), "all");
				copy = replace(copy, "|customerref|", 		trim(Arguments.strAttr.SUBSCRIPTIONID), "all");
				copy = replace(copy, "|paymentmethod|", 	trim(paymentmethod), "all");
				if (Arguments.strAttr.purchase_order_no NEQ '')
				copy = replace(copy, "|purchase_order_no|", "Purchase Order No: #Arguments.strAttr.purchase_order_no#", "all");
				else
				copy = replace(copy, "|purchase_order_no|", "", "all");
				copy = replace(copy, "|forename|", 			trim(Arguments.qryUserDetails.FORENAME), "all");
				copy = replace(copy, "|surname|", 			trim(Arguments.qryUserDetails.SURNAME), "all");
				copy = replace(copy, "|jobtitle|", 			trim(Arguments.qryUserDetails.JOBTITLE), "all");
				copy = replace(copy, "|company|", 			trim(Arguments.qryUserDetails.COMPANY), "all");
				copy = replace(copy, "|address1|", 			trim(Arguments.qryUserDetails.ADDRESS1), "all");
				copy = replace(copy, "|address2|", 			trim(Arguments.qryUserDetails.ADDRESS2), "all");
				copy = replace(copy, "|town|", 				trim(Arguments.qryUserDetails.TOWN), "all");
				copy = replace(copy, "|postcode|", 			trim(Arguments.qryUserDetails.POSTCODE), "all");
				copy = replace(copy, "|country|", 			trim(Arguments.strAttr.COUNTRY), "all");
				copy = replace(copy, "|telephone|", 		trim(Arguments.qryUserDetails.TEL), "all");
				copy = replace(copy, "|fax|", 				trim(Arguments.qryUserDetails.FAX), "all");
				copy = replace(copy, "|email|", 			trim(Arguments.qryUserDetails.EMAIL), "all");
				copy = replace(copy, "|grandtotal|", 		trim(Arguments.strAttr.finaltotal), "all");
				break;
			}
			case "New Subscription":{
				copy =  getCopy(43028);
				//replace vars with data
				copy = replace(copy, "|UserName|", 			trim(Arguments.strSession.userdetails.UserName), "all");	
				copy = replace(copy, "|subscriptionname|", 	trim(subname), "all");	
				copy = replace(copy, "|orderrequested|", 	trim(Arguments.strAttr.SUBJECT), "all");	
				copy = replace(copy, "|transid|", 			trim(transid), "all");
				copy = replace(copy, "|subtype|", 			trim(Arguments.strAttr.TypeOfOrder), "all");
				copy = replace(copy, "|customerref|", 		trim(Arguments.strAttr.SUBSCRIPTIONID), "all");
				copy = replace(copy, "|paymentmethod|", 	trim(paymentmethod), "all");
				if (Arguments.strAttr.purchase_order_no NEQ '')
				copy = replace(copy, "|purchase_order_no|", "Purchase Order No: #Arguments.strAttr.purchase_order_no#", "all");
				else
				copy = replace(copy, "|purchase_order_no|", "", "all");
				copy = replace(copy, "|forename|", 			trim(Arguments.qryUserDetails.FORENAME), "all");
				copy = replace(copy, "|surname|", 			trim(Arguments.qryUserDetails.SURNAME), "all");
				copy = replace(copy, "|jobtitle|", 			trim(Arguments.qryUserDetails.JOBTITLE), "all");
				copy = replace(copy, "|company|", 			trim(Arguments.qryUserDetails.COMPANY), "all");
				copy = replace(copy, "|address1|", 			trim(Arguments.qryUserDetails.ADDRESS1), "all");
				copy = replace(copy, "|address2|", 			trim(Arguments.qryUserDetails.ADDRESS2), "all");
				copy = replace(copy, "|town|", 				trim(Arguments.qryUserDetails.TOWN), "all");
				copy = replace(copy, "|postcode|", 			trim(Arguments.qryUserDetails.POSTCODE), "all");
				copy = replace(copy, "|country|", 			trim(Arguments.strAttr.COUNTRY), "all");
				copy = replace(copy, "|telephone|", 		trim(Arguments.qryUserDetails.TEL), "all");
				copy = replace(copy, "|fax|", 				trim(Arguments.qryUserDetails.FAX), "all");
				copy = replace(copy, "|email|", 			trim(Arguments.qryUserDetails.EMAIL), "all");
				copy = replace(copy, "|grandtotal|", 		trim(Arguments.strAttr.finaltotal), "all");
				
				break;
			}
		}
		if ( send(	variables.strConfig.strVars.subscriptions,
					copy, 
					variables.strConfig.strVars.title & ": " & arguments.action & " - " & arguments.strSession.userdetails.userName) )
			bl = true;
		return 	bl;
		</cfscript>
			
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- <cffunction name="sendNewsletter" access="public" returntype="boolean" output="false" hint="send email newsletter">
		<cfargument name="objUsers" 	required="yes"  type="any" hint="users object">
		<cfargument name="id" 			required="no"  type="numeric" default="0">
		<cfargument name="topicid" 		required="no"  type="numeric" default="0">
	
		<cfscript>
			
			var body 	      = "";
			var modifybody    = "";
			var unsublink 	  = "http://www.localgov.co.uk/index.cfm?method=user.newsletterUnsub";
			var qryNewsletter = "";
			var qryUsers 	  = "";
			var adlinkurl 	  =	"http://www.localgov.co.uk/index.cfm?method=ads.adlink";
			var bl			  = false;	
			var i 			  = 0;
			var u 			  = 0;	
			var siteVersionLink = '<a href="http://www.localgov.co.uk/extends/components/Services/newsletter.cfc?method=display&id=#arguments.id#">clicking here</a>';
			
			if (arguments.topicid){
				qryUsers 	  = arguments.objusers.getTopicNewsletterSubs(arguments.topicid);
				unsublink	  = "http://www.localgov.co.uk/index.cfm?" & "topic.Unsubscribe";
				}
			else
				qryUsers 	  = arguments.objusers.GetNewsletterSubs();
			
		
			qryNewsletter = variables.objNewsletter.GetNewsletterByid(id);
		</cfscript>	
		
		<!---Loop over qry as there may be more than one newsletter --->
		<cfif qryNewsletter.recordcount and qryNewsletter.IsSent neq 1>
		
			<cfloop from="1" to="#qryNewsletter.recordcount#" index="i">
				<!---build page content --->
				<cfset body = variables.objNewsletter.prepareCopy(qryNewsletter.BodyText[i],adlinkurl)>
				
				<!--- Insert link for site version of newsletter --->
				<cfset body = replace(body, "|newsletterPageLink|",  trim(siteVersionLink))>
				
				<!---Send an email to each recipient --->
				<cfloop from="1" to="#qryUsers.recordcount#" index="u">
					<!---amend user detais, to page content --->
					<cfset modifybody = replace(body, "|unsublink|", trim(unsublink & "&amp;userid=#qryUsers.userid[u]#&amp;email=#qryUsers.email[u]#&amp;topicid=#arguments.topicid#"))>
					
					<!--- Replace direct sending for new queued batch sending method --->
					<!--- <cfif send(to=qryUsers.email[u],
								body=modifybody,
								subject=qryNewsletter.Subject[i],
								from=strConfig.strVars.bulletin,
								includeHeaders=false,
								reply=strConfig.strVars.editor)>
						<cfset bl = true>	
					</cfif>	 --->
					
					<cfset variables.objNewsletter.addToQueue(to=qryUsers.email[u],
																body=modifybody,
																subject=qryNewsletter.Subject[i],
																newsletterID=qryNewsletter.Newsletterid[i],
																from=strConfig.strVars.bulletin,
																reply=strConfig.strVars.editor)>
					
				</cfloop>
				<!--- mark newsletter as sent by updating table--->
				<cfset bl = true>
				<cfset variables.objNewsletter.UpdateNewsletter(qryNewsletter.Newsletterid[i])>
		</cfloop>	
	</cfif>
		 <cfreturn bl>
	</cffunction> --->
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="genNewsletterCopy" access="remote" returntype="void" output="false" hint="Generate the newsletter body copy">
		
		<cfset var qryGenList = variables.objNewsletter.getNewslettersToGen()>
		
		
		
		<cfscript>
			
			var body 	      = "";
			var modifybody    = "";
			var unsublink 	  = "http://www.localgov.co.uk/index.cfm?method=user.newsletterUnsub";
			var qryNewsletter = "";
			var qryUsers 	  = "";
			var adlinkurl 	  =	"http://www.localgov.co.uk/index.cfm?method=ads.adlink";
			var bl			  = false;	
			var i 			  = 0;
			var u 			  = 0;	
			var siteVersionLink = '<a href="http://www.localgov.co.uk/extends/components/Services/newsletter.cfc?method=display&id=#qryGenList.newsletterid[1]#">clicking here</a>';
			
			/*if (arguments.topicid){
				qryUsers 	  = arguments.objusers.getTopicNewsletterSubs(arguments.topicid);
				unsublink	  = "http://www.localgov.co.uk/index.cfm?" & "topic.Unsubscribe";
				}
			else
				qryUsers 	  = arguments.objusers.GetNewsletterSubs();*/
			
			if (qryGenList.recordcount gt 0)
				qryNewsletter = variables.objNewsletter.GetNewsletterByid(qryGenList.newsletterid[1]);
		</cfscript>	
		
		<cfif qryGenList.recordcount gt 0>
			
			<cfif qryNewsletter.recordcount>
			
				<cfloop from="1" to="#qryNewsletter.recordcount#" index="i">
					<!---build page content --->
					<cfset body = variables.objNewsletter.prepareCopy(qryNewsletter.BodyText[i],adlinkurl)>
					
					<!--- Insert link for site version of newsletter --->
					<cfset body = replace(body, "|newsletterPageLink|",  trim(siteVersionLink))>
					
					<!---Send an email to each recipient --->
					<cfloop from="1" to="#qryGenList.recordcount#" index="u">
						<!---amend user detais, to page content --->
						<cfset modifybody = replace(body, "|unsublink|", trim(unsublink & "&amp;userid=#qryGenList.userid[u]#&amp;email=#qryGenList.sendTo[u]#&amp;topicid=#qryGenList.topicid[u]#"))>
						
						<cfset variables.objNewsletter.updateNewsletterCopy(id=qryGenList.newsletterQueueID[u],	body=modifybody)>
						
					</cfloop>
				</cfloop>	
			</cfif>	
		</cfif>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="popNewsletterTable" access="public" returntype="boolean" output="false" hint="send email newsletter">
		<cfargument name="objUsers" 	required="yes"  type="any" hint="users object">
		<cfargument name="id" 			required="no"  type="numeric" default="0">
		<cfargument name="topicid" 		required="no"  type="numeric" default="0">
		
		<cfscript>
			
			var qryNewsletter = "";
			var qryUsers 	  = "";
			var bl			  = false;	
			var i 			  = 0;
			var u 			  = 0;	
			
			if (arguments.topicid){
				qryUsers 	  = arguments.objusers.getTopicNewsletterSubs(arguments.topicid);
				unsublink	  = "http://www.localgov.co.uk/index.cfm?" & "topic.Unsubscribe";
				}
			else
				qryUsers 	  = arguments.objusers.GetNewsletterSubs();
			
		
			qryNewsletter = variables.objNewsletter.GetNewsletterByid(id);
		</cfscript>	
		
		<!---Loop over qry as there may be more than one newsletter --->
		<cfif qryNewsletter.recordcount and qryNewsletter.IsSent neq 1>
		
			<cfloop from="1" to="#qryNewsletter.recordcount#" index="i">
				
				<!---Send an email to each recipient --->
				<cfloop from="1" to="#qryUsers.recordcount#" index="u">
					
					<cfset variables.objNewsletter.addToQueue(to=qryUsers.email[u],
																userid=qryUsers.userid[u],
																body='',
																subject=qryNewsletter.Subject[i],
																newsletterID=qryNewsletter.Newsletterid[i],
																topicid=arguments.topicid,
																from=strConfig.strVars.bulletin,
																reply=strConfig.strVars.editor)>
					
				</cfloop>
				<!--- mark newsletter as sent by updating table--->
				<cfset bl = true>
				<cfset variables.objNewsletter.UpdateNewsletter(qryNewsletter.Newsletterid[i])>
			</cfloop>	
		</cfif>
		<cfreturn bl>		
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="sendNLQueue" access="public" returntype="void" output="false">
		<cfargument name="to"      			type="string"  required="yes">
		<cfargument name="body"     		type="string"  required="yes">
		<cfargument name="subject"   	 	type="string"  required="yes">
		<cfargument name="from"     		type="string"  required="no" default="#variables.strConfig.strVars.mailsender#">
		<cfargument name="includeHeaders" 	type="boolean" required="no" default="true">
		<cfargument name="reply" 			type="string"  required="no" default="reply address">
		
		<cfset send(to=arguments.to,
								body=arguments.body,
								subject=arguments.subject,
								from=arguments.from,
								includeHeaders=false,
								reply=arguments.reply)>
		
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="sendNewsletterTest" access="public" returntype="boolean" output="false" hint="send email newsletter">
		<cfargument name="NewsletterID" required="true" 	type="numeric">
		<cfargument name="recipient" 	required="true" 	type="string">
		<cfargument name="topicid" 		required="false" 	type="numeric" default="0">
	 	
		<cfscript>
			var adlinkurl 	  	= "http://www.localgov.co.uk/index.cfm?method=ads.adlink";
			var unsublink 	  	= "http://www.localgov.co.uk/index.cfm?method=user.newsletterUnsub";
			var qryNewsletter 	= variables.objNewsletter.GetNewsletterDetail(Arguments.NewsletterID);
			var siteVersionLink = '<a href="http://www.localgov.co.uk/extends/components/Services/newsletter.cfc?method=display&id=#arguments.NewsletterID#">clicking here</a>';
			
			var body			= variables.objNewsletter.prepareCopy(qryNewsletter.BodyText, adlinkurl, arguments.topicid);
			body           		= replace(body, "|newsletterPageLink|",  trim(siteVersionLink));
			
			if (arguments.topicid)
				unsublink	  = variables.myself & "topic.Unsubscribe";
				
			body = replace(body, "|unsublink|", trim(unsublink & "&amp;userid=0&amp;email=#recipient#&amp;topicid=#arguments.topicid#"));
			//var body = nheader & qryNewsletter.BodyText & nfooter;
			send(to=arguments.recipient,
								body=body,
								subject=qryNewsletter.Subject,
								from=strConfig.strVars.bulletin,	
								includeHeaders=false,
								reply=strConfig.strVars.editor);
			return true;
		</cfscript>
		
		
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="sendNeed2know" access="public" returntype="boolean" output="false" hint="send need 2 know to editor">
		<cfargument name="keywords" required="yes" type="string">
		<cfargument name="email" 	required="yes" type="string">
			<cfscript> 
			var body = "User: <strong>#arguments.email#</strong><br/>Question: #arguments.keywords#<br/>";
			send(to=variables.strConfig.strVars.editor,
							body=body,
							subject="Need 2 Know Request"
							);
			return true;				
	</cfscript>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="SendGovepediaConfirmation" access="public" returntype="boolean" output="false" hint="send comfirmation of new govepedia article to editor">
	<cfargument name="link" 		required="yes" type="string">
	<cfargument name="isAllowed" 	required="no" type="boolean" default="true">
	
	<cfscript>
	var bl = false; 
	var copy = "<span class=text><p>A new Govepedia article has been posted onto the site</p>";
	if (NOT arguments.isAllowed)		
		copy = copy & "<p class=error> The article has been rejected</p>";
	
	copy = copy & "<a href=#variables.strConfig.strpaths.adminpath##link#>click here to edit</a></span>";
	
	if (send(variables.strConfig.strVars.editor, copy, "#variables.strConfig.strVars.title#: New Govepedia Aricle"))
			bl = true;
		return 	bl;

	</cfscript>
	</cffunction> 
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="EmailNewEventAlert" access="public" output="false" returntype="void" 
		hint="Email the event to the Editor">
		
	  	<cfargument name="strAttr" 			required="yes" 	type="struct" hint="qry of attribute data">
		<cfargument name="EventID" 			required="yes"	type="numeric">

		<cfscript>
		var copy= getCopy( 46196 );
		
		copy= replacenocase(copy, "|eventid|", 			trim(arguments.EventID), 						"all");
		copy= replacenocase(copy, "|eventname|", 		trim(arguments.strAttr.event_name), 			"all");
		copy= replacenocase(copy, "|description|", 		trim(arguments.strAttr.detail), 		 		"all");
		copy= replacenocase(copy, "|organiser|", 		trim(arguments.strAttr.organiser), 		 		"all");
		copy= replacenocase(copy, "|datestart|", 		trim(arguments.strAttr.date_start), 			"all");
		copy= replacenocase(copy, "|dateend|", 			trim(arguments.strAttr.date_end), 		 		"all");
		copy= replacenocase(copy, "|eventtype|", 		trim(arguments.strAttr.hid_EventType), 			"all");
		if (StructKeyExists(arguments.strAttr, 'sectors'))
		copy= replacenocase(copy, "|sectors|", 			trim(arguments.strAttr.sectors), 		 		"all");
		else
		copy = replace(copy, "|sectors|", "", "all");
		copy= replacenocase(copy, "|speakers|", 		trim(arguments.strAttr.speakers), 		 		"all");
		copy= replacenocase(copy, "|venuename|", 		trim(arguments.strAttr.venue_name), 			"all");
		copy= replacenocase(copy, "|postcode|", 		trim(arguments.strAttr.Postcode), 		 		"all");
		copy= replacenocase(copy, "|venueaddress1|", 	trim(arguments.strAttr.venue_address1), 		"all");
		copy= replacenocase(copy, "|venueaddress2|", 	trim(arguments.strAttr.venue_address2), 		"all");
		copy= replacenocase(copy, "|venueaddress3|", 	trim(arguments.strAttr.venue_address3), 		"all");
		copy= replacenocase(copy, "|town|", 			trim(arguments.strAttr.town), 		 			"all");
		copy= replacenocase(copy, "|county|", 			trim(arguments.strAttr.hid_County), 			"all");
		copy= replacenocase(copy, "|country|", 			trim(arguments.strAttr.hid_Country), 			"all");
		copy= replacenocase(copy, "|tel|", 				trim(arguments.strAttr.tel), 		 			"all");
		copy= replacenocase(copy, "|fax|", 				trim(arguments.strAttr.fax), 		 			"all");
		copy= replacenocase(copy, "|email|", 			trim(arguments.strAttr.email), 		 			"all");
		copy= replacenocase(copy, "|title|", 			trim(arguments.strAttr.f_contact_salutationID), "all");
		copy= replacenocase(copy, "|forename|", 		trim(arguments.strAttr.contact_forename), 		"all");
		copy= replacenocase(copy, "|surname|", 			trim(arguments.strAttr.contact_surname), 		"all");
		copy= replacenocase(copy, "|contacttel|", 		trim(arguments.strAttr.contact_tel), 		 	"all");
		copy= replacenocase(copy, "|contactfax|", 		trim(arguments.strAttr.contact_fax), 		 	"all");
		copy= replacenocase(copy, "|contactemail|", 	trim(arguments.strAttr.contact_email), 		 	"all");
		if (StructKeyExists(arguments.strAttr, 'LinkToEevnt'))
		copy= replacenocase(copy, "|EventLink|", 		trim(arguments.strAttr.LinkToEevnt), 		 	"all");
		else
		copy = replace(copy, "|EventLink|", "", "all");

		send(variables.strConfig.strVars.sales, copy, "#variables.strConfig.strVars.title#: New Event Alert - #arguments.strAttr.event_name#" );

		</cfscript>

	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="SendMS_SurveyLink" access="public" returntype="boolean" output="false" hint="send link to user who has asked for report">
	<cfargument name="name" 		required="yes" type="string" >
	<cfargument name="email" 		required="yes" type="string" >
	<cfargument name="report" 		required="yes" type="string" >
	
	<cfscript>
	var bl = false; 
	var reportLink = "";
	var copy = "";
	
	if (arguments.report eq 'flexible working')
		reportLink = "<a href='http://www.localgov.co.uk/msreport/FlexibleWorkingBenefits.doc'>Download report</a>";
	else
		reportLink = "<a href='http://www.localgov.co.uk/msreport/PerformanceManagementResearchReport_web.pdf'>Download report</a>";	
	
	copy = "<span class=bodytext><p>Dear #arguments.name#</p>To download the #arguments.report# report, please click on the following link:<br>
<br>#reportLink#<br><br>

If you experience any difficulty downloading the file, please let us know by replying to this e-mail <br>
with your address and we will have a hard copy of the report sent to you by post. </span>";
	
	if (send(arguments.email, copy, "#variables.strConfig.strVars.title#: MS Report", 'microsoft@localgov.co.uk '))
			bl = true;
		return 	bl;

	</cfscript>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="SendRenewals" access="public" returntype="void" output="false" hint="send renewal email reminders to thos whose subs are due to expire">
	<cfscript>
	var i 			= 0;
	var body 		= "";
	var subject 	= "It's time to renew your LocalGov.co.uk subscription";
	var sentDate 	= Now();
	var qryCorrespondence = objSubscriptions.GetCorrespondence();
	
	
	for  (i=1; i lte qryCorrespondence.recordcount; i=i+1){
		body 		= "<span class='bodytext'><p>Dear " & qryCorrespondence.forename[i] & "<p>" & "<p>Over the past 12 months you have had full access to <a href='http://www.localgov.co.uk'>LocalGov.co.uk</a>. 
 This access has enabled you to find out who's who, who's where and what's what in local government.<br />
  <br />
You have been able to link from news stories to information about the people making the news, read their biographies and find out their e-mail address.  However, your subscription will expire shortly and your working life will become much more difficult.  Avoid this situation by renewing today.</p>
<p>
  You can renew by phone on +44 (0) 207 973 6694 or by email on <a href='mailto:customer@hgluk.com'>customer@hgluk.com</a>.
Make sure that you re-subscribe today to continue to receive all the information you need on local government.</p><p>Yours sincerely<br /></p><p>Matt Hobley<br />Publisher</p><p>P.S. Don&rsquo;t fall behind - re-subscribe to <a href='http://www.localgov.co.uk'>LocalGov.co.uk</a> today</p></span>";
		
		//attepmt to send
		if ( send(to=qryCorrespondence.username[i], from=variables.strConfig.strVars.customerservices, body=body, subject=subject, bcc="p.mortimer@hgluk.com,m.collins@hgluk.com") )
		/*if ( send(to='m.collins@hgluk.com', body=body, subject=subject & "- " & qryCorrespondence.username[i]) )*/
			//if success, update table
			objSubscriptions.CommittCorrespondence(qryCorrespondence.p_correspondence_id[i] ,sentDate);
			
	}
	
	</cfscript>
	</cffunction> 
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="SendCorporateAccessCode" access="public" returntype="void" output="false" hint="send Corp admin access code and details about corp sub">
		<cfargument name="email" 		 type="string" required="yes" />
		<cfargument name="accesscode" 	 type="string" required="yes" />
		<cfargument name="fullname" 	 type="string" required="yes" />
		
			<cfset var body 		= "">
			<!--LocalGov.co.uk Corporate Subscription Access Code"--->
			
			 <cf_EmailCorpAdmin fullname="#arguments.fullname#"		
			                    accesscode="#arguments.accesscode#"	
								sitepath="#strConfig.strPaths.sitepath#" >	
			<cfset body = Emailcopy>
			<cfset send(to=arguments.email, body=body, subject="LocalGov.co.uk Corporate Subscription Access Code")>
			
	</cffunction> 
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="SendWebinarConfirmationEmail" access="public" output="false" returntype="void" hint="Save User Interest in Specified Webinar">
		<cfargument name="WebinarID" 	type="numeric" 	required="yes">
		<cfargument name="WebinarName" 	type="string" 	required="yes">
		<cfargument name="UserID" 		type="numeric" 	required="yes">
		<cfargument name="strUser" 		type="struct" 	required="yes">
		<cfargument name="WebinarDate" 	type="date" required="yes">
		
		<cfscript>
			var body			= 	"";
			var emailBody		= 	"";
			var from 			= 	"webmaster@localgov.co.uk";
			var bcc				= 	"";
			var cc				= 	"";
			var sendTo			=	arguments.strUser.username;
			var subject 		= 	"LocalGov Webinar: " & arguments.WebinarName;
			var attachmentPath 	=   "";
			var link			=   strConfig.strPaths.sitepath & "webinar/?id=#arguments.WebinarID#";
			var reglink			=   strConfig.strPaths.sitepath & "index.cm?method=webinar.item&amp;id=#arguments.WebinarID#";
			var HoursSinceEvent =   DateDiff("h", WebinarDate, now());//check if has been more than 24 hrs since webinar
		</cfscript>
		 
		<cfoutput><cfsavecontent variable="emailBody">
			<cfif HoursSinceEvent GT 24>
			<p>Thank you for you interest in the #arguments.Webinarname# Webinar.
			<br><br> 
			To view the event, please <a href="#link#">click on this link: </a>

			</p>
			<cfelse>
			<p>
				Thank you for you interest in the #arguments.Webinarname# Webinar.
				
				<br><br>
				You can check that you will be able to view the event on you machine by <a href="#link#">clicking here</a>.
				
				<P>If you would like to recommend that someone else should attend, please forward them to <a href="#reglink#">clicking here</a></P>
				
				<p>If you have any questions, please do not hesitate to contact <a href="mailto:jp.danon@hgluk.com">John-Paul Danon</a>  </p>

				<p>Date	&nbsp;:&nbsp;  #DateFormat(arguments.WebinarDate, "dd mmmm yyyy")# #TimeFormat(arguments.WebinarDate, "hh:mm:ss")#</p>
				
				<p>To make sure you can login to view the event <a href="http://www.localgov.public-i.tv/site/player/pl_compact.php?a=22666&t=0&m=wm&l=en_GB">please click here</a> </p>
			</p>
		</cfif>
		</cfsavecontent></cfoutput>
		
		<cfset send
				(
					to = sendTo
					, body = emailBody
					, subject = subject
					, from = from
					, bcc = bcc
					, cc = cc
					, attachment = attachmentPath
				)>
		
	</cffunction>
	 
	 
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PRIVATE Functions ----------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getCopy" access="private" output="false" returntype="string" hint="return copy form db">
		<cfargument name="articleid" required="yes" type="numeric">
			<cfscript>
			var qryCopy = variables.objArticle.getFull(8, arguments.articleid);
			return qryCopy.story ; 
			</cfscript>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="send" access="private" returntype="boolean" output="false" hint="I send emails WITH THE DISCLAIMER INCLUDED. Can be called directly with a receipt is unnecessary e.g. password reminder">
		<cfargument name="to"      			type="string"  required="yes">
		<cfargument name="body"     		type="string"  required="yes">
		<cfargument name="subject"   	 	type="string"  required="yes">
		<cfargument name="from"     		type="string"  required="no" default="#variables.strConfig.strVars.mailsender#">
		<cfargument name="includeHeaders" 	type="boolean" required="no" default="true">
		<cfargument name="bcc"        		type="string"  required="no" default="">
		<cfargument name="cc"        		type="string"  required="no" default="">
		<cfargument name="attachment" 		type="any"     required="no" default="pass in string for a single attacment or an array for more than 1">
		<cfargument name="reply" 			type="string"  required="no" default="reply address">
			
		<cfscript>
		var bl			=true;
		var filname 	="";
		var bodycopy 	= arguments.body;
		if (arguments.includeHeaders)
			bodycopy = variables.header & "<br /><br />" & arguments.body & variables.footer;
		</cfscript>
		
	   	<cftry>
		
			<!--- send an HTML email --->
			<cfmail	to=		"#arguments.to#"
					from=	"#arguments.from#"
					bcc=	"#arguments.bcc#"
					subject="#arguments.subject#"
					type=	"html">
			 
			<!---check if attachment is array--->
			<cfif isArray(arguments.attachment)>
				<cfloop from="1" to="#ArrayLen(arguments.attachment)#" index="filname">
					 <!---get files to include from array--->
					<cfif FileExists(arguments.attachment[filname])>
						<cfmailparam file="#arguments.attachment[filname]#">
					</cfif>
				</cfloop> 
				
			<cfelse>
				<!---check if attachment has value--->
				<cfif Len(arguments.attachment) and FileExists(arguments.attachment)>
					<!---get file to include --->
					<cfmailparam file="#arguments.attachment#">
				</cfif>
			</cfif> 
			
			<cfif Len(arguments.reply)>
				<cfmailparam name="Reply-To" value="#arguments.reply#">
			</cfif>
					
			#bodycopy#
			</cfmail>
			
			<cfcatch>
				<cfset bl=false>
				<cflog log="application" application="yes" text="Local Gov Email To #arguments.to# FAILED AT #Now()#">
			</cfcatch>
			
	  	</cftry>
		
		<cfreturn bl>
		
	 </cffunction> 
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="send_cfx" access="private" returntype="boolean" output="false" hint="I send emails using cf_mail WITH THE DISCLAIMER INCLUDED. Can be called directly with a receipt is unnecessary e.g. password reminder">
		<cfargument name="to"      			type="string"  required="yes">
		<cfargument name="body"     		type="string"  required="yes">
		<cfargument name="subject"   	 	type="string"  required="yes">
		<cfargument name="from"     			type="string"  required="no" default="#variables.strConfig.strVars.mailsender#">
		<cfargument name="includeHeaders" 	type="boolean" required="no" default="true">
		<cfargument name="bcc"        		type="string"  required="no" default="">
		<cfargument name="cc"        			type="string"  required="no" default="">
		<cfargument name="attachment" 		type="any"     required="no" default="pass in string for a single attacment or an array for more than 1">
		<cfargument name="reply" 			type="string"     required="no" default="reply address">
			
		<cfscript>
			var bl			=true;
			var filname 	="";
			var bodycopy 	= arguments.body;
			if (arguments.includeHeaders)
				bodycopy = variables.header & "<br /><br />" & arguments.body & variables.footer;
			if (NOT Len(arguments.reply)){
				arguments.reply = strConfig.strVars.mailsender;
				}	
		</cfscript>
		
	   	<cftry>
		
			<!--- send an HTML email --->
			<cf_mail	to=		"#arguments.to#"
					from=	"#arguments.from#"
					bcc=	"#arguments.bcc#"
					subject="#arguments.subject#"
					type=	"html" verbose="true" server= "#strConfig.strVars.mailserver#" replyto="#arguments.reply#">
			 
			<!---check if attachment is array--->
			<cfif isArray(arguments.attachment)>
				<cfloop from="1" to="#ArrayLen(arguments.attachment)#" index="filname">
					 <!---get files to include from array--->
					<cfif FileExists(arguments.attachment[filname])>
						<cf_MailAttachment file="#arguments.attachment[filname]#">
					</cfif>
				</cfloop> 
				
			<cfelse>
				<!---check if attachment has value--->
				<cfif Len(arguments.attachment) and FileExists(arguments.attachment)>
					<!---get file to include --->
					<cf_MailAttachment  file="#arguments.attachment#">
				</cfif>
			</cfif> 
			
			<cfoutput>#bodycopy#</cfoutput>
			</cf_mail>
			
			<cfcatch>
				<cfset bl=false>
				<cflog log="application" application="yes" text="Local Gov Email To #arguments.to# FAILED AT #Now()#">
			</cfcatch>
			
	  	</cftry>
		
		<cfreturn bl>
		
	</cffunction> 
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- --- ** NEW FUNCTIONS ** ----------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="sendNewRenewal" access="public" returntype="boolean" output="false" hint="I Send the new renewal emails">
		<cfargument name="to"      			type="string"  required="yes">
		<cfargument name="body"     		type="string"  required="yes">
		<cfargument name="subject"   	 	type="string"  required="yes">
		<cfargument name="from"     		type="string"  required="no" default="#variables.strConfig.strVars.mailsender#">
		<cfargument name="includeHeaders" 	type="boolean" required="no" default="true">
		<cfargument name="bcc"        		type="string"  required="no" default="">
		<cfargument name="cc"        		type="string"  required="no" default="">
		<cfargument name="attachment" 		type="any"     required="no" default="pass in string for a single attacment or an array for more than 1">
		<cfargument name="reply" 			type="string"  required="no" default="reply address">
		
		<cfscript>
			var result = send(argumentCollection=arguments);			
		</cfscript>
		<cfreturn result>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
</cfcomponent>