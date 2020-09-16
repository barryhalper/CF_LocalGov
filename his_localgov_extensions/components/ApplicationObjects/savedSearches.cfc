<cfcomponent hint="component to manage saved searches" extends="his_Localgov_Extends.components.ApplicationManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="savedSearches" hint="Pseudo-constructor">
		
		
		<cfargument name="objUtils"  type="any" 	required="yes">
		<cfargument name="objString" type="any" 	required="yes" >
		<cfargument name="strConfig" type="struct" 	required="yes">
		
		<cfscript>
		variables.objUtils  = arguments.objUtils;
		variables.objString = arguments.objString;
		variables.strConfig = arguments.strConfig;
		return this;
		</cfscript>
		
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions --------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getVariables" access="public" output="false" returntype="struct" hint="">
		<cfreturn variables>
	</cffunction>
	
	 <cffunction name="isMaxSaved" access="public" output="false" returntype="boolean" hint="Return true if user has not exceeded the maximum numer of saved searches">
		<cfargument name="strSession" required="yes" type="struct" hint="session scope">
		<cfscript>
		bl = true;
		if (structKeyExists(arguments.strSession.UserDetails, "arrSavedSearches") AND arrayLen(arguments.strSession.UserDetails.arrSavedSearches) gte variables.strConfig.strVars.max_savesearches)
			bl = false;
		return bl;
		</cfscript>
	</cffunction> 
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="saveSearch" access="public" returntype="boolean" output="false" hint="save search criteria into session">
	<cfargument name="strSession" required="yes" type="struct" hint="session scope">
	<cfargument name="SearchName" required="yes" type="string" hint="name of search">
	<cfargument name="fbx_method" required="yes" type="string" hint="">
	 
		<cfscript>
		var strSaveSearch = StructNew();
		var blreturn =true;
		var strForm ="";
		if (StructKeyExists(arguments.strSession, "strSavedSearch")){
		//create structure to store saved search  
			strForm = duplicate(arguments.strSession.strSavedSearch);
			//set vars into saved search
			strSaveSearch.searchName = arguments.SearchName;
			strSaveSearch.fbx_method = arguments.fbx_method;
			strSaveSearch.dateSaved = Now();;
			//set struct into qry string and save in str
			strSaveSearch.querystring = variables.Objstring.Struct2QueryString(strForm);
			//check if array is present in session
			if (NOT StructKeyExists(arguments.strSession.UserDetails, "arrSavedSearches"))
			//create array
				arguments.strSession.UserDetails.arrSavedSearches = ArrayNew(1);
			//plase saved search str into array session
			ArrayAppend(arguments.strSession.UserDetails.arrSavedSearches, strSaveSearch);
			}
		else
		blreturn =false;
			
		return blreturn;
		</cfscript>	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="removeSaveSearch" access="public" returntype="boolean" output="false" hint="remove save searches from session">
		<cfargument name="strSession" required="yes" type="struct" hint="session scope">
		<cfargument name="SearchName" required="yes" type="string" hint="name of search">
		 <cfscript>
			var i = 0;
			for (i=1;i LTE arrayLen(arguments.strSession.UserDetails.arrSavedSearches);i=i+1 ){
				If (arguments.strSession.UserDetails.arrSavedSearches[i].searchname eq arguments.SearchName)
					ArrayDeleteAt(arguments.strSession.UserDetails.arrSavedSearches, i);
			}
			return true;
		 </cfscript>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="SaveSearches2Query" access="public" returntype="query" output="false" hint="return a query object of all searches and url varibales">
			<cfargument name="strSession" required="yes" type="struct" hint="session scope">
				
				<cfscript>
				var i=0;
				var qrySavedSearches=QueryNew("Searchname,fbx_method,querystring,dateSaved");
				
				if (StructKeyExists(arguments.strSession.UserDetails, "arrSavedSearches") and ArrayLen(arguments.strSession.UserDetails.arrSavedSearches)){
				//loop over arry to get saved searches
				for (i=1;i LTE arrayLen(arguments.strSession.UserDetails.arrSavedSearches);i=i+1 ){
				    //create a row in qry for each saved search
					QueryAddRow(qrySavedSearches);
					QuerySetCell(qrySavedSearches, "Searchname", arguments.strSession.UserDetails.arrSavedSearches[i].searchname);
					QuerySetCell(qrySavedSearches, "fbx_method", arguments.strSession.UserDetails.arrSavedSearches[i].fbx_method);
					QuerySetCell(qrySavedSearches, "querystring", arguments.strSession.UserDetails.arrSavedSearches[i].querystring);		
					QuerySetCell(qrySavedSearches, "dateSaved", arguments.strSession.UserDetails.arrSavedSearches[i].dateSaved);		
					qrySavedSearches = variables.objUtils.QueryOfQuery(qrySavedSearches, "*", "0=0 Order By Searchname");	
					
					}
				}	
				return qrySavedSearches;	
				</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->

</cfcomponent>

