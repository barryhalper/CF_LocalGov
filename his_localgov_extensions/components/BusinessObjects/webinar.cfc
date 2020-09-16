<cfcomponent displayname="Webinar" hint="Webinar-related business object functions" extends="his_Localgov_Extends.components.BusinessObjectsManager">

	<!--- -------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR -------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Webinar" hint="Pseudo-constructor">
	
		<cfargument name="objAppObjs" 		type="any" 	   required="yes" hint="The application manager object">
		<cfargument name="objBusObjs" type="any" required="yes" hint="The application manager object">
		
		<cfscript>
			// Call the genric init function, placing business, app, and dao objects into a local scope...
				StructAppend( variables, Super.initChild( arguments.objAppObjs, this, arguments.objBusObjs ) );
	
			return this;
		</cfscript>
				
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="GetDetails" access="public" output="false" returntype="query" hint="return details of specified Webinar">
		<cfargument name="WebinarID" type="numeric" required="yes">
		
		<cfreturn objDAO.GetDetails(arguments.WebinarID)> 
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="Commit" access="public" output="false" returntype="numeric" hint="Save User Interest in Specified Webinar">
		<cfargument name="id" 				type="numeric" 	required="no" default="0">
		<cfargument name="webinarName" 		type="string" 	required="yes">
		<cfargument name="WebinarDate" 		type="date" 	required="yes">
		<cfargument name="organisation" 	type="string" 	required="yes">
		<cfargument name="urlID" 			type="numeric" 	required="yes">
		<cfargument name="newsid" 			type="numeric" 	required="yes">
	
		<cfreturn objDAO.Commit(argumentCollection=arguments)> 
	</cffunction>
	
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="SaveInterest" access="public" output="false" returntype="void" hint="Save User Interest in Specified Webinar">
		<cfargument name="WebinarID" 	type="numeric" 	required="yes">
		<cfargument name="WebinarName" 	type="string" 	required="yes">
		<cfargument name="UserID" 		type="numeric" 	required="yes">
		<cfargument name="strUser" 		type="struct" 	required="yes">
		<cfargument name="objEmail"		type="any"		required="yes">
		<cfargument name="WebinarDate"	type="date"	required="yes">
		
		
		<cfset objDAO.SaveInterest(argumentCollection=arguments)> 
		
		<cfset arguments.objEmail.SendWebinarConfirmationEmail(argumentCollection=arguments)>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	
	<cffunction name="hasSignedUp" access="public" output="false" returntype="boolean" hint="evalues if user has signed u for this webinar return tue or false">
		<cfargument name="UserID" type="numeric" required="yes">
		<cfargument name="WebinarID" type="numeric" required="yes">
		
		<cfscript>
		var bl = false;
		if (GetRegistrations(arguments.UserID, arguments.WebinarID).recordcount)
			bl = true;
			
		return bl;	
		</cfscript>
		
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="GetRegistrations" access="public" output="false" returntype="query" hint="Get details of all the Webinars the User has registered for">
		<cfargument name="UserID" type="numeric" required="yes">
		<cfargument name="WebinarID" type="numeric" required="yes">
		
		<cfreturn objDAO.GetRegistrations(arguments.UserID, arguments.WebinarID)> 
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="list" access="public" output="false" returntype="query" hint="list all webinars">
			<cfreturn objDAO.list()> 
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getUsers" access="public" output="false" returntype="query" hint="list all users by webinar">
		<cfargument name="WebinarID" 	type="numeric" 	required="yes">
			<cfreturn objDAO.getUsers(arguments.WebinarID)> 
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="saveDateVisited" access="public" output="false" returntype="void" hint="executed last visted date stamp for a user agais a webinar">
			<cfargument name="WebinarID" 	type="numeric" 	required="yes">
			<cfargument name="UserID" 		type="numeric" 	required="yes">
		
		<cfset objDAO.saveDateVisited(arguments.WebinarID, arguments.UserID)> 
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
</cfcomponent>