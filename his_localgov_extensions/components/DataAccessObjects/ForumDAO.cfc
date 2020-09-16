<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/COMPONENTS/DataAccessObjects/ForumDAO.cfc $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 8/08/07 10:06 $

	Notes:
		Method naming convention:
		
		1. add<Noun>	- e.g. addArticle()
		2. update<Noun>	- e.g. updateArticle()
		3. delete<Noun>	- e.g. deleteArticle()
		4. get<Noun>	- e.g. getArticle()

--->

<cfcomponent displayname="ForumDAO" hint="<component description here>" extends="his_Localgov_Extends.components.DAOManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="ForumDAO" hint="Pseudo-constructor">
	
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		StructAppend( variables, Super.init( arguments.strConfig ) );

		return this;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions: *ADD* ----------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="addF1" access="public" output="false" returntype="string" hint="<description>">
		
		<cfargument name="A1" type="string" default="1">
		<cfargument name="A2" type="string" default="1">

		<cfscript>
		// Local variable declarations...
		var sRtnValue = "";

		// ...code...		
		
		return sRtnValue;		
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions: *UPDATE* -------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="updateF1" access="public" output="false" returntype="string" hint="<description>">
		
		<cfargument name="A1" type="string" default="1">
		<cfargument name="A2" type="string" default="1">

		<cfscript>
		// Local variable declarations...
		var sRtnValue = "";

		// ...code...		
		
		return sRtnValue;		
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions: *GET* ----------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getF1" access="public" output="false" returntype="string" hint="<description>">
		
		<cfargument name="A1" type="string" default="1">
		<cfargument name="A2" type="string" default="1">

		<cfscript>
		// Local variable declarations...
		var sRtnValue = "";

		// ...code...		
		
		return sRtnValue;		
		</cfscript>
		
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions: *DELETE* -------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="deleteF1" access="public" output="false" returntype="string" hint="<description>">
		
		<cfargument name="A1" type="string" default="1">
		<cfargument name="A2" type="string" default="1">

		<cfscript>
		// Local variable declarations...
		var sRtnValue = "";

		// ...code...		
		
		return sRtnValue;		
		</cfscript>
		
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PRIAVTE Functions ----------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="F2" access="private" output="false" returntype="string" hint="<description>">
	
		<cfargument name="A1" type="string" default="1">
		<cfargument name="A2" type="string" default="1">

		<cfscript>
		// Local variable declarations...
		var sRtnValue = "";

		// ...code...		
		
		return sRtnValue;		
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->

</cfcomponent>