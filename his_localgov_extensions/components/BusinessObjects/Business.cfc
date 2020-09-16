<!--- 
	
	$Archive: /LocalGov.co.uk/his_localgov_extensions/components/BusinessObjects/Business.cfc $
	$Author: Anagpal $
	$Revision: 2 $
	$Date: 2/10/06 17:38 $

--->

<cfcomponent displayname="Business" hint="Business-related business object functions" extends="BusinessObjectsManager">

	<!--- -------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR -------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Business" hint="Pseudo-constructor">
	
		<cfargument name="objAppObjs" 		type="any" 	   required="yes" hint="The application manager object">
		<cfargument name="bFilter" 			type="boolean" required="no" default="false" hint="Flag to determine whether we need to filter RSS feed">
		<cfargument name="bForceRetrieval"  type="boolean" required="no" default="false" hint="Flag to determine whether we need to retrieve RSS feed">
		
		<cfscript>
		// Call the genric init function, placing business, app, and dao objects into a local scope...
		StructAppend( variables, Super.initChild( arguments.objAppObjs, this ) );
		
		// Today's papers, initialisation...
		variables.strPapers= 				StructNew();
		variables.strPapers.dLastRetrieved= DateAdd("y",-6,now());
		variables.strPapers.arrPapers= 		ArrayNew(1);
		variables.strPapers= 				getTodaysPapers( arguments.bFilter, arguments.bForceRetrieval );
		
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
	<cffunction name="getRelatedArticles" access="public" output="false" returntype="query" hint="">
		<cfargument name="lstSectorID" required="yes" type="string">
	
		<cfreturn objDAO.getRelatedArticles( arguments.lstSectorID )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="postComment" access="public" output="false" returntype="numeric" hint="">
		<cfargument name="userID" required="yes" type="numeric">
		<cfargument name="comment" required="yes" type="string">
		<cfargument name="email" required="yes" type="string">
		<cfargument name="name" required="yes" type="string">
		<cfargument name="newsid" required="yes" type="string">
	
		<cfreturn objDAO.postComment( arguments.userID, arguments.comment, arguments.email, arguments.name, arguments.newsid )>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getCommentsByArticleID" access="public" output="false" returntype="query" 
		hint="">
		
		<cfargument name="newsid" required="yes" type="numeric">
		<cfargument name="statusid" required="no" type="numeric" default="2" hint="approved">
		
		<cfreturn objDAO.getCommentsByArticleID( arguments.newsid, arguments.statusid )>

	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getComment" access="public" output="false" returntype="query" 
		hint="">
		
		<cfargument name="commentid" required="no" type="numeric" default="0">

		<cfreturn objDAO.getComment( arguments.commentid )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getNewsForTicker" access="public" output="true" returntype="query" hint="returns a query containing all data for the news ticker">
		<cfargument name="qryArticles"  		required="yes" type="query">
		<cfargument name="qryPressReleases"  	required="yes" type="query">
		<cfargument name="strPapers"   			required="yes" type="struct">
		<cfargument name="strInfo4Local"		required="yes" type="struct">
		<cfargument name="noOfHISArticles"		required="yes" type="numeric">
		<cfargument name="noOfPaperArticles"	required="yes" type="numeric">

		<cfset var qry = QueryNew("id,title,source,link")>
		<cfset var qryPapers = "">
				
		<!--- Tailor Articles flagged for the news ticker... --->
		<cfloop query="arguments.qryArticles" startrow="1" endrow="#arguments.NoOfHISArticles#" >
			<cfif arguments.qryArticles.NewsTicker eq 0 or arguments.qryArticles.NewsTicker eq "">
				<cfset QueryAddRow(qry)>
				<cfset QuerySetCell(qry, "id", 		newsid)>
				<cfset QuerySetCell(qry, "title", 	title)>
				<cfset QuerySetCell(qry, "source", 	product)>
				<cfset QuerySetCell(qry, "link", 	"")>
			</cfif>
		</cfloop>
		
		<!--- Tailor Press Releases flagged for the news ticker... --->
		<cfloop query="arguments.qryPressReleases" startrow="1" endrow="#arguments.NoOfHISArticles#" >
			<cfif arguments.qryPressReleases.NewsTicker eq 0 or arguments.qryPressReleases.NewsTicker eq "">
				<cfset QueryAddRow(qry)>
				<cfset QuerySetCell(qry, "id", 		newsid)>
				<cfset QuerySetCell(qry, "title", 	title)>
				<cfset QuerySetCell(qry, "source", 	product & " - Press Release")>
				<cfset QuerySetCell(qry, "link", 	"")>
			</cfif>
		</cfloop>
		
		<!--- Tailor articles from Today's Papers for the news ticker... --->
		<cfloop from="1" to="#ArrayLen(arguments.strPapers.arrPapers)#" index="i">
			<cfset qryPapers = strPapers.arrPapers[i]>
			<cfif qryPapers.RecordCount>
				<cfoutput query="qryPapers" maxrows="#arguments.NoOfPaperArticles#">
					<cfset QueryAddRow(qry)>
					<cfset QuerySetCell(qry, "id", 		"###i#")>
					<cfset QuerySetCell(qry, "title", 	qryPapers.title)>
					<cfset QuerySetCell(qry, "source", 	qryPapers.rsstitle)>
					<cfset QuerySetCell(qry, "link", 	"")>
				</cfoutput>
			</cfif>
		</cfloop>

		<!--- Tailor articles from Info4Loca.gov.uk for the news ticker... --->
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
		</cfloop>
		<!--- Return the concatenated recordsets for the news ticker... --->
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
	<cffunction name="searchNews" access="public" returntype="query" output="false" hint="limit verity search results to news and other specfied filters">
		<cfargument name="qrySearch"   required="yes" type="query">
		<cfargument name="lstSectorID" required="no"  type="string">
			
		<cfset var qryNews ="">
		<cfset var qryNewsinSectors ="">
	
		<cfquery dbtype="query" name="qryNews">
		SELECT *
		FROM arguments.qrySearch
		WHERE contenttype = 'news'
		</cfquery>
	
		<!--- check if sectord id's have been passed ---> 
		<cfif len(arguments.lstSectorID)>
			<!---perform join on verity search and sql search for sectors  --->
			<cfset qryNewsinSectors = objDAO.getNewsInSectors(arguments.lstSectorID)>
			<cfquery dbtype="query" name="qryNews">
			SELECT *
			FROM arguments.qrySearch, qryNewsinSectors
			WHERE  arguments.qrySearch.uid = qryNewsinSectors.NewsID
			</cfquery>
		</cfif>	
	 
	 	<cfreturn qryNews>
	 
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
				
		<cfreturn objDAO.adminSearchResults( arguments.keywords )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getPressReleases" access="public" output="false" returntype="query" hint="returns press releases">
		<cfargument name="HowMany" type="numeric" required="no" hint="number items to return" default="-1">
		<cfargument name="lstSectorIDs" 	type="string" 	required="no" hint="list containing sector ids" default="">
		
		<cfreturn objDAO.getNewsArticles( NewsTypeID=5, HowMany=Arguments.HowMany, lstSectorIDs=arguments.lstSectorIDs )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getInfo4Local" access="public" output="false" returntype="struct" hint="returns press releases">
		<cfargument name="section" type="string" required="no" default="">
		<cfscript>
		var strInfo4Local = StructNew();
		strInfo4Local.qryRSS = ArrayNew(1);

		arr = XMLSearch( objRSS.getInfo4LocalRSS(arguments.section), "/rss/feed_url" );
	
		// Loop through feed rss'
		for ( i=1; i LTE ArrayLen(arr); i=i+1 ) 	
			strInfo4Local.qryRSS[i] = objRSS.readRSS( arr[i].XmlText, arr[i].xmlAttributes.type, true );

		return strInfo4Local;
		</cfscript>
		
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getSupplements" access="public" output="false" returntype="query" hint="">
		<cfargument name="HowMany" type="numeric" required="no" hint="number items to return" default="-1">
		<cfargument name="lstSectorIDs" 	type="string" 	required="no" hint="list containing sector ids" default="">
		
		<cfreturn objDAO.getNewsArticles( newsTypeID=4, howMany=Arguments.HowMany, lstSectorIDs=arguments.lstSectorIDs )>
		
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getEditorsComment" access="public" output="false" returntype="query" hint="">
		<cfargument name="HowMany" 			type="numeric" required="no" hint="number items to return" default="-1">
		<cfargument name="lstSectorIDs" 	type="string" 	required="no" hint="list containing sector ids" default="">
		
		<cfreturn objDAO.getNewsArticles( newsTypeID=6, howMany=Arguments.HowMany, lstSectorIDs=arguments.lstSectorIDs )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getFeatures" access="public" output="false" returntype="query" hint="">
		<cfargument name="HowMany" 			type="numeric" 	required="no" hint="number items to return" 	   default="-1">
		<cfargument name="lstSectorIDs" 	type="string" 	required="no" hint="list containing sector ids" default="">
		
		<cfreturn objDAO.getNewsArticles( newsTypeID=2, howMany=Arguments.HowMany, lstSectorIDs=arguments.lstSectorIDs )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getLatest" access="public" output="false" returntype="query" hint="Generic article retrieval function, return query based on supplied type argument.">
	
		<cfargument name="Type" 			type="numeric" 	required="yes"  	hint="type of article to get">
		<cfargument name="HowMany" 			type="numeric" 	required="yes" 	hint="number items to return">
		<cfargument name="lstSectorIDs" 	type="string" 	required="no" 	hint="list containing sector ids" default="">
		
		<cfscript>
		var n = Arguments.howMany;
		
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
	<cffunction name="getTodaysPapers" access="public" output="false" returntype="struct" hint="Retrieve Today's Papers">
		
		<cfargument name="bFilter" 				type="boolean" 	required="false" 	default="false"  hint="">
		<cfargument name="bForceRetrieval" 		type="boolean" 	required="false" 	default="false"  hint="">
		<cfargument name="section" 				type="string" 	required="false" 	default="">
		 
		<cfscript>
		var bRetrieve = false;
		
		// Determine whether we need to retrieve the external RSS feeds...
		//if ( DateDiff( "n", variables.strPapers.dLastRetrieved, now() ) GT objRSS.GetRetrievalFrequency() )
			//bRetrieve = true;

		// Force retrieval, if specified...
		if ( arguments.bForceRetrieval )
			bRetrieve = true;

		// DEVELOPMENT ONLY...
		if ( isDefined("url.bFilter") )
			arguments.bFilter = url.bFilter;

		// Only retrieve the RSS feeds if required... 
		if ( bRetrieve OR NOT arguments.bFilter) {
			
			// Obtain an array of rss feed urls...
			arrRSSElements = XMLSearch( objRSS.getRSSConfig(arguments.section), "/rss/feed_url" );
	
			// Loop through feed rss'
			for ( i=1; i LTE ArrayLen(arrRSSElements); i=i+1 ) 	
				variables.strPapers.arrPapers[i] = objRSS.readRSS( arrRSSElements[i].XmlText, arrRSSElements[i].XmlAttributes.type, true );
			
			// Keep a note of the retrieval date/time...
			variables.strPapers.dLastRetrieved = now();
		
		}  

		// Filter or not to filter?
		if ( arguments.bFilter )
			variables.strPapers.arrPapers = objRSS.filterRSS( variables.strPapers.arrPapers, arguments.section );
		
		// Return an array containing all the rss feeds...
		return variables.strPapers;
		</cfscript>
		
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

		<cfargument name="Type" 		type="numeric" required="true"  hint="type of article to get">
		<cfargument name="ID" 			type="numeric" required="true"  hint="id of the article">
		<cfargument name="VersionID" 	type="numeric" required="false" default="0"  hint="version of the article, zero/null means latest">
		<cfargument name="Resolve" 		type="boolean" required="false" default="true"  hint="flag to determine whether or not to resolve <his_link ...> links.">
		<cfargument name="GetLatestVersion" type="numeric" required="false" default="1"  hint="">
		
		<cfscript>
		var bGetLatestVersion = arguments.getLatestVersion;
			
		if (Arguments.VersionID neq 0) {
			Arguments.ID = 		Arguments.VersionID;
			bGetLatestVersion= 	0;
		}
				
		// Obtain data set...
		qryRtn = objDAO.getFull( arguments.ID, bGetLatestVersion );
		
		/* Now redundant.
		 if (arguments.Resolve)
			qryRtn.story = ResolveLinks( qryRtn.story );
		*/
		
		// Replace tildas used in the auto-linking process...
		qryRtn.story = replace(qryRtn.story, "~", "", "all");
		
		/* Clean article...
		s1 = mid(s, 1, Find(".", qryRtn.story) );
		s1 = REReplace(s1, "#Chr(10)#|#Chr(13)#|", "<br>", "All");
		s2 = mid(qryRtn.story, Find(".",qryRtn.story)+1, Len(qryRtn.story) );
		s2 = REReplace(s2, "#Chr(10)#|#Chr(13)#|", "<br>", "All");
		*/
		
		// Return the query for the specified article type...
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
		
		productID= 			mid(productID, find("?", productID)+1, len(productID));
		
		return objDAO.commitArticle( 
						arguments.strAttr.news_ID,
						arguments.strAttr.title, 
						arguments.strAttr.story,
						dateFormat(dateCommence, "dd/mm/yyyy") & " " & TimeFormat(dateCommence),
						arguments.strAttr.isHeadline,
						productID,
						arguments.strAttr.news_Type,
						arguments.strAttr.sectors,
						arguments.strAttr.byLine,
						listGetAt(client.userDetails, 1),
						arguments.strAttr.article_Status,
						arguments.strAttr.circuit_id,
						arguments.strAttr.news_ticker,
						arguments.strAttr.section_id	
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
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="undeleteArticle" access="public" output="false" returntype="boolean" hint="<description>">
		
		<cfargument name="ID" type="numeric" required="yes">
		
		<cfreturn objDAO.undeleteArticle( arguments.id ) >
		
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- PRIAVTE Functions -------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->

	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->

</cfcomponent>