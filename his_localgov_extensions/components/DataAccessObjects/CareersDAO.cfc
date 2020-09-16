<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/COMPONENTS/DataAccessObjects/CareersDAO.cfc $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 8/08/07 10:06 $

--->

<cfcomponent displayname="CareersDAO" hint="Career-related data access methods" extends="his_Localgov_Extends.components.DAOManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="CareersDAO" hint="Pseudo-constructor">
	
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		StructAppend( variables, Super.init( arguments.strConfig ) );
		
		return this;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->		
	<cffunction name="getCareerSections" access="public" output="false" returntype="query" 
		hint="">

		<cfset var qryRecordSet = ""> 
		
		<cfquery name="qryRecordSet" datasource="#variables.DSN1#" cachedwithin="#variables.CACHE_TIME#">
		EXEC sp_GetCareerSections
		</cfquery>
		
		<cfreturn qryRecordSet>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->		
	<cffunction name="commitCareerSection" access="public" output="false" returntype="numeric" 
		hint="">
		<cfargument name="name" 		type="string" required="yes">
		<cfargument name="description" 	type="string" required="yes">
		<cfargument name="sectionid" 	type="numeric" required="yes" >
	
		<cfset var id=0>
		
		<cfif arguments.sectionid eq 0>
			<!--- Perform Insert/Update --->
			<cfstoredproc datasource="#variables.DSN1#" procedure="sp_CommitCareerSections">
				<cfprocparam dbvarname="@name" 			cfsqltype="cf_sql_varchar" 	type="in" value="#arguments.name#" >
				<cfprocparam dbvarname="@description" 	cfsqltype="cf_sql_varchar"  type="in" value="#arguments.description#">
				<cfprocparam dbvarname="@id"			cfsqltype="cf_sql_integer" 	type="out" variable="id">
			</cfstoredproc>
		<cfelse>
			<!--- Perform Insert/Update --->
			<cfstoredproc datasource="#variables.DSN1#" procedure="sp_UpdateCareerSections">
				<cfprocparam dbvarname="@name" 			cfsqltype="cf_sql_varchar" 	type="in" value="#arguments.name#" >
				<cfprocparam dbvarname="@description" 	cfsqltype="cf_sql_varchar"  type="in" value="#arguments.description#">
				<cfprocparam dbvarname="@id"			cfsqltype="cf_sql_integer" 	type="in" value="#arguments.sectionid#">
			</cfstoredproc>
			<cfset id = arguments.sectionid>
		</cfif>
		
		<!--- Return the ID --->
		<cfreturn id>
		
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->		
	<cffunction name="deleteCareerSection" access="public" output="false" returntype="void" 
		hint="">
		<cfargument name="sectionid" 	type="numeric" required="yes">

		<cfset var qryRecordSet = ""> 
		
		<cfquery name="qryRecordSet" datasource="#variables.DSN1#">
		EXEC sp_DeleteCareerSection
			@sectionid=#arguments.sectionid#
		</cfquery>
		
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->		
	<cffunction name="getArticleIDsInCareerSection" access="public" output="false" returntype="query" 
		hint="">
			
		<cfargument name="sectionID" required="yes" type="numeric">
		
		<cfset var qryRecordSet = ""> 
		
		<cfquery name="qryRecordSet" datasource="#variables.DSN1#" cachedwithin="#variables.CACHE_TIME#">
		EXEC sp_GetArticleIDsInCareerSection
			@SectionID = #arguments.sectionID#
		</cfquery>
		
		<cfreturn qryRecordSet>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->		
	<cffunction name="getArticlesInCareerSections" access="public" output="false" returntype="query" 
		hint="returns all articles in all career sections">
		
		<cfset var qryRecordSet = ""> 
		
		<cfquery name="qryRecordSet" datasource="#variables.DSN1#" cachedwithin="#variables.CACHE_TIME#">
		EXEC sp_GetArticleInCareerSection
		</cfquery>
		
		<cfreturn qryRecordSet>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
</cfcomponent>