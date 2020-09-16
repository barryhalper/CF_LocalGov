<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/COMPONENTS/DataAccessObjects/CommonDAO.cfc $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 8/08/07 10:06 $

--->

<cfcomponent displayname="CommonDAO" hint="" extends="his_Localgov_Extends.components.DAOManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="CommonDAO" hint="Pseudo-constructor">
	
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		StructAppend( variables, Super.init( arguments.strConfig ) );

		return this;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions: ----------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetCommonFields" access="public" output="false" returntype="struct" hint="">

		<cfset var strRecordSet = StructNew()>
		
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_GetCommonFields">
			<cfprocresult resultset="1" name="strRecordSet.qrySalutations"> 
			<cfprocresult resultset="2" name="strRecordSet.qryCounties"> 
			<cfprocresult resultset="3" name="strRecordSet.qryCountries"> 
		</cfstoredproc>	
		
		<cfreturn strRecordSet>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetProducts" access="public" output="false" returntype="query" hint="get all products relavent to this application">
		<cfargument name="Productid" required="yes" type="string">
		
		<cfset var qry = "">
		
		<cfquery datasource="#variables.DSN1#" name="qry">
		EXEC sp_GetHisProducts
			'#arguments.Productid#'
		</cfquery>	
		
		<cfreturn qry>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetCircuits" access="public" output="false" returntype="query" hint="returns a query containing system circuits">
		<cfargument name="Productid" required="yes" type="string">
		<cfset var qryCircuits = "">
		
		<cfquery datasource="#variables.DSN1#" name="qryCircuits">
		EXEC sp_GetCircuits
			'#arguments.Productid#'
		</cfquery>	
		
		<cfreturn qryCircuits>
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->

</cfcomponent>