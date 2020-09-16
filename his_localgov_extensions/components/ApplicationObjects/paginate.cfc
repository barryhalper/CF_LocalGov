<cfcomponent displayname="paginate" hint="function for paginating through recordset" extends="his_Localgov_Extends.components.ApplicationObjects.utils">
	<!--- --------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- --------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- --------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getPagination" returntype="struct" access="public" hint="call method to set up pagination and return private data">
		<cfargument name="QueryRecordCount" 	type="numeric" required="true" hint="CF query object 'recordcount'">
		<cfargument name="RowsPerPage" 			type="numeric" required="true" hint="The number of rows to be displayed by the page">
		<cfargument name="StartRow" 			type="numeric" required="true" hint="The value of the row which the page begins at">
		<cfargument name="link" 				type="string"  required="true">
		<cfargument name="querystring" 			type="string"  required="true">
		<cfargument name="queryStringDelimeter" type="string"  required="false" default="?">
		
		<cfscript>
			var strPageNo				= StructNew();
			var strPagination 			= setPagination(argumentCollection=arguments);
			strPagination.link 			= arguments.link & arguments.querystringdelimeter & setQueryString(arguments.querystring);
			strPagination.arrPageNo 	= ArrayNew(1);
			
			//super.dumpabort(arguments);
			if (arguments.QueryRecordCount){
				
				strPageNo					= getPageByPageLinks(strPagination, arguments.StartRow);
				strPagination.arrPageNo	    = strPageNo.arrPageNo;
				
				if(isDefined('strPageNo.thispage'))
				{
					strPagination.getPage		= strPageNo.thispage;
				}
				
				getPageByPageGroups(strPagination);
			}
			
			return  strPagination;
		</cfscript>
	
	</cffunction>
	<!--- --------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- --------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- --------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="setPagination" access="private" returntype="struct" hint="Allows clients to navigation through a recordset ">
		<cfargument name="QueryRecordCount" type="numeric" required="true" hint="CF query object 'recordcount'">
		<cfargument name="RowsPerPage" 		type="numeric" required="true" hint="The number of rows to be displayed by the page">
		<cfargument name="StartRow" 		type="numeric" required="true" hint="The value of the row which the page begins at">		
		
		<cfreturn Super.Pagination(argumentCollection=arguments)>
	</cffunction>
	<!--- --------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- --------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- --------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="setQueryString" access="private" returntype="string" output="false" hint="remove words that may cause problems in query string">
		<cfargument name="query_string" type="string" required="true">
		
		<cfscript>
			var i =0;
			var queryString = arguments.query_string;
			var arrQueryString = ListToArray(queryString, "&");
			
			//loop over query string
			for (i=1; i lte ArrayLen(arrQueryString);i=i +1){
				//If element contains startrow remove form list 
				If (arrQueryString[i] contains "startrow" ){
					queryString = ListDeleteAt(queryString, i, "&");	
					break;}
			}
			return queryString;
		</cfscript>
		 	
	</cffunction>
	<!--- --------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- --------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- --------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getPageByPageLinks" access="public" returntype="struct" hint="allow client to browse recordset, page by page">
		<cfargument name="strPagination" type="struct" required="true" hint="struct that hold pagination vars">
		
		<cfscript>
			var strReturn 	= structNew();
			var PageNo 		= 1;
			var i 			= 0;
			var rowsThisPage = arguments.strPagination.TotalRows - arguments.strPagination.StartRow;
			
			strReturn.arrPageNo 	= arrayNew(1);
			
			//begin loop
			for (i=1; i lte(arguments.strPagination.TotalRows); i=i+arguments.strPagination.RowsPerPage)
			{
				if (i gte arguments.strPagination.StartRow AND i LTE arguments.strPagination.EndRow)
				{
					//user is on 1st page
					arrayAppend(strReturn.arrPageNo, PageNo);
					strReturn.thispage = PageNo;
				}
				else
				{
					//set next no into array
					arrayAppend(strReturn.arrPageNo, '<a href="#strPagination.link#&amp;StartRow=#i#">#PageNo#</a>' );
				}
				//increment no.
				PageNo =  PageNo + 1;	
						
			}
			return  strReturn;
		</cfscript>
	
	</cffunction>
	<!--- --------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- --------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- --------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getPageByPageGroups" access="public" returntype="void" hint="create page relevant page no's for client">
		<cfargument name="strPagination" type="struct" required="true" hint="struct that hold pagination vars">
		
		<cfscript>
			//Determine the very final page of results
			var finalPage = Ceiling((arguments.strPagination.totalRows/arguments.strPagination.rowsPerPage));
			
			//Set up default values for first page and last page in displayed links
			arguments.strPagination.firstNo = 1 ;
			arguments.strPagination.lastNo =  5;
			
			/**
				If the number of pages needed to display all the results is less than 5 pages,
				set the last page link to the final page
			**/
			//If ((arguments.strPagination.totalRows/arguments.strPagination.rowsPerPage) LT 5) {
			if (finalPage LT 5) {
				arguments.strPagination.lastNo =  finalPage;
			}
					
			/**
				Otherwise determine first page link and last page link for display depending
				on the page the user has requested 
			**/
			else {	
			
				//Scenario getPage = 1 or 6 or 11 etc...
				if (arguments.strPagination.getpage Mod 5 eq 1){
					arguments.strPagination.firstNo = arguments.strPagination.getpage ;
					
					//If there are enough results to display on an additional 4 pages
					if((arguments.strPagination.getpage + 4) LTE finalPage)
					{
						arguments.strPagination.lastNo =  arguments.strPagination.getpage + 4;
					}
					//Otherwise, the last page link is the final page
					else
					{
						arguments.strPagination.lastNo =  finalPage;
					}
					
						
				}
				
				//Scenario getPage = 2 or 7 or 12 etc...
				else
				if (arguments.strPagination.getpage Mod  5 eq 2){
					arguments.strPagination.firstNo = arguments.strPagination.getpage - 1;
					//arguments.strPagination.lastNo =  arguments.strPagination.getpage + 3;
					
					//If there are enough results to display on an additional 3 pages
					if((arguments.strPagination.getpage + 3) LTE finalPage)
					{
						arguments.strPagination.lastNo =  arguments.strPagination.getpage + 3;
					}
					//Otherwise, the last page link is the final page
					else
					{
						arguments.strPagination.lastNo =  finalPage;
					}
				}
				
				//Scenario getPage = 3 or 8 or 13 etc...
				else
				if (arguments.strPagination.getpage Mod 5 eq 3){
					arguments.strPagination.firstNo = arguments.strPagination.getpage - 2;
					//arguments.strPagination.lastNo =  arguments.strPagination.getpage + 2;
					
					//If there are enough results to display on an additional 2 pages
					if((arguments.strPagination.getpage + 2) LTE finalPage)
					{
						arguments.strPagination.lastNo =  arguments.strPagination.getpage + 2;
					}
					//Otherwise, the last page link is the final page
					else
					{
						arguments.strPagination.lastNo =  finalPage;
					}
				}	
				
				//Scenario getPage = 4 or 9 or 14 etc...
				else
				if (arguments.strPagination.getpage Mod 5 eq 4){
					arguments.strPagination.firstNo = arguments.strPagination.getpage - 3;
					//arguments.strPagination.lastNo  = arguments.strPagination.getpage + 1;	
					
					//If there are enough results to display on an additional page
					if((arguments.strPagination.getpage + 1) LTE finalPage)
					{
						arguments.strPagination.lastNo =  arguments.strPagination.getpage + 1;
					}
					//Otherwise, the last page link is the final page
					else
					{
						arguments.strPagination.lastNo =  finalPage;
					}
				}
					
				//Scenario getPage = 5 or 10 or 15 etc...
				else
				//page clicked is a multipe of 5
				if (arguments.strPagination.getpage MOD 5 eq 0){
					arguments.strPagination.firstNo = arguments.strPagination.getpage - 4;
					arguments.strPagination.lastNo  = arguments.strPagination.getpage; 
				}
			}
			//return 	arguments.strPagination;	
			//dumpabort(arguments.strPagination.getpage MOD 5);
		 
		</cfscript>
	
	</cffunction>
	<!--- --------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- --------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- --------------------------------------------------------------------------------------------------------------------------------------------->
	
</cfcomponent>