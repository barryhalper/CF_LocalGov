<!--- 
	
	$Archive: /LocalGov.co.uk/his_localgov_extensions/components/DataAccessObjects/BusinessDAO.cfc $
	$Author: Anagpal $
	$Revision: 2 $
	$Date: 2/10/06 17:39 $

--->
<cfcomponent displayname="BusinessDAO" hint="Business-related data access methods" extends="DAOManager">

	<!--- ------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="BusinessDAO" hint="Pseudo-constructor">
	
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		StructAppend( variables, Super.init( arguments.strConfig ) );
		
		return this;
		</cfscript>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Get Functions ----------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="postComment" access="public" output="false" returntype="numeric" 
		hint="">
		
		<cfargument name="userID" required="yes" type="numeric">
		<cfargument name="comment" required="yes" type="string">
		<cfargument name="email" required="yes" type="string">
		<cfargument name="name" required="yes" type="string">
		<cfargument name="newsid" required="yes" type="string">
	
		<cfset var commentID=0>
		
		<!--- Perform Insert/Update --->
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_CommitComment">
			<cfprocparam dbvarname="@userID" 	cfsqltype="cf_sql_integer" 	type="in" value="#arguments.userID#" >
			<cfprocparam dbvarname="@comment" 	cfsqltype="cf_sql_varchar"  type="in" value="#arguments.comment#">
			<cfprocparam dbvarname="@email" 	cfsqltype="cf_sql_varchar"  type="in" value="#arguments.email#">
			<cfprocparam dbvarname="@name" 		cfsqltype="cf_sql_varchar"  type="in" value="#arguments.name#">
			<cfprocparam dbvarname="@newsid" 	cfsqltype="cf_sql_integer"  type="in" value="#arguments.newsid#">
			
			<cfprocparam dbvarname="@CommentID"	cfsqltype="cf_sql_integer" 	type="out" variable="commentID">
		</cfstoredproc>
		
		<!--- Return the article's ID --->
		<cfreturn commentID>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getNewsTypes" access="public" output="false" returntype="query" 
		hint="">
		
		<cfset var qryRecordSet = ""> 
		
		<cfquery name="qryRecordSet" datasource="#variables.DSN1#" cachedwithin="#variables.CACHE_TIME#">
		EXEC sp_GetNewsTypes
		</cfquery>
		
		<cfreturn qryRecordSet>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getNewsArticles" access="public" returntype="query" 
		hint="return all news articles based on input criteria">
		
		<cfargument name="Productid"    required="no"  	type="string" 	default="#variables.NEWS_PRODUCT_IDs#">
		<cfargument name="NewsTypeID"   required="no"  	type="string" 	default="">
		<cfargument name="Commence"     required="no"  	type="boolean" 	default="1">
		<cfargument name="HowMany"     	required="no"  	type="numeric" 	default="-1">
		<cfargument name="lstSectorIDs" required="no"	type="string" 	default="">
		
		<cfset var qryNews = ""> 
		<!--- <cfdump var="#arguments#"><cfabort> --->
		<cfquery name="qryNews" datasource="#variables.DSN1#" cachedwithin="#variables.CACHE_TIME#" maxrows="#Arguments.HowMany#">
		EXEC sp_GetNewsArticles_Business
			@ProductID  			=  			'#arguments.Productid#',
			@NewsTypeID 			= 			'#arguments.NewsTypeID#',
			@Commence   			=  			#arguments.Commence#,
			@CheckIsHeadlineOnly 	= 			1,
			@lstSectorIDs 			=			'#arguments.lstSectorIDs#'
		</cfquery>
		
		<cfreturn qryNews>
	
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getDeletedArticles" access="public" returntype="query" 
		hint="return all news articles based on input criteria">
		
		<cfargument name="Productid"    required="no"  type="string" default="#variables.NEWS_PRODUCT_IDs#">
		<cfargument name="NewsTypeID"   required="no"  type="string" default="">
		
		<cfset var qryNews = ""> 
		
		<cfquery name="qryNews" datasource="#variables.DSN1#" cachedwithin="#variables.CACHE_TIME#">
		EXEC sp_GetDeletedArticles
			@ProductID  =  '#arguments.Productid#',
			@NewsTypeID = '#arguments.NewsTypeID#'
		</cfquery>
		
		<cfreturn qryNews>
	
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getHeadline" access="public" returntype="string" 
		hint="return all news articles based on input criteria">
		
		<cfargument name="NewsID"    required="no" default="0"  type="numeric" >
		
		<cfset var qryDataset = ""> 
		
		<cfquery name="qryDataset" datasource="#variables.DSN1#" cachedwithin="#variables.CACHE_TIME#" >
		EXEC sp_GetHeadline 
			@NewsID = #arguments.NewsID#
		</cfquery>
		
		<cfreturn qryDataset.HeadlineBanner>
	
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getArticles" access="public" output="false" returntype="query" hint="Returns a headline for a specific articles">
		
		<cfargument name="lstIDs" type="string" required="false" default="0" hint="list of article ids">
		
		<cfset var qryDataset = ""> 
		
		<cfquery name="qryDataset" datasource="#variables.DSN1#" cachedwithin="#variables.CACHE_TIME#" >
		EXEC sp_GetArticles
			@ArticleIDs = '#arguments.lstIDs#'
		</cfquery>
		
		<cfreturn qryDataset>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getVersions" access="public" returntype="query" 
		hint="return a query containing all versions for a given article">
		
		<cfargument name="NewsID"    required="yes" default="0"  type="numeric" >
		
		<cfset var qryVersions = ""> 
		
		<cfquery name="qryVersions" datasource="#variables.DSN1#" cachedwithin="#variables.CACHE_TIME#" >
		EXEC sp_GetVersions
			@NewsID = #arguments.NewsID#
		</cfquery>
		
		<cfreturn qryVersions>
	
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------->
	<cffunction name="getFull" access="public" output="false" returntype="query" 
		hint="Get the full article, based on the arguments passed to the ">
	
		<!--- Data arguments... --->
		<cfargument name="NewsID" type="numeric" required="true" hint="limits news to primary key">
		<cfargument name="GetLatestVersion" type="boolean" required="false" default="1" hint="limits news to primary key">

		<cfset var qryRecordSet = ""> 
		
		<cfquery name="qryRecordSet" datasource="#variables.DSN1#" cachedwithin="#variables.CACHE_TIME#">
		EXEC sp_GetFullArticle
			@NewsID = '#arguments.NewsID#',
			@GetLatestVersion  = #arguments.GetLatestVersion#
		</cfquery>
		
		<cfreturn qryRecordSet>
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getLatest" access="public" output="false" returntype="query" hint="">
		<cfargument name="Args" required="yes" type="struct">
	
		<cfquery name="qryDataset" datasource="#variables.DSN1#" cachedwithin="#Arguments.Args.CacheTime#" maxrows="#Arguments.Args.MaxRows#" >
		EXEC sp_GetLatest
		</cfquery>
	
	</cffunction>	
	<!--- ------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getRelatedArticles" access="public" output="false" returntype="query" hint="">
		<cfargument name="lstSectorID" required="yes" type="string">
		
		<cfset var qry="">
		<cfquery name="qry" datasource="#variables.DSN1#" maxrows="6">
		EXEC sp_GetRA
			'#arguments.lstSectorID#'
		</cfquery>
		<cfreturn qry>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getNewsInSectors" access="public" returntype="query" output="false" 
		hint="return all news stories in specfic sectors">

		<cfargument name="lstSectorID" required="yes" type="string">
		
		<cfset var qry="">
		<cfquery name="qry" datasource="#variables.DSN1#">
		EXEC spGetNewInSectors
			'#arguments.lstSectorID#'
		</cfquery>
		<cfreturn qry>
			
	</cffunction> 
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -----------------------------------------------------------------------------------------------
	<cffunction name="getWebNews" access="public" output="false" returntype="query" hint="Get web news, based on the arguments passed to the function.">

		<!--- todo: check whether this fn is now redundant??  --->

		<!--- System arguments... --->
		<cfargument name="MaxRows" type="numeric" required="false"  hint="" default="-1">
		<cfargument name="CacheTime" type="date" required="false" hint="query cache time" default="#variables.CACHE_TIME#">

		<!--- Data arguments... --->
		<cfargument name="HeadlineNews" type="boolean" required="false" default="true" hint="limits news to headlines only">
		<cfargument name="DateCommence" type="date" required="false" default="0" hint="Limits news to date set to commence">
		<cfargument name="NewsID" type="numeric" required="false" default="0" hint="limits news to primary key">
		<cfargument name="ProductID" type="string" required="false" default="0" hint="limits news to a particular HIS magazine">
 		<cfargument name="OrderBy" type="string" required="false" default="DESC" hint="orders results">
		
		<!--- Perform query... --->
		<cfquery name="qryDataset" datasource="#variables.DSN1#" cachedwithin="#Arguments.CacheTime#" maxrows="#Arguments.MaxRows#" >
		SELECT p_news_id, HeadlineBanner, DateCommence, story
		FROM tblNews
		ORDER BY DateCommence #Arguments.OrderBy#
		</cfquery>
		
		<!--- Return query... --->
		<cfreturn qryDataset>

	</cffunction>	--->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->	
	
	<cffunction name="getCopy" access="public" output="false" returntype="query" 
		hint="return misc copy">
		
		<cfargument name="productID" required="yes" type="numeric" >
		<cfargument name="PageId" 	 required="no"  type="numeric" default="0"> 
			
		<cfset var qry = "">
		
		<cfquery name="qry" datasource="#variables.DSN1#">
		 EXEC sp_GetCopy 
			 @productID  = '#arguments.productID#',
			 @Pageid  	 =  #arguments.PageId#
		</cfquery>
	
	   <cfreturn qry>	
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getNewsStatusTypes" access="public" output="false" returntype="query" hint="">

		<cfset var qry = "">
		<cfquery name="qry" datasource="#variables.DSN1#">
		EXEC sp_GetNewsStatusTypes
		</cfquery>
	  	<cfreturn qry>	

	</cffunction>		
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="adminGetRecentArticles" access="public" output="false" returntype="query" 
		hint="returns recently added articles">

		<cfset var qry = "">
		<cfquery name="qry" datasource="#variables.DSN1#">
		EXEC sp_AdminGetRecentArticles
		</cfquery>
	  	<cfreturn qry>	

	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="adminGetDeletedArticles" access="public" output="false" returntype="query" 
		hint="returns all deleted articles">

		<cfset var qry = "">
		<cfquery name="qry" datasource="#variables.DSN1#">
		EXEC sp_AdminGetDeletedArticles
		</cfquery>
	  	<cfreturn qry>	

	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="adminGetScheduledArticles" access="public" output="false" returntype="query" 
		hint="returns any articles scheduled in the future">

		<cfset var qry = "">
		<cfquery name="qry" datasource="#variables.DSN1#">
		EXEC sp_AdminGetScheduledArticles
		</cfquery>
	  	<cfreturn qry>	

	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="adminSearchResults" access="public" output="false" returntype="query" 
		hint="return queries containing the supplied keywords in the title">
		
		<cfargument name="keywords" required="yes"  type="string"> 
		
		<cfset var qry = "">
		<cfquery name="qry" datasource="#variables.DSN1#">
		EXEC sp_AdminSearchArticles
			@keywords = '#trim(arguments.keywords)#'
		</cfquery>
		<cfreturn qry>		
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Commit Functions -------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="commitArticle" access="public" output="false" returntype="numeric" 
		hint="Commit news article into db, returns it's ID">
	
		<cfargument name="newsID" 			required="yes" type="numeric">
		<cfargument name="title"    	 	required="yes" type="string">   
		<cfargument name="story"      		required="yes" type="string"> 
		<cfargument name="dateCommence" 	required="yes" type="date">
		<cfargument name="isHeadline"   	required="yes" type="boolean">
		<cfargument name="productID"   		required="yes" type="numeric">
		<cfargument name="newsTypeID"   	required="yes" type="numeric">
		<cfargument name="lstSectorIDs"   	required="yes" type="string">
		<cfargument name="byLine"   		required="yes" type="string">
		<cfargument name="modifiedBy" 		required="yes" type="numeric">
		<cfargument name="articleStatus"	required="yes" type="numeric">
		<cfargument name="circuit_id"		required="yes" type="numeric">
		<cfargument name="news_ticker"		required="yes" type="boolean">
		<cfargument name="section_id"		required="yes" type="numeric">
	
		<cfset var articleID=0>
		
		<!--- Perform Insert/Update --->
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_AddNews">
			<cfif arguments.newsID eq 0>				
				<cfprocparam dbvarname="@NewsID" 	 cfsqltype="cf_sql_integer" 	type="in" value="" null="yes">
			<cfelse>	
				<cfprocparam dbvarname="@NewsID" 	 cfsqltype="cf_sql_integer" 	type="in" value="#arguments.newsID#" >
			</cfif>
			<cfprocparam dbvarname="@HeadLineBanner" cfsqltype="cf_sql_varchar"  	type="in" value="#trim(arguments.title)#">
			<cfprocparam dbvarname="@Story" 		 cfsqltype="cf_sql_longvarchar" type="in" value="#trim(arguments.story)#">
			<cfprocparam dbvarname="@DateCommence"   cfsqltype="cf_sql_timestamp" 	type="in" value="#arguments.dateCommence#">
			<cfprocparam dbvarname="@HeadlineNews" 	 cfsqltype="cf_sql_bit" 		type="in" value="#arguments.isHeadline#">
			<cfprocparam dbvarname="@ProductID" 	 cfsqltype="cf_sql_integer" 	type="in" value="#arguments.productID#"> 
			<cfprocparam dbvarname="@NewsTypeID" 	 cfsqltype="cf_sql_integer" 	type="in" value="#arguments.newsTypeID#">
			<cfprocparam dbvarname="@SectorIDs" 	 cfsqltype="cf_sql_varchar" 	type="in" value="#arguments.lstSectorIDs#">
			<cfprocparam dbvarname="@ByLine" 	 	 cfsqltype="cf_sql_varchar" 	type="in" value="#trim(arguments.byLine)#">
			<cfprocparam dbvarname="@ModifiedBy" 	 cfsqltype="cf_sql_integer" 	type="in" value="#arguments.modifiedBy#">
			<cfprocparam dbvarname="@Status"  		 cfsqltype="cf_sql_integer" 	type="in" value="#arguments.articleStatus#">
			<cfprocparam dbvarname="@circuit_id"  	 cfsqltype="cf_sql_integer" 	type="in" value="#arguments.circuit_id#">
			<cfprocparam dbvarname="@NewsTicker"  	 cfsqltype="cf_sql_bit" 		type="in" value="#arguments.news_ticker#">
			<cfprocparam dbvarname="@section_id"  	 cfsqltype="cf_sql_integer" 	type="in" value="#arguments.section_id#">
			
			<cfprocparam dbvarname="@NewStoryID" 	 cfsqltype="cf_sql_integer" 	type="out" variable="articleID">
		</cfstoredproc>
		
		<!--- Return the article's ID --->
		<cfreturn articleID>
				
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Delete Functions -------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="deleteArticle" access="public" output="false" returntype="string" hint="">
		
		<cfargument name="ID" type="numeric" required="yes">
		
		<cfquery name="qryDel" datasource="#variables.DSN1#">
		EXEC sp_DeleteArticle
			@NewsID  = #Arguments.ID#
		</cfquery>
		
		<cfreturn true>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="undeleteArticle" access="public" output="false" returntype="string" hint="">
		
		<cfargument name="ID" type="numeric" required="yes">
		
		<cfquery name="qryDel" datasource="#variables.DSN1#">
		EXEC sp_UndeleteArticle
			@NewsID  = #Arguments.ID#
		</cfquery>
		
		<cfreturn true>
		
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->

</cfcomponent>