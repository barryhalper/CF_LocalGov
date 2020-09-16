<cfcomponent displayname="Letter" hint="Letter-related business functions" extends="his_Localgov_Extends.components.BusinessObjectsManager">
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR -------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Letter" hint="Pseudo-constructor">
		<cfargument name="objAppObjs" type="any" required="yes" hint="The application objects">
		<cfargument name="objBusObjs" type="any" required="yes" hint="The business objects">
		
		<cfscript>
		// Call the genric init function, placing business, app, and dao objects into a local scope...
		StructAppend( variables, Super.initChild( arguments.objAppObjs, this ) );
		//variables.strAdSelects = GetAdSelects();
		
		return this;
		</cfscript>
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getInstance" access="public" returntype="struct">
		<cfreturn instance>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetLetterByID" access="public" output="false" returntype="Query" hint="return a single letter">
		<cfargument name="LetterID" type="numeric" required="yes">
		
		<cfreturn objDAO.GetLetterByID(arguments.LetterID)>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="SaveLetter" access="public" output="false" returntype="numeric" hint="Save Letter to db">
		<cfargument name="LetterID" 		type="numeric" 	required="no">
		<cfargument name="LetterTitle" 		type="string" 	required="yes">
		<cfargument name="LetterContent" 	type="string" 	required="yes">
		
		<cfreturn objDAO.SaveLetter(argumentCollection=arguments)>
			
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="DeleteLetter" access="public" output="false" returntype="void" hint="Delete letter from db">
		<cfargument name="LetterID" 		type="numeric" 	required="no">
		
		<cfreturn objDAO.DeleteLetter(arguments.LetterID)>
		
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="GetLookups" access="public" output="false" returntype="struct" hint="return necessary data to populate select menus">
		<cfargument name="refresh" type="boolean" default="false">
		
		<cfscript>
			var strLookUps=StructNew();
			if (StructKeyExists(instance, "strLookUps") and NOT arguments.refresh) 
				strLookUps = instance.strLookUps;
			else{
				strLookUps = instance.objDAO.GetLookups();
				instance.strLookUps = strLookUps;
				}
			return strLookUps;
		</cfscript>
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="GetAllLetters" access="public" output="false" returntype="query" hint="return all letters">
		<cfreturn objDAO.GetAllLetters()>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
</cfcomponent>