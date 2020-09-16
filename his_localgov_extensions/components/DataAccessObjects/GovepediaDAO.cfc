<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/COMPONENTS/DataAccessObjects/GovepediaDAO.cfc $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 8/08/07 10:06 $

--->

<cfcomponent displayname="Govepedia" hint="Govepedia Data Access Functions" extends="his_Localgov_Extends.components.DAOManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="GovepediaDAO" hint="Pseudo-constructor">
		
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		StructAppend( variables, Super.init( arguments.strConfig ) );

		return this;
		</cfscript>
						
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions ------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetArticlesbySection" access="public" output="false" returntype="query" hint="get all artciles in govepedia by section">

		<cfargument name="SectionID" type="numeric" required="yes">
		<cfargument name="Sectors"  type="string" required="no" default="">
			
			<cfset var qry=""> 
	
			<cfquery datasource="#variables.dsn1#" name="qry">
					EXEC sp_GetGovepediaArticlesbySection 	
					@SectionID = <cfif arguments.SectionID>#arguments.SectionID#<cfelse>NULL</cfif>,
					@Sector  = <cfif Len(arguments.Sectors)>'#arguments.Sectors#'<cfelse>NULL</cfif>		
			</cfquery>
		
		<cfreturn qry>	
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetSections" access="public" output="false" returntype="query" hint="get all govepedia sections">
			<cfset var qry=""> 
	
			<cfquery datasource="#variables.dsn1#" name="qry" >
					EXEC sp_GetGovepediaSections 			
			</cfquery>
		
		<cfreturn qry>	
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetSectors" access="public" output="false" returntype="query" hint="get all govepedia sectors">
			<cfset var qry=""> 
	
			<cfquery datasource="#variables.dsn1#" name="qry" >
					sp_GetSectorsWithNews 11		
			</cfquery>
		
		<cfreturn qry>	
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getAllArticles" access="public" returntype="query" 
		hint="return all news articles based on input criteria">
		
		<cfargument name="All" required="no"  type="boolean" defualt="0">
		
		
		<cfset var qryNews = ""> 
		<!--- <cfdump var="#arguments#"><cfabort> --->
		<cfquery name="qryNews" datasource="#variables.DSN1#" cachedwithin="#CreateTimeSpan(0,0,0,30)#">
		EXEC sp_GetGovepediaArticles
			@All  			=  	#arguments.All#		
		</cfquery>
		
		<cfreturn qryNews>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetArticle" access="public" output="false" returntype="query" hint="get all details about an entry">
			<cfargument name="Newsid" 	 type="numeric" required="yes">
			<cfargument name="getLastest" type="boolean"  required="no" default="1">
			
			<cfset var qry=""> 
	
			<cfquery datasource="#variables.dsn1#" name="qry">
					EXEC sp_GetFullArticle_govepedia
					@NewsID				= #arguments.Newsid#,		
					@GetLatestVersion   = #arguments.getLastest#						
			</cfquery>
		
		<cfreturn qry>	
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetTodaysArticles" access="public" output="false" returntype="query" hint="get all todays' article and biography">
			
			
			<cfset var qryArticles=""> 
	
			<cfstoredproc datasource="#variables.dsn1#" procedure="sp_GetGovepedia_Today">
				<cfprocresult resultset="1" name="qryArticles">
			</cfstoredproc>
									
		
		<cfreturn qryArticles>	
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="CommitArticle" access="public" output="false" returntype="numeric" hint="insert article">

			<cfargument name="newsid" 			type="numeric" required="yes"> 
			<cfargument name="HeadlineBanner" 	type="string" required="yes">
			<cfargument name="sectors" 			type="string" required="yes" default="">
			<cfargument name="Story" 			type="string" required="yes">
			<cfargument name="Status" 			type="numeric" required="yes">
			<cfargument name="ModifiedBy" 		type="numeric" required="yes">
			<cfargument name="userID" 			type="numeric" required="yes">
			<cfargument name="sectionid" 		type="numeric" required="yes">
			<cfargument name="teaser" 			type="string" required="yes">
			
			<cfset var newNewsid =0>
			
			<cfstoredproc datasource="#variables.dsn1#" procedure="sp_CommitGovepediaArticle">
				<cfif arguments.Newsid>
					<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@articleid" value="#arguments.newsid#">
				<cfelse>
					<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@ArticleID" null="yes">
				</cfif>
				<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@HeadlineBanner" value="#trim(arguments.HeadlineBanner)#">			
				<cfprocparam type="in" cfsqltype="cf_sql_longvarchar" dbvarname="@Story"  value="#trim(arguments.story)#">
				<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@Status" value="#arguments.Status#">
				<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@ModifiedBy" value="#arguments.ModifiedBy#">
				<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@userID" value="#arguments.userID#">
				<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@sectors" value="#arguments.sectors#">
				<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@sectionid" value="#arguments.sectionid#">
				
				<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@teaser" value="#arguments.teaser#">
				<cfprocparam type="out" cfsqltype="cf_sql_integer" variable="newNewsid">
			</cfstoredproc>
		<cfreturn newNewsid>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PRIAVTE Functions ----------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="F2" access="private" output="false" returntype="string" hint="<description>">
	
		<cfargument name="A1" type="string" default="1">
		<cfargument name="A2" type="string" default="1">

		<cfscript>
		// Local variable declarations...
		var sRtnValue = "";

		// ...code...		
		
		return sRtnValue;		
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->

</cfcomponent>