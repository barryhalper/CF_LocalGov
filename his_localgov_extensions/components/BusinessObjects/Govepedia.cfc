<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/BusinessObjects/Govepedia.cfc $
	$Author: Bhalper $
	$Revision: 2 $
	$Date: 18/12/07 11:17 $

--->

<cfcomponent displayname="Govepedia" hint="Govepedia Business functions" extends="his_Localgov_Extends.components.BusinessObjectsManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Govepedia" hint="Pseudo-constructor">
		<cfargument name="objAppObjs" type="any" required="yes" hint="The application manager object">
		<cfargument name="objBusObjs" type="any" required="yes" hint="The application manager object">

		<cfscript>
		// Call the genric init function, placing business, app, and dao objects into a local scope...
		StructAppend( variables, Super.initChild( arguments.objAppObjs, this, arguments.objBusObjs ) );
		//variables.qrySectors = GetSectors();
		//variables.qryTodays =  GetTodaysArticles();
		return this;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions ------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="SearchArticles" access="public" output="false" returntype="struct" hint="perform search for articles">
		<cfargument name="keywords"  type="string" required="no">
		<cfargument name="sectionid" type="string" default="0">
		<cfargument name="Sectors"  type="string" default="">

		<cfscript>
		var strReturn = StructNew();
		var qryArticles=queryNew("temp");
		var qryColllection=queryNew("temp");
		strReturn.isError=0;
		//search through verity collection
		if (Len(arguments.keywords))
		     arguments.keywords = objString.SqlSafe(ObjString.StripHTML(arguments.keywords));
		</cfscript>
		
		<cftry>
		<cfset qryColllection  = variables.objSearch.getCollectionSearch(arguments.keywords & " AND cf_custom1=Govepedia").qryResults>
		
		<!--- if user has selected govepedia section ....---->
		<cfif Len(arguments.Sectors) and qryColllection.recordcount>
			<cfset qryArticles = objDAO.GetArticlesbySection(arguments.sectionid, arguments.Sectors)>
			<!--- join govepedia articles to those in collection --->
			<cfquery dbtype="query" name="qryArticles">
				SELECT * 
				FROM   	qryArticles, qryColllection
				WHERE	qryArticles.ArticleID = qryColllection.custom2
				ORDER	BY qryColllection.score DESC
			</cfquery>
		
		<cfelse>
			<!---limit verity search by custom value--->	
			<cfset qryArticles = variables.objUtils.queryofquery(qryColllection, "*", "custom1 = 'Govepedia'")>
		</cfif>
			<cfcatch type="InvalidSearch">
				<cfset strReturn.isError=1>
				<!--- place error message in struct - removing the 'cf_custom' var from the string---> 
				<cfset strReturn.ErrorMessage =cfcatch.message>
			</cfcatch>	
		</cftry>
		<cfset strReturn.qryArticles=qryArticles>
		 <cfreturn strReturn> 
		
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="SearchArticlesAdmin" access="public" output="false" returntype="query" hint="perform search for articles">
		
		<cfargument name="keywords"  type="string" required="yes">
		<cfscript>
		var qryArticles=queryNew("temp");
		if (IsNumeric(arguments.keywords))
			//check if user has searched using an id
			qryArticles = getArticle(arguments.keywords, 0);
		else{
			//run keyword search
			qryArticles = variables.objArticle.adminSearchResults(arguments.keywords);
			qryArticles = variables.objUtils.queryofquery(qryArticles, "*", "newstype='Govepedia'");
			}
		return qryArticles;
		</cfscript>
		
	</cffunction>	
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getArticleforWeb" access="public" returntype="struct" output="false" hint="get full article details and relavent stories">
		<cfargument name="id" type="numeric" required="yes">
		
			<cfscript>
			var headline = "";
			var strReturn  =  Structnew();
			var previousid =  0;
			strReturn.qryRelated = QueryNew("temp");
			
			
			//get all details on articles
			strReturn.qryarticle = getArticle(arguments.id);
			//check if story is 'rejected' and there is a previous version
			if (strReturn.qryarticle.status eq 4 and listlen(strReturn.qryarticle.VersionIDs gt 1)){
				//get id of previous version
				previousid = ListGetAt(strReturn.qryarticle.VersionIDs, ListFind(strReturn.qryarticle.VersionIDs, arguments.id) -1);
				//rerun qry to get older version
				strReturn.qryarticle = getArticle(previousid, 0);
				
				}
			
			headline = REReplace(strReturn.qryarticle.headlinebanner, "", "", "All");
			if (strReturn.qryarticle.sectionid eq 2)
				headline = Replace(headline, ", MP", "");
			</cfscript>
			
			
			
			<cfreturn strReturn>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="GetSectors" access="public" output="false" returntype="query" hint="get all govepedia sectors">
			
			<cfscript>
			var qrySectors= querynew("temp");
			if (structkeyExists(variables, "qrySectors"))
			 	qrySectors = variables.qrySectors;
			else
				qrySectors	= objDAO.GetSectors();
			
			return qrySectors;
			</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="GetSections" access="public" output="false" returntype="query" hint="get all govepedia sections">
		<cfreturn  objDAO.GetSections()>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="getArticle" access="public" output="false" returntype="query" hint="get all details about an entry">
		<cfargument name="Newsid" 	 type="numeric" required="yes">
		<cfargument name="getLastest" type="boolean"  required="no" default="1">
		<cfreturn  objDAO.getArticle(arguments.Newsid, arguments.getLastest)>
		
		
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="GetTodaysArticles" access="public" returntype="query" hint="get all todays' article and biography">
		<cfargument name="refresh" type="boolean" default="false">
		<cfscript> 
		var qryTodays = "";
		if (structkeyExists(variables, "qryTodays") and NOT arguments.refresh)
			 	qryTodays = variables.qryTodays;
			else {
				variables.qryTodays	= objDAO.GetTodaysArticles();
				qryTodays = variables.qryTodays;
				}
			
			return qryTodays;
		  </cfscript>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetHome" access="public" returntype="struct" hint="get content for homepage">
		<cfscript> 
		var strHome = StructNew();
		strHome.qryCopy 	=  variables.objArticle.GetFull(id=44379, type=7, resolve=0);
		strHome.qryTodays   = GetTodaysArticles();
		
		return strHome;
		</cfscript>
	</cffunction>
	
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getAllArticles" access="public" returntype="query" 
		hint="return all news articles based on input criteria">
		<cfargument name="All" required="no" type="boolean" defualt="0">
		<cfreturn  objDAO.getAllArticles(arguments.All)>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="CommitArticle" access="public" output="false" returntype="struct" hint="insert article and return structure">
		<cfargument name="newsid" 			type="string"  required="no" default=""> 
		<cfargument name="HeadlineBanner" 	type="string"  required="yes">
		<cfargument name="sectors" 			type="string"  required="yes">
		<cfargument name="Story" 			type="string"  required="yes">
		<cfargument name="Status" 			type="numeric" required="yes">
		<cfargument name="sectionid" 		type="numeric" required="yes">
		<cfargument name="ModifiedBy" 		type="numeric" required="no" default="0">
		<cfargument name="userID" 			type="numeric" required="no" default="0">
		<cfargument name="isAdmin" 			type="boolean" required="no" default="0">
		<cfargument name="link" 			type="string"  required="no" default="">
		<cfargument name="teaser" 			type="string"  required="no" default="">
		<cfargument name="image_teaser" 	type="any" 	   required="no" default="false">
		
		<cfscript>
		var PColumn 		= "p_news_id";
		var newfilename		= "";
		var SQLstring		="";
		var SQLSelect       = "UPDATE tblNews SET ";
		var SQLWhere		= "WHERE p_news_id = "  ;
		var strReturn = structnew();
		
		strReturn.blStatus = true;
		
		if (NOT Len(arguments.newsid))
			arguments.newsid = 0;
		//check if story has profanity
		if (NOT arguments.isAdmin){
		//check if story has profanity
			if (variables.objComment.isProfane(Story) OR variables.objComment.isProfane(HeadlineBanner)){
				//set status to rejected
				arguments.Status=4;
				strReturn.blStatus=false;
				}
		}
		//update article	
		strReturn.articleid= objDAO.CommitArticle(argumentcollection=arguments);
		
		//UPLOAD FILES
		If (Len(form.image_teaser)){
		  //upload logo
		 newfilename = objUtils.UploadImage(arguments.image_teaser, strConfig.strPaths.uploadimgdir, 'image');
		  //check if file has been upload
		  if (Len(newfilename)){
		  	//set string to upload filename
		  	 SQLString = SQLSelect & "ImageFile='#newfilename#' " & SQLWhere & strReturn.articleid;
			 //call method to upload file
			 objDAO.query(SQLString, variables.strConfig.strVars.dsn1);
			 }
		  
		  }
		
		//set link to article in admin
		if (Len(arguments.link)){
			arguments.link = arguments.link & strReturn.articleid;
			//email editor that article has been added
			variables.objEmail.SendGovepediaConfirmation(arguments.link, strReturn.blStatus);
		};
		return strReturn;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PRIAVTE Functions ----------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->

</cfcomponent>