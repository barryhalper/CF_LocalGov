<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/BusinessObjects/Home.cfc $
	$Author: Bhalper $
	$Revision: 17 $
	$Date: 29/01/09 15:39 $

--->

<cfcomponent displayname="Home" hint="This component actually represents the website home page and contains method used to construct it" extends="his_Localgov_Extends.components.BusinessObjectsManager">

	<!--- -------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR -------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Home" hint="Pseudo-constructor">
	
		<cfargument name="objAppObjs" type="any" required="yes" hint="The application manager object">
		<cfargument name="objBusObjs" type="any" required="yes" hint="The business object manager">

		<cfscript>
		// Call the genric init function, placing business, app, and dao objects into a local scope...
		StructAppend( variables, Super.initChild( arguments.objAppObjs, this, arguments.objBusObjs ) );

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
	<!------------------------------------------------------------------------------------------------------>
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getContent" access="public" output="false" returntype="struct" hint="Retrieves all data required to construct the home page, returns a structure of queries.">
		
		<cfargument name="HowMany" type="numeric" required="true" hint="number of news items to return">
		<cfargument name="strSession" required="yes" type="struct">

		<cfscript>
		var n= 		 arguments.HowMany;
		var strRtn=	 StructNew();
		var qryJobs= getLatestJobs();
		
		// Get all data required for page and store it in a structure of queries...
		
		// News: If the session variable exists and the user is logged in, only news articles that fall in the user's sectors are displayed. If the user is not logged in, all the news articles are displayed.
		if (StructKeyExists(arguments.strSession.userdetails, 'lstSectorIDs'))
			strRtn.qryLatestNews=	getLatestNews( HowMany=n, section=arguments.strSession.userdetails.lstSectorIDs );
		else
			strRtn.qryLatestNews=	getLatestNews( HowMany=n );
		
		strRtn.qryTopNews=	objArticle.getNewsHomeContent().qryFeatures;
		strRtn.qryTopStory=	objArticle.getNewsHomeContent().qryTopStory;
		strRtn.qryMJVideo =	objArticle.getFull(Type=7, ID=71400, GetLatestVersion=1);
		
		//Business News
		strRtn.qryLatestBusNews = objArticle.getBusinessNewsHomeContent().qryFeatures;
		
		// Jobs:
		strRtn.qryFeaturedJobs=	objUtils.QueryOfQuery(qryJobs, "*", 'jobstatus=#chr(39)#Featured#chr(39)#');
		strRtn.qryTopJob= 		objUtils.QueryOfQuery(qryJobs, "*", 'jobstatus=#chr(39)#Top#chr(39)#');
		strRtn.strTopJobs= 		objJobs.GetPremierJobs();

		// Events:
		strRtn.qryEvents=	GetLatestEvents( );
			
		// Today's Papers:
		//strRtn.qryTodaysPapers=	getTodaysPapers( n );
		strRtn.qryEpoll=		getEpoll();
		
		//Biography of the day
		strRtn.qryBiography = objUtils.QueryOfQuery(objGovepedia.GetTodaysArticles(), "*", "Articletype= 'Biography of The Day'");
		// Forum:
		//strRtn.qryLatestForumTopics = getLatestForumTopics( n );
		
		return strRtn;
		</cfscript>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!------------------------------------------------------------------------------------------------------>
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getLatestNews" access="public" output="false" returntype="query" hint="Retrieve that latest news articles">
		
		<cfargument name="HowMany" type="numeric" 	required="true" hint="number items to return">
		<cfargument name="section" type="string" 	required="no" default="" hint="list of sector ids">

		<cfreturn objArticle.getLatest( Type=1, HowMany=Arguments.HowMany, lstSectorIDs=Arguments.section )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!------------------------------------------------------------------------------------------------------>
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getLatestJobs" access="public" output="false" returntype="query" hint="<description>">
		<cfreturn variables.objJobs.GetFeaturedJobs()>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!------------------------------------------------------------------------------------------------------>
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getLatestForumTopics" access="public" output="false" returntype="string" hint="<description>">

		<cfargument name="HowMany" type="numeric" required="true" hint="number items to return">

		<cfreturn objForum.getLatestTopics( Arguments.HowMany )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!------------------------------------------------------------------------------------------------------>
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getLatestEvents" access="public" output="false" returntype="query" hint="<description>">

		<cfreturn objEvents.getLatestEvents(  )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!------------------------------------------------------------------------------------------------------>
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getFeaturedEvents" access="public" output="false" returntype="query" hint="<description>">

		<cfargument name="HowMany" type="numeric" required="true" hint="number items to return">

		<cfreturn objEvents.GetFeaturedEvents( Arguments.HowMany )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!------------------------------------------------------------------------------------------------------>
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getTodaysPapers" access="public" output="false" returntype="struct" hint="<description>">

		<cfreturn objArticle.getTodaysPapers( bFilter=false )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!------------------------------------------------------------------------------------------------------>
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getEpoll" access="public" output="false" returntype="query" hint="<description>">
	
		<!--- <cfreturn variables.objSurvey.GetLatestEpoll()> --->
		<!--get epoll javscript form article (poll monkey)--->
		<cfreturn variables.objarticle.getFull(id=42972, type=7, resolve=0)>
		
	</cffunction>	
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!------------------------------------------------------------------------------------------------------>
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="SaveAsHtm" access="public" output="false" returntype="void" hint="save content generated by cf into htm file">
		<cfargument name="pageContent" required="yes" type="string">
		<cfargument name="filePath"    required="no" type="string" default="\home\dsp_home.htm">
		
		<cffile action="write" file="#variables.strConfig.strPaths.sitedir##arguments.filePath#" output="#pageContent#" /> 
		
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!------------------------------------------------------------------------------------------------------>
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="setHomePage" access="public" output="false" returntype="void" hint="set all data for V2 of home page">`
		<cfargument name="objBus" type="any" required="true" hint="number items to return">
		<cfargument name="refresh" required="no"	type="boolean" 	default="false">	
			
			<cfscript>
				if (NOT StructKeyExists(variables, "strHomePage") OR arguments.refresh){
					//Get Top story to display
						variables.strHomePage	= runHomePage(arguments.objBus);
				}
			</cfscript>
		
	</cffunction>		
	<!--- -------------------------------------------------------------------------------------------------->
	<!------------------------------------------------------------------------------------------------------>
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getHomePage" access="public" output="false" returntype="struct" hint="return all data for V2 of home page">`
		<cfargument name="objBus" 				type="any" 				required="true" hint="number items to return">
		<cfargument name="fromMemory" 		type="boolean" 		required="false" default="false" >
		 
		<cfscript>
			var strReturn = StructNew();
			if (arguments.fromMemory){
				setHomePage(arguments.objBus);
				strReturn	= variables.strHomePage;
			}
			else
				strReturn	= runHomePage(arguments.objBus);
				
			return strReturn;
		</cfscript>
		
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!------------------------------------------------------------------------------------------------------>
	<!--- -------------------------------------------------------------------------------------------------->
	
	<cffunction name="runHomePage" access="public" output="false" returntype="struct" hint="run code to build str  for V2 of home page">`
		<cfargument name="objBus" 	type="any" 		required="true" hint="number items to return">
		 
		<cfscript>
			var strHome 					= objDAO.getHomePage();
			var qryJobs 					= getLatestJobs();
			var qryBlogs 					= arguments.objBus.objBlogs.GetBlogHome().qryLatest;
			var i 	     = 0;
			
			//Get Top story to display
			strHome.qryTopStory		= arguments.objBus.objArticle.getNewsHomeContent().qryTopStory;
			
			strHome.qryComments		= arguments.objBus.objArticle.GetHomepageComments();
			
			/*Get Jobs*/	
			strHome.qryTopJob			= arguments.objBus.objJobs.GetPremierJobs().qryTopJob;
			
			//objutils.dumpabort(qryBlogs);
			
			/*get blogs*/
			if (qryBlogs.recordcount)
				strHome.qryBlog				= objutils.queryOfquery(qryBlogs, "*", 'UID = #qryBlogs.Uid[1]#');
			else
				strHome.qryBlog				= objutils.queryOfquery(qryBlogs, "*", 'UID = 0');	
			
			strHome.qryBlog				= blogCopy(strHome.qryBlog);
			strHome.qrySurvey			= arguments.objBus.objSurvey.GetLatest();
			return strHome;
		</cfscript>
		
		
	</cffunction>	
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!------------------------------------------------------------------------------------------------------>
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getRelevantProducts" access="public" output="false" returntype="query" hint="return all relevant products form his products list">
		<cfargument name="hisproductids" required="yes" type="string" default="#variables.strConfig.strVars.hisproductids#">
		<cfreturn objDAO.getRelevantProducts(Arguments.hisproductids)>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- PRIVATE Functions -------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="BlogCopy" access="public" output="false" returntype="query" hint="return all relevant products form his products list">
		<cfargument name="qryBlog" required="yes" type="query">
		
		<cfscript>
		var qry = arguments.qryBlog;
		var string = objstring.StripHtml(qry.content);
			if ( Len(string) gt 260)
				querySetCell(qry, "content", objstring.FormatTeaser(string, 260) & "...");	
		
		return qry;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetMenu" access="public" returntype="array" output="false" hint="get xml menu for the layout v2.0">
		<cfargument name="strSession" required="yes" type="struct">
		
		<cfscript>
			var strMenu 	= Duplicate(strConfig.xmlMenu);
			var arrMenu 	= strMenu.xmlroot.xmlchildren;
			var i			= 0;
			var corpPos		= 0;
			for (i = 1; i lte arrayLen(arrMenu); i=i+1){
				if (arrMenu[i].xmlattributes.name eq "my Corporate Home"){
					corpPos = i;
					break;
				}
			}
			//if ((NOT StructKeyExists( strSession.userDetails, "userID") OR NOT StructKeyExists( strSession.userDetails, "userTypeID")) OR strSession.userDetails.userTypeID NEQ 5){
				//ArrayDeleteAt(arrMenu, corpPos);
			//}
			return arrMenu;
		</cfscript>	
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getLatestTweets" access="public" returntype="query" hint="I get the latest 5 tweets from the log for display">
		<cfreturn objDAO.getLatestTweets()>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getLotsOfTweets" access="public" returntype="query" hint="I get the latest 30 tweets from the log for display">
		<cfreturn objDAO.getLotsOfTweets()>
	</cffunction>

</cfcomponent>