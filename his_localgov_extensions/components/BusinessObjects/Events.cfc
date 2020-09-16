<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/BusinessObjects/Events.cfc $
	$Author: Bhalper $
	$Revision: 2 $
	$Date: 18/12/07 12:05 $

--->

<cfcomponent displayname="Events" hint="Functions related to events" extends="his_Localgov_Extends.components.BusinessObjectsManager">

	<!--- -------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR -------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Events" hint="Pseudo-constructor">
	
		<cfargument name="objAppObjs" type="any" required="yes" hint="The application objects">
		<cfargument name="objBusObjs" type="any" required="yes" hint="The business objects">

		<cfscript>
		// Call the genric init function, placing business, app, and dao objects into a local scope...
		StructAppend( variables, Super.initChild( arguments.objAppObjs, this, arguments.objBusObjs ) );	
		
		// Set directory path to folder that holds the event logos...
		variables.eventLogoDir = variables.strConfig.strPaths.dirpath &  variables.strConfig.strPaths.eventlogodir;
		// Set url path to folder that holds the event logos...
		variables.eventLogoPath = variables.strConfig.strPaths.sitepath &  variables.strConfig.strPaths.eventlogopath;
		// Set the directory path of the folder that holds the MS-Outloko event calendars (*.vcs)...
		variables.eventOutlookDir = variables.strConfig.strPaths.dirpath &  variables.strConfig.strPaths.eventoutlookdir;
		//variables.qryEventTypes = 	getEventTypes();
		return this;
		</cfscript>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions --------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getVariables" access="public" output="false" returntype="struct" hint="return local scope to caller">
		<cfreturn variables>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getEventSelects" access="public" output="false" returntype="struct" hint="">
	
		<cfif NOT StructKeyExists(variables, "strEventSelects")>
			<cfreturn objDAO.GetEventSelects()>
		<cfelse>
			<cfreturn variables.strEventSelects>
		</cfif>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getAllEvents" access="public" output="false" returntype="query" 
		hint="return query of all events">
		
		<cfreturn objDAO.GetAllEvents()>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getLatestEvents" access="public" output="false" returntype="query" 
		hint="return query of all events">
			<cfargument name="isAdmin" type="boolean" required="no" default="0">
		
		<cfreturn objDAO.GetLatestEvents(arguments.isAdmin)>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getFeaturedEvents" access="public" output="false" returntype="query" 
		hint="return query of all featured events">
		
		<cfreturn objDAO.GetFeaturedEvents()>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getEvents" access="public" output="false" returntype="query" 
		hint="return query of all events based on the passed arguments">
		
		<cfargument name=	"event_type_ids" 	type="string" 	required="yes">
		<cfargument name=	"sector_ids" 		type="string" 	required="yes">
		<cfargument name=	"view_id" 			type="numeric" 	required="yes" hint="1:day; 2:week; 3:month">
		<cfargument name=	"start_date" 		type="date" 	required="yes">
		
		<cfscript>
		var end_date = "";
		
		// Determine the end date based on the given view (i.e. day/week/month)...
		switch (arguments.view_id) {
			case 1: {
				end_date = CreateODBCDateTime(arguments.start_date);
				break;
			}
			case 2: {
				end_date = DateAdd("d", 7, arguments.start_date);
				break;
			}
			case 3: {
				start_date = DateFormat(start_date, "yyyy-mm-01");
				end_date = DateAdd("m", 1, arguments.start_date);
				break;
			}
		}	
		
		// Query the DAO to obtain the events...
		return objDAO.GetEvents( 
			arguments.event_type_ids, 
			arguments.sector_ids,
			arguments.start_date, 
			end_date 
		);
		</cfscript>
				
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="deleteEvent" access="public" output="false" returntype="void" hint="delete specific event">
			
		<cfargument name="id" type="numeric" required="yes">
		<cfscript>
		objDAO.deleteEvent( arguments.id );
		</cfscript>
					
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
<cffunction name="getEventsForCalendar" access="public" output="false" returntype="query"
		hint="tailors the supplied events query for the calendar">
		
		<cfargument name=	"qryEvents" 	type="query" 	required="yes">		
		<cfargument name=	"xfadetail" 	type="string" 	required="yes">		
		<cfargument name=	"start_date" 	type="string" 	required="yes">		
		<cfargument name=	"mid" 			type="string" 	required="yes">		
		
		<cfset var qryEventsForCalendar = QueryNew("Date, Events, Detail")>
		<cfset var sDaysInMonth = DaysInMonth(arguments.start_date)>
		<cfset var tmp = "">
		<cfset var day = "">
		<cfset var i = 0>
		<cfset var j = 0>
		
		<!--- Initialise query... --->
		<cftry>
		<cfloop from="1" to="#sDaysInMonth#" index="i">
			<cfset tmp = QueryAddRow(qryEventsForCalendar)>
			<cfset day = CreateDate(DatePart("yyyy",DateFormat(arguments.start_date)), DatePart("m", DateFormat(arguments.start_date)), i)>
			<cfset tmp = QuerySetCell(qryEventsForCalendar, "Date", day, i)>
		</cfloop>
		<cfcatch type="any"></cfcatch>
		</cftry>
		
		<!--- Tailor query so it can be used with the JS calendar... --->
		<cfset j=0><!--- rename to ~event --->
		<cfoutput>
		<cfloop from="1" to="#sDaysInMonth#" index="i">
			<cfset day = CreateDate(DatePart("yyyy",LSDateFormat(arguments.start_date)), DatePart("m", LSDateFormat(arguments.start_date)), i)>
			<cfloop query="arguments.qryEvents" >
				<!---inner loop.. check that event is one of 3 and withing a valid range --->	
				<cfif j lt 3 and DateCompare(day, arguments.qryEvents.date_start) gte 0 and DateCompare(day, arguments.qryEvents.date_end) lte 0>
				 				
					<!--- todo: consider moving this the the presentation layer... --->
					<cfset tmp = QuerySetCell(qryEventsForCalendar, "Events", 
						"<img src=#request.sImgPath#icons/event_icon#arguments.qryEvents.event_type_id#.gif border=0 width=16 height=16>&nbsp;<a href=#request.myself##arguments.xfadetail#&amp;id=#arguments.qryEvents.eventid#&amp;mid=#arguments.mid# title='Click for more info on #JSStringFormat(arguments.qryEvents.Event_Name)#'><strong>" & Mid(arguments.qryEvents.Event_Name,1,19) & "</strong>...</a><br>" & qryEventsForCalendar.Events[i], i)>
					
					<cfset tmp = QuerySetCell(qryEventsForCalendar, "Detail", 
												"<li><strong>" & arguments.qryEvents.Event_Name & "</strong></li>" & qryEventsForCalendar.Detail[i], i)>
					
					<cfset j=j+1>
					
					
				</cfif> 
			</cfloop>
			<cfset j=0>
		</cfloop>
		</cfoutput>
				
		<cfreturn qryEventsForCalendar>
			
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getEventDetail" access="public" output="false" returntype="query" 
		hint="return query of specified events">
		
		<cfargument name="id" type="numeric" required="yes">
		
		<cfreturn objDAO.GetEventDetail( arguments.id )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getEventTypes" access="public" output="false" returntype="query" 	
		hint="return query of all events">
		
		<cfscript>
		var qryEventTypes = querynew("temp");
		if (structkeyExists(variables, "qryEventTypes"))
		 	qryEventTypes = variables.qryEventTypes;
		else
			 qryEventTypes =objDAO.GetEventTypes();
			 
		return qryEventTypes;
		</cfscript>
	
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="recordClickThru" access="public" output="false" returntype="boolean" 
		hint="return query of all events">
		
		<!--- 	todo: business logic to record click thrus here.	--->
		
		<cfreturn true>
		
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- Public Function: GenerateEventsForOutlook() ------------------------------------------------------>
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="generateEventsForOutlook" access="public" output="true" returntype="string" 
		hint="return query of all events">
		
		<cfargument name=	"qryEvents" 	type="query" required="yes">
		<cfargument name=	"type_ids" 		type="string" required="yes">
		<cfargument name=	"sector_ids" 	type="string" required="yes">
		<cfargument name=	"start_date"	type="string" required="yes">
		
		<!--- Local variable initialisation... --->
		<cfset var sFilename= 	"Events_#DateFormat(arguments.start_date, "mmmyyyy")#_#arguments.type_ids#_#arguments.sector_ids#.vcs">
		<cfset var bRecreate= 	false>
		<cfset var bFound= 		false>

		<!--- Create the outlook folder, if not present... --->
		<cfif Not DirectoryExists(variables.EventOutlookDir)>
			<cfdirectory action="create" directory="#variables.EventOutlookDir#">
		</cfif>
		
		<!--- Determine whether we need to recreate the VCS, yes if older than one day... --->
		<cfdirectory action="list" directory="#variables.EventOutlookDir#" name="qryOutlook">
		<cfloop query="qryOutlook">
			<cfif qryOutlook.name eq sFilename>
				<cfif DateDiff("d", LSDateFormat(qryOutlook.dateLastModified), LSDateFormat(now())) GTE 1>
					<cfset bRecreate = true>
					<cfbreak>
				</cfif>
				<cfset bFound = true>
			</cfif>
		</cfloop>
		
		<!--- Recreate if we have to, according to the above logic, or if a version doesn't already exist... --->
		<cfif bRecreate or not bFound>
		
			<!--- Caution! the formating is purposely like this... --->
