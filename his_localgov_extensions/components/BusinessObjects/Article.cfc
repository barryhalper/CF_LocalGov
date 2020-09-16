<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/BusinessObjects/Article.cfc $
	$Author: bhalper $
	$Revision: 45 $
	$Date: 7/09/10 14:21 $

--->

<cfcomponent displayname="Article" hint="Article-related business object functions" extends="his_Localgov_Extends.components.BusinessObjectsManager">

	<!--- -------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR -------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Article" hint="Pseudo-constructor">
	
		<cfargument name="objAppObjs" 		type="any" 	   required="yes" hint="The application manager object">
		<cfargument name="bFilter" 			type="boolean" required="no" default="false" hint="Flag to determine whether we need to filter RSS feed">
		<cfargument name="bForceRetrieval"  type="boolean" required="no" default="false" hint="Flag to determine whether we need to retrieve RSS feed">
		<cfargument name="useProxy"  		type="boolean" required="no" default="false" hint="Flag to determine whether we use the proxy or not">
		
		<cfscript>
			// Call the genric init function, placing business, app, and dao objects into a local scope...
			structAppend( variables, Super.initChild( arguments.objAppObjs, this) );
			
			// Today's papers, initialisation...
			variables.strPapers= 						structNew();
			variables.strBusinessPapers= 				structNew();
			variables.strPapers.dLastRetrieved= 		dateAdd("y",-6,now());
			variables.strBusinessPapers.dLastRetrieved=	dateAdd("y",-6,now());
			variables.strPapers.arrPapers= 				arrayNew(1);
			variables.strBusinessPapers.arrPapers= 		arrayNew(1);
			variables.businessSectorid					=65;
	
			return this;
		</cfscript>
				
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions --------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getVariables" access="public" output="false" returntype="struct" hint="">
		<cfreturn variables>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getNewsTypes" access="public" output="false" returntype="query" hint="">
		<cfreturn objDAO.getNewsTypes()>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	
	<cffunction name="getNewsHome" access="public" output="false" returntype="struct" hint="">
		<cfargument name="refresh" type="boolean" required="no" default="false"> 
        
        <cfset setNewsHome(refresh)>
        <cfreturn variables.strHomePageNews>
        
        
	</cffunction>
    <!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getNewsHomebySector" access="public" output="false" returntype="struct" hint="">
		<cfargument name="sectorid" type="numeric" required="yes"> 
        <cfreturn objDAO.getNewsHomeForSector(arguments.sectorid)>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="setNewsHome" access="public" output="false" returntype="void" hint="">
		<cfargument name="refresh" required="no"	type="boolean" 	default="false">
		
		<cfset var strHomePageNews = StructNew()>
        
		
		<!--- if the key exists in the variables structure and the refreshQuery argument is false, acess the recordset from memory --->
		<cfif NOT StructKeyExists(variables, "strHomePageNews") OR arguments.refresh>
			<cfset variables.strHomePageNews			= objDAO.getNewsHome()>
			
		</cfif>
	</cffunction>
	
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getRelatedArticles" access="public" output="false" returntype="struct" hint="get all articles related to an article from memory">
		<cfargument name="refresh" required="no"	type="boolean" 	default="false">
		
		<cfset setRelatedArticles()>
		<cfreturn variables.strRelated>
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="setRelatedArticles" access="public" output="false" returntype="void" hint="set all articles related to an article in memory">
		<cfargument name="refresh" required="no"	type="boolean" 	default="false">
		
		<cfset var strRelated = StructNew()>
		
		<!--- if the key exists in the variables structure and the refreshQuery argument is false, acess the recordset from memory --->
		<cfif NOT StructKeyExists(variables, "strRelated") OR arguments.refresh>
			<cfset variables.strRelated			= objDAO.getRelatedArticles()>		
		</cfif>
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getNewsForRSS" access="public" output="false" returntype="query" hint="get all articles userd in our RSSS">
		<cfargument name="refresh" required="no"	type="boolean" 	default="false">
		
		<cfset setNewsForRSS()>
		<cfreturn variables.qryRSSFeed>
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="setNewsForRSS" access="public" output="false" returntype="void" hint="set all articles userd in our RSSS">
		<cfargument name="refresh" required="no"	type="boolean" 	default="false">
		
		<cfset var qryRSSFeed = queryNew("title,teaser,dateposted,newsid,byline")>
		<cfset var filecontent = ''>
		
		<!--- if the key exists in the variables structure and the refreshQuery argument is false, acess the recordset from memory --->
		
		<cfset qryRSSFeed			= objDAO.getNewsForRSS()>	
		<cfloop query="qryRSSFeed">
			<cfif NOT Len(trim(teaser))>
				<cfset QuerySetCell(qryRSSFeed, "teaser", request.objApp.ObjString.stripHtml(request.objApp.ObjString.FormatTeaser(qryRSSFeed.story, 250)), qryRSSFeed.currentrow)>
			</cfif>
		</cfloop>	
		
		<cfscript>
		//prepare recorset for RSS
		qryRSSFeed =request.objApp.ObjRss.Qry4RSS(qryRSSFeed, "title", "teaser", "dateposted", "newsid", "byline");
		//outout RSS
		filecontent = request.objApp.ObjRss.CreateRSS(qryRSSFeed, "LocalGov News", request.sSitePath & "index.cfm?method=news.detail&amp;id");
		</cfscript>
		
		<cffile action="write" file="#request.strsiteconfig.strPaths.sitedir##request.strsiteconfig.strPaths.rssdir#newsrss.xml" output="#filecontent#">
		
	</cffunction>
	
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getBusinessHome" access="public" output="false" returntype="struct" hint="Retrieve all content required for the Business home page">
		<cfargument name="refresh" required="no"	type="boolean" 	default="false">
		
		<cfscript>
			var strBusiness 	= StructNew();
			var qryNewsTicker 	= queryNew("temp");
			var lstIDs 			= "";
			var strPapers 		= StructNew();
			
			//if the key exists in the variables structure and the refreshQuery argument is false, acess the recordset from memory
			if (NOT StructKeyExists(variables, "strBusinessHomeContent") OR arguments.refresh)
			{
				variables.strBusinessHomeContent	= objDAO.getBusinessHome();
				strBusiness							= variables.strBusinessHomeContent;
			}
				
			else
			{
				strBusiness					= variables.strBusinessHomeContent;
			}
			
			strBusiness.qryPapers			= PapersToQuery();	
			
			//Get News Ticker data
			/*qryNewsTicker = getBusinessTicker();
			if(qryNewsTicker.recordCount)
			{
				//Randomise the Ids
				strBusiness.lstIDs = randomiseIDs(qryNewsTicker);
			}*/
			
			//Todays papers
			//strBusiness.strPapers = getTodaysBusinessPapers(bFilter=false, useProxy=request.strSiteConfig.strVars.useProxy);
			//strBusiness.Papers = strPapers;
			
			/**<invoke methodcall=	"getBusinessTicker()"	
							object=	"request.objBus.objArticle" 
							returnvariable=	"qryNewsTicker" />
					
					<invoke methodcall=	"randomiseIDs(qryNewsTicker)"		
							object="request.objBus.objArticle" 
							returnvariable=	"lstIDs" />
							
					<invoke methodcall=	"getTodaysBusinessPapers( bFilter=false, useProxy=request.strSiteConfig.strVars.useProxy )" 	
							object="request.objBus.objArticle" 
							returnvariable= "strPapers" 			/>	**/
			
			return strBusiness;
		
		</cfscript>
		
		<!--- <cfdump var="#strBusiness#"><cfabort> --->
	</cffunction>
	
    
    <!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getCompanyProfiles" access="public" output="false" returntype="struct" hint="get all articles userd in company profiles">
		<cfreturn objDAO.getCompanyProfiles()>
	</cffunction>
    
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="PapersToQuery" access="public" output="false" returntype="query" hint="">
		
		<cfscript>
		var strPapers 	= getTodaysPapers(useProxy=strConfig.strVars.useProxy);
		var i 			= 0;
		var qry 		= QueryNew("id,title,NoOfArticles");
		for (i=1; i lte arrayLen(strPapers.arrPapers); i=i+1) {
			QueryAddRow(qry);
			QuerySetCell(qry, 'id', "#i#");
			QuerySetCell(qry, 'title', strPapers.arrPapers[i].rssTitle[1]);
			QuerySetCell(qry, 'NoOfArticles', strPapers.arrPapers[i].recordcount);
		}
		return qry;
		</cfscript>
	</cffunction>
	
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getNewsHomeContent" access="public" output="false" returntype="struct" hint="">
	
		<cfargument name="lstSectorIDs" required="no"	type="string" 	default="">
		<cfargument name="refresh" required="no"	type="boolean" 	default="false">
		
		<cfscript>
		var strNewsHome = structNew();
		if (structKeyExists(variables, "strNewsHomeContent") and not arguments.refresh)
			strNewsHome = variables.strNewsHomeContent;
		else{
			strNewsHome = objDAO.getNewsHomeContent(lstSectorIDs);
			variables.strNewsHomeContent = strNewsHome;
			
			
			strNewsHomeContent.qryTopStory 		=  objUtils.queryofQuery(strNewsHomeContent.qryTopStory , "*", "SectorIDs <> '65'");
			strNewsHomeContent.qrySupplements 	=  objUtils.queryofQuery(strNewsHomeContent.qrySupplements , "*", "SectorIDs <> '65'");
			strNewsHomeContent.qryFeatures 		=  objUtils.queryofQuery(strNewsHomeContent.qryFeatures , "*", "SectorIDs <> '65'");
			strNewsHomeContent.qryNews 			=  objUtils.queryofQuery(strNewsHomeContent.qryNews , "*", "SectorIDs <> '65'");
			
			
			/*qryAllNews = 						duplicate(strNewsHome.qryAllNews);			  
	
			strNewsHomeContent.qryNews 			=  objUtils.queryofQuery(qryAllNews, "*", "f_newstype_Id=1");
			strNewsHomeContent.qryFeatures 		=  objUtils.queryofQuery(qryAllNews , "*", "0=0", "");
			strNewsHomeContent.qryPapers 		=  objUtils.queryofQuery(qryAllNews , "*", "f_newstype_Id=3",  "",1);
			strNewsHomeContent.qrySupplements 	=  objUtils.queryofQuery(qryAllNews , "*", "f_newstype_Id=4 AND SectorIDs <> '65'", "",5);
			strNewsHomeContent.qryPress 		=  objUtils.queryofQuery(qryAllNews , "*", "f_newstype_Id=5", "",1);
			strNewsHomeContent.qryComments 		=  objUtils.queryofQuery(qryAllNews , "*", "f_newstype_Id=6", "",1);
			//strNewsHomeContent.qryTopStory 		=  ;
			strNewsHomeContent.qryTopStory 		=  objUtils.queryofQuery(strNewsHome.qryAllNews , "*", "Istop=1", "", 5);
			strNewsHomeContent.qryUserComments  =  strNewsHome.qryUserComments;
			strNewsHomeContent.qryAllNews 				= strNewsHome.qryAllNews;	*/
			//strNewsHome 						= variables.strNewsHomeContent;	
		
		//request.objApp.objUtils.dumpabort();
			}
		return strNewsHome;
		</cfscript>
	
	</cffunction>
	
	
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getBusinessNewsHomeContent" access="public" output="false" returntype="struct" hint="">
	<cfargument name="refresh" required="no"	type="boolean" 	default="false">
		
		<cfscript>
		var strBusiness = StructNew();
		if(structKeyExists(variables, "strBusinessHome") and not arguments.refresh)
			strBusiness = variables.strBusinessHome;
		else{
			variables.strBusinessHome =  objDAO.getNewsHomeContent(variables.businessSectorid);
			strBusiness = variables.strBusinessHome; 
			}
		return 	strBusiness;
		</cfscript>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	
	<!--- <cffunction name="getRelatedArticles" access="public" output="false" returntype="query" hint="">
		<cfargument name="lstSectorID" required="yes" type="string">
		<cfargument name="title" 	   required="no"  type="string" default="">

	
		<cfreturn objDAO.getRelatedArticles( arguments.lstSectorID, arguments.title )>
		
	</cffunction> --->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getNewsForTicker" access="public" output="true" returntype="query" hint="returns a query containing all data for the news ticker">
		<cfargument name="noOfHISArticles"		required="no" type="numeric" default="#strConfig.strVars.newsTicker_NoOfHISArticles#">
		<cfargument name="noOfPaperArticles"	required="no" type="numeric" default="#strConfig.strVars.newsTicker_NoOfPaperArticles#">
		<cfargument name="useProxy"				required="no" type="numeric" default="false">

		<cfscript>
		var qry = 				QueryNew("id,title,source,link");
		var qryPapers = 		"";
		var strContent = 		getNewsHomeContent();
		var qryPressReleases = 	strContent.qryPress;
		var qryArticles = 		strContent.qryNews;
		var strPapers = 		getTodaysPapers(useProxy=arguments.useProxy);
		//var strInfo4Local =     getInfo4Local();
		</cfscript>
				
		<!--- Tailor Articles flagged for the news ticker... --->
		<cfloop query="qryArticles" startrow="1" endrow="#arguments.NoOfHISArticles#" >
			<cfif qryArticles.NewsTicker eq 0 or qryArticles.NewsTicker eq "">
				<cfset QueryAddRow(qry)>
				<cfset QuerySetCell(qry, "id", 		newsid)>
				<cfset QuerySetCell(qry, "title", 	title)>
				<cfset QuerySetCell(qry, "source", 	product)>
				<cfset QuerySetCell(qry, "link", 	"")>
			</cfif>
		</cfloop>
		
		<!--- Tailor Press Releases flagged for the news ticker... --->
		<cfloop query="qryPressReleases" startrow="1" endrow="#arguments.NoOfHISArticles#" >
			<cfif qryPressReleases.NewsTicker eq 0 or qryPressReleases.NewsTicker eq "">
				<cfset QueryAddRow(qry)>
				<cfset QuerySetCell(qry, "id", 		newsid)>
				<cfset QuerySetCell(qry, "title", 	title)>
				<cfset QuerySetCell(qry, "source", 	product & " - Press Release")>
				<cfset QuerySetCell(qry, "link", 	"")>
			</cfif>
		</cfloop>
		
		<!--- Tailor articles from Today's Papers for the news ticker... --->
		<cfloop from="1" to="#ArrayLen(strPapers.arrPapers)#" index="i">
			<cfset qryPapers = strPapers.arrPapers[i]>
			<cfif qryPapers.RecordCount>
				<cfloop query="qryPapers" startrow="1" endrow="#NoOfPaperArticles#">
					<cfset QueryAddRow(qry)>
					<cfset QuerySetCell(qry, "id", 		"###i#")>
					<cfset QuerySetCell(qry, "title", 	qryPapers.title)>
					<cfset QuerySetCell(qry, "source", 	qryPapers.rsstitle)>
					<cfset QuerySetCell(qry, "link", 	"")>
				</cfloop>
			</cfif>
		</cfloop>

	
		<cfreturn qry>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="randomiseIDs" access="public" returntype="string" output="false" 
		hint="returns a list of randomly ordered ids for a given query">
		
		<cfargument name="qry" required="yes" type="query">
		
		<cfscript>
		var lstIDs= 		"";
		var lstUsedIDs= 	"";
		var nQrySize= 		arguments.qry.recordcount;
		var nRndAttempts=	nQrySize * 100;
		 
		for (item=1; item lte nQrySize; item=item+1) {
			for (randomise=1; randomise lte nRndAttempts; randomise=randomise+1) {
				rnd_id = randrange(1, nQrySize);
				if (not listfind(lstUsedIDs, rnd_id)) {
					lstUsedIDs = ListAppend(lstUsedIDs, rnd_id);
					break;
				}
		   }
		   lstIDs = ListAppend(lstIDs, rnd_id);
		}
		return lstIDs;
		</cfscript>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="setNewsTicker" access="public" returntype="void" hint="set news ticker data into xml">
		<cfargument name="fuseaction" required="no" type="string" default="index.cfm?method=news.detail&amp;id=">
		<cfscript>
		var xmldoc	= "";
		var qryNews = objDAO.getNewsTicker();
		//qryNews 	= randomiseIDs(qryNews);
		</cfscript>
		
		<cfoutput>
		<cfsavecontent variable="xmlDoc">
		<!--- <?xml version="1.0" encoding="iso-8859-1"?> --->
		<news>
		<news pausecountdown="3" maxChar="80" uppercase="true" />
			<cfloop query="qryNews"><news headline="#xmlFormat(qryNews.title)#" date="#DateFormat(qryNews.DateCommence, 'dd/mm/yy')#" link="#arguments.fuseaction##qryNews.newsid#" target="_self"/></cfloop>
		</news>
		</cfsavecontent>
		</cfoutput>
		
		<cfset objxml.Xml2File(xmlDoc, strConfig.strPaths.sitedir & "extends\xml\news.xml" , "overwrite") >
	</cffunction>

	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="searchNews" access="public" returntype="struct" output="false" hint="limit verity search results to news and other specfied filters">
		<cfargument name="objsearch" 	required="yes"  type="any" default="">
		<cfargument name="keywords"		required="yes"  type="string" default="">
		<cfargument name="lstSectorID" required="no"  type="string" default="">
		<cfargument name="contenttype" required="no"  type="string" default="News">
		<cfargument name="pubdate" 	   required="no"  type="string" default="">
		<cfargument name="startdate"   required="no"  type="string" default="">
		<cfargument name="endate" 	   required="no"  type="string" default="">
		
		
		<cfscript>
		var strReturn = StructNew();
		var sqlwhere = "0=0";
		var qryNews = queryNew("temp");
		var qryNewsinSectors ="";
		var criteria = arguments.keywords;
		//set error key
		strReturn.isError=0;
		If (len(criteria))
			criteria = criteria & " AND cf_custom1=#arguments.contenttype#";
		else
			criteria = "cf_custom1=#arguments.contenttype#";
		
		if 	(len(arguments.endate) OR len(arguments.startdate) OR len(arguments.pubdate))
			sqlwhere = sqlwhere & " and custom3 <> ''";
			
		if (len(arguments.pubdate))
			sqlwhere = 	sqlwhere & " AND custom3 >= '#datePeriod2string(arguments.pubdate)#'";
		if (len(arguments.startdate)) 
			sqlwhere = sqlwhere & " AND custom3 >= '#datePeriod2string(arguments.startdate)#'";
		if (len(arguments.endate))
			sqlwhere = sqlwhere & " AND custom3 <= '#datePeriod2string(arguments.endate)#'";
		
		</cfscript>
		
		<cftry>
		<cfscript>
		qryNews = arguments.objSearch.getCollectionSearch(criteria).qryResults;
		qryNews =variables.objUtils.QueryOfQuery(qryNews, '*', sqlwhere, "custom3 DESC");</cfscript>
		
		<!--- check if sectord id's have been passed ---> 
		<cfif len(arguments.lstSectorID)>
			<!---perform join on verity search and sql search for sectors  --->
			<cfset qryNewsinSectors = getNewsInSectors(arguments.lstSectorID)>
			<cfquery dbtype="query" name="qryNews">
			SELECT *
			FROM qryNews,qryNewsinSectors
			WHERE qryNews.custom2 = qryNewsinSectors.NewsIDVar
			ORDER BY qryNews.custom3 DESC
			</cfquery>
		</cfif>
			<cfcatch type="InvalidSearch">
				<cfset strReturn.isError=1>
				<!--- place error message in struct - removing the 'cf_custom' var from the string---> 
				<cfset strReturn.ErrorMessage =cfcatch.message>
			</cfcatch>	
	 	</cftry>
			<cfset strReturn.qryNews=qryNews>
		 <cfreturn strReturn>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getNewsInSectors" access="public" returntype="query" output="false" 
		hint="return all news stories in specfic sectors">
		<cfargument name="lstSectorID" required="yes" type="string">
		<cfreturn objDAO.getNewsInSectors( arguments.lstSectorID )>	
	</cffunction> 
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="storeRecentArticles" access="public" output="false" returntype="boolean" hint="">
		<!--- todo: passs session in --->
				
		<!--- Store the article ID in the session scope for My Local Gov page... --->
		<cfif FindNoCase("news.detail", cgi.QUERY_STRING)>
			<cfif Not StructKeyExists(Session, "Articles")>
				<cfset session.Articles = "">
			</cfif>
			<cfif Not ListFindNoCase(session.Articles, url.id)>
				<cfif ListLen(session.Articles) GTE 10>
					<cfset session.Articles = url.id  & "," & ListDeleteAt(session.Articles, ListLen(session.Articles)) >
				<cfelse>
					<cfset session.Articles = url.id & "," & session.Articles>
				</cfif>
			</cfif>
		</cfif>
		
		<cfreturn true>

	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="GetTopics" access="public" output="false" returntype="query" hint="returns topics">

		<cfreturn objDAO.GetTopics()>
	
	</cffunction>	
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="adminGetRecentArticles" access="public" output="false" returntype="query" hint="returns recently added articles">

		<cfreturn objDAO.adminGetRecentArticles( 0 )>
	
	</cffunction>		
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="adminGetDeletedArticles" access="public" output="false" returntype="query" hint="returns all deleted articles">

		<cfreturn objDAO.adminGetDeletedArticles( 0 )>
	
	</cffunction>		
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="adminGetScheduledArticles" access="public" output="false" returntype="query" hint="returns any articles scheduled in the future">

		<cfreturn objDAO.adminGetScheduledArticles( 0 )>
	
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="adminSearchResults" access="public" output="false" returntype="query" hint="return queries containing the supplied keywords in the title">
		<cfargument name="keywords" required="yes"  type="string"> 
						
		<cfif isnumeric(arguments.keywords)>
			<cfreturn objDAO.adminSearchResultsByID( arguments.keywords )>
		<cfelse>
			<cfreturn objDAO.adminSearchResults( arguments.keywords )>
		</cfif>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="adminAdvSearch" access="public" output="false" returntype="query" 
		hint="return adv article search for admin">
				
		<cfargument name="id" 			required="no"  type="numeric"  default="0">
		<cfargument name="keys" 		required="no"  type="string" 	default=""> 
		<cfargument name="productid" 	required="no"  type="numeric"  default="0"> 
		<cfargument name="newstypeid" 	required="no"  type="numeric"  default="0"> 
		<cfargument name="statusid" 	required="no"  type="numeric"  default="0">
		<cfargument name="sectors" 		required="no"  type="string" 	default=""> 
		<cfargument name="datefrom" 	required="no"  type="string" 	default=""> 
		<cfargument name="dateto" 		required="no"  type="string" 	default=""> 
		
		<!--- <cfdump var="#arguments#"><cfabort> --->
		<cfreturn objDAO.adminAdvSearch(argumentcollection=arguments) />
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	
	<cffunction name="getPressReleases" access="public" output="false" returntype="query" hint="returns press releases">
		<cfargument name="HowMany" type="numeric" required="no" hint="number items to return" default="-1">
		<cfargument name="lstSectorIDs" 	type="string" 	required="no" hint="list containing sector ids" default="">	
		<cfargument name="refresh" 			type="boolean" 	required="no" hint="" default="0">
		
		<!--- <cfreturn objDAO.getNewsArticles( NewsTypeID=5, HowMany=Arguments.HowMany, lstSectorIDs=arguments.lstSectorIDs )> --->
		<cfscript>
		var qryPressReleases = "";
		if (StructKeyExists(variables, "qryPressReleases") and NOT arguments.refresh)
			qryPressReleases =  variables.qryPressReleases;
		else	
			{
		    variables.qryPressReleases =objDAO.getNewsArticles( NewsTypeID=5, HowMany=Arguments.HowMany, lstSectorIDs=arguments.lstSectorIDs, refresh= Arguments.refresh);
			qryPressReleases =  variables.qryPressReleases;
			}
		return 	qryPressReleases;
		</cfscript>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getInfo4Local" access="public" output="false" returntype="struct" hint="returns press releases">
		<cfargument name="section"  type="string" required="no" default="">
		<cfargument name="useProxy" type="boolean" 	required="false" 	default="true"  hint="">
		<cfargument name="refresh"  type="boolean" 	required="false" 	default="false"  hint="">
		
		<cfscript>
		var strReturn = StructNew();
		var arr = ArrayNew(1);
		strReturn.qryRSS = ArrayNew(1);
		

		/*if (structKeyExists(variables, "strInfo4Local") and NOT arguments.refresh) 
		 strReturn = variables.strInfo4Local;
		 
		 else 
		{
		arr = XMLSearch( objRSS.getInfo4LocalRSS(arguments.section), "/rss/feed_url" );
		// Loop through feed rss'
		for ( i=1; i LTE ArrayLen(arr); i=i+1 ) 	
			strReturn.qryRSS[i] = objRSS.readRSS( arr[i].XmlText, arr[i].xmlAttributes.type, arguments.useProxy );
	
			 variables.strInfo4Local = strReturn;
		};*/
			return strReturn;
				
		</cfscript>
		
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="get24Dash" access="public" output="false" returntype="struct" hint="returns press releases">
		<cfargument name="section" type="string" required="no" default="">
		<cfargument name="useProxy" type="boolean" 	required="false" 	default="true"  hint="">
		<cfargument name="refresh"  type="boolean" 	required="false" 	default="false"  hint="">
		
		<cfscript>
		var strReturn = StructNew();
		var arr = ArrayNew(1);
		strReturn.qryRSS = ArrayNew(1);

		if (structKeyExists(variables, "str24Dash") and NOT arguments.refresh) 
		 strReturn = variables.str24Dash;
		 
		 else 
		{
		arr = XMLSearch( objRSS.get24DashRSS(arguments.section), "/rss/feed_url" );
		// Loop through feed rss'
		for ( i=1; i LTE ArrayLen(arr); i=i+1 ) 	
		 strReturn.qryRSS[i] = objRSS.readRSS( arr[i].XmlText, arr[i].xmlAttributes.type, arguments.useProxy );
	
			 variables.str24Dash = strReturn;
		}
			return strReturn;
				
		</cfscript>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getSupplements" access="public" output="false" returntype="query" hint="">
		<cfargument name="HowMany" 			type="numeric" required="no" hint="number items to return" default="-1">
		<cfargument name="lstSectorIDs" 	type="string" 	required="no" hint="list containing sector ids" default="">
		<cfargument name="refresh" 			type="boolean" 	required="no" hint="" default="0">
		
		<cfscript>
		var qrySupplements = objDAO.getNewsArticles( newsTypeID=4, howMany=Arguments.HowMany, lstSectorIDs=arguments.lstSectorIDs, refresh= Arguments.refresh );
		if (arguments.lstSectorIDs neq variables.businessSectorid)
			qrySupplements = objUtils.queryOfQuery(qrySupplements, "*", "SectorIds <> '65'");
		
		return 	qrySupplements;
		</cfscript>		
		
		
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getEditorsComment" access="public" output="false" returntype="query" hint="">
		<cfargument name="HowMany" 			type="numeric" required="no" hint="number items to return" default="-1">
		<cfargument name="lstSectorIDs" 	type="string" 	required="no" hint="list containing sector ids" default="">
		<cfargument name="refresh" 			type="boolean" 	required="no" hint="" default="false">	
		
		<cfreturn objDAO.getNewsArticles( newsTypeID=6, howMany=Arguments.HowMany, lstSectorIDs=arguments.lstSectorIDs, refresh= Arguments.refresh, IsHeadlineOnly=0 )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getResearch" access="public" output="false" returntype="query" hint="">
		<cfargument name="HowMany" 			type="numeric" required="no" hint="number items to return" default="-1">
		<cfargument name="lstSectorIDs" 	type="string" 	required="no" hint="list containing sector ids" default="">
		<cfargument name="refresh" 			type="boolean" 	required="no" hint="" default="false">	
		
		<cfreturn objDAO.getNewsArticles( newsTypeID=12, howMany=Arguments.HowMany, lstSectorIDs=arguments.lstSectorIDs, refresh= Arguments.refresh )>
		
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="GetArticlesByType" access="public" returntype="query" hint="return all news articles based on input criteria">
		<cfargument name="NewsTypeID"   required="yes"  	type="numeric" 	>

		<cfreturn objDAO.GetArticlesByType(#arguments.NewsTypeID#)>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getFeatures" access="public" output="false" returntype="query" hint="">
		<cfargument name="HowMany" 			type="numeric" 	required="no" hint="number items to return" 	   default="-1">
		<cfargument name="lstSectorIDs" 	type="string" 	required="no" hint="list containing sector ids" default="">
		
		<cfreturn objDAO.getNewsArticles( newsTypeID=2, howMany=Arguments.HowMany, lstSectorIDs=arguments.lstSectorIDs, refresh= Arguments.refresh )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getLatest" access="public" output="false" returntype="query" hint="Generic article retrieval function, return query based on supplied type argument.">
	
		<cfargument name="Type" 			type="numeric" 	required="yes"  	hint="type of article to get">
		<cfargument name="HowMany" 			type="numeric" 	required="yes" 	hint="number items to return">
		<cfargument name="lstSectorIDs" 	type="string" 	required="no" 	hint="list containing sector ids" default="">
		
		<cfscript>
		n = Arguments.howMany;
		
		/* Obtain data set, depending on the supplied article type... */
		
		switch ( Arguments.Type ) {
		case 1 : { 
			qryRtn = objDAO.getNewsArticles( howMany=n, newsTypeID="1,2", lstSectorIDs=arguments.lstSectorIDs ); // News and features 
			// Remove any ~ left over from the auto-linking...
			qryRtn.teaser = replace(qryRtn.teaser, "~", "", "all"); 
			break; 
		}
		case 2 : {  qryRtn = objDAO.getFeature( n ); 		break; }
		case 3 : {  qryRtn = objDAO.getPaper( n ); 			break; }
		case 4 : {  qryRtn = objDAO.getSupplement( n ); 	break; }
		case 5 : {  qryRtn = objDAO.getPressRelease( n ); 	break; }
		case 6	: { qryRtn = objDAO.getEditorsComment( n ); break; }
		//default : {}
		} 
				
		// Return the query for the specified article type...
		return qryRtn;
		</cfscript>
		
	
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getHeadline" access="public" output="false" returntype="string" hint="Returns a headline for a specific article">
		
		<cfargument name="ID" type="numeric" required="false" default="0" hint="id of the article">
		
		<cfreturn objDAO.getHeadline( arguments.ID )>
		
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getArticles" access="public" output="false" returntype="query" hint="Returns a headline for a specific articles">
		
		<cfargument name="lstIDs" type="string" required="false" default="0" hint="list of article ids">
		
		<cfreturn objDAO.getArticles( arguments.lstIDs )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getTodaysPapers" access="public" output="true" returntype="struct" hint="Retrieve Today's Papers">
		
		<cfargument name="bFilter" 				type="boolean" 	required="false" 	default="false"  hint="">
		<cfargument name="bForceRetrieval" 		type="boolean" 	required="false" 	default="false"  hint="">
		<cfargument name="useProxy" 			type="boolean" 	required="false" 	default="true"   hint="">

		<cfscript>
			var strReturn = StructNew(); 
			var qryRss    = queryNew("temp");
			var arrRSSElements    = arrayNew(1);  
		
			// Force retrieval, if specified...
			if (NOT arguments.bForceRetrieval  and StructKeyExists(variables.strPapers, "arrPapers") and ArrayLen(variables.strPapers.arrPapers) gt 0 ){
					strReturn = variables.strPapers ;					
				}
			else {
				strReturn.bl=0;
				// Obtain an array of rss feed urls...
				arrRSSElements = XMLSearch( objRSS.getRSSConfig(), "/rss/feed_url" );
				
				variables.strPapers.arrPapers = arrayNew(1);
				
				// Loop through feed rss'
				for ( i=1; i LTE ArrayLen(arrRSSElements); i=i+1 ){ 
					 qryRss = objRSS.readRSS( arrRSSElements[i].XmlText, arrRSSElements[i].XmlAttributes.type, arguments.useProxy );
						If (qryRss.recordcount)
						 	ArrayAppend(variables.strPapers.arrPapers, qryRss);	
						 	//arrayIndex = arrayIndex + 1
							//variables.strPapers.arrPapers[arrayIndex + 1 ] = qryRss;
					}
					
					 //set papers into persistant scope
					  strReturn = variables.strPapers;
				}  
	
			return strReturn;
		</cfscript>
		<!--- <cfdump var="#strReturn#"><cfabort> --->
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getTodaysBusinessPapers" access="public" output="false" returntype="struct" hint="Retrieve Today's Business Papers">
		
		<cfargument name="bFilter" 				type="boolean" 	required="false" 	default="false"  hint="">
		<cfargument name="bForceRetrieval" 		type="boolean" 	required="false" 	default="false"  hint="">
		<cfargument name="section" 				type="string" 	required="false" 	default="business">
		<cfargument name="useProxy" 			type="boolean" 	required="false" 	default="#strConfig.strVars.useProxy#"  >
		 
		<cfscript>
		
		var strReturn 		  = StructNew(); 
		var qryRss    		  = queryNew("temp"); 
		var arrRSSElements    = arrayNew(1); 
		// Determine whether we need to retrieve the external RSS feeds...
		//if ( DateDiff( "n", variables.strPapers.dLastRetrieved, now() ) GT objRSS.GetRetrievalFrequency() )
			//bRetrieve = true;

		// Force retrieval, if specified...
		
		if (NOT arguments.bForceRetrieval  and StructKeyExists(variables.strBusinessPapers, "arrPapers") and ArrayLen(variables.strBusinessPapers.arrPapers) gt 0 ){
				strReturn = variables.strPapers ;
			}
		else {
			// Obtain an array of rss feed urls...
			arrRSSElements = XMLSearch( objRSS.getRSSConfig(arguments.section), "/rss/feed_url" );
			
			// Loop through feed rss'
			for ( i=1; i LTE ArrayLen(arrRSSElements); i=i+1 ){ 	
				 qryRss = objRSS.readRSS( arrRSSElements[i].XmlText, arrRSSElements[i].XmlAttributes.type, arguments.useProxy );
					If (qryRss.recordcount)
					 	ArrayAppend(variables.strBusinessPapers.arrPapers, qryRss);	
				}
				
				 //set papers into persistant scope
				  strReturn = variables.strBusinessPapers;
			
			// Keep a note of the retrieval date/time...
			//variables.strPapers.dLastRetrieved = now();
			}  

		// Filter or not to filter?
		//if ( arguments.bFilter )
			//variables.strPapers.arrPapers = objRSS.filterRSS( variables.strPapers.arrPapers );
		
		// Return an array containing all the rss feeds...
		return strReturn;
		</cfscript>
	</cffunction>
	
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getBusinessTicker" access="public" output="true" returntype="query" hint="returns a query containing all data for the news ticker">
 
		
		<cfset var qry = QueryNew("id,title,source,link")>
		<cfset var qryArtcile = QueryNew("temp")>
		<cfset var qryPapers = "">
		<cfset var strContent = variables.strBusinessHome>
		<cfset var strPapers = getTodaysBusinessPapers( bFilter=false )>
		<!--- <cfset var strInfo4Local = getInfo4Local( section='business' )> --->
		<cfset var qryPressReleases = getPressReleases( HowMany=10, lstSectorIDs=variables.businessSectorid )>
		
		<!--- <cfdump var="#strContent#"><cfabort> --->
				
		<!--- Tailor Articles flagged for the news ticker... --->
		<cfloop query="strContent.qryNews" startrow="1" endrow="#strConfig.strVars.NewsTicker_NoOfHISArticles#" >
			<cfif strContent.qryNews.NewsTicker eq 0 or NOT Len(strContent.qryNews.NewsTicker)>
				<cfset QueryAddRow(qry)>
				<cfset QuerySetCell(qry, "id", 		newsid)>
				<cfset QuerySetCell(qry, "title", 	title)>
				<cfset QuerySetCell(qry, "source", 	product)>
				<cfset QuerySetCell(qry, "link", 	"")>
			</cfif>
		</cfloop>
		
		<!--- Tailor Press Releases flagged for the news ticker... --->
		<cfloop query="qryPressReleases" startrow="1" endrow="#strConfig.strVars.NewsTicker_NoOfHISArticles#" >
			<cfif qryPressReleases.NewsTicker eq 0 OR NOT Len(qryPressReleases.NewsTicker)>
				<cfset QueryAddRow(qry)>
				<cfset QuerySetCell(qry, "id", 		newsid)>
				<cfset QuerySetCell(qry, "title", 	title)>
				<cfset QuerySetCell(qry, "source", 	product & " - Press Release")>
				<cfset QuerySetCell(qry, "link", 	"")>
			</cfif>
		</cfloop>
		
		<!--- Tailor articles from Today's Papers for the news ticker... --->
		<cfloop from="1" to="#ArrayLen(strPapers.arrPapers)#" index="i">
			<cfset qryPapers = strPapers.arrPapers[i]>
			<cfif qryPapers.RecordCount>
				<cfoutput query="qryPapers" maxrows="#strConfig.strVars.NewsTicker_NoOfPaperArticles#">
					<cfset QueryAddRow(qry)>
					<cfset QuerySetCell(qry, "id", 		"###i#")>
					<cfset QuerySetCell(qry, "title", 	qryPapers.title)>
					<cfset QuerySetCell(qry, "source", 	qryPapers.rsstitle)>
					<cfset QuerySetCell(qry, "link", 	"")>
				</cfoutput>
			</cfif>
		</cfloop>

		<!--- Tailor articles from Info4Loca.gov.uk for the news ticker... 
		<cfloop from="1" to="#ArrayLen(strInfo4Local.qryRSS)#" index="i">
			<cfset qryArticle = strInfo4Local.qryRSS[i]>
			
			<cfif qryArticle.RecordCount>
				<cfoutput query="qryArticle" >
					<cfset QueryAddRow(qry)>
					<cfset QuerySetCell(qry, "id", 		0)>
					<cfset QuerySetCell(qry, "title", 	qryArticle.title)>
					<cfset QuerySetCell(qry, "source", 	qryArticle.rsstitle)>
					<cfset QuerySetCell(qry, "link", 	qryArticle.link)>
				</cfoutput>
			</cfif>
		</cfloop>--->
		<!--- Return the concatenated recordsets for the news ticker... --->
		<cfreturn qry>
	</cffunction>
	
	
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getVersions" access="public" returntype="query" hint="return a query containing all versions for a given article">
		<cfargument name="NewsID"    required="yes" default="0"  type="numeric" >
		
		<cfreturn objDAO.getVersions( arguments.NewsID )>
	
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getFull" access="public" output="false" returntype="query" hint="Generic article retrieval function, return query based on supplied type argument.">
		<cfargument name="Type"				type="numeric" required="true"  hint="type of article to get">
		<cfargument name="ID"              	type="numeric" required="true"  hint="id of the article">
        <cfargument name="VersionID"       	type="numeric" required="false" default="0"  hint="version of the article, zero/null means latest">
        <cfargument name="Resolve"     		type="boolean" required="false" default="true"  hint="flag to determine whether or not to resolve <his_link ...> links.">
        <cfargument name="GetLatestVersion" type="numeric" required="false" default="1"  hint="">

        <cfscript>
			var bGetLatestVersion = arguments.getLatestVersion;
            if (Arguments.VersionID neq 0) 
            {
				Arguments.ID = Arguments.VersionID;
				bGetLatestVersion=   0;
			}
			// Obtain data set...
			qryRtn = objDAO.getFull( arguments.ID, bGetLatestVersion );

			if (qryRtn.recordcount eq 1 and bGetLatestVersion)
			{
				//set value for metedescription if there is none
				if (NOT Len(qryRtn.metaDescription) )
					if (Len(qryRtn.teaser) )
						querySetCell(qryRtn, "metaDescription", LEFT( objString.StripHTML(qryRtn.teaser) , 155) );
					else
						querySetCell(qryRtn, "metaDescription", LEFT( objString.StripHTML(qryRtn.story), 155) );
			}        

            return qryRtn;
		</cfscript>

	</cffunction>

	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getRelated" access="public" output="false" returntype="query" hint="">

		<cfargument name="ID" type="numeric" required="true"  hint="id of the article">
		<cfset qryRtn = objDAO.getRelated( Arguments.ID )>
		<cfreturn qryRtn>

	</cffunction>		
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getNewsStatusTypes" access="public" output="false" returntype="query" hint="">

		<cfreturn objDAO.getNewsStatusTypes()>

	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="resolveLinks" access="public" output="false" returntype="string" hint="">

		<cfargument name="sString" type="string" required="true"  hint="string to resolve links">
		
		<cfscript>
		var sResolvedString = "";
		
		var sLink_Start_RegEx = ArrayNew(1);
		var sLink_End = ArrayNew(1);

		var sResolvedLink_Start = "<a style=""text-decoration:underline"" title=""Click for more detail on \1"" href=""index.cfm?method=directory.Orgitem&id=0&orgtype=\1&orgname=";
		var sResolvedLink_End = "</a>";
		var nOrgID = 0;

		sLink_Start_RegEx[1] = "&lt;his_link type=([A-Za-z]*)&gt;" & "([A-Za-z| ]+)";
		sLink_Start_RegEx[2] = "&lt;his_link type=&quot;([A-Za-z]*)&quot;&gt;" & "([A-Za-z| ]+)";
		sLink_Start_RegEx[3] = "<his_link type=([A-Za-z]*)>" & "([A-Za-z| ]+)";
		sLink_Start_RegEx[4] = "<his_link type=""([A-Za-z]*)"">" & "([A-Za-z| ]+)";

		sLink_End[1] = "&lt;/his_link&gt;";
		sLink_End[2] = "&lt;/his_link&gt;";
		sLink_End[3] = "</his_link>";
		sLink_End[4] = "</his_link>";

		/*
		1. Check only words surround with the <localgov_link /> tag...
		2. Determine type
		3. Apply link
		*/	
		sResovledString = arguments.sString;
		for (i=1; i LTE ArrayLen(sLink_Start_RegEx); i=i+1) 
			sResovledString = REReplaceNoCase(
				sResovledString, 
				sLink_Start_RegEx[i] & sLink_End[i], 
				sResolvedLink_Start & "\2"">\2" & sResolvedLink_End, 
				"all");
		
		return sResovledString;		
		</cfscript>
  
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="highLight" access="public" hint="Highlights keywords within a string" output="false">
		<cfargument name="str" required="yes" type="string">		
		<cfargument name="words" required="yes" type="string">
		<cfargument name="sFront" required="no" type="string" default="<span style=""background-color: ##FFFFCC;"">">
		<cfargument name="sBack" required="no" type="string" default="</span>">
	
		<cfscript>
		var sHighlightedText = arguments.str;
		var sWord= "";
		
		sHighlightedText = REReplaceNoCase(sHighlightedText,"(#arguments.words#)","#arguments.sFront#\1#arguments.sBack#","ALL");
		
		return sHighlightedText;
		</cfscript>
	
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Commit Functions -------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="commitArticle" access="public" output="false" returntype="numeric" 
		hint="">
		
		<cfargument name="strAttr" required="yes"  type="struct">
		
		<cfscript>
		var dateCommence= 	arguments.strAttr.Date_Commence;
		var productID= 		arguments.strAttr.Product_ID; 
		var imgName= 		'';
		
		productID= 			mid(productID, find("?", productID)+1, len(productID));
		
		
		if (StructkeyExists(arguments.strAttr, "hd_image_teaser") and Len(arguments.strAttr.hd_image_teaser))
			imgName = arguments.strAttr.hd_image_teaser;
			
		// upload the teaser image
		if (Len(form.image_teaser))
			imgName=objUtils.uploadImage( "form."& arguments.strAttr.formField, arguments.strAttr.dirPath, 'image' );	
			
		return objDAO.commitArticle(	arguments.strAttr.news_ID,
										arguments.strAttr.title, 
										arguments.strAttr.story,
										dateFormat(dateCommence, "dd/mm/yyyy") & " " & TimeFormat(dateCommence),
										arguments.strAttr.isHeadline,
										productID,
										arguments.strAttr.news_Type,
										arguments.strAttr.sectors,
										arguments.strAttr.byLine,
										session.userDetails.userid,
										arguments.strAttr.article_Status,
										arguments.strAttr.circuit_id,
										arguments.strAttr.news_ticker,
										arguments.strAttr.section_id,
										imgName,
										arguments.strAttr.image_caption,
										arguments.strAttr.teaser,
										arguments.strAttr.istop,
										arguments.strAttr.metaDescription,
										arguments.strAttr.topicid,
										arguments.strAttr.accesstypeid
									);
		</cfscript>
		
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Delete Functions  ------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="deleteArticle" access="public" output="false" returntype="boolean" hint="<description>">
		
		<cfargument name="ID" type="numeric" required="yes">
		
		<cfreturn objDAO.deleteArticle( arguments.id ) >
		
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Delete Functions  ------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="destroyArticle" access="public" output="false" returntype="boolean" hint="Destroy article by deleting it and all associated versions">
		
		<cfargument name="ID" type="numeric" required="yes">
		
		<cfreturn objDAO.destroyArticle( arguments.id ) >
		
	</cffunction>	
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="undeleteArticle" access="public" output="false" returntype="boolean" hint="<description>">
		
		<cfargument name="ID" type="numeric" required="yes">
		
		<cfreturn objDAO.undeleteArticle( arguments.id ) >
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="GetHomepageComments" access="public" output="false" returntype="query" hint="return all comments to be displayed on home page">
		<cfreturn objDAO.GetHomepageComments()>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="mostPopular" access="public" returntype="query" hint="get top most popluar news stories">
		<cfreturn objDAO.mostPopular()>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- PRIVATE Functions -------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="datePeriod2string" returntype="string" output="false" hint="return string of a date period (such as last week, last month etc) based on passed in value">
		<cfargument name="period" type="string" required="yes" hint="period from which date string will be created">
			
			<cfscript>
			var sReturn ="";
			var dformat = "yyyyddmm";
			switch (arguments.period){
				case "week":
				sReturn = dateFormat(DateAdd("ww",  -1, Now()), dformat );
				break;
				case "month":
				sReturn = dateFormat(DateAdd("m",  -1, Now()), dformat);
				break;
				case "6 months":
				sReturn = dateFormat(DateAdd("m",  -6, Now()), dformat);
				break;
				case "year":
				sReturn = dateFormat(DateAdd("yyyy",  -1, Now()), dformat);
				break;
				default:
				sReturn = dateFormat(arguments.period, dformat);
				break;
			}
			return sReturn;
			</cfscript>
			 
	</cffunction> 
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="exportToGovernetz" access="public" output="false" returntype="void" hint="export an article to Governetz db">
		<cfargument name="ID" type="numeric" required="yes">
			<cfset objDAO.exportToGovernetz(arguments.ID)>		
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="exportCheck" access="public" output="false" returntype="query">
		<cfargument name="dbname" type="string" required="yes">
		<cfargument name="articleID" type="numeric" required="yes">
		
		<cfreturn objDAO.exportCheck(arguments.dbname, arguments.articleID)>		
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="exportArticle" access="public" output="false" returntype="numeric">
		<cfargument name="dbname" type="string" required="yes">
		<cfargument name="articleID" type="numeric" required="yes">
		<cfargument name="newID" type="numeric" required="no" default="0">
		
		<cfset var qryArticle = objDAO.getFull(arguments.articleID, 1)>
		<cfset retval = 0>
		
		<cfif qryArticle.recordcount eq 1>
			
			<cfset retval = objDAO.exportArticle(
										dbname = arguments.dbname
										, newID = arguments.newID
										, origID = arguments.articleID
										, qryArticle = qryArticle
										)>
			
		</cfif>
		
		<cfreturn retval>
	</cffunction>

</cfcomponent>