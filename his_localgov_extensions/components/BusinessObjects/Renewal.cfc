<cfcomponent displayname="Renewal" hint="Letter-related business functions" extends="his_Localgov_Extends.components.BusinessObjectsManager">
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR -------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Renewal" hint="Pseudo-constructor">
		<cfargument name="objAppObjs" type="any" required="yes" hint="The application objects">
		<cfargument name="objBusObjs" type="any" required="yes" hint="The business objects">
		
		<cfscript>
		// Call the genric init function, placing business, app, and dao objects into a local scope...
		StructAppend( variables, Super.initChild( arguments.objAppObjs, this ) );
		//variables.strAdSelects = GetAdSelects();
		
		return this;
		</cfscript>
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getInstance" access="public" returntype="struct">
		<cfreturn instance>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetEmailByID" access="public" output="false" returntype="Query" hint="return a single letter">
		<cfargument name="EmailID" 		type="numeric" 	required="yes">
		<cfargument name="EmailType" 	type="string" 	required="no" default="renewal">
		
		<cfreturn objDAO.GetEmailByID(argumentCollection=arguments)>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="SaveEmail" access="public" output="false" returntype="numeric" hint="Save Letter to db">
		<cfargument name="EmailID" 		type="numeric" 	required="no">
		<cfargument name="EmailSubject" type="string" 	required="yes">
		<cfargument name="LetterID" 	type="numeric" 	required="yes">
		<cfargument name="DaysPrior"	type="numeric"	required="yes">
		<cfargument name="EmailType"	type="string"	required="yes">
		<cfargument name="IsActive"		type="numeric"	required="no" default="1">
		
		<cfreturn objDAO.SaveEmail(argumentCollection=arguments)>
			
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="DeleteEmail" access="public" output="false" returntype="void" hint="Delete Email from db">
		<cfargument name="EmailID"	type="numeric" 	required="no">
		
		<cfreturn objDAO.DeleteEmail(arguments.EmailID)>
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="GetLookups" access="public" output="false" returntype="struct" hint="return necessary data to populate select menus">
		<cfargument name="refresh" type="boolean" default="false">
		
		<cfscript>
			var strLookUps=StructNew();
			if (StructKeyExists(instance, "strLookUps") and NOT arguments.refresh) 
				strLookUps = instance.strLookUps;
			else{
				strLookUps = objDAO.GetLookups();
				instance.strLookUps = strLookUps;
				}
			return strLookUps;
		</cfscript>
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="GetAllEmails" access="public" output="false" returntype="query" hint="return all letters">
		<cfreturn objDAO.GetAllEmails()>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="GetAllEmailsByType" access="public" output="false" returntype="query" hint="Return all emails by type">
		<cfargument name="emailType" type="string" required="true">
		
		<cfreturn objDAO.GetAllEmailsByType(arguments.emailType)>
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="GetRenewalUsers" access="public" output="false" returntype="query" hint="Return all users within the renewal series time period">
		<cfargument name="startPeriod" type="numeric" required="true">
		
		<cfscript>
			var renewalDate = DateAdd('d',arguments.startPeriod,now());
			
			return objDAO.GetRenewalUsers('#renewalDate#');
		</cfscript>
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="SendRenewalEmail" access="public" output="false" returntype="void" hint="Send the specified renewal email to specified user">
		<cfargument name="UserID" 				type="Numeric" required="true">
		<cfargument name="toAddress" 			type="String"  required="true">
		<cfargument name="SubscriptionID" 		type="Numeric" required="true">
		<cfargument name="SubscriptionPeriodID" type="Numeric" required="true">
		<cfargument name="EmailID" 				type="Numeric" required="true">
		<cfargument name="LetterID" 			type="Numeric" required="true">
		<cfargument name="DateSent" 			type="String"  required="true">
		<cfargument name="Subject"				type="String"  required="true">
		<cfargument name="objLetter" 			type="his_Localgov_Extends.components.BusinessObjects.Letter" 			required="false" default="#request.objBus.objLetter#">
		<cfargument name="objEmail" 			type="his_Localgov_Extends.components.BusinessObjects.Email" 			required="false" default="#request.objBus.objEmail#">
		<cfargument name="objCorrespondence" 	type="his_Localgov_Extends.components.BusinessObjects.Correspondence" 	required="false" default="#request.objBus.objCorrespondence#">
		<cfargument name="objUser" 				type="his_Localgov_Extends.components.BusinessObjects.User" 			required="false" default="#request.objBus.objUser#">
		
		<cfscript>
			var from = 	request.strsiteconfig.strVars.subscriptions;
			var bcc = "";
			var HTMLEmail = "";
			var x = 0;
			
			
			//1. Retrieve details about user receiving renewal email
			var qryUser = arguments.objUser.getUserDetailsByID(arguments.UserID);
			
			//2. Retrieve the content of the email to be sent and set teh content into local variable
			var qryLetter = arguments.objLetter.GetLetterByID(arguments.LetterID);
			HTMLEmail = qryLetter.LetterContent;
			
			//3. Customise email by filling in personal details in email
			//Fill in User's name
			HTMLEmail = ReplaceNocase(HTMLEmail, "[Name]", "#qryUser.Forename# #qryUser.Surname#");
			
			HTMLEmail = ReplaceNocase(HTMLEmail, 'src="/library/images/', 'src="#request.strsiteconfig.strPaths.sitepath##request.strsiteconfig.strPaths.imagepath#');
			
			//3.5 Add Registrants table to Info Email
			if(arguments.EmailID eq 6 and arguments.LetterID eq 7)
			{
				qryRegistrants = request.objBus.objUser.getCorpRegistrants(arguments.SubscriptionID);
				
				HTMLEmail = HTMLEmail & '<br /><br />
				<table border="1">
					<tr>
						<td>Username</td>
						<td>Forename</td>
						<td>Surname</td>
						<td>Joined</td>
					</tr>
				';
				
				for(x=1; x LTE qryRegistrants.recordCount; x=x+1)
				{
					HTMLEmail = HTMLEmail & "
						<tr>
							<td>#qryRegistrants.username[x]#</td>
							<td>#qryRegistrants.forename[x]#</td>
							<td>#qryRegistrants.surname[x]#</td>
							<td>#dateformat(qryRegistrants.dtSubStarted[x],'dd/mm/yyyy')#</td>
						</tr>
					";
				}
				
				HTMLEmail = HTMLEmail & '</table>';
			}
			
			//4. Now send the email to user
			arguments.objEmail.sendNewRenewal(arguments.toAddress,HTMLEmail,arguments.Subject,from,1,bcc,'','','');		
			
			//5. Record sending of email
			arguments.objCorrespondence.saveCorrespondence
			(
				UserID 					= arguments.UserID
				, ToAddress 			= arguments.toAddress
				, DateSent 				= arguments.DateSent
				, SubscriptionID 		= arguments.SubscriptionID
				, SubscriptionPeriodID 	= arguments.SubscriptionPeriodID
				, EmailID 				= arguments.EmailID
				, HTMLEmail				= HTMLEmail
			);
		</cfscript>
		
		<!--- <cfdump var="#qryLetter#"><br><br>
		<cfdump var="#arguments#"><cfabort> --->
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	
	<cffunction name="sendCorp3MonthInfo" access="public" output="false" returntype="void" hint="Send the tri-monthly email updating corp admins on registrants">
	
		<cfscript>
			var qryCorpAdmins = "";
			var qryInfoEmails = "";
			var j = 0;
			var lastDate = DateAdd('d', -90, now());
			var DateSent = now();
			
			//Get corp admin users who should get an email
			qryCorpAdmins = request.objBus.objUser.getUserDetailsByTypeID(id = '5');
			
			//Now get the info emails
			qryInfoEmail = GetAllEmailsByType(emailType = 'Info');
			
			for(j=1; j LTE qryCorpAdmins.recordCount; j=j+1)
			{
				
				lastEmail = request.objBus.objCorrespondence.GetInfoCorrespondenceByUser(qryCorpAdmins.UserID[j]);
				//If admin has never had an email and is over 3 month old, or the last email they got was more then 3 month ago
				if (qryCorpAdmins.EndDate[j] gte now() and ((not lastEmail.recordcount and qryCorpAdmins.datecreated[j] lte lastDate) or (lastEmail.recordcount and lastEmail.datesent lte lastDate)))
				{
					
					SendRenewalEmail
					(
						UserID 					= qryCorpAdmins.UserID[j],
						toAddress				= qryCorpAdmins.Email[j],
						SubscriptionID 			= qryCorpAdmins.SubscriptionID[j],
						SubscriptionPeriodID 	= qryCorpAdmins.SubscriptionPeriodID[j],
						EmailID					= qryInfoEmail.EmailID,
						LetterID				= qryInfoEmail.LetterID,
						DateSent				= DateSent,
						Subject					= qryInfoEmail.Subject
					);
				}
			}
		</cfscript>
		
		<cfsetting showdebugoutput="yes">
	
	</cffunction>
	
</cfcomponent>