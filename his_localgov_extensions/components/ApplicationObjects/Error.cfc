<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/ApplicationObjects/Error.cfc $
	$Author: Bhalper $
	$Revision: 12 $
	$Date: 29/07/08 10:59 $

--->

<cfcomponent displayname="Error" hint="Handles all application errors">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="error" hint="Pseudo-constructor">
		<cfargument name="config" type="struct" required="yes">
		
			<cfscript>
			//get site config struct
			variables.strConfig = arguments.config;
			//set config vars into local scope
			//set directory path to folder that holds error logs
			variables.errordir  =  variables.strConfig.strPaths.dirpath &  variables.strConfig.strPaths.errordir;
			//set url path to folder that holds error logs
			variables.errorpath = variables.strConfig.strPaths.sitepath &  variables.strConfig.strPaths.errorpath;
			//create array to hold error logs	
			variables.ArrLog 	= ArrayNew(1);
			//check error directory exists
			Check4ErrorDir();
			return this;
			</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions ------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetVariables" access="public" returntype="struct" hint="returns the Variables scope">
		<cfreturn variables>
	</cffunction>
	
	<cffunction name="GetArrLog" access="public" returntype="array" hint="returns the array that conatins  error logs">
		<cfreturn variables.ArrLog>
	</cffunction>
	
	<cffunction name="ErrorAlert" access="public" output="false" returntype="boolean" hint="log error and send email to alert webmaster of error">
		<cfargument name="error"  		type="any"    required="yes">
		<cfargument name="cgiscope" 	type="struct" required="yes">
		<cfargument name="pagecontent" 	type="any" 	  required="no" default="">
		
		
		<cfscript>
		//create unique name for error file
		var Errorfile 		= CreateUUID() & ".htm";
		var message 		= "";
		var sReturn 		= "";
		var emailboyd 		= "";
		var displayMessage	="";
		var sdump			= "";
		// Log error into memory 
		Add2ArrLog(arguments.error.type, arguments.error.message, arguments.cgiscope.http_user_agent);
		</cfscript>
		
			
			<!--- Check if this error has alrady been sent ---> 
			<cfif CountError(arguments.error.message) lte 1>
			
				<!---create cf log files 
				<cfset cf_log('Error Type: #arguments.error.type#')>
				<cfset cf_log('Error Type: #arguments.error.message#')>
				<!--- write error to file --->--->
				
				<!--- create email body  --->
				<cfsavecontent variable="emailbody">
					<cfoutput>
					<div align="center" style="font-family:Verdana, Arial, Helvetica; font-size:12px">
					<cfif StructKeyExists(request, "sImgPath")>
					<img src="#request.sImgPath#error.jpg"><br>
					</cfif>
					<h3>An unexpected error occurred.</h3>
					<table style="font-family:Verdana, Arial, Helvetica; font-size:12px"><tr><td>
					Error Event: <em>#arguments.error.type#</em><br>
					Error Message: <strong><em>#arguments.error.Message#</em></strong><br>
					Error Date/Time:<em> #Now()#</em><br>
					User's Browser: <em>#arguments.cgiscope.HTTP_USER_AGENT#</em><br>
					Previous Page: <em>#arguments.cgiscope.HTTPReferer#</em><br><br>
					</td></tr></table>
					Error details:<br>
					<!--- <a href="#variables.errorpath##Errorfile#">
					#variables.errorpath##Errorfile#</a> ---></cfoutput>
					</div>
				</cfsavecontent>

				<!--create message for log file --->
				<cfsavecontent variable="message">
				 <p>Error details:<br/>
					<cfdump var="#arguments.error#" 	  expand="yes" label="error">
					<cfdump var="#arguments.cgiscope#"    expand="yes" label="cgi">
					<cfdump var="#form#"   				  expand="yes" label="form">
					<cfdump var="#session#"   			  expand="yes" label="form">
				</cfsavecontent>	
				
			
				<!---write file to h/drive (and check it was done)
				<cfif cf_file(emailbody & message, Errorfile)>
					<!---send email alert--->
					<cfset cf_Email(body=emailbody)> --->
				
					<!---send email alert with dta that was to be saved in file --->
					<cfif arguments.cgiscope.SERVER_NAME contains "admin" or arguments.cgiscope.SCRIPT_NAME contains "admin">
						<cfset sSubject="LocalGov Admin Error">
					<cfelse>
						<cfset sSubject=variables.strConfig.strVars.title & " Error">	
					</cfif>
		
					<cfset cf_Email(body=emailbody & message, subject=sSubject & ": "& arguments.error.message)> 
				
				
			</cfif>
		
		<!--- remove logs from memeory if older than [n] hours --->
		<cfset ClearLogs()>
		<cfreturn true> 	
	</cffunction>
	

	  
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PRIAVTE Functions ----------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="cf_Email" access="private" output="false" returntype="void" hint="Alter error via email">
	  	<cfargument name="to" 		type="string" required="no" default="#variables.strConfig.strVars.errormailto#">
		<cfargument name="from" 	type="string" required="no" default="#variables.strConfig.strVars.mailsender#">
		<cfargument name="body" 	type="string" required="no" default="">
		<cfargument name="subject"	type="string" required="no" default="#variables.strConfig.strVars.title# Error">
		<cfargument name="bcc" 		type="string" required="no" default="">
		<cfargument name="format" 	type="string" required="no" default="html">
			
			<cfmail	to="#arguments.to#"
					from="#arguments.from#"
					bcc="#arguments.bcc#"
					subject="#arguments.subject#"
					type="#arguments.format#">
				#arguments.body#
				
					<div style="font-size: 10px; color:##999999">
						#variables.strConfig.strVars.disclaimer#
					</div>
				
			</cfmail>
		
	</cffunction>	
	
	<cffunction name="cf_log" access="private" output="false" returntype="void" hint="Write colfusion error log">
		<cfargument name="text" type="string" required="yes">

			<cflog type="error" text="Error Type: #arguments.text#" application="yes">
		
	</cffunction>
	
	
	<cffunction name="cf_file" access="private" output="false" returntype="boolean" hint="Write colfusion error log">
		<cfargument name="content"  required="yes" type="string">
		<cfargument name="filename" required="yes" type="string">
		
			<cfset var bl = false>
			<cfset var filenamepath  = variables.errordir & arguments.filename>
			<!--- write the error file to the errors folder --->
			
			<cffile action="WRITE" 
				output="#arguments.content#" 
				file="#filenamepath#"
				nameconflict="makeunique">
			
			<cfif FileExists(filenamepath)>
				<cfset bl = true>
			</cfif>
			
			<cfreturn bl>
	</cffunction>
	
	
	<cffunction name="Add2ArrLog" access="private" output="false" returntype="void" hint="add a error details structure to erro log held in memory">
		<cfargument name="errortype" 		required="yes" type="string">
		<cfargument name="message" 			required="yes" type="string">
		<cfargument name="user" 		 	required="yes" type="string">
		<cfargument name="ErrordateTime" 	required="no"  default="#Now()#">
		
			<cfset ArrayAppend(variables.ArrLog, arguments)>
	
	</cffunction>
	
	<cffunction name="CountError" access="private" output="false" returntype="numeric" hint="return a count of how many times the same error has been logged within the last [n] minutes)">
		<cfargument name="message" required="yes" type="string">
		
			<cfscript>
			var arr = variables.ArrLog;
			var i="";
			var ErrorDate="";
			var ErrorTime="";
			var NoErrors =0;
			var date = lsDateFormat(Now(), "ddmmyy");
			var dtime = LsTimeFormat(now(), "hh:mm:ss");
			
			//loop over array of logs 
			for (i=1;i LTE arrayLen(arr);i=i+1 ){
				//check if current structure has the same message
				If (arguments.message EQ arr[i].message) {
				  //set day of error
				  ErrorDate = lsDateFormat(arr[i].ErrordateTime, "ddmmyy");
				  //set time of error
				  ErrorTime = lsTimeFormat(arr[i].ErrordateTime, "hh:mm:ss");
				  //check if this error was logged within the last [n] minutes
				  If (date eq ErrorDate AND DateDiff("n", dtime, ErrorTime) lte variables.strConfig.strVars.ErrorFrequncy)
					 //add to count of the same error logged 	
					 NoErrors=NoErrors + 1;
				}
			 }
			 return NoErrors;		
			</cfscript> 
			<!--- <cfdump var="#arr#"><cfdump var="#NoErrors#"><Cfabort> --->
	</cffunction>
	
	<cffunction name="Check4ErrorDir" access="private" returntype="void" output="false" hint="create directory that holds logs if not already present">
		<cfif Not DirectoryExists(variables.errordir)>
			<cfdirectory action="create" directory="#variables.errordir#">
		</cfif>
	</cffunction> 
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
		
	<cffunction name="ClearLogs" access="private" returntype="void" output="false" hint="remove logs from memeory if older than [n] hours">

		  <cfscript>
		 	var arr = variables.ArrLog;
			var i="";
			var ErrorDate="";
			var ErrorTime="";
			var date = lsDateFormat(Now(), "ddmmyy");
			var dtime = LsTimeFormat(now(), "hh:mm:ss");
			
			//loop over array of logs in memory
			for (i=1;i LTE arrayLen(arr);i=i+1 ){
				//set day of error
				ErrorDate = lsDateFormat(arr[i].ErrordateTime, "ddmmyy");
				//set time of error
				ErrorTime = lsTimeFormat(arr[i].ErrordateTime, "hh:mm:ss");
				//check if curent log has been in memeory for more than [n] hours
				If (date eq ErrorDate AND DateDiff("h", dtime, ErrorTime) lte variables.strConfig.strVars.ErrorPersist) {
				 ArrayDeleteAt(arr, i); 
				 //array length has now changed so reset position of [i] back to 0	
				 i=0;
				}
			}
		 </cfscript>

	</cffunction> 	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="ErrorStatus" access="public" returntype="struct" hint="evaluate if" output="false">
		<cfargument name="error"  		type="any"    required="yes">
		<cfargument name="event"  		type="string"    required="yes">
		
	
		<cfscript>
		var strReturn 		= StructNew();
		strReturn.IsError 	= true;
		strReturn.statusCode = 200;
		if (StructKeyExists(arguments.error, 'rootCause')){
			If (arguments.error.rootCause.type eq "coldfusion.runtime.AbortException")
				strReturn.IsError=false;
		}
		
		switch(arguments.error.type){
			case "InvalidSearch":
				strReturn.IsError=false;
				break;
		}
		
		switch(arguments.error.message){
			case "Event Handler Exception":
				strReturn.IsError=false;
				break;
			case "The value returned from function getMID() is not of type numeric":{
				strReturn.IsError=false;
				strReturn.statusCode=404;
				break;
				}
			case "undefined Fuseaction":{
				strReturn.IsError=false;
				strReturn.statusCode=404;
				break;}	
			case "Element FUSEBOX.FUSEACTIONVARIABLE is undefined in APPLICATION":
				strReturn.IsError=false;
				break;
			case "":{
				strReturn.IsError=false;
				break;	
				}		
					
		}
		
		switch(arguments.event){
			case "onSessionEnd":
				strReturn.IsError=false;
				break;
			case "onApplicationEnd":
				strReturn.IsError=false;
				break;
			case "java.lang.IllegalStateException":
				strReturn.IsError=false;
				break;	
	
		}
		
		return strReturn;	
		</cfscript> 
	
	</cffunction> 
</cfcomponent>