<cfcomponent displayname="TopicsDAO" hint="Article-related data access methods" extends="his_Localgov_Extends.components.DAOManager">

	<!--- ------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="TopicsDAO" hint="Pseudo-constructor">
	
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		StructAppend( variables, Super.init( arguments.strConfig ) );
		
		return this;
		</cfscript>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->	
	<cffunction name="GetTopics" access="public" output="false" returntype="query" hint="returns topics">
		
		<cfset var qryTopics = "">
		
		<cfquery name="qryTopics" datasource="#variables.DSN1#">
		EXEC sp_GetTopics
		</cfquery>
	  	
		<cfreturn qryTopics>	
	
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->	
	<cffunction name="GetArticlesByTopicID" access="public" output="false" returntype="query" hint="returns topics">
		<cfargument name="topicId" required="yes" type="numeric" >
		
		<cfset var qryArticles = "">
		
		<cfquery name="qryArticles" datasource="#variables.DSN1#">
		EXEC sp_getArtilcesByTopicID #arguments.topicId#
		</cfquery>
			
		 <cfreturn qryArticles>			
	</cffunction>
	
</cfcomponent>