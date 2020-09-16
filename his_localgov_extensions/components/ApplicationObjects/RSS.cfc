<!---
Author: Barry Halper
Date Created:28/11/03
Description: component to manage Really simple syndication (RSS) . For more info go to http://www.xml.com/pub/a/2002/12/18/dive-into-xml.html or http://blogs.law.harvard.edu/tech/rss
--->


<cfcomponent hint="component to manage Really Simple Syndication (RSS)" extends="his_Localgov_Extends.components.ApplicationManager">
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="RSS" hint="Pseudo-constructor">
		
		<cfargument name="strConfig" type="struct" required="yes">
		<cfargument name="objUtils"  	type="any" 	required="yes">
		<cfargument name="objString"    type="any" 	required="false">
		
		<cfscript>
		variables.strConfig = 					arguments.strConfig;
		variables.objUtils=						arguments.objUtils;
		//variables.sXMLRSS = ;
		variables.xmlRSS_newspapers= 			XMLParse( readConfig( variables.strConfig.strPaths.xmlpath & "rss_config.xml" ) );
		variables.xmlRSS_info4local= 			XMLParse( readConfig( variables.strConfig.strPaths.xmlpath & "rss_info4local.xml" ) );
		variables.xmlRSS_24dash= 				XMLParse( readConfig( variables.strConfig.strPaths.xmlpath & "rss_24dash.xml" ) );
		variables.xmlRSS_business_newspapers= 	XMLParse( readConfig( variables.strConfig.strPaths.xmlpath & "rss_business_config.xml" ) );
		variables.xmlRSS_business_info4local= 	XMLParse( readConfig( variables.strConfig.strPaths.xmlpath & "rss_business_info4local.xml" ) );
		variables.objString				   		=arguments.objString;
		return this;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getVariables" access="public" returntype="struct" hint="returns variables scope">
		<cfreturn variables>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getRSSConfig" access="public" returntype="xml" hint="returns the rss xml config document">
		<cfargument name="section" type="string" required="no" default="">
		<cfif arguments.section EQ "business">
			<cfreturn variables.xmlRSS_business_newspapers>
		<cfelse>
			<cfreturn variables.xmlRSS_newspapers>
		</cfif>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getInfo4LocalRSS" access="public" returntype="xml" hint="returns the rss xml config document">
		<cfargument name="section" type="string" required="no" default="" hint="this is an optional argument.">
		<!--- If 'business' is the value passed to the argument, the business xml file is returned which is then used by the XMLSearch function. --->
		<!--- <cfif arguments.section EQ "business">
			<cfreturn variables.xmlRSS_business_info4local>
		<cfelse>
			<cfreturn variables.xmlRSS_info4local>
		</cfif> --->	<cfreturn variables.xmlRSS_info4local>
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="get24DashRSS" access="public" returntype="xml" hint="returns the rss xml config document">
		<cfreturn variables.xmlRSS_24dash>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="readRSS" access="public" returntype="any" hint="read rss xml file and return content">
	
		<cfargument name="RssURL" type="string" required="yes" hint="web address to xml file">
		<cfargument name="type" type="string" required="yes" hint="define whether feed is 'RDF' or 'RSS' ">
		<cfargument name="UseProxy" type="boolean" required="no" hint="decide if method needs to perfom request through the proxy server" default="1">

		
		<cfset var XMLDoc="">
		<cfset var qryRss=querynew("temp")>
		
		<cftry>
		
			<!---check which version of CF is making the request --->
			<cfif arguments.UseProxy >
				<!---Perform HTTP GET through the proxy server --->
				<cfhttp url="#arguments.rssurl#" method="GET" resolveUrl="false" 
					proxyserver="192.168.1.12" 
					proxyport="8080" 
					proxyuser="hisproxy" 
					proxypassword="COldfusion" 
					throwonerror="yes" timeout="60" />
			<cfelse>
				<!---perform url get opeartaion to return xml file content --->
				<cfhttp url="#arguments.rssurl#" method="GET" resolveUrl="false" timeout="60"/> 
			</cfif> 
			
			<!--- parse file content into xml doc --->
		<cfset XMLDoc = XMLParse(trim(cfhttp.filecontent))>
		<cfset qryRss = rss2qry(XMLDoc)>	
		<cfcatch type="any">
			<!--- <cfrethrow> --->
		</cfcatch>
		
		</cftry>
		<cfreturn qryRss>

	
	</cffunction>
		<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="rss2qry" access="public" returntype="query" hint="turn rss xml doc into qry">
		<cfargument name="xmldoc" 	required="yes" type="xml">
		<cfargument name="type" 	type="string" required="no" default="rss" hint="define whether feed is 'RDF' or 'RSS' ">
		<cfargument name="RssURL" 	type="string" required="no" default="" hint="">
		
		<cfscript>
		
		var arrItems=		ArrayNew(1);
		var arrDetails=		ArrayNew(1);
		var strDetails=		StructNew();
		var qryRss=			QueryNew("RSSTitle,Image,RSSDesc,lastBuildDate,PubDate,Title,Link,Description,Category,content,FeedUrl");
		var arrReturn=		ArrayNew(1);
		var FeedTitle=		"";
		var Image=			"";
		var Desc=			"";
		var lastBuildDate= 	"";
		var pubDate= 		"";
		var Category= 		"";
		var i= 				"";
		
		
		//evaluate type of xml feed
		Switch(trim(lcase(arguments.type))) {
			case 'rss':{
				//search for each story using XPath and set result into array
				arrDetails= 	XMLSearch(arguments.XMLDoc, "/rss/channel");
				arrItems=		XMLSearch(arguments.XMLDoc, "/rss/channel/item");
				break;}
			case 'rdf':{
				//search for each story using XPath and set result into array
				arrDetails=		XMLSearch(arguments.XMLDoc, "/rdf:RDF");
				arrItems= 		XMLSearch(arguments.XMLDoc, "/rdf:RDF/:item");
			  	break;}	
		}
		
	
		
		//loop over channel details to get info about the RSS feed	  
		for (i=1; i LTE arrayLen(arrDetails); i=i+1 ) {
		   if (arguments.type eq 'rss') {
		      	if (StructKeyExists(arrDetails[i], "title"))		FeedTitle=  	arrDetails[i].title.xmltext;
		      	if (StructKeyExists(arrDetails[i], "image"))		Image=  		arrDetails[i].image.url.xmltext;
			   	if (StructKeyExists(arrDetails[i], "description"))	Desc=  			arrDetails[i].description.xmltext;
		      	if (StructKeyExists(arrDetails[i], "lastBuildDate"))lastBuildDate=  arrDetails[i].lastBuildDate.xmltext;
				if (StructKeyExists(arrDetails[i], "link"))			Feedurl=  		arrDetails[i].link.xmltext;
				  	
			// RDF:					
		   } else {
		   
		   		 //request.objApp.objUtils.dumpabort(arrDetails[i]);
		   	
			   	FeedTitle=  	arrDetails[i].channel.title.xmltext;
				Feedurl=  		arrDetails[i].channel.link.xmltext;
		      	Image=  		arrDetails[i].channel.image.xmlText;
			   	Desc=  			arrDetails[i].channel.description.xmltext;
			   	lastBuildDate=	arrDetails[i].channel.date.xmltext;  
				
		   }

		}
		//loop over array and set items into query object
		for (i=1; i LTE arrayLen(arrItems); i=i+1 ){
			QueryAddRow(qryRss);
			//Add empty row to query object
			if (arguments.type eq 'rss') {
			
				//set channel info into recordset
				QuerySetCell(qryRss, "RSSTitle", 		FeedTitle);
				QuerySetCell(qryRss, "RSSDesc", 		Desc);
				QuerySetCell(qryRss, "Image", 			Image);
				QuerySetCell(qryRss, "lastBuildDate", 	lastBuildDate);
				QuerySetCell(qryRss, "feedurl", 		Feedurl);
				
		
				//set cells to each item in array
				if (StructKeyExists(arrItems[i], "link"))			QuerySetCell(qryRss, "link", 			arrItems[i].link.xmltext);
				if (StructKeyExists(arrItems[i], "title"))			QuerySetCell(qryRss, "title", 			arrItems[i].title.xmltext);
				if (StructKeyExists(arrItems[i], "category"))		QuerySetCell(qryRss, "Category", 		arrItems[i].category.xmltext);
				if (StructKeyExists(arrItems[i], "pubDate"))		QuerySetCell(qryRss, "pubDate", 		arrItems[i].pubDate.xmltext);
				if (StructKeyExists(arrItems[i], "description"))	QuerySetCell(qryRss, "description", 	arrItems[i].description.xmltext);
				if (StructKeyExists(arrItems[i], "content:encoded"))
					QuerySetCell(qryRss, "content", 		arrItems[i]["content:encoded"].xmltext);
				else
					QuerySetCell(qryRss, "content", 		arrItems[i].description.xmltext);	

			// RDF:
		   } else {
				//set cells to each item in array
				QuerySetCell(qryRss, "link", arrItems[i].link.xmltext);
				QuerySetCell(qryRss, "title", arrItems[i].title.xmltext);
				QuerySetCell(qryRss, "description", arrItems[i].description.xmltext);
				//set channel info into recordset
				QuerySetCell(qryRss, "RSSTitle", FeedTitle);
				QuerySetCell(qryRss, "Feedurl", Feedurl);
				QuerySetCell(qryRss, "Image", Image);
				QuerySetCell(qryRss, "RSSDesc", Desc);
				QuerySetCell(qryRss, "lastBuildDate", lastBuildDate);
		   }
		} 
		
		return qryRss;
		</cfscript>

		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
   <cffunction name="atom2qry" access="public" returntype="query" hint="turn atom (feed) xml doc into qry">
	 <cfargument name="xmldoc" required="yes" type="xml">
	 <cfargument name="FeedUrl" required="no" type="string">
	
		<cfscript>
		var qryRss     =  QueryNew("RSSTitle,Image,RSSDesc,lastBuildDate,PubDate,Title,Link,Description,Category,content,FeedUrl");
		var arrDetails =  arguments.XMLDoc.xmlroot.xmlchildren;
		var arrItems   =  xmlSearch(arguments.XMLDoc, "//:entry");
		var i		   = 0;
		var j		   = 0;	
		var RSSTitle   = "";
		var lastBuildDate   = "";
		var xchildren   = "";
		//loop over root elements
		for (i=1; i LTE arrayLen(arrDetails); i=i+1 ) {
			if (StructKeyExists(arrDetails[i], "author"))
				RSSTitle=  arrDetails[i].author.xmlChildren[1].xmltext;
			if (StructKeyExists(arrDetails[i], "updated"))
				lastBuildDate=  arrDetails[i].updated.xmltext;	
		}
				
			//loop over entries
			for (i=1; i LTE arrayLen(arrItems); i=i+1 ) {
				xchildren = arrItems[i].xmlchildren;
				//create a row for each child	
				QueryAddRow(qryRss);
				///loop over entry elements
				for (j=1; j LTE arrayLen(arrItems[i].xmlchildren); j=j+1 ) {
					QuerySetCell(qryRss, "RSSTitle", 		RSSTitle);
					QuerySetCell(qryRss, "lastBuildDate", 	lastBuildDate);
					//QuerySetCell(qryRss, "FeedUrl", 		FeedUrl);
					QuerySetCell(qryRss,'Link',			    arrItems[i].link.xmlAttributes.href);
					QuerySetCell(qryRss,'FeedUrl',			arguments.FeedUrl);
					
					switch (arrItems[i].xmlchildren[j].xmlname){
					   case 'Title':
						 QuerySetCell(qryRss, "Title", 			arrItems[i].xmlchildren[j].xmltext);
						 break;
					  case 'content':
						 QuerySetCell(qryRss, "content", 			arrItems[i].xmlchildren[j].xmltext);
						 break; 
					  case 'published':
						 QuerySetCell(qryRss, "PubDate", 			arrItems[i].xmlchildren[j].xmltext);
						 break; 	 
					  }	
				 }
			}
		
	    return qryRss;
	    </cfscript>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getKeywords" access="public" output="false" returntype="string" hint="">
		<cfargument name="section" 	type="string" 	required="false" default="">
		<cfscript>
		var selectedElements = "";
		
		if (arguments.section EQ 'business')
			xmltosearch = variables.xmlRSS_business_newspapers;
		else
			xmltosearch = variables.xmlRSS_newspapers;
			
		selectedElements = XMLSearch(xmltosearch, "/rss/keywords");
		
		return selectedElements[1].XmlText;
		</cfscript>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getRSSURL" access="public" output="false" returntype="array" hint="">
		<cfargument name="section" 	type="string" 	required="false" default="">
		<cfscript>
		var selectedElements = ArrayNew(1);
		
		if (arguments.section EQ 'business')
			xmltosearch = variables.xmlRSS_business_newspapers;
		else
			xmltosearch = variables.xmlRSS_newspapers;
			
		selectedElements = XMLSearch(xmltosearch, "/rss/feed_url");
		
		return selectedElements;
		</cfscript>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getRetrievalFrequency" access="public" output="false" returntype="string" hint="">
		
		<cfscript>
		var selectedElements = XMLSearch(variables.xmlRSS_newspapers, "/rss/retrieval_frequency");
		
		return selectedElements[1].XmlText;
		</cfscript>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="filterRSS" access="public" output="false" returntype="array" hint="">
	
		<cfargument name="arrRSS" 	type="array" 	required="yes">
		<cfargument name="section" 	type="string" 	required="false" default="">
		
		<cfscript>
		var arrFilteredRSS = ArrayNew(1);
		var selectedElements = "";
		var lstKeywords = "";
		var qryRSS = "";
		var qryFilteredRSS = "";
		var bFound = false;
		
		if (arguments.section EQ 'business')
			xmltosearch = variables.xmlRSS_business_newspapers;
		else
			xmltosearch = variables.xmlRSS_newspapers;
			
		selectedElements = XMLSearch(xmltosearch, "/rss/keywords");
		lstKeywords = selectedElements[1].XmlText;
		qryFilteredRSS = QueryNew("RSSTitle,Image,RSSDesc,lastBuildDate,title,link,description");

		// Loop though original array...
		for (i=1; i LTE ArrayLen(arguments.arrRSS); i=i+1) {
		
			qryRSS = arguments.arrRSS[i];			
			
			// Loop through original query...
			for (j=1; j LTE qryRSS.RecordCount; j=j+1) {
	
				// If our keywords exist in the original description, add a row to our filtered query...
				if ( REFindNoCase(lstKeywords, qryRSS.description[j]) ) {
					QueryAddRow(qryFilteredRSS);
					QuerySetCell(qryFilteredRSS, "link", qryRSS.link[j]);
					QuerySetCell(qryFilteredRSS, "title", qryRSS.title[j]);
					QuerySetCell(qryFilteredRSS, "description", qryRSS.description[j] );
					QuerySetCell(qryFilteredRSS, "RSSTitle", qryRSS.RSSTitle[j]);
					QuerySetCell(qryFilteredRSS, "Image", qryRSS.Image[j]);
					QuerySetCell(qryFilteredRSS, "RSSDesc", qryRSS.RSSDesc[j]);
					QuerySetCell(qryFilteredRSS, "lastBuildDate", qryRSS.lastBuildDate[j]);
				}	
			}	
			ArrayAppend(arrFilteredRSS, qryFilteredRSS);
			qryFilteredRSS = QueryNew("RSSTitle,Image,RSSDesc,lastBuildDate,title,link,description");
		}		
		
		return arrFilteredRSS;
		</cfscript>
	
	</cffunction>
			
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- begin CreateNewsFeed() Function --->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="createRSS" access="public" output="true" returntype="any" hint="create RSS feed based on qry">
		<cfargument name="qry"  	  type="query"   required="yes" hint="data to create feed from"> 
		<cfargument name="FeedTitle"  type="string"  required="yes" hint="Header of Feed"> 
		<cfargument name="link" type="string" required="no" hint="" default="#variables.strConfig.strPaths.sitepath#"> 
		<cfargument name="uID" type="string" required="no" hint="varible in query that content unique query" default="id"> 
	 
		<!--- Call method to get product details based on ID --->
		<cfscript>	 
		 //set channel attributes
		 var DateToday = DateFormat(Now(), "ddd, dd mmm yyyy") & " " & TimeFormat(Now(), "HH:mm:ss");
		 var tz = getTimeZoneInfo();
			var offset = numberFormat(tz.utcHourOffset,"00") & numberFormat(tz.utcMinuteOffset, "00");
		 
		//var description = replace(qryProduct.description, "&", "&amp;", "ALL");
		 var image = variables.strConfig.strPaths.sitepath & variables.strConfig.strPaths.imagepath & "headers/logo_bluebg.gif";
		 /*call method to return news
		 var qrynews = */
		 if (len(offset) eq 4)
			{ DateToday = DateToday & " +" & offset;}
		else
			{DateToday = DateToday & " " & offset;}
		
		 DateToday = Replace(DateToday, "-0100"	, "+0100");
		 </cfscript>

		<cfsavecontent variable="xmldoc"><!--RSS generated by hgluk.com on #Now()#--><rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" >
			<!---Define channel/doc details --->
			<channel>
			<cfoutput>
				 <title>#XMLFormat(arguments.FeedTitle)#</title>
				  <webMaster>#variables.strConfig.strVars.mailsender# (Webmaster)</webMaster>
				  <link>#variables.strConfig.strPaths.sitepath#</link>
				  <description>News</description>
				  <lastBuildDate>#DateToday#</lastBuildDate> 
				  <managingEditor>#variables.strConfig.strVars.editor# (Editor)</managingEditor> 
				<language>en-gb</language>
			<cfloop query="qry">
				<item>
				<title>#objString.DeMoronize(XMLFormat(qry.title))#</title>	
				<link>#arguments.link#=#qry.uid#</link> 
                <guid>#arguments.link#=#qry.uid#</guid> 
				<description><![CDATA[#objString.DeMoronize(XMLFormat(qry.description))#]]></description>				
				<pubDate>#DateToday#</pubDate>
			  </item>
			</cfloop>	
			</cfoutput> 
		  </channel>		 
	    </rss>
		</cfsavecontent> 
		<cfreturn trim(xmldoc)>		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- --->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="qry4RSS" access="public" output="false" returntype="query" hint="Prepare qry for RSS feed by renaming exsiting SQL columns">
		<cfargument name="qry" required="yes" type="query" hint="pass into query whose columns are to be aliased">
		<cfargument name="Title" required="yes" type="string" hint="name of column in qry">
		<cfargument name="Desc" required="yes" type="string" hint="name of column in qry">
		<cfargument name="pubDate" required="yes" type="string" hint="name of column in qry">
		<cfargument name="Uid" required="yes" type="string" hint="name of column in qry">
		<cfargument name="Author" required="no" type="string" hint="name of column in qry" default="">	
								
			
			<cfscript> 
			var RssQry = "";
			//build up SELECT string based on arguments to re-aliased columns
			var SelectVar = arguments.Title & " AS Title, "  & arguments.Desc & " AS Description, "  & arguments.pubDate & " AS pubDate, " & arguments.Uid & " AS Uid, ";
			var authorVar =' '' ' & " AS Author ";
			if (Len(arguments.Author)) 
				authorVar =arguments.Author & " AS Author " ;
			SelectVar = SelectVar & authorVar;
			///qry the incoming qry to alias existing columns
			return objUtils.queryofquery(arguments.qry, SelectVar);
			</cfscript>

		</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="refresh" access="public" returntype="void" hint="refreshes rss">
		<cfargument name="section" type="string" required="no" default="" hint="this is an optional argument.">
		<cfscript>
		if (arguments.section EQ 'business')
			variables.xmlRSS_business_newspapers = XMLParse( ReadConfig( variables.strConfig.strPaths.xmlpath & "rss_business_config.xml" ) );
		else
			variables.xmlRSS_newspapers = XMLParse( ReadConfig( variables.strConfig.strPaths.xmlpath & "rss_config.xml" ) );
		</cfscript>
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="readConfig" access="private" returntype="any" hint="read rss xml file and return content">
		<cfargument name="sXMLRSS_Path" required="yes" type="string">
		<cffile action="read" file="#arguments.sXMLRSS_Path#" variable="sXML">
		<cfreturn sXML>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
			
</cfcomponent>