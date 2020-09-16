<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/BusinessObjects/Search.cfc $
	$Author: Bhalper $
	$Revision: 9 $
	$Date: 29/10/08 17:15 $

--->

<cfcomponent displayname="search" hint="generic searches business object functions" extends="his_Localgov_Extends.components.BusinessObjectsManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Search" hint="Pseudo-constructor">
	
		<cfargument name="objAppObjs" type="any" required="yes" hint="The application manager object">
		<cfargument name="objBusObjs" type="any" required="yes" hint="The application manager object">
		
		<cfscript>
		// Call the genric init function, placing business, app, and dao objects into a local scope...
		StructAppend( variables, Super.initChild( arguments.objAppObjs, this, arguments.objBusObjs ) );
		variables.qrySectors = GetSectors();
		return this;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions ------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetVariables" access="public" output="false" returntype="struct" hint="">
		<cfreturn variables>
	</cffunction>
	
	<cffunction name="GetSectors" access="public" output="false" returntype="query" hint="gte sectors for search forms">
		
		<cfscript>
		var qrySectors = queryNew("Temp");
		if (NOT StructKeyExists(variables, "qrySectors"))
			qrySectors = objDAO.GetSectors(variables.strConfig.strVars.ProductID);
		else
			qrySectors = variables.qrySectors;
			
		return 	qrySectors;
		</cfscript>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="StoreSearchTerms" access="public" output="false" returntype="boolean" hint="">
	
		<cfscript>
		var sKeywords = "";
		
		if ( StructKeyExists(url, "keywords") )
			sKeywords = url.keywords;
		
		if ( StructKeyExists(form, "keywords") ) 
			sKeywords = form.keywords;
	
		if ( Not StructKeyExists(Session, "Searches") )
			session.searches = "";

		if ( Not ListFindNoCase(session.Searches, sKeywords) )
			if ( ListLen(session.Searches) GTE 10 )
				session.Searches = sKeywords & "," & ListDeleteAt(session.Searches, ListLen(session.Searches));
			else
				session.Searches = sKeywords & "," & session.Searches;
			
		return true;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetCollectionSearch" access="public" output="false" returntype="struct" hint="perform generic search using verity">
		<cfargument name="criteria" required="yes" type="string" >
		<cfargument name="contextPassages" required="no" type="numeric" default="1" >
		<cfargument name="contextBytes" required="no" type="numeric" default="300" >
		<cfargument name="type" required="no" type="string" default="simple" >
		<cfargument name="contexthighlightbegin" required="no" type="string" default="" >
		<cfargument name="contexthighlightend" required="no" type="string" default="" >
		 
	 	<cfscript>
		var LeftPos = 0;
		var strReturn =StructNew(); 
		//call method to Strip HTML from search term
		arguments.criteria  = objString.StripHTML(arguments.criteria);
		arguments.criteria  = Lcase(objString.SQLSafe(arguments.criteria));
		//set position in string from which to trim
		LeftPos = Len(arguments.criteria);
		if ( Find("AND cf_custom1=", arguments.criteria) )
			LeftPos = 	Find("AND cf_custom1=", arguments.criteria) -1 ;
		
			
		//call method to add 'AND' next to brackets'
		//arguments.criteria  = CreateVerityOperator(arguments.criteria);
		//if (Find('(', arguments.criteria) gte 3)
			//arguments.criteria  = Replace(arguments.criteria, '(', 'OR (');	
		</cfscript>
		
		<cftry>
			<cfset strReturn = objDAO.SearchCollection(argumentCollection=arguments)>
			<cfcatch>
				<cfset arguments.criteria = trim( Left(arguments.criteria, LeftPos) )>
				<cfthrow type="InvalidSearch" message="Your search criteria '<em>#arguments.criteria#</em>' is invalid. <br> Please try again.">
			</cfcatch>
		</cftry>
		<cfreturn strReturn>
		
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="QuickSearch" access="public" output="false" returntype="struct" hint="perform specific search in a directory using verity">
		<cfargument name="keywords" type="string" required="yes">
		<cfargument name="context" 	type="string" required="no" default="">
	
			<cfscript>
			var strReturn 	= structNew();
			var criteria 	= arguments.keywords;
			var qryBusiness = "";
			criteria 		= variables.objString.SQLSafe(criteria);
			if (Len(arguments.context)){
			 	//evalute context and set search terms
				switch (arguments.context){
					//if user has selected orgnisation, search all of MYB
					case "organisations":{
						criteria = criteria & " AND cf_custom4=#variables.strConfig.strVars.dsn2# AND cf_custom1 != People";
						break;}	
					case "myb":{
						criteria =  criteria & " AND cf_custom4=#variables.strConfig.strVars.dsn2#";
						break;}		
					case "Business news":{
						//reset criteria to news
						criteria 	=  criteria & " AND cf_custom1=News";
						break;}	
							
					default:{
						criteria =  criteria & " AND cf_custom1=#arguments.context#";
						break;}	
				}
			 }
			 //perform search
			strReturn 				   = getCollectionSearch(criteria);
			
			//if business news.....
			if (arguments.context eq "Business news")
				strReturn.qryResults = variables.objArticle.searchNews(strReturn.qryResults, "65", "News");
			
			//group result
			strReturn.qrygroupResults  = groupResults( StrReturn.qryResults );
				
			return 	strReturn;
			</cfscript>
	
	</cffunction> 
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------>
	<cffunction name="TopQuickSearch" access="public" output="false" returntype="struct" hint="perform top quick search across entire verity collection">
		<cfargument name="keywords" 	type="string" required="yes">
		<cfargument name="context" 		type="string" required="no" default="">
		<cfargument name="strSession" 	type="struct" required="yes">
		<cfargument name="circuit" 		type="string" required="yes">
		
		<cfscript>	
		var strResult =   structNew();
		var keyword = ObjString.StripHTML(ObjString.StripHTML(arguments.keywords));
		var strValidate = validateQuickSearch(keyword);
		strResult.qryContent=queryNew("temp");
		strResult.ErrorMessage = "";
		strResult.qryGroupedResult=queryNew("temp");
		
		try {
		if (strValidate.IsSearchValid){
		 
			if (arguments.context eq "business news")
				strResult.qryContent = objArticle.searchNews(request.objBus.objSearch, keyword, 65, "News").qryNews;	
			else{	
				strResult = QuickSearch(keyword, arguments.context );
				strResult.qryContent  = strResult.qryResults;
				strResult.qryGroupedResult = strResult.qrygroupResults;}
			
			if (arguments.context eq "news" OR arguments.context eq "jobs") 
				strResult.qryContent = objUtils.queryofquery(strResult.qryContent, "*", "0=0", "Custom3 DESC");	
			
			strResult.ErrorMessage = "";		
		}
		else
			strResult.ErrorMessage = strValidate.message;	
		}
		catch (InvalidSearch Exception){
				//objutils.dumpabort(Exception);
				strResult.ErrorMessage = Exception.message;
			}	
		
		
		return 	strResult;
		</cfscript>
		
	</cffunction>	
		
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GroupResults" access="public" output="false" returntype="query" hint="group Search results based on content type and number of results">
		<cfargument name="qrySearch" required="yes" type="query">
		<cfset var qryGroup =QueryNew("Custom1,TypeCount,Pubseq")>
		<cfset var qryContent ="">
		
		<!---group search results by content type ---> 
		<cfset qryContent = objutils.QueryOfQuery(arguments.qrySearch, 'COUNT(custom1) as TypeCount', '0=0 GROUP BY custom1', 'typecount DESC')>
		<!---create new query to contian pubseq --->
		<cfloop query="qryContent">
			<cfscript>
			QueryAddRow(qryGroup);
			QuerySetCell(qryGroup, "Custom1", Custom1);
			QuerySetCell(qryGroup, "TypeCount", TypeCount);
			QuerySetCell(qryGroup, "Pubseq", 0);
			</cfscript>
		</cfloop>
		<!---reset pubseq based on content type --->
		<cfloop query="qryGroup">
			<cfscript>
			 switch (Custom1){
			 	case "News":
					QuerySetCell(qryGroup, "Pubseq", 3, currentrow);
					break;
				case "Councils":
					QuerySetCell(qryGroup, "Pubseq", 2, currentrow);
					break;
				case "People":
					QuerySetCell(qryGroup, "Pubseq", 1, currentrow);
					break;
				}
			</cfscript>	
		</cfloop>
		
		<!---re order qry by pubseq ---> 
		<cfset qryGroup = objutils.QueryOfQuery(qry=qryGroup, columns='*', OrderBy='Pubseq desc, typecount DESC')>
		
		<cfreturn qryGroup>
	</cffunction>  
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="IndexCollection" access="public" returntype="void" output="false" hint="tunr sql query into verity collection">
		<cfargument name="collectionName" required="no"  type="string"  default="#variables.strConfig.strVars.veritycollection#">
		<cfargument name="IndexAction" required="no"  type="string"  default="update">
		<cfargument name="StartRow"    required="no"  type="numeric" default="1"> 
		<cfargument name="EndRow"      required="no"  type="numeric" default="0"> 
		<cfargument name="ProductID"   required="no" type="string" hint="list of website id's to be indexed" default="#variables.strConfig.strVars.newsproductids#">
		<cfargument name="Attributeid" required="no"  type="string" default="#variables.strConfig.strVars.lstAttributeID#"> 
		
		<!---get all local gov data --->					
		<cfset var qryCollection=GetCollectionData(argumentCollection=arguments)> 		  	
	
		<cfindex 
			collection="#arguments.collectionName#" 
			action="#arguments.IndexAction#"
			query="qryCollection" 
			type="custom"
			key="ContentID" 
			Title="title" 
			Body="title,byline,story"  
			custom1="contenttype" 
			custom2="UID"
			custom3="datestart" custom4="source">
			
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="Add2Collection" access="public" returntype="void" output="false" hint="insert new record into verity collection">
		<cfargument name="Str" required="yes" type="struct" hint="input structure">
	 	<!--- turn input struct into qry to be indexed--->
	 	<cfset  var qry = objutils.Struct2Query(arguments.Str)> 
	  	<cfset  var qryCollection = "">
	  	<cfset  var IndexID = "">
	  	<!---get collection details --->	
		<cfcollection action="list" name="qryCollection">
		<cfloop query="qryCollection">
			<cfif name eq variables.strConfig.strVars.veritycollection>
				<!---Get number of docuemtsn for the collection--->
				<cfset IndexID = DoCount + 1>
			</cfif>
		</cfloop>	
		<!---Rebuild query to match indexed qry --->
		
	</cffunction> 
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetCollectionData" access="public" output="false" returntype="query" hint="return all data which is to be added to collection">
		<cfargument name="ProductID" 	required="yes" type="string" hint="list of website id's to be indexed">
		<cfargument name="startrow"  	required="no" type="numeric" default="1">	
		<cfargument name="Endrow"     	required="no" type="numeric" default="0">
		<cfargument name="AttributeID"  required="no" type="string" default="">
		
		<cfreturn objDAO.GetCollectionData(argumentcollection=arguments)>	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetLink" returntype="string" output="false" access="public" hint="work out item link for a result basd on type of data in search result ">
	 	<cfargument name="sType"  required="yes" type="string" hint="type of content">
		
	  		<cfscript>
				var link = "";
				switch (arguments.sType) {
					case "news" : 						link = "news.detail"; break;
					case "Business news" : 	case "Business"	: link = "business.detail"; break;
					case "Jobs": 						link = "jobs.item"; break;
					case "events": 						link = "events.item"; break;
					case "person": 						link = "directory.Personitem"; break;
					case "People": 						link = "directory.Personitem" ; break;
					case "councils": 					link = "directory.Orgitem" & "&amp;Orgtype=council"; break;
					case "Local Government Suppliers": 	link = "procguide.item"; break;
					case "associations":				link = "directory.Orgitem" & "&amp;Orgtype=associations"; break;
					case "Need 2 Know":					link = "need.copy"; break;
					case "Suppliers":  					link = "pg.orgdetails"; break;	
					case "Procurement Guide Products":	link = "pg.searchaction&searchtype=company"; break;
					case "Govepedia":					link = "govepedia.detail"; break;
					case "blogs":						link = "blogs.item"; break;
					default: 							link = "directory.Orgitem" & "&amp;Orgtype=" & UrlEncodedFormat(sType);
				}
				return link;
				</cfscript>
	
	</cffunction>

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PRIAVTE Functions ----------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="CreateVerityOperator" access="public" returntype="string" output="false" hint="add opening and closing tags to operator words to be passed to verity search">
		<cfargument name="criteria" type="string" default="">
		<!-- removing noise words from the text string using regular expressions--->
		<cfreturn REReplaceNoCase(arguments.criteria,"( AND|OR )",chr(60) & "\1" & chr(62),"ALL")>	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="StripNoise" access="private" output="false" returntype="string" hint="strips 'noise words from blocks of text passed in client form">
		<cfargument name="SearchString" required="yes" type="string">
		
		<cfscript>
		var i ="";
		//list if noise of words
		var lstNoiseWords = variables.strConfig.strVars.noisewords;
		var localString = REReplaceNoCase(arguments.SearchString, "[[:punct:]]"," ","ALL");
		//set list into array for looping
		var arrNoiseWords = ListtoArray(lstNoiseWords);
		//Remove all numbers, dollar signs,underscores and hyphens from the text
		//localString = ReReplace(localString, "[0-9\$_-]", " ", "All");
		//loop through the array of noise words,
		for (i=1; i LTE arrayLen(arrNoiseWords); i=i+1 ){
			// removing noise words from the text string using regular expressions
			localstring = ReReplaceNoCase(localstring, "(([[:space:]])#arrNoiseWords[i]#([[:space:]]))", " ", "all");
			localstring = ReReplaceNoCase(localstring, "(([[:space:]])#arrNoiseWords[i]#([[:space:]]))", " ", "all");
		 }
		//return localstring;
		</cfscript>

	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="validateQuickSearch" access="private" output="false" returntype="struct" hint="evluate if qucik serch is valid">
		<cfargument name="keywords" type="string" required="yes">
			
		<cfscript>
		var strReturn = StructNew();
		strReturn.IsSearchValid = true;
		strReturn.message = "";
		
		If (NOT Len(arguments.keywords))
			strReturn.message = "Please supply your search text";
		else	
		If (Len(arguments.keywords) LTE 1)
			strReturn.message = "Your search <em>'#arguments.keywords#'</em> is not valid";
		else	
		If (ListContains("(,)", arguments.keywords))
			strReturn.message = "Your search <em>'#arguments.keywords#'</em> is not valid";	
		else
		
		If (ListContains(strConfig.strVars.noisewords, arguments.keywords))
			strReturn.message = "Your search <em>'#arguments.keywords#'</em> is not valid";	
		
		If (Len(strReturn.message))
			strReturn.IsSearchValid = false;
		
		return	strReturn;
		</cfscript>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="displaySummary" access="public"  returntype="string" output="false" hint="cleans summary for output">
		<cfargument name="keywords" 			type="string"  required="yes">
		<cfargument name="summary" 			type="string"  required="yes">
		<cfargument name="context" 				type="string" 	required="yes">
		<cfargument name="title" 					type="string" 	required="yes">
		<cfargument name="custom1" 			type="string" 	required="yes">
		
		<cfscript>
		var strippedcontext  =  "";
		if ( (len(arguments.summary) or len(arguments.context)) and len(arguments.title) ) {
		// remove title from context, if it appeats at the start
			if (findnocase(arguments.title, arguments.context) eq 1 )
						strippedcontext = ReplaceNoCase(arguments.context, arguments.title, "");
			else
						strippedcontext = arguments.context;
			// remove html characters from text of certain areas
			if (arguments.custom1 neq "councils")
					strippedcontext = objString.StripHTML(strippedcontext);
											
			strippedcontext  = objString.StripUnclosedTags(strippedcontext);
			strippedcontext =  objString.HighLight(strippedcontext, arguments.keywords);	
			}
			return strippedcontext;						
		</cfscript>
		
	</cffunction>
	
</cfcomponent>