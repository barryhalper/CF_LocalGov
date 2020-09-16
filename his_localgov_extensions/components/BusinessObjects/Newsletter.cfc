<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/BusinessObjects/Newsletter.cfc $
	$Author: Bhalper $
	$Revision: 14 $
	$Date: 26/11/09 16:14 $

--->

<cfcomponent displayname="Newsletter" hint="Newsletter business functions" extends="his_Localgov_Extends.components.BusinessObjectsManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Newsletter" hint="Pseudo-constructor">

		<cfargument name="objAppObjs" type="any" required="yes" hint="The application manager object">
		<cfargument name="objBusObjs" type="any" required="yes" hint="The business object">
		
		<cfscript>
		// Call the genric init function, placing business, app, and dao objects into a local scope...
		StructAppend( variables, Super.initChild( arguments.objAppObjs, this, arguments.objBusObjs ) );
		//variables.header = variables.objUtils.GetContentFromInclude(variables.strConfig.strPaths.includepath & variables.strConfig.strPaths.emailpath & "dsp_NewsletterheaderV2.cfm");
		loadHeader();
		return this;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions ------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetVariables" access="public" output="false" returntype="struct" hint="return local scope to caller">
		<cfreturn variables>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetNewsletters" access="public"  returntype="query" hint="Get Newsletters" output="no">
		<cfreturn objDAO.GetNewsletters()>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetNewsletterDetail" access="public"  returntype="query" hint="Get Newsletters" output="no">
		<cfargument name="NewsletterID" required="yes" type="numeric">
		
			<cfscript>
			var qryNewsletter = objDAO.GetNewsletterDetail(arguments.NewsletterID);
			var imglink  	  = '="http://admin.localgov.co.uk/his_localgov/';
			var copy 		  = qryNewsletter.bodytext;
			if  (strConfig.strVars.environment neq 'live')
				imglink 	  = '="' & strConfig.strPaths.sitepath ;
			
			if (qryNewsletter.recordcount){
				copy 			  = replace(qryNewsletter.bodytext, '="/his_localgov/', imglink, 'all');		
				QuerySetCell(qryNewsletter, 'bodytext', copy, 1);
				}
			
			return qryNewsletter;
			</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetNewsletterByDate" access="public"  returntype="query" hint="Get Newsletters" output="no">
		<cfargument name="senddate" required="yes" type="numeric" default="#now()#" >
		<cfreturn objDAO.GetNewsletterByDate(variables.strConfig.strVars.mediacode, createODBCDate(arguments.senddate))>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetNewsletterByid" access="public"  returntype="query" hint="Get Newsletters" output="no">
		<cfargument name="Id" 		 required="yes" type="numeric" >
		<cfargument name="isSent"    required="no" 	 type="boolean"  default="0">
			<cfreturn objDAO.GetNewsletterByid(arguments.Id, arguments.isSent)>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="loadHeader" access="public"  returntype="void" hint="reset Newsetter from variables" output="no">
		<cfscript>
		variables.header = "";
		variables.header = variables.objUtils.GetContentFromInclude(variables.strConfig.strPaths.includepath & variables.strConfig.strPaths.emailpath & "dsp_Newsletterheader.cfm");
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="CommitNewsletter" access="public" returntype="numeric" hint="insert/update newsletter details" output="no">
		<cfargument name="NewsletterID" required="true"  type="any">
		<cfargument name="BodyText" 	required="true"  type="string">
		<cfargument name="SendDate" 	required="true"  type="date">
		<cfargument name="Subject" 		required="true"  type="string">
		<cfargument name="MediaCode" 	required="false" type="string"  default="#variables.strconfig.strVars.Mediacode#">
		<cfargument name="topicid" 		required="false" type="numeric"  default="0">
		
		<cfreturn objDAO.CommitNewsletter(argumentcollection=arguments)>
		
	</cffunction>	
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="CommitCopy" access="public" returntype="void" hint="Add conent to newsletter " output="no">
		<cfargument name="NewsletterID" required="true"  type="any">
		<cfargument name="UID" 	required="true"  type="string">
		<cfargument name="IsJob" 	required="true"  type="boolean">
		
		<cfreturn objDAO.CommitCopy(argumentcollection=arguments)>
		
	</cffunction>	
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getNewsletterebyContent" access="public" returntype="query" hint="get newsletterid for a specific piece of content">
		<cfargument name="uid"  type="numeric"  required="yes" hint="content id">
		<cfargument name="isJob" type="boolean" required="yes" hint="">
		
			<cfreturn objDAO.getNewsletterebyContent(argumentcollection=arguments)>
	
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="DeleteNewsletter" access="public"  returntype="boolean" hint="remove newsltter from db" output="no">
		<cfargument name="NewsletterID" required="yes" type="numeric" >
		<cfset objDAO.DeleteNewsletter(arguments.NewsletterID)>
		<cfreturn true>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="prepareCopy" access="public" returntype="string" hint="return newsletter copy" output="no">
		<cfargument name="bodytext"  required="yes" type="string">
		<cfargument name="adlinkurl" required="yes" type="string">
		<cfargument name="topicid"  required="no" 	type="numeric" default="0">
		
		
		<cfscript>	
			var topads 		 	= "";
			var copy          	= variables.header;
			var siteVersionLink = "";
	
			//panel 1
			var rightadspanel = objAds.OutputNewsLetterAd(objAds.GetAdsforOutput('newsletter', '', 15, 3), 15, 3, Arguments.adlinkurl,120,150, Arguments.topicid);
	 	 	//panel 2
	 		rightadspanel =  rightadspanel & objAds.OutputNewsLetterAd(objAds.GetAdsforOutput('newsletter', '', 15, 4), 15, 4, Arguments.adlinkurl, 120,150, Arguments.topicid);
	  		//panel 3
	 		rightadspanel =  rightadspanel & objAds.OutputNewsLetterAd(objAds.GetAdsforOutput('newsletter', '', 15, 5), 15, 5, Arguments.adlinkurl,120,150, Arguments.topicid);
			//panel 4
			rightadspanel =  rightadspanel & objAds.OutputNewsLetterAd(objAds.GetAdsforOutput('newsletter', '', 15, 8),15, 8, Arguments.adlinkurl,120,150, Arguments.topicid);
			//panel 5
			rightadspanel =  rightadspanel & objAds.OutputNewsLetterAd(objAds.GetAdsforOutput('newsletter', '', 15, 9),15, 9, Arguments.adlinkurl,120,150, Arguments.topicid);
				
			topads 		   = objAds.OutputNewsLetterAd(objAds.GetAdsforOutput('newsletter', '', 14, 1 ), 14, 1,  Arguments.adlinkurl,120,150, Arguments.topicid);
			
			copy           = replace(copy, "|pagecontent|", trim(Arguments.bodytext));
			copy           = replace(copy, "|rightpanel|",  trim(rightadspanel));
			copy           = replace(copy, "|topads|",  trim(topads));	
			//copy 		   = replace(copy, "192.168.1.149/his_localgov/", "www.localgov.co.uk/", "all");
						
			return copy;	
		</cfscript>
		
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="UpdateNewsletter" access="public" returntype="void" hint="mark newsletter as sent" output="false">
		<cfargument name="id" required="yes" type="numeric">
		
		<cfset var SQLString = "UPDATE tblNewsletters SET isSent = 1 WHERE p_newsletter_id =" & Arguments.id>
		<cfset objDAO.query(SQLString, variables.strConfig.strVars.dsn1)>
	
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="addToQueue" access="public" returntype="boolean" output="false" hint="Add Newsletter emails to the queue for sending by the scheduled job">
		<cfargument name="to"      			type="string"  required="yes">
		<cfargument name="userid"			type="numeric" required="yes">
		<cfargument name="body"     		type="string"  required="yes">
		<cfargument name="subject"   	 	type="string"  required="yes">
		<cfargument name="newsletterID" 	type="numeric" required="yes">
		<cfargument name="topicid"			type="numeric" required="no" default="0">
		<cfargument name="from"     		type="string"  required="no" default="#variables.strConfig.strVars.mailsender#">
		<cfargument name="reply" 			type="string"  required="no" default="reply address">
		
		
		<cfset var bl = objDAO.addToQueue(to=arguments.to,
											userid=arguments.userid,
											body=arguments.body,
											subject=arguments.subject,
											newsletterID = arguments.newsletterID,
											topicid=arguments.topicid,
											from=arguments.from,
											reply=arguments.reply)>
		
		<cfreturn bl>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="updateNewsletterCopy" access="public" returntype="void" hint="Write the generated copy back to the queue table">
		<cfargument name="id"     		type="numeric"  required="yes">
		<cfargument name="body"     		type="string"  required="yes">
		
		<cfset objDAO.updateNewsletterCopy(id=arguments.id, body=arguments.body)>
		
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getNewslettersToGen" access="public" returntype="query" hint="return top 250 newsletter email for generating">
		<cfreturn objDAO.getNewslettersToGen()>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getQueuedNewsletters" access="public" returntype="query" hint="return top 250 newsletter email for sending">
		<cfreturn objDAO.getQueuedNewsletters()>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="setSent" access="public" returntype="void" hint="updated record as sent">
		<cfargument name="newsletterQueueID" type="numeric" required="yes">
		
		<cfset objDAO.setSent(arguments.newsletterQueueID)>
		
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="webBug" access="public" returntype="void" hint="update user derailed and return web bug">
		<cfargument name="id" type="numeric" required="yes">
		
		<cfset objDAO.webBug(arguments.id)>		
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getCopy" access="public" returntype="struct" hint="Get the datasets for the body copy">
		<cfargument name="id" type="numeric" required="yes" hint="newsletter id">
		
		<cfreturn objDAO.getCopy(arguments.id)>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="setCopy" access="public" returntype="string" hint="Get the datasets for the body copy and set it into html">
		<cfargument name="id" type="numeric" required="yes" hint="newsletter id">
		
		<cfset var str = getCopy(arguments.id)>
		<cfset var html = "">
			<cfsavecontent variable="html">
				<cfinclude template="/his_LocalGov/view/email/dsp_NewsLetterCopy.cfm"/> 
			</cfsavecontent>
			
			<cfreturn html>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getNewsletterStats" access="public" returntype="struct" hint="Get the send/open statistics of the newsletter">
		<cfargument name="id" type="numeric" required="yes">
		
		<cfreturn objDAO.getNewsletterStats(arguments.id)>
	</cffunction>
</cfcomponent>