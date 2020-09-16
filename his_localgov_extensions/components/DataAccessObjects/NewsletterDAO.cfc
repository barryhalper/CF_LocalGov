<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/DataAccessObjects/NewsletterDAO.cfc $
	$Author: Bhalper $
	$Revision: 8 $
	$Date: 24/11/09 15:34 $

--->

<cfcomponent displayname="Newsletter" hint="Newsletter DAO" extends="his_Localgov_Extends.components.DAOManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="NewsletterDAO" hint="Pseudo-constructor">
		
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		StructAppend( variables, Super.init( arguments.strConfig ) );

		return this;
		</cfscript>
						
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions ------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<cffunction name="GetTemplates" access="public"  returntype="query" hint="Return details of Newsletter templates" output="no">
			<cfargument name="TemplateID" required="false" type="numeric" default="">
				<cfset var qrytemplates="">

				<cfquery datasource="#variables.DSN1#" name="qrytemplates">
					EXEC sp_GetNewsLetterTemplates
					@TemplateID = #arguments.TemplateID#,
					@MediaCode = '#variables.strConfig.strVars.MediaCode#'
				</cfquery>	
				
				<cfreturn	qrytemplates>
		</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<cffunction name="GetNewsletters" access="public"  returntype="query" hint="Get Newsletters" output="no">
		
		<cfset var qryNewsLetters="">
					
			<cfquery datasource="#variables.DSN1#" name="qryNewsLetters">
				 EXEC sp_GetNewsletters
				 @MediaCode = '#variables.strConfig.strVars.MediaCode#'
				</cfquery>
					
		<cfreturn qryNewsLetters>
	</cffunction>	
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<cffunction name="GetNewsletterDetail" access="public"  returntype="query" hint="Get Newsletters" output="no">
		<cfargument name="NewsletterID" required="yes" type="numeric" >
		<cfset var qryNewsLetter="">
					
			<cfquery datasource="#variables.DSN1#" name="qryNewsLetter">
				 EXEC sp_GetNewsletterDetail
				 @NewsletterID = #arguments.NewsletterID#
				</cfquery>
					
		<cfreturn qryNewsLetter>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<cffunction name="GetNewsletterByDate" access="public"  returntype="query" hint="Get Newsletters" output="no">
		<cfargument name="Mediacode" required="yes" type="string" >
		<cfargument name="SendDate"  required="yes" type="date" >
		<cfset var qryNewsLetter="">
					
			<cfquery datasource="#variables.DSN1#" name="qryNewsLetter">
				 EXEC sp_GetNewsletterbyDate
				 @Mediacode = '#arguments.Mediacode#',
				 @SendDate = #arguments.SendDate#
				</cfquery>
					
		<cfreturn qryNewsLetter>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetNewsletterByid" access="public"  returntype="query" hint="Get Newsletter by id" output="no">
		<cfargument name="Id" 		 required="yes" type="numeric" >
		<cfargument name="isSent"    required="no" 	 type="boolean"  default="0">
		<cfset var qryNewsLetter="">
					
			<cfquery datasource="#variables.DSN1#" name="qryNewsLetter">
				 EXEC sp_GetNewsletterbyID
				 @Id = #arguments.Id#
				</cfquery>
					
		<cfreturn qryNewsLetter>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- COMMITT FUNCTIONS ----------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="CommitTemplates" access="public"  returntype="numeric" hint="insert/update Newsletter templates" output="no">
		<cfargument name="TemplateID" 	required="true" type="any">
		<cfargument name="MediaCode"  	required="true" type="string">
		<cfargument name="Email" 		required="true" type="string">
		<cfargument name="Template" 	required="true" type="string">
		
		<cfscript>
		//Check if primary key is present
		var ReturnID ="";
		If (IsNumeric(arguments.TemplateID))
			   // If primary key is present, prepare stored proc to perform update 
			{TemplateID = arguments.TemplateID;
				NullValue = "No";}
		else
			// prepare stored proc to perform insert 
			{TemplateID = "";
			NullValue = "yes";}	
		</cfscript>
			
			<!---Exec Stored Proc --->
			<cfstoredproc  datasource="#variables.DSN1#" procedure="spAddNewsletterTemplates">
				<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@TemplateID"  value="#TemplateID#" null="#NullValue#">
				<cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@MediaCode" value="#arguments.MediaCode#">
				<cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@Email" value="#arguments.Email#">
				<cfprocparam type="in"  cfsqltype="cf_sql_longvarchar" dbvarname="@Template" value="#arguments.template#">
					<cfprocparam type="out" cfsqltype="cf_sql_integer" dbvarname="@NewTemplateID" variable="ReturnID">
			</cfstoredproc>
		
		<cfreturn ReturnID>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="CommitNewsletter" access="public" returntype="numeric" hint="insert/update newsletter details" output="no">
		<cfargument name="NewsletterID" required="true" type="any">
		<cfargument name="BodyText" 	required="true" type="string">
		<cfargument name="SendDate" 	required="true" type="date">
		<cfargument name="Subject" 		required="true" type="string">
		<cfargument name="MediaCode" 	required="true" type="string">
		<cfargument name="topicid" 		required="false" type="numeric"  default="0">
	
			<cfscript>
			////Check if primary key is present
			var ReturnID =0;
			If (IsNumeric(arguments.NewsletterID))
				   // If primary key is present, prepare stored proc to perform update 
				{NewsletterID = arguments.NewsletterID;
					NullValue = "No";}
			else
				// prepare stored proc to perform insert 
				{NewsletterID = "";
				NullValue = "yes";}	
			</cfscript>		
						
				<!---Exec Stored Proc --->
				<cfstoredproc  datasource="#variables.DSN1#" procedure="sp_CommitNewsletter">
						<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@NewsletterID"  value="#NewsletterID#" null="#NullValue#">
						<cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@MediaCode" value="#arguments.MediaCode#">
						<cfprocparam type="in"  cfsqltype="cf_sql_longvarchar" dbvarname="@BodyText" value="#arguments.BodyText#">
						<cfprocparam type="in"  cfsqltype="cf_sql_timestamp" dbvarname="@SendDate" value="#dateformat(arguments.SendDate, 'dd/mm/yyyy')# #Timeformat(now())#">
						<cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@Subject" value="#arguments.Subject#">
						
						<cfif arguments.topicid>
							<cfprocparam type="in"  cfsqltype="cf_sql_integer" dbvarname="@topicid" value="#arguments.topicid#">
						<cfelse>
							<cfprocparam type="in"  cfsqltype="cf_sql_integer" dbvarname="@topicid" value="" null="yes">	
						</cfif>
						
						<cfprocparam type="out" cfsqltype="cf_sql_integer" dbvarname="NewNewsLetterID" variable="ReturnID">
				</cfstoredproc>	


		<cfreturn ReturnID>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="CommitCopy" access="public" returntype="void" hint="Add conent to newsletter " output="no">
		<cfargument name="NewsletterID" required="true"  type="any">
		<cfargument name="UID" 	required="true"  type="string">
		<cfargument name="IsJob" 	required="true"  type="boolean">
		
		<cfstoredproc  datasource="#variables.DSN1#" procedure="sp_CommitContentToNewsletter">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@NewsletterID"  value="#arguments.NewsletterID#" >
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@UID"  value="#arguments.UID#" >
			<cfprocparam type="in" cfsqltype="cf_sql_bit"     dbvarname="@IsJob"  value="#arguments.IsJob#" >
		</cfstoredproc>
		
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="DeleteNewsletter" access="public"  hint="Delete a particular newsletter" output="no" returntype="boolean">
		<cfargument name="NewsletterID" required="true" type="numeric">
			<!---Exec Stored Proc --->
			<cfstoredproc  datasource="#variables.DSN1#" procedure="spDeleteNewsletter">
				<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@NewsletterID" value="#arguments.NewsletterID#">
			</cfstoredproc>
		<cfreturn true>
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
		
		<cfstoredproc  datasource="#variables.DSN5#" procedure="usp_addToNewsletterQueue">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@NewsletterID"  value="#arguments.NewsletterID#">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@topicid" value="#arguments.topicid#">
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@to" value="#arguments.to#">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@userid" value="#arguments.userid#">
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@body" value="" null="yes">
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@subject" value="#arguments.subject#">
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@from" value="#arguments.from#">
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@reply" value="#arguments.reply#">
		</cfstoredproc>
		
		<cfreturn true>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getNewslettersToGen" access="public" returntype="query" output="false">
		<cfset var qryGenList = querynew("temp")>
					
		<cfquery datasource="#variables.DSN5#" name="qryGenList" maxrows="250">
			EXEC usp_getNewslettersToGenerate
		</cfquery>
					
		<cfreturn qryGenList>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="updateNewsletterCopy" access="public" returntype="void" hint="Write the generated copy back to the queue table">
		<cfargument name="id"     		type="numeric"  required="yes">
		<cfargument name="body"     		type="string"  required="yes">
		
		<cfstoredproc  datasource="#variables.DSN5#" procedure="usp_updateNewsletterCopy">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@newsletterQueueID"  value="#arguments.id#">
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@bodycopy" value="#arguments.body#">
		</cfstoredproc>
		
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getQueuedNewsletters" access="public" returntype="query" output="false">
		<cfset var qrySendList = querynew("temp")>
					
		<cfquery datasource="#variables.DSN5#" name="qrySendList">
			EXEC usp_getNewslettersToSend
		</cfquery>
					
		<cfreturn qrySendList>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="setSent" access="public" returntype="void">
		<cfargument name="newsletterQueueID" type="numeric" required="yes">
		
		<cfquery datasource="#variables.DSN5#" name="qrysetSent">
			EXEC usp_setNewsletterSent #arguments.newsletterQueueID#
		</cfquery>
		
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="webBug" access="public" returntype="void">
		<cfargument name="id" type="numeric" required="yes">
		
		<cfquery datasource="#variables.DSN5#" name="qrywebBug">
			EXEC usp_setNewsletterOpened #arguments.id#
		</cfquery>	
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getCopy" access="public" returntype="struct" hint="Get the datasets for the body copy">
		<cfargument name="id" type="numeric" required="yes" hint="newsletter id">
		
		<cfset var strCopy = structnew()>
		
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_getLocalGovNewsletterCopy ">
			<cfprocparam dbvarname="@newsletterID" value="#arguments.id#" cfsqltype="cf_sql_integer" type="in" null="no">
			
			<cfprocresult name="strCopy.qryNews" resultset="1">
			<cfprocresult name="strCopy.qryJobs" resultset="2">
		</cfstoredproc>
		
		<cfreturn strCopy>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getNewsletterebyContent" access="public" returntype="query" hint="get newsletterid for a specific piece of content">
		<cfargument name="uid"  type="numeric"  required="yes" hint="content id">
		<cfargument name="isJob" type="boolean" required="yes" hint="">
		
		<cfset var qry = querynew("temp")>
		<cfquery datasource="#variables.DSN1#" name="qry">
			EXEC sp_getNewsletterContentbyID #arguments.uid#,  #arguments.isJob#
		</cfquery>	
		
		
		<cfreturn qry>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getNewsletterStats" access="public" returntype="struct" hint="Get the send/open statistics of the newsletter">
		<cfargument name="id" type="numeric" required="yes">
		
		<cfset var strNewsletterStats = structnew()>
		
		<cfstoredproc datasource="#variables.DSN5#" procedure="usp_getNewsletterStats">
			<cfprocparam dbvarname="@id" value="#arguments.id#" cfsqltype="cf_sql_integer" type="in" null="no">
			
			<cfprocresult name="strNewsletterStats.all" resultset="1">
			<cfprocresult name="strNewsletterStats.chart" resultset="2">
		</cfstoredproc>
		
		<cfreturn strNewsletterStats>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PRIAVTE Functions ----------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->

</cfcomponent>