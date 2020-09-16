<cfcomponent displayname="LetterDAO" hint="Letter-related data access methods" extends="his_Localgov_Extends.components.DAOManager">
	
	<!--- ------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="LetterDAO" hint="Pseudo-constructor">
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		StructAppend( variables, Super.init( arguments.strConfig ) );

		return this;
		</cfscript>
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="GetLetterByID" access="public" output="false" returntype="Query" hint="return a single letter">
		<cfargument name="LetterID" type="numeric" required="yes">
	
		<!--- <cfset var strArticle=StructNew()>
		
		<cfstoredproc datasource="#instance.strConfig.strVars.dsn1#" procedure="usp_GetArticleByID">
			<cfprocparam cfsqltype="cf_sql_integer" type="in" dbvarname="@ArticleID" value="#arguments.ArticleID#">
			<cfprocresult resultset="1" name="strArticle.qryArticleByID">
			<cfprocresult resultset="2" name="strArticle.qryArticleToOrganisation">
			<cfprocresult resultset="3" name="strArticle.qryComments">
			<cfprocresult resultset="4" name="strArticle.qryKeyword">
		</cfstoredproc> --->
		
		<cfset qryGetLetterByID = queryNew("temp")>
		
		<cfquery name="qryGetLetterByID" datasource="#variables.dsn5#">
			EXEC usp_GetLetterByID @LetterID = #arguments.LetterID#
		</cfquery>
		
		<cfreturn qryGetLetterByID>
	
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="SaveLetter" access="public" output="false" returntype="numeric" hint="Save letter to db and return the LetterID">
		<cfargument name="LetterID" 		type="numeric" 	required="no" default="0">
		<cfargument name="LetterTitle" 		type="string" 	required="yes">
		<cfargument name="LetterContent" 	type="string" 	required="yes">
		
		<cfset var RetLetterID = 0>
		
		<cfstoredproc procedure="usp_SaveLetter" datasource="#variables.dsn5#" returncode="yes">
			
			<cfif arguments.LetterID EQ 0>
				<cfprocparam type="in"  cfsqltype="cf_sql_integer" 		dbvarname="@LetterID"		value="" null="true">
			<cfelse>
				<cfprocparam type="in"  cfsqltype="cf_sql_integer" 		dbvarname="@LetterID"		value="#arguments.LetterID#">
			</cfif>
			<cfprocparam type="in"  	cfsqltype="cf_sql_varchar" 		dbvarname="@LetterTitle" 	value="#arguments.LetterTitle#">
			<cfprocparam type="in"  	cfsqltype="cf_sql_longvarchar"  dbvarname="@LetterContent"	value="#arguments.LetterContent#">

			<cfprocparam type="out" 	cfsqltype="cf_sql_integer" 		dbvarname="@NewID" 			variable="RetLetterID">

		</cfstoredproc>
	 
		<cfreturn RetLetterID>
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="DeleteLetter" access="public" output="false" returntype="void" hint="Delete Letter from db">
		<cfargument name="LetterID" 	type="numeric" 	required="no">
		
		<cfset var qryDeleteLetter = queryNew("temp")>
		
		<cfquery name="qryDeleteLetter" datasource="#variables.dsn5#">
			EXEC usp_DeleteLetter #arguments.LetterID#
		</cfquery>	
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="GetLookups" access="public" output="false" returntype="struct" hint="return all keywords and Organisations">
		<cfset var strLookUps=StructNew()>
		
		<cfstoredproc datasource="#instance.strConfig.strVars.dsn1#" procedure="usp_GetArticleLookups">
			<cfprocresult resultset="1" name="strLookUps.qryKeywords">
			<cfprocresult resultset="2" name="strLookUps.qryAuthors">
			<cfprocresult resultset="3" name="strLookUps.qryArticleTypes">
			<cfprocresult resultset="4" name="strLookUps.qryArticlePositions">
		</cfstoredproc>
		
		<cfreturn strLookUps>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="GetAllLetters" access="public" output="false" returntype="query" hint="Return all letters">
		
		<cfset var qryGetAllLetters = queryNew("temp")>
		
		<cfquery name="qryGetAllArticles" datasource="#variables.dsn5#">
			EXEC usp_GetAllLetters
		</cfquery>	
		
		<cfreturn qryGetAllArticles>
	</cffunction>
	
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
</cfcomponent>