<cfsavecontent variable="CalendarTxt"><cfoutput>BEGIN:VCALENDAR<cfloop query="arguments.qryEvents">
BEGIN:VEVENT
DTSTART:#DateFormat(date_start, "yyyymmdd") & "T" & TimeFormat(date_start, "hhmmss") & "Z"#
DTEND:#DateFormat(date_end, "yyyymmdd") & "T" & TimeFormat(date_end, "hhmmss") & "Z"#
<cfif Len(event_name)>SUMMARY:#event_name#</cfif>
<cfif Len(event_name)>DESCRIPTION:#event_name#</cfif>
END:VEVENT
</cfloop>END:VCALENDAR</cfoutput>

</cfsavecontent> 
		
			<!--- Write the calendar to file, overwrite if necessary... --->
			<cffile action="write" file="#variables.EventOutlookDir##sFilename#" output="#CalendarTxt#" nameconflict="overwrite"> 	
		
		</cfif>
		
		<!--- Return the name of the file... --->
		<cfreturn sFilename>

	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="commitEvent" access="public" output="false" returntype="numeric" 
		hint="Commit event into db, returns it's ID">
			
		<cfargument name="strDataSet" type="struct" required="yes">
		<cfargument name="LogoFileName" type="string" required="yes">
				
		<!--- Return the event's ID --->
		<cfreturn objDAO.CommitEvent( strDataSet, arguments.LogoFileName ) >
				
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="adminSearchEvents" access="public" output="false" returntype="query" 
		hint="Commit event into db, returns it's ID">
			
		<cfargument name="Keywords" type="string" required="yes">
				
		<!--- Return the event's ID --->
		<cfreturn objDAO.AdminSearchEvents( arguments.Keywords ) >
				
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="searchEvents" access="public" returntype="query" output="false" 
		hint="search events in verity and sql">
		
		<cfargument name="keywords" required="no" type="string" default="">	
		
		<cfscript>
		var qryReturn=querynew("temp");
		var qry="";
		var strResult=StructNew();
		arguments.keywords =objString.SqlSafe(ObjString.StripHTML(arguments.keywords));
		//if not keywords were present...
		if (NOT Len(arguments.keywords))
		
			//...return all latest events
			qryReturn = GetLatestEvents();
		else{
			//run verity search
			strResult=objSearch.GetCollectionSearch(arguments.keywords);
			//check if verity search has returned any results
			if (strResult.qryResults.recordcount){
				//run QofQ to get the ID of only the events found in search
				qry=objUtils.QueryOfQuery(strResult.qryResults, 'custom2 AS UID', 'custom1 LIKE #chr(39)#%Events%#chr(39)#');
				//pass list of ids to sql 
				qryReturn=objDAO.GetEventsFromIndex(ValueList(qry.Uid));	
			}	 		
		}  
		return  qryReturn;	 
		</cfscript>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
 	<cffunction name="advSearch" access="public" output="false" returntype="query" hint="perform adv search jobs">
		<cfargument name="keywords"		type="string"  	required="no" default="">
		<cfargument name="sectors"  	type="string"  	required="no" default="">
		<cfargument name="eventtypeid"  type="string"  	required="no" default="">
		<cfargument name="startdate" 	type="string" 	required="no" default="">
		<cfargument name="enddate" 	type="string" 	required="no" default="">
		<cfargument name="UID" 			type="string"  	required="no" default="">
		<Cfset arguments.keywords =objString.SqlSafe(ObjString.StripHTML(arguments.keywords))>
		<cfreturn objDAO.AdvSearchEvents( argumentscollection=arguments )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="EventDate" access="public" output="false" returntype="string" hint="">
			
		<cfargument name="startDate"  type="date"  required="yes">
		<cfargument name="endDate"    type="string" required="no" default="">
		
		<cfscript>
		var sFormat = 'dd-mmm-yy';
		var Eventdate = Dateformat(arguments.startDate, sFormat);
		
		if (arguments.startDate eq arguments.endDate)
			Eventdate = Dateformat(arguments.startDate, sFormat);
		else
		if (isDate(arguments.Enddate) AND Dateformat(arguments.startDate, 'mmm') eq Dateformat(arguments.endDate, 'mmm'))
			//event occurs over several days in the same month
			Eventdate = Dateformat(arguments.startDate, 'dd') & " to " & Dateformat(arguments.endDate, sFormat);
		else
		if (isDate(arguments.Enddate) AND Dateformat(arguments.startDate, 'mmm') neq Dateformat(arguments.endDate, 'mmm') AND Dateformat(arguments.startDate, 'yy') eq Dateformat(arguments.endDate, 'yy') )
			//event occurs over several days in different month
			Eventdate 	= Dateformat(arguments.startDate, 'dd-mmm') & " to " & Dateformat(arguments.endDate, sFormat); 
		else
		if (isDate(arguments.Enddate) AND Dateformat(arguments.startDate, 'mmm') neq Dateformat(arguments.endDate, 'mmm') AND Dateformat(arguments.startDate, 'yy') neq Dateformat(arguments.endDate, 'yy') )
			//event occurs over several days in different month
			Eventdate 	= Dateformat(arguments.startDate, sFormat) & " to " & Dateformat(arguments.endDate, sFormat); 		
		
		return Eventdate;
		</cfscript>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
		<cffunction name="resultText" access="public" returntype="string" output="false" hint="work out result text based on search criteria">
		<cfargument name="keywords"		type="string"  	required="no" default="">
		<cfargument name="sectors"  	type="string"  	required="no" default="">
		<cfargument name="eventtypeid"  type="string"  	required="no" default="">
		<cfargument name="startdate" 	type="string" 	required="no" default="">
		<cfargument name="enddate" 	  	type="string" 	required="no" default="">
		
		<cfscript>
		var qry	="";
		var lst	="";
		var resultstring    = "We have found <b>#arguments.recordcount#</b> events that match your search ";
		if (Len(arguments.keywords))
		resultstring 		= resultstring &  'for <b>#arguments.keywords#</b> '  ;
		//check if all sectors have been passed
		if(Len(arguments.sectors) and ListLen(arguments.sectors) neq objSearch.getSectors().recordcount ){
			//get sectors names
			qry 	= objUtils.queryofquery(objSearch.getSectors(), "*", "SectorID IN (#arguments.sectors#)");
			lst 	= ListChangeDelims(QuotedValueList(qry.sector), ", ");
			resultstring   	= resultstring &  '<br/>Sectors: <b>#lst#</b><br/> ';
			}
		if (Len(arguments.eventtypeid)){
			qry =  objUtils.queryofquery(getEventTypes(), "*", "event_type_id IN (#arguments.eventtypeid#)");
			lst = ListChangeDelims(QuotedValueList(qry.event_type), ", ");; 
			resultstring = resultstring &  'in  <b>#lst#</b>';
    	}
		if (Len(arguments.startdate) and Len(arguments.enddate))
			resultstring =  resultstring & "between " & startdate & " and " & enddate;
		else
		 if (Len(arguments.startdate) and NOT Len(arguments.enddate))
				resultstring =  resultstring & "beginning " & startdate;
    	
		return resultstring;
		</cfscript>
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="GetRelatedArticles" access="public" output="false" returntype="query" hint="return related articles for a specific event">
		<cfargument name="event" required="yes" type="string" hint="string containing employer name">
			
			<cfscript>
			var criteria = arguments.event;
			var qryRelatedArticles = QueryNew("temp");
			 	//search collection for articles
				qryRelatedArticles = objSearch.getCollectionSearch(criteria & " AND cf_custom1=News").qryResults;
				qryRelatedArticles = objUtils.queryofquery(qryRelatedArticles, "*, custom2 as NewsID", "0=0", "Custom3 DESC");
			 
			return	 qryRelatedArticles;
			</cfscript>
			
	</cffunction>		
