<!--- 
	
	$Archive: /localgov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/DataAccessObjects/AdsDAO.cfc $
	$Author: Bhalper $
	$Revision: 9 $
	$Date: 12/11/09 10:08 $

	Notes:
		Method naming convention:
		
		1. add<Noun>	- e.g. addArticle()
		2. update<Noun>	- e.g. updateArticle()
		3. delete<Noun>	- e.g. deleteArticle()
		4. get<Noun>	- e.g. getArticle()

--->

<cfcomponent displayname="AdsDAO"  hint="<component description here>" extends="his_Localgov_Extends.components.DAOManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="AdsDAO" hint="Pseudo-constructor">
	
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		StructAppend( variables, Super.init( arguments.strConfig ) );

		return this;
		</cfscript>
		
	</cffunction>

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions: *GET* ----------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<cffunction name="GetAdSelects" returntype="struct" access="public" hint="returns mutilple result sets to be used in the various ad select forms" output="no">
		
		<cfscript>
		var strReturn = StructNew();
		</cfscript>

		<!--- return select list from using SQL stored procedure --->
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_AdFormSelects">
			<!--- Return Companies --->
			<cfprocresult resultset="1" name="strReturn.qryCompanies">
			<!--- Return Positions --->
			<cfprocresult resultset="2" name="strReturn.qryAdPositions">
			<!--- Return Ad Types --->
			<cfprocresult resultset="3" name="strReturn.qryAdTypes">
			<!--- Return Ad Keyword --->
			<cfprocresult resultset="4" name="strReturn.qryAdKeywords">
			<!--- Return Circuits --->
			<cfprocresult resultset="5" name="strReturn.qryCircuits">
			<!--- Return AdLinks --->
			<cfprocresult resultset="6" name="strReturn.qryAdLinks">
			<!--- Return Keyword Ads --->
			<cfprocresult resultset="7" name="strReturn.qryKeywordTitles">
			
		</cfstoredproc>
	
	<cfreturn strReturn>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="GetAllAds" access="public" output="false" returntype="query" hint="returns all ads">
		<cfquery name="qry" datasource="#variables.DSN1#">
			EXEC sp_getAllAds
		</cfquery>
	
		<cfreturn qry>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="GetAdsinSectors" access="public" output="false" returntype="query" hint="returns ads that have sectors">
		
		<cfquery name="qry" datasource="#variables.DSN1#">
			EXEC sp_getAdsinSectors
		</cfquery>
	
		<cfreturn qry>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="GetAdDetails" access="public" output="false" returntype="query" hint="exec SQL to return all data on a specific ad" >	
		<cfargument name="adid" required="yes" type="numeric" >
			
		<cfset var qry ="">		
		
		<cfquery name="qry" datasource="#variables.DSN1#">
			EXEC sp_getAdDetails 
			@AdID		= #arguments.adid#
			</cfquery>
	
		<cfreturn qry>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="GetKeywordAdDetails" access="public" output="false" returntype="query" hint="exec SQL to return all data on a specific keyword ad" >	
		<cfargument name="keyword_id" required="yes" type="numeric" >
			
		<cfset var qry ="">		
		
		<cfquery name="qry" datasource="#variables.DSN1#">
			EXEC sp_getKeywordAd 
			@keyword_id	= #arguments.keyword_id#
			</cfquery>
	
		<cfreturn qry>
	</cffunction>  
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="outputKeywordAd" access="public" output="false" returntype="query" hint="outputs the ad on the localgov website">
		<cfargument 	name="keywords"		required="yes" 	type="string">
		<cfargument 	name="circuit" 		required="yes" 	type="string">

		<cfquery name="qry" datasource="#variables.DSN1#">
			EXEC sp_AdsKeywordSearch 
			@keywords		= '#arguments.keywords#',
			@circuit 		= '#arguments.circuit#'
			</cfquery>
	
		<cfreturn qry>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="AdminSearchAds" access="public" output="true" returntype="query" hint="call method to return results for the keyword ads" >
		<cfargument name="keywords" required="yes" type="string" >

		<cfset var qry ="">		

		<cfquery name="qry" datasource="#variables.DSN1#">
			EXEC sp_AdsKeywordSearch 
			<cfif arguments.keywords eq "">
			@keywords		= <cfqueryparam cfsqltype="cf_sql_varchar" null="true" value="#arguments.keywords#">
			<cfelse>
			@keywords		= '#arguments.keywords#'
			</cfif>
			</cfquery>
	
		<cfreturn qry>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="CommitAd" access="public" output="false" returntype="Numeric" 
	hint="Insert/update ad details">
		
	<cfargument name="AdID" 			required="no"  	type="numeric" default="0">
	<cfargument name="companyID"		required="yes" 	type="numeric">
	<cfargument name="adName" 			required="no" 	type="string" default="">
	<cfargument name="circuitID" 		required="yes" 	type="string">
	<cfargument name="adtypeID"         required="yes" 	type="numeric">
	<cfargument name="positionID" 		required="yes" 	type="numeric">
	<!---<cfargument name="source" 			required="no"  type="string">--->
	<cfargument name="start_date" 		required="yes" 	type="date">
	<cfargument name="end_date" 		required="yes"  type="date">
	<cfargument name="adLink" 			required="yes"  type="string">
	<cfargument name="hid_stickyness" 	required="yes"  type="boolean">
	<cfargument name="topicid" 			required="no"  type="numeric" default="0">
	<cfargument name="sectors" 			required="no"  type="string" default="">
	
	<cfset var sRtnValue = 0>

	<cfstoredproc datasource="#variables.DSN1#" procedure="sp_CommitAd">
		 <cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@AdID" 	   	value="#arguments.AdID#">
		 <cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@companyID" 	value="#arguments.companyID#">
		 <cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@adName" 	value="#arguments.adName#"> 
		 <cfif arguments.circuitID eq "">
		 <cfprocparam type="in"  cfsqltype="cf_sql_varchar"    	dbvarname="@circuitID" null="yes" value="#arguments.circuitID#"> 
		 <cfelse>
		 <cfprocparam type="in"  cfsqltype="cf_sql_varchar"    	dbvarname="@circuitID" 	value="#arguments.circuitID#"> 
		 </cfif>
		 <cfprocparam type="in"  cfsqltype="cf_sql_integer"    	dbvarname="@adtypeID" 	value="#arguments.adtypeID#">
		 <cfprocparam type="in" cfsqltype="cf_sql_integer" 		dbvarname="@positionID" value="#arguments.positionID#"> 
		 <cfprocparam type="in" cfsqltype="cf_sql_timestamp" 	dbvarname="@start_date" value="#CreateODBCDateTime(LSDateFormat(arguments.start_date,'dd/mmm/yyyy') & ' ' & TimeFormat(arguments.start_date, 'HH:mm'))#"> 
		 <cfprocparam type="in" cfsqltype="cf_sql_timestamp" 	dbvarname="@end_date" 	value="#CreateODBCDateTime(LSDateFormat(arguments.end_date,'dd/mmm/yyyy') & ' ' & TimeFormat(arguments.end_date, 'HH:mm'))#">	      	  
		 <cfprocparam type="in" cfsqltype="cf_sql_varchar" 		dbvarname="@adLink" 	value="#arguments.adLink#"> 
		 <cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@stickyness" value="#arguments.hid_stickyness#">
		 <cfif arguments.topicid>
		  	<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@topicid" value="#arguments.topicid#">
		<cfelse>
				<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@topicid" value="" null="yes">	
		 </cfif>
		<cfif Len(arguments.sectors)>
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@sectors" value="#arguments.sectors#">
		<cfelse>
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@sectors" value="" null="yes">
		</cfif>
		
		 <cfprocparam type="out" cfsqltype="cf_sql_integer" 	dbvarname="@NewAdID" Variable="sRtnValue">
	</cfstoredproc>
		
		<cfreturn sRtnValue> 
				
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="CommitKeyword" access="public" output="false" returntype="Numeric" 
	hint="Insert/update keyword ad details">
		
	<cfargument 	name="KeywordAdID" 		required="no"  type="numeric" default="0">
	<cfargument 	name="ADID" 			required="no"  type="numeric" default="0">
	<cfargument 	name="keyword" 			required="yes" type="string">
	<cfargument 	name="companyID"		required="yes" type="numeric">
	<cfargument 	name="circuitID" 		required="yes" type="string">
	<cfargument 	name="start_date" 		required="yes" type="date">
	<cfargument 	name="end_date" 		required="yes"  type="date">
	<cfset var sRtnValue = 0>
	
	<cfstoredproc datasource="#variables.DSN1#" procedure="sp_CommitKeywordAd">
		 <cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@KeywordAdID" 	value="#arguments.KeywordAdID#">
		 <cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@ADID" 			value="#arguments.ADID#">
		 <cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@keyword" 		value="#arguments.keyword#">
		 <cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@companyID" 		value="#arguments.companyID#"> 
		 <cfif arguments.circuitID eq "">
		 	<cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@circuitID" 		null="yes" value="#arguments.circuitID#"> 
		 <cfelse>
		 	<cfprocparam type="in"  cfsqltype="cf_sql_varchar"  dbvarname="@circuitID" 		value="#arguments.circuitID#"> 
		 </cfif>
		 <cfprocparam type="in" cfsqltype="cf_sql_timestamp" 	dbvarname="@start_date" 	value="#CreateODBCDateTime(LSDateFormat(arguments.start_date,'dd/mmm/yyyy') & ' ' & TimeFormat(arguments.start_date, 'HH:mm'))#"> 
		 <cfprocparam type="in" cfsqltype="cf_sql_timestamp" 	dbvarname="@end_date" 		value="#CreateODBCDateTime(LSDateFormat(arguments.end_date,'dd/mmm/yyyy') & ' ' & TimeFormat(arguments.end_date, 'HH:mm'))#">			 		 <cfprocparam type="out" cfsqltype="cf_sql_integer" 	dbvarname="@NewAdID" 		Variable="sRtnValue"> 
	</cfstoredproc>
		
		<cfreturn sRtnValue> 
				
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="Commit_LinkAd" access="public" output="false" returntype="boolean" hint="Inserts the ad/user details when the user hits an ad on the site">
		<cfargument	name="adid"			required="yes"	type="numeric">
		<cfargument name="userid"		required="no"	type="numeric">
		<cfargument name="circuit" 		required="yes" 	type="string">
		<cfargument	name="ipAddress"	required="yes"	type="string">

		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_CommitLinkAd">
			 <cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@ADID" 				value="#arguments.adid#">
			 <cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@USERID" 			value="#arguments.userid#">
			 <cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@CIRCUIT" 			value="#arguments.circuit#">
			 <cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@IPADDRESS" 			value="#arguments.ipAddress#">
		</cfstoredproc>
		<cfreturn true>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="deleteAd" access="public" output="false" returntype="boolean" hint="delete specific ad">
		
		<cfargument name="AdID" type="numeric" required="yes">
		
		<cfstoredproc datasource="#variables.DSN1#" procedure="spDeleteAd">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@AdID" value="#arguments.adid#">
		</cfstoredproc>
		
		<cfreturn true>
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="deleteKeywordAd" access="public" output="false" returntype="boolean" hint="delete specific keyword ad">
		
		<cfargument name="ID" type="numeric" required="yes">
		
		<cfstoredproc datasource="#variables.DSN1#" procedure="spDeleteKeywordAd">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@ID" value="#arguments.id#">
		</cfstoredproc>
		
		<cfreturn true>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions: *DELETE* -------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->

	<cffunction name="GetAdverts" access="public" output="false" returntype="query" hint="exec SQL to return ads " >	
		
		<cfargument name="companyID" 	required="yes" 	type="numeric">
		<cfargument name="adtypeID" 	required="yes" 	type="numeric">
		<cfargument name="positionID" 	required="yes"  type="numeric">
		<cfargument name="circuitID" 	required="yes" 	type="string">
		<cfargument name="end_date" 	required="yes"  type="date">
		<cfargument name="adLink" 		required="yes"  type="string">

		<cfset var qry=QueryNew("temp")>
		
		<cfquery name="qry" datasource="#variables.DSN1#">
		EXEC sp_AdminSearchAdverts
		  <cfif arguments.companyID eq 0>
		  	@CompanyID = <cfqueryparam cfsqltype="cf_sql_integer" null="yes" value="#arguments.companyID#">,
		  <cfelse>
		  	@CompanyID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.companyID#">,
		  </cfif>
		  <cfif arguments.adtypeID eq 0>
		  	@adtypeID = <cfqueryparam cfsqltype="cf_sql_integer" null="yes" value="#arguments.adtypeID#">,
		  <cfelse>
		  	@adtypeID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.adtypeID#">,
		  </cfif>
		  <cfif arguments.positionID eq 0>
		  	@positionID = <cfqueryparam cfsqltype="cf_sql_integer" null="yes" value="#arguments.positionID#">,
		  <cfelse>
		  	@positionID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.positionID#">,
		  </cfif>
		  <cfif arguments.circuitID eq "">
		  	@circuitID = <cfqueryparam cfsqltype="cf_sql_varchar" null="yes" value="#arguments.circuitID#">,
		  <cfelse>
		  	@circuitID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.circuitID#">,
		  </cfif>
		  	@enddate = <cfqueryparam cfsqltype="cf_sql_date" value="#CreateODBCDateTime(LSDateFormat(arguments.end_date,'dd/mmm/yyyy') & ' ' & TimeFormat(arguments.end_date, 'HH:mm'))#">,
			<cfif arguments.adLink eq 0>
		  	@adLink = <cfqueryparam cfsqltype="cf_sql_varchar" null="yes" value="#arguments.adLink#">
		  <cfelse>
		  	@adLink = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.adLink#">
		  </cfif>
		</cfquery>
		
		<cfreturn qry>
	</cffunction>  
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="GetSectorsAdverts" access="public" output="false" returntype="query" hint="exec SQL to return ads " >	
		
		<cfargument name="companyID" 	required="yes" 	type="numeric" default="0">
		<cfargument name="positionID" 	required="yes"  type="numeric" default="0">	
		
		<cfargument name="adLink" 		required="yes"  type="string"  default="">
		<cfargument name="end_date" 	required="yes"  type="date"    >

		<cfset var qry=QueryNew("temp")>
		
		
		<cfquery name="qry" datasource="#variables.DSN1#">
		EXEC sp_AdminSearchSectorAdverts
		 
		  	@CompanyID = <cfif arguments.companyID>#arguments.companyID#<cfelse>NULL</cfif>,
		  	@positionID = <cfif arguments.positionID>#arguments.positionID#<cfelse>NULL</cfif>,
		  	@enddate =    '#arguments.end_date#',
		  	@adLink =     <cfif Len(arguments.adLink) and arguments.adLink  neq '0'>#arguments.adLink#<cfelse>NULL</cfif>
		</cfquery>
		
		<cfreturn qry>
	</cffunction>  
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="saveAdViews" access="public" output="false" returntype="boolean" hint="delete specific ad">		
		<cfargument name="adviews" type="query" required="yes">
		<cfset sql_to_run = "">
		
		<cfloop query="arguments.adviews">
			<cfif Len(adid) and IsNumeric(adid)>
			<cfset sql_to_run = sql_to_run & " INSERT INTO  tblAdViews (f_ad_id,circuit,date_viewed,remote_host) VALUES (#adid#, '#circuit#', #CreateODBCDateTime(LSDateFormat(vieweddate,'dd/mmm/yyyy') & ' ' & TimeFormat(vieweddate, 'HH:mm'))#, '#remote_host#');">
			</cfif>
		</cfloop>
		
		<cftry>
		<cfquery datasource="#variables.DSN1#">
			#preservesinglequotes(sql_to_run)#
		</cfquery>
			<cfcatch type="database">
				
			</cfcatch>
		</cftry>
		<cfreturn true>
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="GetAdvertViews" access="public" output="false" returntype="query" hint="exec SQL to return ad views " >
		<cfargument name="adid" type="numeric" required="no" default="0">
		<cfargument name="justcount" type="numeric" required="no" default="0">
		
		<cfquery name="qry" datasource="#variables.DSN1#">
			EXEC sp_AdminGetAdViews @adid = #arguments.adid#, @justCount = #arguments.justcount#
		</cfquery>
		
		<cfreturn qry>
	</cffunction>  
	
</cfcomponent>