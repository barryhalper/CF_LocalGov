<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/BusinessObjects/Guides.cfc $
	$Author: Bhalper $
	$Revision: 3 $
	$Date: 18/12/07 12:05 $

--->

<cfcomponent displayname="Guides" hint="Procurement guide-related business object functions" extends="his_Localgov_Extends.components.BusinessObjectsManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Guides" hint="Pseudo-constructor">
	
		<cfargument name="objAppObjs" type="any" required="yes" hint="The application manager object">
		
		<cfscript>
		// Call the genric init function, placing business, app, and dao objects into a local scope...
		StructAppend( variables, Super.initChild( arguments.objAppObjs, this ) );
		//variables.strSelects=SetFormSelects();
		return this;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions ------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="SetFormSelects" access="public" returntype="struct" output="false" hint="get all qry used to create froms "> 
				<cfreturn objDAO.FormSelects()>
	</cffunction>
	
	<cffunction name="GetFormSelects" access="public" returntype="struct" output="false" hint="get all qry used to create froms "> 
				<cfreturn Variables.strSelects>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="SearchCompanies" access="public" returntype="query"  output="false" hint="search for companies"> 
		
		<cfargument name="Keyword"    type="string" required="no" default="">
		<cfargument name="CategoryID" type="string" required="no" default="">
		<cfargument name="ProductID"  type="string" required="no" default="">
			<cfreturn ObjDAO.SearchCompanies(argumentcollection=arguments)>	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="SearchCompaniesByProduct" access="public" returntype="query"  output="false" hint="search for companies by a single product"> 
		<cfargument name="Product"    type="string" required="no" default="">
		<cfreturn ObjDAO.SearchCompaniesByProduct(arguments.Product)>	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="CompanyDetails" access="public" returntype="struct"  output="false" hint="return structure that contains mutiple resultsets for a compnay's details" > 
		 <cfargument name="OrganistaionID" type="numeric" required="yes" > 			
				<cfreturn ObjDAO.CompanyDetails(argumentcollection=arguments)>	
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="AssocCompanies" access="public" returntype="struct"  output="false" hint="return structure that contains mutiple resultsets for a compnay's details">
			<cfargument name="OrganistaionID" type="numeric" required="yes">
				<cfreturn objDAO.AssocCompanies(argumentcollection=arguments)>			
	</cffunction>
		

</cfcomponent>