<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
		
	
	
	<cffunction name="sendNotification" access="public" output="false" returntype="void" hint="">
			
		<cfargument name="strDataSet" type="struct" required="yes">
		<cfargument name="EventID" type="numeric" required="yes">
		
		<cfscript>
		variables.objEmail.EmailNewEventAlert( Arguments.strDataSet, Arguments.EventID );
		</cfscript>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="uploadLogo" access="remote" output="false" returntype="string" hint="">
			
		<cfargument name="Filename" type="string" required="yes">
		
		<cffile action="upload" 
			fileField="LogoToUpload"
			destination="#variables.EventLogoDir#"
			nameconflict="makeunique">
					
		<cfreturn cffile.serverFile>

	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- PRIAVTE Functions -------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="cf_Email" access="private" output="false" returntype="void" 
		hint="Alter error via email">
	
	  	<cfargument name="to" 		type="string" required="no" default="#variables.strConfig.strVars.errormailto#">
		<cfargument name="from" 	type="string" required="no" default="#variables.strConfig.strVars.mailsender#">
		<cfargument name="body" 	type="string" required="no" default="">
		<cfargument name="subject"	type="string" required="no" default="#variables.strConfig.strVars.title#">
		<cfargument name="cc" 		type="string" required="no" default="">
		<cfargument name="bcc" 		type="string" required="no" default="">
		<cfargument name="format" 	type="string" required="no" default="html">
			
		<cfmail	to=		"#arguments.to#" 
				from=	"#arguments.from#"
				cc=		"#arguments.cc#"
				bcc=	"#arguments.bcc#"
				subject="#arguments.subject#"
				type=	"#arguments.format#">
			#arguments.body#
			
			<div style="font-size: 10px; color:##999999">
				#variables.strConfig.strVars.disclaimer#
			</div>
			
		</cfmail>
		
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->

</cfcomponent>