<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/DataAccessObjects/SurveyDAO.cfc $
	$Author: Hbehnia $
	$Revision: 5 $
	$Date: 10/10/08 11:54 $

--->

<cfcomponent displayname="SurveyDAO" hint="Survey-related data access methods" extends="his_Localgov_Extends.components.DAOManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="SurveyDAO" hint="Pseudo-constructor">
		
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
			StructAppend( variables, Super.init( arguments.strConfig ) );
	
			return this;
		</cfscript>
						
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions ------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetLatest" access="public" output="false" returntype="query" hint="return data for latest E-Poll">
	
		<cfset var qryReturn = "">
	
		<cfquery name="qryReturn" datasource="#variables.DSN1#" cachedwithin="#CreateTimeSpan(0,1,0,0)#">
			EXEC sp_GetLatestEpoll
		</cfquery>
		
		<cfreturn qryReturn>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions ------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetSurveyById" access="public" output="false" returntype="struct" hint="call method to return data for latest E-Poll">
		<cfargument name="surveyid" type="numeric" required="yes">
		
		<cfset var strSurvey = StructNew()>
		
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_GetSurveyById">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" variable="@surveyid" value="#arguments.surveyid#">
			<cfprocresult resultset="1" name="strSurvey.qrySurvey">
			<cfprocresult resultset="2" name="strSurvey.qryOptions">
		</cfstoredproc>
		
		<cfreturn strSurvey> 	
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="CommitVote" access="public" output="false" returntype="boolean" hint="Enter vote in epoll">
		<cfargument name="OptionID" type="numeric" required="yes">
		<cfargument name="SurveyID" type="numeric" required="yes">
		<cfargument name="UserID" 	type="numeric" required="no" default="0">
		<cfargument name="Comment"  type="string"  required="no" default="">
		
		<cfquery name="qryReturn" datasource="#variables.DSN1#" >
			EXEC sp_CommitEpollVote
				@OptionID = #arguments.OptionID#,
				@SurveyID = #arguments.SurveyID#,
				@UserID  = <cfif trim(arguments.UserID) GT 0>'#arguments.UserID#'<cfelse>NULL</cfif>,
				@Comment  = <cfif Len(trim(arguments.Comment))>'#arguments.Comment#'<cfelse>NULL</cfif>
		</cfquery>
		
		<cfreturn true>
		
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="SaveSurvey" access="public" output="false" returntype="numeric" hint="Save Survey">
		<cfargument name="SurveyID" 		type="numeric" 	required="no" default="0">
		<cfargument name="SurveyQuestion"  	type="String" 	required="yes">
		<cfargument name="IsCurrent"  		type="numeric" 	required="yes">
		<cfargument name="OptionType"  		type="String" 	required="yes">
		<cfargument name="OptionName1"  	type="String" 	required="yes">
		<cfargument name="OptionName2"  	type="String" 	required="yes">
		<cfargument name="OptionName3"  	type="String" 	required="yes">
		<cfargument name="OptionName4"  	type="String" 	required="yes">
		<cfargument name="OptionOther"  	type="numeric" 	required="yes">
		<cfargument name="ProductID"  		type="numeric" 	required="no" default="66">
		
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_SaveSurvey" returncode="true">
			
			<cfif arguments.SurveyID EQ "0">
				<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@SurveyID"		value="" null="true">
			<cfelse>
				<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@SurveyID"		value="#arguments.SurveyID#">
			</cfif>
			
			<cfprocparam type="in" 	cfsqltype="cf_sql_varchar" 	dbvarname="@SurveyQuestion" 	value="#arguments.SurveyQuestion#">
			<cfprocparam type="in" 	cfsqltype="cf_sql_integer" 	dbvarname="@IsCurrent" 			value="#arguments.IsCurrent#">
			<cfprocparam type="in" 	cfsqltype="cf_sql_varchar" 	dbvarname="@OptionType" 		value="#arguments.OptionType#">
			
			<cfif Len(trim(arguments.OptionName1))>
				<cfprocparam type="in" 	cfsqltype="cf_sql_varchar" 	dbvarname="@OptionName1" 	value="#arguments.OptionName1#">
			<cfelse>
				<cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@OptionName1"	value="" null="true">
			</cfif>
			
			<cfif Len(trim(arguments.OptionName2))>
				<cfprocparam type="in" 	cfsqltype="cf_sql_varchar" 	dbvarname="@OptionName2" 	value="#arguments.OptionName2#">
			<cfelse>
				<cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@OptionName2"	value="" null="true">
			</cfif>
			
			<cfif Len(trim(arguments.OptionName3))>
				<cfprocparam type="in" 	cfsqltype="cf_sql_varchar" 	dbvarname="@OptionName3" 	value="#arguments.OptionName3#">
			<cfelse>
				<cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@OptionName3"	value="" null="true">
			</cfif>
			
			<cfif Len(trim(arguments.OptionName4))>
				<cfprocparam type="in" 	cfsqltype="cf_sql_varchar" 	dbvarname="@OptionName4" 	value="#arguments.OptionName4#">
			<cfelse>
				<cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@OptionName4"	value="" null="true">
			</cfif>
			
			<cfprocparam type="in" 	cfsqltype="cf_sql_integer" 	dbvarname="@OptionOther" 	value="#arguments.OptionOther#">
			<cfprocparam type="in" 	cfsqltype="cf_sql_integer" 	dbvarname="@ProductID" 		value="#arguments.ProductID#">
			
			<cfprocparam type="out" cfsqltype="cf_sql_integer" 	dbvarname="@NewID" 	variable="SurveyID">
		</cfstoredproc>
		
		<cfreturn SurveyID>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="GetAllSurveys" access="public" output="false" returntype="query" hint="call method to return data for all surveys">		
		
		<!--- <cfset var strSurvey = StructNew()>
		
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_GetAllSurveys">
			<cfprocresult resultset="1" name="strSurvey.qrySurvey">
			<cfprocresult resultset="2" name="strSurvey.qryOptions">
		</cfstoredproc>
		
		<cfreturn strSurvey>  --->
		
		<cfset var qrySurveys = "">
	
		<cfquery name="qrySurveys" datasource="#variables.DSN1#">
			EXEC sp_GetAllSurveys
		</cfquery>
		
		<cfreturn qrySurveys>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PRIVATE Functions ----------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	

</cfcomponent>