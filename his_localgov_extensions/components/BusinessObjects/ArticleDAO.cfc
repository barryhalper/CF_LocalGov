<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/DataAccessObjects/ArticleDAO.cfc $
	$Author: Bhalper $
	$Revision: 22 $
	$Date: 7/09/10 14:21 $

--->
<cfcomponent displayname="ArticleDAO" hint="Article-related data access methods" extends="his_Localgov_Extends.components.DAOManager">

	<!--- ------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="ArticleDAO" hint="Pseudo-constructor">
	
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		StructAppend( variables, Super.init( arguments.strConfig ) );
		
		return this;
		</cfscript>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Get Functions ----------------------------------------------------------------------------->
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
	<cffunction name="getNewsHomeContent" access="public" returntype="struct" 
		hint="retrieve all content required for the news home page">		
		
		<cfargument name="lstSectorIDs" required="no"	type="string" 	default="">
		
		 <cfset var strContent = StructNew()> 

		<cfstoredproc  datasource="#variables.DSN1#" procedure="sp_GetNewsHomeContent2">
			<cfif Len(arguments.lstSectorIDs)>
				<cfprocparam cfsqltype="cf_sql_varchar" type="in" dbvarname="@lstSectorIDs" value="#arguments.lstSectorIDs#">
			<cfelse>	
				<cfprocparam cfsqltype="cf_sql_varchar" type="in" dbvarname="@lstSectorIDs" value="" null="yes">
			</cfif>
			<!--- <cfprocresult name="strContent.qryAllNews"		resultset="1" >
			<cfprocresult name="strContent.qryUserComments" resultset="2" maxrows="5">
			<!---<cfprocresult name="strContent.qryTopStory" 	resultset="3" maxrows="5">---> --->
			<cfprocresult name="strContent.qryNews"			resultset="1" >
			<cfprocresult name="strContent.qryFeatures" 	resultset="2" maxrows="10">
			<cfprocresult name="strContent.qryPapers" 		resultset="3" maxrows="1">
			<cfprocresult name="strContent.qrySupplements"	resultset="4" maxrows="5">
			<cfprocresult name="strContent.qryPress" 		resultset="5" maxrows="1">
			<cfprocresult name="strContent.qryComments" 	resultset="6" maxrows="1">
			<cfprocresult name="strContent.qryUserComments" resultset="7" maxrows="5">
			<cfprocresult name="strContent.qryTopStory" 	resultset="8" maxrows="5">
		</cfstoredproc>

		<cfreturn strContent> 
		
	</cffunction>	
	
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getNewsHome" access="public" returntype="struct" hint="retrieve all content required for the news home page">		
		
		<cfset var strContent = StructNew()> 

		<cfstoredproc  datasource="#variables.DSN1#" procedure="sp_getLocalGovNewsHome">
			<cfprocresult name="strContent.qryTopStory" 	resultset="1" >
			<cfprocresult name="strContent.qryFeatures" 	resultset="2" >
			<cfprocresult name="strContent.qrySoapBox" 		resultset="3">
			<cfprocresult name="strContent.qryComments" 	resultset="4" >
		</cfstoredproc>

		<cfreturn strContent> 
		
	</cffunction>	
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getBusinessHome" access="public" returntype="struct" hint="retrieve all content required for the Business home page">		
		
		<cfset var strBusinessHomeContent = StructNew()> 

		<cfstoredproc  datasource="#variables.DSN1#" procedure="sp_getLocalGovBusinessHome">
			<cfprocresult name="strBusinessHomeContent.qryTopStory" 	resultset="1" >
			<cfprocresult name="strBusinessHomeContent.qryFeatures" 	resultset="2" >
			<cfprocresult name="strBusinessHomeContent.qrySupplements" 	resultset="3">
			<cfprocresult name="strBusinessHomeContent.qryAnalysis" 	resultset="4" >
			<!--- <cfprocresult name="strContent.qryNews"			resultset="5" > --->
		</cfstoredproc>

		<cfreturn strBusinessHomeContent> 
		
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
		<cfargument name="refresh" 		required="no"	type="boolean" 	default="0">
		<cfargument name="isHeadline" 		required="no"	type="boolean" 	default="1">
		
	
		
		<cfscript>
		var qryNews = "";
		var cacheTime = CreateTimeSpan(0,0,15,0);
		if (arguments.refresh)
			cacheTime = CreateTimeSpan(0,0,0,0);
		</cfscript>
		
		<!--- <cfdump var="#arguments#"><cfabort> --->
		<cfquery name="qryNews" datasource="#variables.DSN1#" cachedwithin="#cacheTime#" maxrows="#Arguments.HowMany#">
		EXEC sp_GetNewsArticles2
			@ProductID  			=  			'#arguments.Productid#',
			@NewsTypeID 			= 			'#arguments.NewsTypeID#',
			@Commence   			=  			#arguments.Commence#,
			@CheckIsHeadlineOnly 	= 			#arguments.isHeadline#,
			@lstSectorIDs 			=			'#arguments.lstSectorIDs#'
		</cfquery>
		
		<cfreturn qryNews>
	
	</cffunction>
	
	<cffunction name="GetArticlesByType" access="public" returntype="query" hint="return all news articles based on input criteria">
		<cfargument name="NewsTypeID"   required="yes"  	type="numeric" 	>
		<cfset var qryNews = QueryNew("temp")>	
		<!--- <cfdump var="#arguments#"><cfabort> --->
		<cfquery name="qryNews" datasource="#variables.DSN1#" >
		EXEC  dbo.sp_GetArticlesByType	
		#arguments.NewsTypeID#
			
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
	<cffunction name="getRelatedArticles" access="public" output="false" returntype="struct" hint="">
		
			<cfset var str = structNew()>
			<cfstoredproc  datasource="#variables.DSN1#" procedure="sp_LocalGov_GetRelatedArticles">
				<cfprocresult resultset="1" name="str.qryMostPopular"/>
				
				<cfprocresult resultset="2" name="str.qryMostComments" />
			</cfstoredproc>
		
		<cfreturn str>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getNewsInSectors" access="public" returntype="query" output="false" 
		hint="return all news stories in specfic sectors">

		<cfargument name="lstSectorID" required="yes" type="string">
		
		<cfset var qry="">
		<cfquery name="qry" datasource="#variables.DSN1#" cachedwithin="#CreateTimespan(0,2,0,0)#">
		EXEC spGetNewInSectors
			'#arguments.lstSectorID#'
		</cfquery>
		<cfreturn qry>
			
	</cffunction> 
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
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="adminSearchResultsByID" access="public" output="false" returntype="query" 
		hint="return queries containing the supplied keywords in the title">
		
		<cfargument name="keywords" required="yes"  type="string"> 
		
		<cfset var qry = "">
		<cfquery name="qry" datasource="#variables.DSN1#">
		EXEC sp_AdminSearchArticlesByID
			@keywords = '#trim(arguments.keywords)#'
		</cfquery>
		<cfreturn qry>		
		
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="adminAdvSearch" access="public" output="false" returntype="query" 
		hint="return query of article search">
		
		
		<cfargument name="id" 			required="no"  type="numeric"  default="0">
		<cfargument name="keys" 	required="no"  type="string" 	default=""> 
		<cfargument name="productid" 	required="no"  type="numeric"  default="0"> 
		<cfargument name="newstypeid" 	required="no"  type="numeric"  default="0"> 
		<cfargument name="statusid" 	required="no"  type="numeric"  default="0">
		<cfargument name="sectors" 		required="no"  type="string" 	default=""> 
		<cfargument name="datefrom" 	required="no"  type="string" 	default=""> 
		<cfargument name="dateto" 		required="no"  type="string" 	default=""> 
		
		<cfset var qrySearch = "">
		<cfquery name="qrySearch" datasource="#variables.DSN1#" cachedwithin="#CreateTimeSpan(0,0,0,20)#">
		sp_AdminAdvArticleSearch
			@NewsID    		=<cfif arguments.ID>#arguments.ID#<cfelse>NULL</cfif>,
			@keywords 		=<cfif Len(keys)>'#arguments.keys#'<cfelse>NULL</cfif>,
			@ProductID		=<cfif arguments.ProductID>#arguments.ProductID#<cfelse>NULL</cfif>,
			@NewsTypeid		=<cfif arguments.NewsTypeid>#arguments.NewsTypeid#<cfelse>NULL</cfif>,
			@statusid		=<cfif arguments.statusid>#arguments.statusid#<cfelse>NULL</cfif>,
			@lstSectorIDs	=<cfif len(arguments.sectors)>'#arguments.sectors#'<cfelse>NULL</cfif>,
			@datefrom		=<cfif len(arguments.datefrom)>#CreateODBCDate(LSDateFormat(arguments.datefrom,'dd/mmm/yyyy'))#<cfelse>NULL</cfif>,
			@dateto	 		=<cfif len(arguments.dateto)>#CreateODBCDate(LSDateFormat(arguments.dateto,'dd/mmm/yyyy'))#<cfelse>NULL</cfif>
		</cfquery>
		<cfreturn qrySearch>		
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="GetHomepageComments" access="public" output="false" returntype="query" hint="return all comments to be displayed on home page">
		
		<cfset var qryComments = "">
		
		<cfquery name="qryComments" datasource="#variables.DSN1#">
			EXEC sp_GetHomepageComments
		</cfquery>
		
		<cfreturn qryComments>	
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->

	
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

		<cfargument name="imgName"			required="yes" type="string">
		<cfargument name="imgCaption"		required="yes" type="string">
		<cfargument name="teaser"			required="yes" type="string">
		<cfargument name="IsTop"			required="yes" type="boolean">
		<cfargument name="metaDescription"	required="no"  type="string" default="">
		<cfargument name="topicid"			required="no"  type="string" default="">
		<cfargument name="accesstypeid"		required="no"  type="string" default="">
	
	
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

			<cfprocparam dbvarname="@imgName"  		 cfsqltype="cf_sql_varchar" 	type="in" value="#arguments.imgName#">
			<cfprocparam dbvarname="@imgCaption"  	 cfsqltype="cf_sql_varchar" 	type="in" value="#arguments.imgCaption#">
			<cfprocparam dbvarname="@teaser"  	 	 cfsqltype="cf_sql_varchar" 	type="in" value="#arguments.teaser#">
			<cfprocparam dbvarname="@Istop"  	 	 cfsqltype="cf_sql_bit" 	type="in" value="#arguments.Istop#">
			
			<cfprocparam dbvarname="@metaDescription" cfsqltype="cf_sql_varchar" type="in" value="#arguments.metaDescription#">
			<cfif Len(arguments.topicid) and isNumeric(arguments.topicid)>
				<cfprocparam dbvarname="@topicid"  	  	cfsqltype="cf_sql_integer" type="in" value="#arguments.topicid#">
			<cfelse>
				<cfprocparam dbvarname="@topicid"  	  	cfsqltype="cf_sql_integer" type="in" null="yes" value="">	
			</cfif>
			
			<cfif Len(arguments.accesstypeid) and isNumeric(arguments.accesstypeid)>
				<cfprocparam dbvarname="@accesstypeid"  	  	cfsqltype="cf_sql_integer" type="in" value="#arguments.accesstypeid#">
			<cfelse>
				<cfprocparam dbvarname="@accesstypeid"  	  	cfsqltype="cf_sql_integer" type="in" null="yes" value="">	
			</cfif>
			
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
	<!--- PUBLIC Destroy Functions -------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="destroyArticle" access="public" output="false" returntype="string" hint="Destroy an article by deleting all versions">
		
		<cfargument name="ID" type="numeric" required="yes">
		
		<cfquery name="qryDel" datasource="#variables.DSN1#">
		EXEC usp_destroyArticle
			@newsID  = #Arguments.ID#
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
	<cffunction name="getNewsTicker" access="public" returntype="query" hint="set news ticker data into xml">
		<cfset var qryticker = "">
		
		<cfquery name="qryticker" datasource="#variables.DSN1#">
			EXEC sp_getLocalGovNewsforTicker
		</cfquery>
		
		<cfreturn qryticker>	
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="mostPopular" access="public" returntype="query" hint="get top most popluar news stories">
		<cfset var qry = "">
		
		<cfquery name="qry" datasource="#variables.DSN1#">
			EXEC dbo.usp_GetMostPopularNews
		</cfquery>
		
		<cfreturn qry>	
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getNewsForRSS" access="public" output="false" returntype="query" hint="set all articles userd in our RSSS">
		<cfset var qry = "">
		
		<cfquery name="qry" datasource="#variables.DSN6#">
			dbo.usp_GetNewsForRSS
		</cfquery>
		
		<cfreturn qry>	
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getCompanyProfiles" access="public" output="false" returntype="struct" hint="get all articles userd in company profiles">
		<cfset var str = structNew()>
			<cfstoredproc datasource="#variables.DSN1#" procedure="sp_GetLocalGovCompanyProfiles">
            	<cfprocresult resultset="1" name="str.qryTop">
                <cfprocresult resultset="2" name="str.qryArticles">
            </cfstoredproc>
		
		
		<cfreturn str>	
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="exportToGovernetz" access="public" output="false" returntype="void" hint="export an article to Governetz db">
		<cfargument name="ID" type="numeric" required="yes">

		<cfquery name="qry" datasource="#variables.DSN1#">
			[sp_ExportNewsToGovernetz] @NewsID=#arguments.ID#
		</cfquery>
		
	</cffunction>
	
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="exportCheck" access="public" output="false" returntype="query">
		<cfargument name="dbname" type="string" required="yes">
		<cfargument name="articleID" type="numeric" required="yes">
		
		<cfset var qry = "">
		
		<cfquery datasource="#arguments.dbname#" name="qry">
			exec dbo.usp_exportCheck #arguments.articleid#
		</cfquery>
		
		<cfreturn qry>	
	</cffunction>	
	
	<cffunction name="exportArticle" access="public" output="false" returntype="numeric">
		<cfargument name="dbname" type="string" required="yes">
		<cfargument name="newID" type="numeric" required="yes">
		<cfargument name="origID" type="numeric" required="yes">
		<cfargument name="qryArticle" type="query" required="yes">
		
		<cfset var nid = 0>
		
		<!--- <cfquery datasource="#arguments.dbname#" name="qry">			
			exec usp_saveArticle 
			@ArticleID    	= <cfif arguments.newID neq 0>#arguments.newID#<cfelse>NULL</cfif>,			
			@ArticleTypeID 	= 1,			
			@Title			= '#qryArticle.HeadlineBanner[1]#',
			@Byline			= '#qryArticle.byline[1]#',
			@ArticlePosition = 1,
			@Copy			= '#qryArticle.story[1]#',
			@DatePublished 	= '#qryArticle.datePosted[1]#',
			@statusid		= 1,
			@oldID			= #arguments.origID#		
		</cfquery> --->
		
			<!--- <cfdump var="#arguments#"> --->
		
		<cfstoredproc datasource="#arguments.dbname#" procedure="usp_SaveArticleFromLocalGov" returncode="yes">
			<cfif arguments.newid eq 0>
				<cfprocparam dbvarname="@ArticleID" 	 cfsqltype="cf_sql_integer" 	type="in" value="" null="yes"  >	
			<cfelse>
				<cfprocparam dbvarname="@ArticleID" 	 cfsqltype="cf_sql_integer" 	type="in" value="#arguments.newID#" >
			</cfif>		
			<cfprocparam dbvarname="@ArticleTypeID" cfsqltype="cf_sql_integer"  	type="in" value="1">			
			<cfprocparam dbvarname="@Title" 		 cfsqltype="cf_sql_varchar" type="in" value="#qryArticle.HeadlineBanner[1]#">			
			<cfprocparam dbvarname="@Byline"   cfsqltype="cf_sql_varchar" 	type="in" value="#qryArticle.byline[1]#">			
			<cfprocparam dbvarname="@ArticlePosition" 	 cfsqltype="cf_sql_integer" 		type="in" value="1">			
			<cfprocparam dbvarname="@Copy" 	 cfsqltype="cf_sql_varchar" 	type="in" value="#qryArticle.story[1]#">
				<cfprocparam dbvarname="@AuthorID" 	 cfsqltype="cf_sql_integer" 		type="in" value="1">		
			<cfprocparam dbvarname="@DatePublished" 	 cfsqltype="cf_sql_date" 	type="in" value="#qryArticle.datePosted[1]#">
			
			<cfprocparam dbvarname="@MetaDescription"   cfsqltype="cf_sql_varchar" 	type="in" value="" null="yes">
			<cfprocparam dbvarname="@SectorID"   cfsqltype="cf_sql_varchar" 	type="in" value="" null="yes">
			<cfprocparam dbvarname="@teaserImage"   cfsqltype="cf_sql_varchar" 	type="in" value="" null="yes">
			<cfprocparam dbvarname="@dateend"   cfsqltype="cf_sql_date" 	type="in" value="" null="yes">
					
			<cfprocparam dbvarname="@statusid" 	 cfsqltype="cf_sql_integer" 	type="in" value="1">		
			
			<cfprocparam dbvarname="@abstract"   cfsqltype="cf_sql_varchar" 	type="in" value="" null="yes">
			<cfprocparam dbvarname="@image"   cfsqltype="cf_sql_varchar" 	type="in" value="" null="yes">
			<cfprocparam dbvarname="@oldurl"   cfsqltype="cf_sql_varchar" 	type="in" value="" null="yes">
				
			<cfprocparam dbvarname="@oldID" 	 	 cfsqltype="cf_sql_integer" 	type="in" value="#arguments.origID#">
			
			<cfprocparam dbvarname="@newID" 	 cfsqltype="cf_sql_integer" 	type="out" variable="nid">
		</cfstoredproc>
		
		<!--- <cfdump var="#cfstoredproc#"><cfabort> --->
		
		<cfset retcode = cfstoredproc.StatusCode>
		<cfreturn retcode>
		<!--- <cfdump var="#qry#"> --->
	</cffunction>	
	
</cfcomponent>