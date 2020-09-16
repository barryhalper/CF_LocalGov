<cfcomponent extends="his_Localgov_Extends.components.DAOManager">
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="PapersDAO" hint="Pseudo-constructor">	
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
			StructAppend( variables, Super.init( arguments.strConfig ) );
			return this;
		</cfscript>
		
	</cffunction>
	
	
	<cffunction name="getPaperFeeds" access="public" returntype="query">
		
		<cfset var qryPapers = querynew('temp')>
			
		<cfquery name="qryPapers" datasource="#variables.DSN6#">
			exec dbo.usp_getPaperFeeds
		</cfquery>
		
		<cfreturn qryPapers>
	</cffunction>
	
	<cffunction name="getPaperStories" access="public" returntype="query">
		<cfargument name="feedID" type="numeric" required="yes">
		
		<cfset var qryStories = querynew('temp')>
			
		<cfquery name="qryStories" datasource="#variables.DSN6#">
			exec dbo.usp_getPaperStory #arguments.feedID#
		</cfquery>
		
		<cfreturn qryStories>
	</cffunction>
	
	<cffunction name="clearStories" access="public" returntype="void">
		<cfargument name="feedID" type="numeric" required="yes">
		
		<cfquery datasource="#variables.DSN6#">
			exec dbo.usp_clearPaperStories #arguments.feedID#
		</cfquery>
	</cffunction>
	
	<cffunction name="setCount" access="public" returntype="void">
		<cfargument name="feedID" type="numeric" required="yes">
		<cfargument name="count" type="numeric" required="yes">
		
		<cfquery datasource="#variables.DSN6#">
			exec dbo.usp_setStoryCount #arguments.feedID#, #arguments.count#
		</cfquery>
	</cffunction>
	
	<cffunction name="insertStory" access="public" returntype="void">
		<cfargument name="feedID" type="numeric" required="yes">
		<cfargument name="content" type="string" required="yes">
		<cfargument name="lastBuild" type="date" required="yes">
		<cfargument name="link" type="string" required="yes">
		<cfargument name="title" type="string" required="yes">
		<cfargument name="image" type="string" required="yes">
		<cfargument name="rsstitle" type="string" required="yes">
		
		<cfstoredproc datasource="#variables.DSN6#" procedure="usp_insertPaperStory">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="@feedID" value="#arguments.feedID#" type="in">
			<cfprocparam cfsqltype="cf_sql_varchar" dbvarname="@content" value="#arguments.content#" type="in">
			<cfprocparam cfsqltype="cf_sql_date" dbvarname="@builddate" value="#arguments.lastBuild#" type="in">
			<cfprocparam cfsqltype="cf_sql_varchar" dbvarname="@link" value="#arguments.link#" type="in">
			<cfprocparam cfsqltype="cf_sql_varchar" dbvarname="@title" value="#arguments.title#" type="in">
			<cfprocparam cfsqltype="cf_sql_varchar" dbvarname="@image" value="#arguments.image#" type="in">
			<cfprocparam cfsqltype="cf_sql_varchar" dbvarname="@rsstitle" value="#arguments.rsstitle#" type="in">
		</cfstoredproc>
		
	</cffunction>
</cfcomponent>