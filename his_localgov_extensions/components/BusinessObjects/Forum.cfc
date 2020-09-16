<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/COMPONENTS/BusinessObjects/Forum.cfc $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 8/08/07 10:06 $

--->

<cfcomponent displayname="Forum" hint="<component description here>" extends="his_Localgov_Extends.components.BusinessObjectsManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Forum" hint="Pseudo-constructor">
	
		<cfargument name="objAppObjs" type="any" required="yes" hint="The application manager object">

		<cfscript>
		// Call the genric init function, placing business, app, and dao objects into a local scope...
		StructAppend( variables, Super.initChild( arguments.objAppObjs, this ) );
		
		return this;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions ------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="F1" access="public" output="false" returntype="string" hint="<description>">
		
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