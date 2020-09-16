<cfcomponent hint="Function which manage import & export of XML Papers">


	<!--- -------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR -------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->	
	<cffunction name="init" returntype="Papers" access="public" output="false" hint="constructure method">
		<cfargument name="objApp"  				 type="any" 			required="yes">
		<cfargument name="useProxyServer"    type="Boolean"	required="yes">
		
		<cfscript>
			//get site config struct
			instance 								= StructNew();
			instance.strPapers  					= StructNew();
			instance.strPapers.arrPapers			= arrayNew(1);
			instance.strBusinessPapers				= structNew();
			instance.strBusinessPapers.arrPapers	= arrayNew(1);
			instance.objApp  						= arguments.objApp;
			instance.useProxy  						= arguments.useProxyServer;
			
			return this;
		</cfscript>
			
		</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->	
	<cffunction name="getAll" access="public" output="false" returntype="query" hint="">
		<cfargument name="feedType" required="yes" type="string" >
		
		<cfscript>
			var qryPaper = QueryNew("id,title,NoOfArticles", "integer,VarChar,Integer");
			var stPapers	= StructNew(); 
			if (arguments.feedType eq "business")
				stPapers  = getTodaysBusinessPapers(instance.useProxy);
			else
				stPapers  = getTodaysPapers(instance.useProxy);
				
			qryPaper  		= PapersToQuery(stPapers);
			
			return 	qryPaper;
		</cfscript>
		
	</cffunction>
		
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="PapersToQuery" access="public" output="false" returntype="query" hint="">
		<cfargument name="strPapers"  type="struct" required="false" default="true" hint="">
		
		<cfscript>
			var i = 0;
			var qry = QueryNew("id,title,NoOfArticles", "integer,VarChar,Integer");
			
			for (i=1; i lte arrayLen(arguments.strPapers.arrPapers); i=i+1) 
			{
				QueryAddRow(qry);
				QuerySetCell(qry, 'id', i);
				QuerySetCell(qry, 'title', arguments.strPapers.arrPapers[i].rssTitle[1]);
				QuerySetCell(qry, 'NoOfArticles', arguments.strPapers.arrPapers[i].recordcount);
			}
			
			return qry;
		</cfscript>
		
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getTodaysPapers" access="public" output="true" returntype="struct" hint="Retrieve Today's Papers">
		<cfargument name="bForceRetrieval" 		type="boolean" 	required="false" 	default="false"  hint="">
		<cfargument name="useProxy" 				type="boolean" 	required="false" 	default="false"   >
		 
		<cfscript>
			var strReturn = StructNew(); 
			var qryRss    = queryNew("temp");
			var arrRSSElements    = arrayNew(1);  
		
			// Force retrieval, if specified...
			if (NOT arguments.bForceRetrieval  and StructKeyExists(instance.strPapers, "arrPapers") and ArrayLen(instance.strPapers.arrPapers) gt 0 )
			{
				strReturn = instance.strPapers ;					
			}
			else 
			{
				strReturn.bl=0;
				// Obtain an array of rss feed urls...
				arrRSSElements = XMLSearch( instance.objApp.objRSS.getRSSConfig(), "/rss/feed_url" );
				
				//Clear the array before writing back into it
				instance.strPapers.arrPapers = arrayNew(1);
				
				// Loop through feed rss'
				for ( i=1; i LTE ArrayLen(arrRSSElements); i=i+1 )
				{ 	
					qryRss = instance.objApp.objRSS.readRSS( arrRSSElements[i].XmlText, arrRSSElements[i].XmlAttributes.type, arguments.useProxy );
					If (qryRss.recordcount)
						 	ArrayAppend(instance.strPapers.arrPapers, qryRss);	
				}
					
				//set papers into persistant scope
				strReturn = instance.strPapers;
			}  
	
			return strReturn;
		</cfscript>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getTodaysBusinessPapers" access="public" output="false" returntype="struct" hint="Retrieve Today's Business Papers">
		
		<cfargument name="bFilter" 				type="boolean" 	required="false" 	default="false"  hint="">
		<cfargument name="bForceRetrieval" 		type="boolean" 	required="false" 	default="false"  hint="">
		<cfargument name="section" 				type="string" 	required="false" 	default="business">
		<cfargument name="useProxy" 			type="boolean" 	required="false" 	default="false"  >
		 
		<cfscript>
		
			var strReturn 		  = StructNew(); 
			var qryRss    		  = queryNew("temp"); 
			var arrRSSElements    = arrayNew(1); 
			// Determine whether we need to retrieve the external RSS feeds...
			//if ( DateDiff( "n", variables.strPapers.dLastRetrieved, now() ) GT objRSS.GetRetrievalFrequency() )
				//bRetrieve = true;
	
			// Force retrieval, if specified...
			
			if (NOT arguments.bForceRetrieval  and StructKeyExists(instance.strBusinessPapers, "arrPapers") and ArrayLen(instance.strBusinessPapers.arrPapers) gt 0 )
			{
				strReturn = variables.strPapers ;
			}
			else 
			{
				// Obtain an array of rss feed urls...
				arrRSSElements = XMLSearch( instance.objApp.objRSS.getRSSConfig(arguments.section), "/rss/feed_url" );
				
				//Clear the array before writing back into it
				instance.strBusinessPapers.arrPapers = arrayNew(1);
				
				// Loop through feed rss'
				for ( i=1; i LTE ArrayLen(arrRSSElements); i=i+1 )
				{ 	
					qryRss = instance.objApp.objRSS.readRSS( arrRSSElements[i].XmlText, arrRSSElements[i].XmlAttributes.type, arguments.useProxy );
					if (qryRss.recordcount)
						ArrayAppend(instance.strBusinessPapers.arrPapers, qryRss);	
				}
					
				//set papers into persistant scope
				strReturn = instance.strBusinessPapers;
			}  
	
			return strReturn;
		</cfscript>
		
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getPapersByElement" access="public" output="true" returntype="query" hint="Retrieve Today's Papers">
		<cfargument name="feedType" 			type="string" 	required="true" 	>
		<cfargument name="Element" 				type="numeric" 	required="true" 	>
		
			<cfscript>
			var stPapers	= StructNew(); 
			if (arguments.feedType eq "business")
				stPapers  = getTodaysBusinessPapers();
			else
				stPapers  = getTodaysPapers();
				
			return 	stPapers.arrPapers[arguments.element];
			</cfscript>
			
		</cffunction>
</cfcomponent>