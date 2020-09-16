<cfcomponent  displayname="StatsDAO" hint="Statistics data access methods" extends="his_Localgov_Extends.components.DAOManager">
	<!--- ------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="StatsDAO" hint="Pseudo-constructor">
	
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		StructAppend( variables, Super.init( arguments.strConfig ) );
		
		return this;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="uploadLog" returntype="boolean" hint="Call db to run DTS and upload log ">
	
		<cfset var qryUpload = "">
		<cfquery datasource="#variables.DSN4#" name="qryUpload">
			EXEC sp_DTS_UploadServerLog
		</cfquery>
		
		<cfreturn true>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetIpAddresses" returntype="query" hint="get all ip address that have no domain name">
		<cfset var qryIP = "">
		
		<cfquery datasource="#variables.DSN4#" name="qryIP">
			EXEC sp_getUnkownIpAddress
		</cfquery>
		
		<cfreturn qryIP>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="InsertRequestReport" returntype="void" hint="">
		
		<cfquery datasource="#variables.DSN4#" >
			EXEC sp_InsertRequestReport
		</cfquery>
		
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="DeleteSeverLogs" returntype="void" hint="">
		
		<cfquery datasource="#variables.DSN4#" >
			EXEC sp_TruncateServerLogs
		</cfquery>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="AdminSearchStats" access="public" returntype="query"  hint="">
		<cfargument name="keyword" 	 required="yes" type="string">
		<cfargument name="startDate" required="yes" type="string">
		<cfargument name="dateEnd" 	 required="no" type="string" default="#Now()#">
		
		<cfscript>
		var qrySearch = "";
		var cacheTime = CreateTimeSpan(0,0,30,0);	
		</cfscript>
		
		<cfquery datasource="#variables.DSN4#" name="qrySearch" cachedwithin="#cacheTime#">
			EXEC sp_GetRequestsByDomian
				@Domain 	=<cfif len(arguments.keyword)>'#arguments.keyword#'<cfelse>NULL</cfif>,
				@dateBegin 	=<cfif IsDate(arguments.startDate)>#CreateODBCDate(LsDateFormat(arguments.startDate))#<cfelse>NULL</cfif>,
				@dateEnd   	=<cfif IsDate(arguments.dateEnd)>#CreateODBCDate(LsDateFormat(arguments.dateEnd))#<cfelse>NULL</cfif>	
		</cfquery>
	
		<cfreturn qrySearch>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
</cfcomponent>