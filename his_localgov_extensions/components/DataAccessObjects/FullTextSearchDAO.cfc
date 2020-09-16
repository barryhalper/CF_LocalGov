<cfcomponent displayname="FullTextSearchDAO" output="false" extends="his_Localgov_Extends.components.DAOManager">
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="FullTextSearchDAO" hint="Pseudo-constructor">
	
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		
		StructAppend( variables, Super.init( arguments.strConfig ) );
		
		return this;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="exec" access="public" returntype="query"  output="false" hint="perform full text search">
		<cfargument name="keyword" 		required="yes" type="string">
        <cfargument name="numSecords"   required="no" type="numeric" default="60" hint="query cache time in seconds">
        
		<cfset var qry = queryNew("SearchID,UID, title,byline,story,contentType,datestart,product,author,YearPublished, intMonthPublished,monthPublished,Sector,Adult_Social_Services,Business,Childrens_Social_Services,Communication,E_Government,Education,Emergency_Services,Environmental_Services,Finance,Health,Housing,Inspection_and_Improvement,Legal,Leisure_and_Tourism,Lifelong_Learning,Management_and_HR,People,Planning_and_Regeneration,Politics_and_Policy,Procurement_and_Efficiency,Top_Team,Transportation,Voluntary")>
		
		<cftry>
		<cfquery  datasource="#variables.DSN6#" name="qry" cachedwithin="#CreateTimeSpan(0,0,0,arguments.numSecords)#">
			EXEC usp_FullTextSearch '#arguments.keyword#'
		</cfquery>
		
			<cfcatch type="database">
			</cfcatch>
		</cftry>
		
		
		<cfreturn qry>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getKeywords" access="public" returntype="query" output="false"  hint="get all keywords">
		<cfset var q = queryNew("temp")>
		<cfquery name="q" datasource="#variables.DSN1#">
			EXEC sp_GetKeywords
		</cfquery>
		<cfreturn q>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="advanced" access="public" returntype="query"  output="false" hint="perform advance full text search ">
		
		<cfargument name="keywords"		required="yes"  type="string" default="">
		<cfargument name="lstSectorID" required="no"  type="string" default="">
		<cfargument name="contenttype" required="no"  type="string" default="News">
		
		<cfargument name="startdate"   required="no"  type="string" default="">
		<cfargument name="endate" 	   required="no"  type="string" default="">
		<cfset var qry = queryNew("temp")>
		
		
		<cfquery  datasource="#variables.DSN6#" name="qry" cachedwithin="#CreateTimeSpan(0,0,0,30)#">
			EXEC usp_FullTextAdvanceSearch 
			@keyword =<cfif len(arguments.keywords)>'#arguments.keyword#'<cfelse>NULL,</cfif>
			@SectorID =<cfif Len(arguments.lstSectorID)>'#arguments.lstSectorID#'<cfelse>NULL</cfif>,
			@contenttype =<cfif Len(arguments.contenttype)>'#arguments.contenttype#'<cfelse>NULL</cfif>,
			@pubdate =<cfif IsDate(arguments.pubdate)>#dateFormat(lsDateFormat(arguments.pubdate, "dd mmm yyyy"))#<cfelse>NULL</cfif>,
			@startdate =<cfif IsDate(arguments.startdate)>'#dateFormat(lsDateFormat(arguments.startdate, "dd mmm yyyy"))#'<cfelse>NULL</cfif>, 
			@enddate =<cfif IsDate(arguments.endate)>'#dateFormat(lsDateFormat(arguments.endate, "dd mmm yyyy"))#'<cfelse>NULL</cfif>
		</cfquery>
		
	
		<cfreturn qry>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="build" access="public" returntype="void"  output="false" hint="exec stored proc to add data to search table ">
		<cfquery  datasource="#variables.DSN6#" >
		usp_CreateFullTextIndex
		</cfquery>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="index" access="public" returntype="void"  output="false" hint="exec stored proc rebuild full text catalogue ">
		<cfquery  datasource="#variables.DSN6#" >
		usp_RebuildCatalogue
		</cfquery>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="saveArticle" access="public" returntype="void"  output="false" hint="perform advance full text search ">
		<cfargument name="ID"			required="yes"  type="string" default="">
		
		<cfquery  datasource="#variables.DSN6#" name="qry" cachedwithin="#CreateTimeSpan(0,0,0,30)#">
			EXEC usp_SaveArticleToSearch
			@NewsID = #arguments.ID#
	
		</cfquery>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="saveBlogs" access="public" returntype="void"  output="false" hint="save blog to search table">
		<cfargument name="aSql"			required="yes"  type="array" hint="array of insert statements" >
		
			<cfset var sql = "">
		
		<cfquery datasource="#variables.DSN6#">
					DELETE FROM search WHERE contentType = 'Blogs'
		</cfquery>
		<!--- loop over array of insert statements --->
		<cfloop from="1" to="#ArrayLen(aSql)#" index="i">
			<cfset sql  = aSql[i]>
				<cftry >
					<cfquery datasource="#variables.DSN6#">
						#PreserveSingleQuotes(sql)# 
					</cfquery>
					<cfcatch type="database"></cfcatch>
				</cftry> 
		</cfloop>
		
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="delete" access="public" returntype="void" output="false"  hint="get all keywords">
		<cfargument name="ID"			required="yes"  type="string" default="">
		<cfquery  datasource="#variables.DSN6#">
			EXEC usp_DeleteArticle #Arguments.ID#
		</cfquery>
		
	</cffunction>
		<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
</cfcomponent>