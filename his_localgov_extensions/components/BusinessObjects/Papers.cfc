<cfcomponent displayname="Papers" extends="his_Localgov_Extends.components.BusinessObjectsManager">
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Papers" hint="Pseudo-constructor">
	
		<cfargument name="objAppObjs" type="any" required="yes" hint="The application manager object">
		<cfargument name="objBusObjs" type="any" required="yes" hint="The business object">

		<cfscript>
		// Call the genric init function, placing business, app, and dao objects into a local scope...
		StructAppend( variables, Super.initChild( arguments.objAppObjs, this, arguments.objBusObjs ) );
		//variables.strLookups = getLookups();
		return this;
		</cfscript>
		
	</cffunction>
	
	
	
	<cffunction name="refreshFeeds" access="public" returntype="void" output="false">
		<cfargument name="useProxy" type="boolean" required="false" default="true" hint="">
		
		<cfset var qryFeeds = objDAO.getPaperFeeds()>
		<cfset var qryContent = querynew('temp')>
		
		<cfloop query="qryFeeds">
			
			<cfset qryContent = objRss.readRSS( feedUrl, feedFormat, arguments.useProxy )>
			
			<cfif qryContent.recordcount gt 0>
			
				<cfset thisFeed = paperFeedID>
				<cfset objDAO.clearStories(thisFeed)>
				
				<cfloop query="qryContent">
					
					<cfif lastbuilddate eq ''>
						<cfset objDAO.insertStory(thisFeed, content, LSParseDateTime(pubdate), link, title, image, rsstitle)>
					<cfelse>					
						<cfset objDAO.insertStory(thisFeed, content, LSParseDateTime(lastbuilddate), link, title, image, rsstitle)>
					</cfif>
				</cfloop>
				
				<cfset objDAO.setCount(thisFeed, qryContent.recordcount)>
				
			</cfif>
			
		</cfloop>
		
	</cffunction>
	
	<cffunction name="getAll" access="public" returntype="query" output="false">
		<cfreturn objDAO.getPaperFeeds()>
	</cffunction>
	
	<cffunction name="getPaperStories" access="public" returntype="query">
		<cfargument name="feedID" type="numeric" required="yes">
		
		<cfreturn objDAO.getPaperStories(arguments.feedID)>
		
	</cffunction>
</cfcomponent>