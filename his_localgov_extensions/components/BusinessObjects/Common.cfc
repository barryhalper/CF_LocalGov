<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/COMPONENTS/BusinessObjects/Common.cfc $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 8/08/07 10:06 $

--->

<cfcomponent displayname="Common" hint="Functions related to events" extends="his_Localgov_Extends.components.BusinessObjectsManager">

	<!--- -------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR -------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Common" hint="Pseudo-constructor">
	
		<cfargument name="objAppObjs" type="any" required="yes" hint="The application manager object">

		<cfscript>
		// Call the genric init function, placing business, app, and dao objects into a local scope...
		StructAppend( variables, Super.initChild( arguments.objAppObjs, this ) );	
		variables.qryProducts=getProducts();
		return this;
		</cfscript>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions --------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getVariables" access="public" output="false" returntype="struct" hint="return local scope">
		<cfreturn variables>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getqryProducts" access="public" output="false" returntype="query" hint="return query that holds products">
		<cfreturn variables.qryproducts>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getCommonFields" access="public" output="false" returntype="struct" hint="">
		<cfreturn objDAO.getCommonFields()>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getProducts" access="public" output="false" returntype="query" hint="call method to get all products relavent to this application">
		<cfreturn objDAO.getProducts(variables.strConfig.strVars.newsproductids)>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getCircuits" access="public" output="false" returntype="query" hint="returns a query containing system circuits">
		<cfreturn objDAO.getCircuits(variables.strConfig.strVars.productid)>
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getMID" access="public" output="true" returntype="numeric" hint="returns the mid id. The function takes three arguments: CGI.QUERY_STRING, Attributes structure, myfusebox.originalcircuit name">
		<cfargument name="strQueryString" required="yes" type="string" hint="contains the query string">
		<cfargument name="strAttr" required="yes" type="struct" hint="struct of attribute data">
		<cfargument name="origcircuit" type="string" required="yes" hint="The name of the origianl circuit">
		
		<cfset var midID = 0>
		<!--- If mid id is not present in the query string and the mid key exists in the attributes structure, then loop through the top level menu items list and set the mid id --->
		<cfif NOT Find('mid', arguments.strQueryString) AND StructKeyExists(arguments.strAttr, 'mid') AND arguments.strAttr.mid EQ 1>
			<cfloop list="#request.strSiteConfig.TopMenuList[request.menutype]#" index="i">
				<cfif FindNoCase(":#arguments.origcircuit#",i)>
					<cfset midID = Left(i, FindNoCase(":#arguments.origcircuit#",i)-1)>
				</cfif>
			</cfloop>
			<cfif midID EQ "">
				<cfset midID = 1>
			</cfif>
		<!--- If mid id is not present in the query string and the attributes structure, then loop through the top level menu items list and set the mid id --->	
		<cfelseif NOT Find('mid', arguments.strQueryString) AND NOT StructKeyExists(arguments.strAttr, 'mid')>
			<cfloop list="#request.strSiteConfig.TopMenuList[request.menutype]#" index="i">
				<cfif FindNoCase(":#arguments.origcircuit#",i)>
					<cfset midID = Left(i, FindNoCase(":#arguments.origcircuit#",i)-1)>
				</cfif>
			</cfloop>
			<cfif midID EQ "">
				<cfset midID = 1>
			</cfif>
		<cfelse>
			<cfset midID = arguments.strAttr.mid>
		</cfif>
		<cfreturn midID>
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
</cfcomponent>