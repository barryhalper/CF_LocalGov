<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/BusinessObjects/Survey.cfc $
	$Author: Hbehnia $
	$Revision: 5 $
	$Date: 10/10/08 11:54 $

--->

<cfcomponent displayname="Survey" hint="Survey-related business object functions" extends="his_Localgov_Extends.components.BusinessObjectsManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Survey" hint="Pseudo-constructor">

		<cfargument name="objAppObjs" type="any" required="yes" hint="The application manager object">
		
		<cfscript>
		// Call the genric init function, placing business, app, and dao objects into a local scope...
		StructAppend( variables, Super.initChild( arguments.objAppObjs, this ) );
		
		return this;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions ------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getVariables" access="public" output="false" returntype="struct" hint="">
		<cfreturn variables>
	</cffunction> 
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions ------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetLatest" access="public" output="false" returntype="query" hint="call method to return data for latest E-Poll">
		<cfreturn objDAO.GetLatest()>	
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="GetSurveyById" access="public" output="false" returntype="struct" hint="call method to return data for specific survey">
		<cfargument name="surveyid" 	type="numeric" required="yes">
		
		<cfreturn objDAO.GetSurveyById(arguments.surveyid)>	
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="SaveSurvey" access="public" output="false" returntype="numeric" hint="Save Survey">
		<cfargument name="SurveyID" 		type="numeric" 	required="no">
		<cfargument name="SurveyQuestion"  	type="String" 	required="yes">
		<cfargument name="IsCurrent"  		type="numeric" 	required="yes">
		<cfargument name="OptionType"  		type="String" 	required="yes">
		<cfargument name="OptionName1"  	type="String" 	required="yes">
		<cfargument name="OptionName2"  	type="String" 	required="yes">
		<cfargument name="OptionName3"  	type="String" 	required="yes">
		<cfargument name="OptionName4"  	type="String" 	required="yes">
		<cfargument name="OptionOther"  	type="numeric" 	required="yes">
		<cfargument name="ProductID"  		type="numeric" 	required="no" default="66"><!--- Localgov productID --->
		
		<!--- If the survey is of type "Yes/No", make the first two options Yes or No --->
		<cfif arguments.OptionType EQ "boolean">
			<cfset arguments.OptionName1 = "Yes">
			<cfset arguments.OptionName2 = "No">
		</cfif>
		
		<cfreturn objDAO.SaveSurvey(argumentCollection=arguments)>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="GetAllSurveys" access="public" output="false" returntype="query" hint="call method to return data for all surveys">		
		<cfreturn objDAO.GetAllSurveys()>	
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="CommitVote" access="public" output="false" returntype="boolean" hint="call method to Enter vote in epoll">
		<cfargument name="OptionID" type="numeric" required="yes">
		<cfargument name="SurveyID" type="numeric" required="yes">
		<cfargument name="UserID" 	type="numeric" required="no" default="0">
		<cfargument name="Comment"  type="string"  required="no" default="">	
		
		<cfset var bl = objDAO.CommitVote(arguments.OptionID, arguments.SurveyID, arguments.UserID, arguments.Comment)>
		<cfcookie name="surveyIdLastVoted" value="#arguments.surveyid#" expires="never" />
		<cfreturn bl>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PRIVATE Functions ----------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->  

</cfcomponent>