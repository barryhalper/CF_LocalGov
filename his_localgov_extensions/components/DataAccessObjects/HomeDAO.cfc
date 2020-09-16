<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/DataAccessObjects/HomeDAO.cfc $
	$Author: Bhalper $
	$Revision: 5 $
	$Date: 10/11/08 16:59 $

	Notes:
		Method naming convention:
		
		1. add<Noun>	- e.g. addArticle()
		2. update<Noun>	- e.g. updateArticle()
		3. delete<Noun>	- e.g. deleteArticle()
		4. get<Noun>	- e.g. getArticle()

--->

<cfcomponent displayname="HomeDAO" hint="<component description here>" extends="his_Localgov_Extends.components.DAOManager" >

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="HomeDAO" hint="Pseudo-constructor">
	
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		StructAppend( variables, Super.init( arguments.strConfig ) );
		
		return this;
		</cfscript>
		
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions: *GET* ----------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getRelevantProducts" access="public" output="false" returntype="query" hint="return all relevant products form his products list">
		<cfargument name="hisproductids" required="yes" type="string">
		<cfset var qry="">
		<cfquery name="qry" datasource="#variables.DSN1#">
			Exec spGetWebProducts
			'#arguments.hisproductids#'
		</cfquery>
		
		<cfreturn qry>
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!------------------------------------------------------------------------------------------------------>
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getHomePage" access="public" output="false" returntype="struct" hint="return all data for home page">
		<cfset var strHome = structNew()>
		<cfstoredproc  datasource="#variables.DSN1#" procedure="sp_GetHomePageContent">
			<cfprocresult resultset="1" name="strHome.qryPromoPanel">
			<cfprocresult resultset="2" name="strHome.qryTopNews">
		</cfstoredproc>
		<cfreturn strHome>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!------------------------------------------------------------------------------------------------------>
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getLatestTweets" access="public" returntype="query" hint="Return the 5 latest tweets">
		<cfset var qryTweets="">
		
		<cfstoredproc datasource="#variables.dsn5#" procedure="usp_getLatestTweets">
			<cfprocresult resultset="1" name="qryTweets">
		</cfstoredproc>
		
		<cfreturn qryTweets>
	</cffunction>
		<!--- -------------------------------------------------------------------------------------------------->
	<!------------------------------------------------------------------------------------------------------>
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getLotsOfTweets" access="public" returntype="query" hint="Return the 30 latest tweets">
		<cfset var qryTweets="">
		
		<cfstoredproc datasource="#variables.dsn5#" procedure="usp_getLotsOfTweets">
			<cfprocresult resultset="1" name="qryTweets">
		</cfstoredproc>
		
		<cfreturn qryTweets>
	</cffunction>

</cfcomponent>