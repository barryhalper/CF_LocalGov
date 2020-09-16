<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/COMPONENTS/DataAccessObjects/EventsDAO.cfc $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 8/08/07 10:06 $

	Notes:
		Method naming convention:
		
		1. committ<Noun>	- e.g. committArticle()
		2. delete<Noun>	- e.g. deleteArticle()
		3. get<Noun>	- e.g. getArticle()

--->

<cfcomponent displayname="EventsDAO" hint="<component description here>" extends="his_Localgov_Extends.components.DAOManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="EventsDAO" hint="Pseudo-constructor">
	
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		StructAppend( variables, Super.init( arguments.strConfig ) );

		return this;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetEventSelects" returntype="struct" access="public" hint="returns mutilple result sets to be used in the various event selects" output="no">
		
		<cfscript>
		var strReturn = StructNew();
		</cfscript>

		<!-- return select list from using SQL stored procedure --->
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_GetEventSelects">
			<!--- Return Regions --->
			<cfprocresult resultset="1" name="strReturn.qryRegions">
			<!--- Return Salary Ranges --->
			<cfprocresult resultset="2" name="strReturn.qryEventTypes">
		</cfstoredproc>
	
		<cfreturn strReturn>
	
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="GetFeaturedEvents" access="public" output="false" returntype="query" hint="return query of all featured events">
		
		<cfset var qry ="">		
		
		<cfquery name="qry" datasource="#variables.DSN1#">
		EXEC sp_GetFeaturedEvents
		</cfquery>
	
		<cfreturn qry>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="deleteEvent" access="public" output="false" returntype="void" hint="delete specific event">

		<cfargument name="id" type="numeric" required="yes">
		
		<cfstoredproc datasource="#variables.DSN1#" procedure="spDeleteEvent">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@ID" value="#arguments.id#">
		</cfstoredproc>

	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetEventsFromIndex" access="public" output="false" returntype="query" hint="exec SQL to return jobs based on a list of Id's present in collection" >	
		<cfargument name="Uids" 	required="yes" type="string">

		<cfset var qry ="">		
		
		<cfquery name="qry" datasource="#variables.DSN1#">
		EXEC sp_GetEventsFromIndex 
			@UID 	= '#arguments.Uids#'
		</cfquery>
	
		<cfreturn qry>
	</cffunction> 
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions: *COMMIT* -------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="CommitEvent" access="public" output="false" returntype="numeric" hint="Commit event into db, returns it's ID">
			
		<cfargument name="strDataSet" 		type="struct" 	required="yes">
		<cfargument name="LogoFileName" 	type="string" 	required="yes">
		
		<cfset var nEventID=0>
		
		<!--- Perform Insert/Update --->
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_AddEvent">
			<cfif arguments.strDataSet.p_event_id eq 0 OR arguments.strDataSet.p_event_id eq "">				
				<cfprocparam dbvarname="@p_event_id" 	 cfsqltype="cf_sql_integer" 	type="in" 	value="" null="yes">
			<cfelse>	
			
			<cfprocparam dbvarname="@p_event_id" 	 cfsqltype="cf_sql_integer" 	type="in" 	value="#arguments.strDataSet.p_event_id#" >
			</cfif>
			<cfprocparam dbvarname="@event_name" 		cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.event_name#">
			<cfprocparam dbvarname="@organiser"  		cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.organiser#">  
			
			<cfprocparam dbvarname="@date_start" 		cfsqltype="cf_sql_date" 		type="in" 	value="#LSParseDateTime(arguments.strDataSet.date_start)#">
			
			<cfprocparam dbvarname="@date_end" 			cfsqltype="cf_sql_date" 		type="in" 	value="#LSParseDateTime(arguments.strDataSet.date_end)#">
			
			<cfprocparam dbvarname="@detail" 			cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.detail#">
			<cfprocparam dbvarname="@venue_name" 		cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.venue_name#">  
			<cfprocparam dbvarname="@venue_address1" 	cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.venue_address1#">
			<cfprocparam dbvarname="@venue_address2" 	cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.venue_address2#">
			<cfprocparam dbvarname="@venue_address3" 	cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.venue_address3#">
			<cfprocparam dbvarname="@town" 				cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.town#"> 
			<cfprocparam dbvarname="@f_county_id" 		cfsqltype="cf_sql_integer" 		type="in" 	value="#arguments.strDataSet.f_county_id#">  
			<cfprocparam dbvarname="@f_country_id" 		cfsqltype="cf_sql_integer" 		type="in" 	value="#arguments.strDataSet.f_country_id#">  
			<cfprocparam dbvarname="@Postcode" 			cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.Postcode#">  
			<cfprocparam dbvarname="@tel" 				cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.tel#">  
			<cfprocparam dbvarname="@fax" 				cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.fax#">  
			<cfprocparam dbvarname="@email" 			cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.email#">  
			<cfprocparam dbvarname="@website" 			cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.website#">  
			<cfprocparam dbvarname="@f_contact_salutationID" cfsqltype="cf_sql_integer" type="in" 	value="#arguments.strDataSet.f_contact_salutationID#">  
			<cfprocparam dbvarname="@contact_forename" 	cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.contact_forename#">  
			<cfprocparam dbvarname="@contact_surname" 	cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.contact_surname#">  
			<cfprocparam dbvarname="@contact_tel" 		cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.contact_tel#">  
			<cfprocparam dbvarname="@contact_fax" 		cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.contact_fax#">  
			<cfprocparam dbvarname="@contact_email" 	cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.contact_email#">
			<cfprocparam dbvarname="@LogoFileName" 		cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.LogoFileName#"> 
			<cfprocparam dbvarname="@f_event_type_id" 	cfsqltype="cf_sql_integer" 		type="in" 	value="#arguments.strDataSet.f_event_type_id#">  
			<cfprocparam dbvarname="@speakers" 			cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.speakers#">  
			<cfprocparam dbvarname="@ProductList" 		cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.ProductList#">
			<cfprocparam dbvarname="@premium_paid" 		cfsqltype="cf_sql_bit" 			type="in" 	value="#arguments.strDataSet.premium_paid#">
			<cfprocparam dbvarname="@status" 			cfsqltype="cf_sql_integer" 		type="in" 	value="#arguments.strDataSet.status#">
			<cfif StructKeyExists(arguments.strDataSet, 'sectors')>
			<cfprocparam dbvarname="@SectorID" 			cfsqltype="cf_sql_varchar" 		type="in" 	value="#arguments.strDataSet.sectors#">
			<cfelse>
			<cfprocparam dbvarname="@SectorID" 			cfsqltype="cf_sql_varchar" 		type="in" 	value="" null="yes">
			</cfif>
			<cfprocparam dbvarname="@EventID" 	 		cfsqltype="cf_sql_integer" 		type="out" 	variable="nEventID">
		</cfstoredproc>
		
		<!--- Return the event's ID --->
		<cfreturn nEventID>
				
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions: *GET* ----------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetEventDetail" access="public" output="false" returntype="query" hint="return query of all deatils about specific event">
		<cfargument name="id" type="numeric" required="yes">

		<cfquery name="qryEventDetail" datasource="#variables.DSN1#">
		EXEC sp_GetEventDetail
			@EventID = '#arguments.id#'
		</cfquery>
		
		<cfreturn qryEventDetail>
	
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetAllEvents" access="public" output="false" returntype="query" hint="return query of all events">
		<cfset var qryAllEvents = ""> 
		
		<cfquery name="qryAllEvents" datasource="#variables.DSN1#" cachedwithin="#variables.CACHE_TIME#">
		EXEC sp_GetAllEvents
		</cfquery>
		
		<cfreturn qryAllEvents>
				
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetLatestEvents" access="public" output="false" returntype="query" hint="return query of all events">
		<cfargument name="isAdmin" type="boolean" required="no" default="0">
		<cfset var qryLatestEvents = ""> 
		
		<cfquery name="qryLatestEvents" datasource="#variables.DSN1#" cachedwithin="#variables.CACHE_TIME#">
		EXEC sp_GetLatestEvents
		#arguments.isAdmin#
		</cfquery>
		
		<cfreturn qryLatestEvents>
				
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetEvents" access="public" output="false" returntype="query" hint="return query of all events">
		
		<cfargument name=	"event_type_ids" 	type="string" required="no" default="0">
		<cfargument name=	"sector_ids" 		type="string" required="no" default="0">
		<cfargument name=	"start_date" 		type="numeric" required="no" default="0">
		<cfargument name=	"end_date" 			type="numeric" required="no" default="0">
			
		<cfset var qryAllEvents = ""> 
				
		<cfquery name="qryGetEvents" datasource="#variables.DSN1#" cachedwithin="#variables.CACHE_TIME#">
		EXEC sp_GetEvents
			@event_type_ids = '#arguments.event_type_ids#',
			@sector_ids		= '#arguments.sector_ids#',
			@start_date 	= '#arguments.start_date#',
			@end_date 		= #arguments.end_date#
		</cfquery>
		
		<cfreturn qryGetEvents>
				
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetEventTypes" access="public" output="false" returntype="query" hint="return query of all events">
		
		<cfset var qryAllEvents = ""> 
		
		<cfquery name="qryGetEventsTypes" datasource="#variables.DSN1#" cachedwithin="#variables.CACHE_TIME#">
		EXEC sp_GetEventTypes
		</cfquery>
		
		<cfreturn qryGetEventsTypes>
				
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="AdminSearchEvents" access="public" output="false" returntype="query" hint="Run the event search store procedure, passing it all relevant arguments.">
			
		<cfargument name="Keywords" type="string" required="yes">
		
		<cfset var qrySearchEvents = ""> 
			
		<cfquery name="qrySearchEvents" datasource="#variables.DSN1#">
		EXEC sp_AdminSearchEvents
			@Keywords = '#arguments.Keywords#'
		</cfquery>
		
		<cfreturn qrySearchEvents>
				
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="AdvSearchEvents" access="public" output="false" returntype="query" hint="perform events advance search">
		<cfargument name="keywords"		type="string"  	required="no" default="">
		<cfargument name="sectors"  	type="string"  	required="no" default="">
		<cfargument name="eventtypeid"  type="string"  	required="no" default="">
		<cfargument name="startdate" 	type="string" 	required="no" default="">
		<cfargument name="enddate" 	type="string" 	required="no" default="">
		<cfargument name="UID" 			type="string"  	required="no" default="">
		
		<cfset var qryEvents="">

		<!--- Perform query... --->
		<cfquery name="qryEvents" datasource="#variables.DSN1#"  cachedwithin="#createTimeSpan(0,0,0,30)#">
		EXEC sp_SearchEvents
			@keywords      = <cfif Len(arguments.keywords)>'#arguments.keywords#'<cfelse>NULL</cfif>,
			@sectorid  	    = <cfif Len(arguments.sectors)>'#arguments.sectors#'<cfelse>NULL</cfif>,
			@eventtypeid   	 = <cfif Len(arguments.eventtypeid)>'#arguments.eventtypeid#'<cfelse>NULL</cfif>,
			@startdate = <cfif Len(arguments.startdate)>#CreateODBCDate(LSDateFormat(arguments.startdate,'dd/mmm/yyyy'))#<cfelse>NULL</cfif>,
			@enddate = <cfif Len(arguments.enddate)>#CreateODBCDate(LSDateFormat(arguments.enddate,'dd/mmm/yyyy'))#<cfelse>NULL</cfif>,
			@Uid			= <cfif Len(arguments.Uid)>'#arguments.Uid#'<cfelse>NULL</cfif>
		</cfquery>
		
		<!--- Return query... --->
		<cfreturn qryEvents>
		
	</cffunction>		
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->

</cfcomponent>