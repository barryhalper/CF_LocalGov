<cfcomponent displayname="Correspondence" hint="Correspondence-related business functions" extends="his_Localgov_Extends.components.BusinessObjectsManager">
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR -------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Correspondence" hint="Pseudo-constructor">
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
	<cffunction name="GetInfoCorrespondenceByUser" access="public" output="false" returntype="Query" hint="Return a Correspondence record">
		<cfargument name="UserID" type="numeric" 	required="yes">
		
		<cfreturn objDAO.GetInfoCorrespondenceByUser(userid=arguments.userid)>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetCorrespondenceByID" access="public" output="false" returntype="Query" hint="Return a Correspondence record">
		<cfargument name="CorrespondenceID" type="numeric" 	required="yes">
		
		<cfreturn objDAO.GetCorrespondenceByID(argumentCollection=arguments)>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="SaveCorrespondence" access="public" output="false" returntype="numeric" hint="Save Correspondence to db">
		<cfargument name="CorrespondenceID"		type="Numeric"	required="no" default="0">
		<cfargument name="UserID" 				type="Numeric" 	required="yes">
		<cfargument name="ToAddress" 			type="String" 	required="yes">
		<cfargument name="SubscriptionID" 		type="Numeric" 	required="yes">
		<cfargument name="SubscriptionPeriodID" type="Numeric" 	required="yes">
		<cfargument name="EmailID"				type="Numeric"	required="yes">
		<cfargument name="HTMLEmail"			type="String"	required="yes">
		<cfargument name="DateSent"				type="String"	required="yes">
		
		<cfreturn objDAO.SaveCorrespondence(argumentCollection=arguments)>			
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="DeleteCorrespondence" access="public" output="false" returntype="void" hint="Delete Correspondence from db">
		<cfargument name="CorrespondenceID"	type="numeric" 	required="no">
		
		<cfreturn objDAO.DeleteCorrespondence(arguments.CorrespondenceID)>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="GetAllCorrespondence" access="public" output="false" returntype="query" hint="return all Correspondence">
		<cfreturn objDAO.GetAllCorrespondence()>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
</cfcomponent>