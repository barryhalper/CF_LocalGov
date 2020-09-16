<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/DAOManager.cfc $
	$Author: Bhalper $
	$Revision: 8 $
	$Date: 14/09/10 10:13 $

--->

<cfcomponent displayname="DAOManager"  hint="Data Access Object Manager">
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="any" hint="Pseudo-constructor">
		<cfargument name="strConfig" type="struct" required="yes" hint="structure containing site congig such as dsn">
		
		<cfscript>
			variables.strConfig = arguments.strConfig;
			variables.DSN1 = variables.strConfig.strVars.dsn1;
			variables.DSN2 = variables.strConfig.strVars.dsn2;
			variables.DSN3 = variables.strConfig.strVars.dsn3;
			variables.DSN4 = variables.strConfig.strVars.dsn4;
			variables.DSN5 = variables.strConfig.strVars.dsn5;
			variables.DSN6 = variables.strConfig.strVars.dsn6;
			variables.DSN7 = variables.strConfig.strVars.dsn7;
			variables.DSN8 = variables.strConfig.strVars.dsn8;
			variables.CACHE_TIME = Evaluate(variables.strConfig.strVars.CacheTime);
			variables.NEWS_PRODUCT_IDs = variables.strConfig.strVars.NewsProductIDs;
			
			return this;
		</cfscript>
		
	</cffunction>

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions ------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="query" access="public" returntype="any" output="false">
		<cfargument name="SQLString" type="string" required="yes">
		<cfargument name="Datasource" type="string" required="yes">
		<cfargument name="dbType" type="string" default="">		
		  
		<cfset var RecordSet = "">
		  
		<cfquery name="RecordSet" datasource="#arguments.Datasource#" dbtype="#arguments.dbType#">
			#preserveSingleQuotes(arguments.SQLString)#
		</cfquery>
		 
		<!---AN INSERT OR UPDATE will set qry  to null...  --->
		<cfif NOT IsDefined("variables.RecordSet")>
			<!--- reset value to empty string --->
		  	<cfset RecordSet="">
		</cfif>
		 
		<cfreturn RecordSet>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PRIVATE Functions ----------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->

</cfcomponent>