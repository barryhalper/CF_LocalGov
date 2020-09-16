<cfcomponent displayname="FullTextSearch" hint="function to peform MSSQL Full Text Search" extends="his_Localgov_Extends.components.BusinessObjectsManager">
	
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="FullTextSearch" hint="Pseudo-constructor">
	<cfargument name="objAppObjs" type="any" required="yes" hint="The application manager object">
		
		<cfscript>
			variables = StructNew();
			// Call the genric init function, placing business, app, and dao objects into a local scope...
			structAppend( variables, Super.initChild( arguments.objAppObjs, this) );
			return this;
		</cfscript>
		
	</cffunction>

	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions ------------------------------------------------------------------------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getVariables" access="public" output="false" returntype="struct" hint="">
		<cfreturn variables>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions ------------------------------------------------------------------------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="run" access="public" output="false" returntype="struct" hint="run FTS ">
		<cfargument name="keyword"  		type="string"	default="">
		<cfargument  name="author" 			type="string"	default=""> 
		<cfargument  name="product" 		type="string"	default=""> 
		<cfargument  name="contenttype" 	type="string"	default=""> 
		<cfargument  name="filter" 			type="boolean"	default="false" > 
		<cfargument  name="YearPublished" 	type="string"	default=""> 
		<cfargument  name="monthPublished"  type="string"	default=""> 
		<cfargument  name="sector" 			type="string"	default=""> 
		<cfargument  name="orderby" 		type="string"	default="datestart DESC">
		<cfargument  name="remotehost" 		type="string"	 required="no" default="">
		
		<cfscript>
		var strSearch = StructNew();
		
		strSearch.qry = exec(keyword=arguments.keyword, remotehost=arguments.remotehost);
			
		//request.objApp.objutils.dumpabort(strSearch);
		//apply group filter
		if (arguments.filter){
			strSearch.qry = filterResults(strSearch, arguments.author, arguments.product, arguments.contenttype, arguments.YearPublished, arguments.monthPublished, 
			arguments.sector, arguments.orderby);
			}
		//prepare the results filter groups 	
		groupResults(strSearch, arguments.author, arguments.product, arguments.contenttype, arguments.YearPublished, arguments.monthPublished, arguments.sector);	
		//group the results 
		//strSearch.qry = resultsforDisplay(strSearch, arguments.orderby);
		return strSearch;
		</cfscript>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="exec" access="public" output="false" returntype="query" hint="run FTS ">
		<cfargument name="keyword"  		type="string"	default="">
		 <cfargument name="numSecords"   	required="no" type="numeric" default="60" hint="query cache time in seconds">
         <cfargument  name="remotehost" 		type="string"	 required="no" default="">
        
		<cflog file="searchlog" text="Search run, keyword: #keyword# || time: #now()# || rem host: #arguments.remotehost# || query str: #cgi.QUERY_STRING# ">
		<cfreturn objDAO.exec(formatCriteria(arguments.keyword), arguments.numSecords)> 
	</cffunction>
	
	
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="groupResults" access="public" returntype="void"  hint="create groupings (a structure of queries) for search result">
		<cfargument name="str" 				required="yes" type="struct">
		<cfargument name="author" 			required="no" type="string" default="">
		<cfargument name="product" 			required="no" type="string" default="">
		<cfargument name="contenttype" 		required="no" type="string" default="">
		<cfargument name="YearPublished" 	required="no" type="string" default="">
		<cfargument name="monthPublished" 	required="no" type="string" default="">
		<cfargument name="sector"  			required="no" type="string" default="">
	
	
		<cfscript>
		var strSearch = arguments.str;
		
		strSearch.strGroups = StructNew(); 
		/*** product group ***/
		if (NOT len(arguments.product))
			strSearch.strGroups.qryProduct = objutils.QueryOfQuery(strSearch.qry, "COUNT(Product) as Num, Product", "0=0 AND Product IS NOT NULL  GROUP BY Product", 'Num DESC'); 
		else
			strSearch.strGroups.qryProduct = objutils.QueryOfQuery(strSearch.qry, "COUNT(Product) as Num, Product", "Product !='#arguments.product#'  GROUP BY Product", 'Num DESC'); 
		/*** content group ***/
		if (NOT len(arguments.contenttype))
			strSearch.strGroups.qryContent = objutils.QueryOfQuery(strSearch.qry, "COUNT(ContentType) as Num, ContentType", "0=0  GROUP BY ContentType", 'Num DESC');
		else
			 strSearch.strGroups.qryContent = objutils.QueryOfQuery(strSearch.qry, "COUNT(ContentType) as Num, ContentType", "ContentType !='#arguments.contenttype#'  GROUP BY ContentType", 'Num DESC');
		/*** author group ***/
		if (NOT len(arguments.author))
			strSearch.strGroups.qryAuthor = objutils.QueryOfQuery(strSearch.qry, "COUNT(Author) as Num, Author", "Author IS NOT NULL AND Author != ''  GROUP BY Author", 'Num DESC', 10); 
		else
			strSearch.strGroups.qryAuthor = objutils.QueryOfQuery(strSearch.qry, "COUNT(Author) as Num, Author", "Author != '#replace(arguments.author, "'", "", "all")#'  GROUP BY Author", 'Num DESC', 10);
		/*** year group ***/
		if (NOT len(arguments.YearPublished))
			strSearch.strGroups.qryYear = objutils.QueryOfQuery(strSearch.qry, "COUNT(YearPublished) as Num, YearPublished", "YearPublished IS NOT NULL  GROUP BY YearPublished", 'YearPublished DESC'); 
		else
			strSearch.strGroups.qryYear = objutils.QueryOfQuery(strSearch.qry, "COUNT(YearPublished) as Num, YearPublished", "YearPublished IS NOT NULL AND YearPublished != #arguments.YearPublished#  GROUP BY YearPublished", 'YearPublished DESC'); 	
		/*** month group ***/
		if (NOT len(arguments.monthPublished))	
			strSearch.strGroups.qryMonth = objutils.QueryOfQuery(strSearch.qry, "COUNT(monthPublished) as Num, monthPublished", "intMonthPublished IS NOT NULL  GROUP BY monthPublished, intMonthPublished", 'intMonthPublished');
		else
			strSearch.strGroups.qryMonth = objutils.QueryOfQuery(strSearch.qry, "COUNT(monthPublished) as Num, monthPublished", "intMonthPublished IS NOT NULL AND monthPublished != '#arguments.monthPublished#'  GROUP BY monthPublished, intMonthPublished", 'intMonthPublished');
		/*** sector group ***/
		groupBySector(strSearch, arguments.sector);
		
		</cfscript>
	
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="groupBySector" access="public"  returntype="void"  hint="group results by sector">
		<cfargument name="str" 			required="yes" type="struct">
		<cfargument name="sector"  		required="no" type="string" default="" >
		
		<cfscript>
		var qofq = querynew("num,sector");
		var sectorname ="";
		var i=0;
		var strSearch = arguments.str;
		
		//columns to filter on
		var arrColumns=["Adult_Social_Services","Business","Childrens_Social_Services","Communication","E_Government","Education","Emergency_Services","Environmental_Services","Finance","Health","Housing","Inspection_and_Improvement","Legal","Leisure_and_Tourism","Lifelong_Learning","Management_and_HR","People","Planning_and_Regeneration","Politics_and_Policy","Procurement_and_Efficiency","Top_Team","Transportation","Voluntary"];
		//create new qry
		strSearch.strGroups.qrySector =QueryNew("num,sqlsector,sector");
	   //loop over column names and run group query for every column
		for (i=1; i lte arrayLen(arrColumns); i=i+1){
			if (NOT len(arguments.sector) or   arguments.sector neq arrColumns[i]){
				qofq = request.objApp.objUtils.queryofQuery(strSearch.qry, "COUNT(*) as num", "#arrColumns[i]# = 1");
				if (qofq.recordcount){
				//clean sector name
				sectorname = replace(arrColumns[i], "_", " ", "all");
				if (sectorname eq "E Government")
					sectorname = "E-Government";
				sectorname = Replace(sectorname,"Childrens", "Children's");	
					
				queryAddRow(strSearch.strGroups.qrySector);
				querySetCell(strSearch.strGroups.qrySector, "num", qofq.num);
				querySetCell(strSearch.strGroups.qrySector, "sqlsector", arrColumns[i]);
				querySetCell(strSearch.strGroups.qrySector, "sector", sectorname);
				}			
			}
		
			}
			strSearch.strGroups.qrySector = request.objApp.objUtils.queryofQuery(strSearch.strGroups.qrySector, "*", "0=0 ORDER BY num desc");
			</cfscript>
		
	</cffunction>	

	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="filterResults" access="public" returntype="query" hint="filter search results based on criteria">
			<cfargument name="str" required="yes" type="struct">
			<cfargument name="author" required="no" type="string">
			<cfargument name="product" required="no" type="string">
			<cfargument name="contenttype" required="no" type="string">
			<cfargument name="YearPublished" required="no" type="string">
			<cfargument name="monthPublished" required="no" type="string">
			<cfargument name="sector"  required="no" type="string">
            <cfargument name="orderBy"  required="no" type="string" default="datestart DESC">
			
			
				<cfscript>
				var qry = str.qry;
				var WhereClause = "0=0";
				if (Len(arguments.author))
					WhereClause =  WhereClause & " AND author = '" & replace(arguments.author, "'", "", "all") & "'";
				if (Len(arguments.product))
					WhereClause = WhereClause & " AND product = '" & arguments.product & "'";
				if (Len(arguments.contenttype))
					WhereClause =  WhereClause & " AND contenttype = '" & arguments.contenttype & "'";
				if (Len(arguments.YearPublished))
					WhereClause =   WhereClause & " AND YearPublished = " & arguments.YearPublished & "";
				if (Len(arguments.monthPublished))
					WhereClause = WhereClause & " AND monthPublished ='" & arguments.monthPublished & "'";	
				if (Len(arguments.sector)){
					
					WhereClause = WhereClause & " AND #replace(Replace(arguments.sector, " ", "_", "all"), "-", "_", "all")# = 1";
					
					}		
				
				    /** run qofq to filter results **/
					qry = objutils.QueryOfQuery(str.qry, "*", WhereClause, arguments.orderBy);
					
					
					
				return qry;	
				</cfscript>
			
			
		</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
		<cffunction name="resultsforDisplay" access="public" returntype="query" hint="group results for display">
			<cfargument name="str" required="yes" type="struct">
			<cfargument name="orderBy" required="no" type="string" default="">
			
				<cfscript>
				var columns = "UID,title,byline,story,ContentType,datestart,rank";
				return objutils.QueryOfQuery(arguments.str.qry, columns, "0=0 GROUP BY #columns#", arguments.orderBy);
				</cfscript>	
			
		</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="filterQueryString" access="public"  returntype="string" output="false" hint="prepare url query string based on filter criteria">
		<cfargument name="attributes" 			type="struct"   required="yes" hint="paramter structutre for url/attributes">
		<cfargument name="contentType" 			type="string" 	required="yes">
		<cfargument name="value" 				type="string" 	required="yes">
	
		
			<cfscript>
			var IgnoreList = "#arguments.contentType#,refresh,pw,startrow,brefresh,debug,queryrecordcount,rowsperpage,layout,admin,mid";
			var queryString  = ""; 
			arguments.attributes.filter = 1;
			queryString  = objString.Struct2QueryString(arguments.attributes, IgnoreList);
			queryString = queryString & "&amp;#arguments.contentType#=" &  URLEncodedFormat(arguments.value);
			return  queryString;
			</cfscript>
		
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="displaySummary" access="public"  returntype="string" output="false" hint="clean result summary for output">
		<cfargument name="keyword" 			type="string"   required="yes">
		<cfargument name="byline" 				type="string" 	required="yes">
		<cfargument name="story" 				type="string"   required="yes">
		<cfargument name="contentType" 			type="string" 	required="no">
		
		<cfscript>
		var summary  =  byline;
		if (NOT len(arguments.byline)) 
			summary = arguments.story;
		
		summary = objString.StripUnclosedTags(summary);
		summary = objString.FormatTeaser(summary, 250);
		summary = objString.HighLight(summary, arguments.keyword);
		return summary;	
						
		</cfscript>
		
	</cffunction>
	
	
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="build" access="public" returntype="void"  output="false" hint="exec stored proc to add data to search table ">
		<cfset objDAO.build()>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="index" access="public" returntype="void"  output="false" hint="exec stored proc rebuild full text catalogue ">
		<cfset objDAO.index()>
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
		
	
		<cfset arguments.keyword = formatCriteria(arguments.keyword)>
		<cfreturn objDAO.advanced(argumentCollection=arguments)>
		
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="formatCriteria" access="public" returntype="string" hint="format search string im prepartion for FTS">
		<cfargument name="criteria" required="yes" type="string">			
			<cfscript>
			var regExpression = "[" &  "'" & '"'  & "##" & "/\\%&`@~!,:;=<>\+\*\?\[\]\^\$\(\)\{\}\|]";
			var keywords = reReplace(arguments.criteria,regExpression,"","all");
			var arr = ListToArray(keywords, " ");
			var lst = "";
			var i = 0;
			
			
			for (i=1; i lte ArrayLen(Arr); i=i+1) {
				if (NOT ListFindNoCase(strConfig.StrVars.noisewords, Arr[i]))
					lst = ListAppend(lst, trim(Arr[i]) );
				
				//lst= ListChangeDelims(lst," AND ") ;	 
			}
			//search is one word
			if (ListLen(lst) eq 1){
				//append apostrphone and asterick
				lst = lst & "*";
				lst = chr(34) & lst & chr(34);
				}
			else
				//add AND to search term
				lst = ListChangeDelims(lst, " AND ");	
			
			return lst;
		</cfscript>
			
			
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getKeywords" access="public" returntype="query" output="false"  hint="get all keywords">
		<cfargument name="refresh" type="boolean" default="false">
			
		<cfset setKeywords(arguments.refresh)>
		<cfreturn variables.qryKeywords>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="setKeywords" access="public" returntype="void" output="false"  hint="set keywords into memory">
		<cfargument name="refresh" type="boolean" default="false">
		
				<cfscript>			
				if (NOT StructKeyExists(variables, "qryKeywords") and NOT arguments.refresh) 
					variables.qryKeywords = objDAO.getKeywords();
				
				//return strLookUps;
		</cfscript>		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="saveArticle" access="public" returntype="void"  output="false" hint="perform advance full text search ">
		
		<cfargument name="ID"			required="yes"  type="numeric" default="">
		
		<cfset objDAO.saveArticle(arguments.ID)> 
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="saveblogs" access="public" returntype="void"  output="false" hint="save blog to array of insert statements">
		<cfargument name="obj" type="his_Localgov_Extends.components.BusinessObjects.blogs">
		<cfscript>
			var a = arrayNew(1);
			//set all blogs into qry
			var qry = arguments.obj.GetLatestBlog();
			var apostrophe=chr(39);
			var inserts = "Insert INTO search (UID, title, byline, story, ContentType, datestart,  author)";
			var sql = "";
			//loop over qry that contains all blogs
			for (i=1;i LTE qry.recordcount;i=i+1 ){
				body  =  objString.stripHtml(qry.content[i]);
				body  =   Trim(Replace(body, apostrophe, '#apostrophe##apostrophe#', "all"));
				title  =  Trim(Replace(qry.title[i], apostrophe, '#apostrophe##apostrophe#', "all"));
				rsstitle  = Trim(Replace(qry.rsstitle[i], apostrophe, '#apostrophe##apostrophe#', "all"));
				author  = Trim(Replace(qry.author[i], apostrophe, '#apostrophe##apostrophe#', "all"));
				//create insert statements
				sql = inserts & " VALUES(#qry.Uid#, #apostrophe##title##apostrophe#, #apostrophe##rsstitle##apostrophe#, #apostrophe##body##apostrophe#, 'Blogs', #qry.pubdate[i]#, #apostrophe##author##apostrophe#)  ";
				//add statemenst to arrays 
				arrayappend(a,sql);
				
			}
			objDAO.saveblogs(a);
			</cfscript>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="delete" access="public" returntype="void" output="false"  hint="get all keywords">
		<cfargument name="ID"			required="yes"  type="string" default="">
			<cfset objDAO.delete(arguments.ID)> 
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
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
	
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------->

</cfcomponent>