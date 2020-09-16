<!--
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/COMPONENTS/ApplicationObjects/FuseboxStats.cfc $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 8/08/07 10:06 $

-->
<cfcomponent hint="Create logs for fusebox application and display the results">

<!--- <cfset init()/> --->

<cffunction name="init" access="public" returntype="his_websites.components.FuseBoxStats" hint="constructor method">
	<cfargument name="dsn" required="yes" type="string"> 
		<cfscript>
		variables.dsn = arguments.dsn;
		CreateQry();
		return this;
		</cfscript>

	<cfreturn>	
</cffunction>

	<cffunction name="GetVariables" access="public" returntype="struct" output="false">
		<cfreturn variables>
	</cffunction> 

	<cffunction name="CreateQry" access="public" returntype="void" output="false">
		<cfset variables.qry_AppStats = queryNew("mediacode, circuit, fuseaction, ipaddress, browsertype, HitDate, Cftoken, SubsID, refer_site")>
	</cffunction>

	<!--- Begin LogPageHit() Function --->
	<cffunction name="LogPageHit" access="public" hint="Set page informtaion into a query object present in application scope" output="no" returntype="void">
		<cfargument name="cgi_scope" type="struct" required="yes">
		<cfargument name="mediacode" type="string" required="yes">
		<cfargument name="circuit" type="string" required="yes">
		<cfargument name="fuseaction" type="string" required="yes">
		<cfargument name="SubsID" type="string" required="no">
		
		
		<cfscript>
		//find http referrer for variables page request
		 findscript_name=findnocase("?",arguments.cgi_scope.http_referer);
			if (findscript_name)
				refer_site=mid(arguments.cgi_scope.http_referer,1,findscript_name-1);
			else
				refer_site=arguments.cgi_scope.http_referer;
	
		//Add empty row to query object
		QueryAddRow(variables.qry_AppStats);
		//set cell values for variables row
		QuerySetCell(variables.qry_AppStats, "mediacode", arguments.mediacode);
		QuerySetCell(variables.qry_AppStats, "circuit", arguments.circuit);
		QuerySetCell(variables.qry_AppStats, "fuseaction", arguments.fuseaction);
		QuerySetCell(variables.qry_AppStats, "ipaddress", arguments.cgi_scope.REMOTE_ADDR); 
		QuerySetCell(variables.qry_AppStats, "browsertype", arguments.cgi_scope.HTTP_USER_AGENT);
		QuerySetCell(variables.qry_AppStats, "HitDate", Now());
		QuerySetCell(variables.qry_AppStats, "Cftoken", cookie.cftoken);
		//only add client sub id if it is present
		if (IsDefined("arguments.SubsID") AND Len(arguments.SubsID))
			QuerySetCell(variables.qry_AppStats, "SubsID", arguments.SubsID);
		QuerySetCell(variables.qry_AppStats, "refer_site", refer_site);
		</cfscript> 
		
	</cffunction> 
	
	<!--- Begin Stats2XML() Function --->
	<cffunction name="Stats2XML" access="public" hint="write query object data into a XML object" returntype="any">
  	
 		<cfset var XmlStats = "">
			<!----Check if log has data present --->
			<cfif variables.qry_AppStats.recordcount gt 0>
				<cfxml variable="XmlStats">
					<ROOT>
						  <cfoutput query="variables.qry_AppStats">
							<STAT>
								<Mediacode>#Trim(mediacode)#</Mediacode>
								<Circuit>#trim(XmlFormat(circuit))#</Circuit>
								<fuseaction>#trim(XmlFormat(fuseaction))#</fuseaction>
								<ipaddress>#trim(XMLFormat(ipaddress))#</ipaddress>
								<browsertype><![CDATA[#browsertype#]]></browsertype>
								<hitdate>#DateFormat(hitdate, 'dd/mmm/yyyy')# #TimeFormat(hitdate, "HH:mm:ss")#</hitdate>
								<token>#trim(Cftoken)#</token>
								<refer_site>#trim(XmlFormat(refer_site))#</refer_site>
								<f_subs_id>#trim(SubsID)#</f_subs_id>
							 </STAT>
						 </cfoutput>
					</ROOT>
				</cfxml>  
			</cfif>
 		<cfreturn XmlStats>
		
			
 </cffunction>

	
		<!--- Begin Stats2SQL() Function --->
		<cffunction name="Stats2SQL" access="public" hint="Pass statistics data to SQL for bulk insert" output="no" returntype="void">
				
					<cfset var XmlStats = "">
						<!----Call Stats2XML method to retrive data from application --->
						<cfset XmlStats = Stats2XML()>
						
						<cfif Len(XmlStats)>
							<!----Pass XML TO SQL using Stored Proc --->
							<cfquery datasource="#variables.dsn#">
								EXEC spImport_FuseBox_Stats
								@XmlDoc = '#ToString(XmlStats)#'
							</cfquery>
							
							<cfscript>
							//Empty query object that holds the stats from application scope
							structdelete(variables,"qry_AppStats");
							//reset query
							Createqry();
							</cfscript>
						</cfif>
		</cffunction>
		
		<!--- Begin GetPageStats() Function --->
		<cffunction name="GetPageStats" access="public" returntype="struct" hint="Exec SQL to return mutiple resutsets which contain statistics for a particular site" output="false">
				<cfargument name="StatsPeriod" type="string" required="yes" hint="pass 'Day', 'Week'  or 'Month', 'Year' or 'All' to sql so it can process stats for that period">
				<cfargument name="mediacode" type="string" required="yes">
				
				<cfset var strPageStats = StructNew()>
				<cfset var qry_TotalHits = "">
				<cfset var qry_Totalusers = "">
				<cfset var qry_PageBreakdown = "">
				<cfset var qry_Top5 = "">
				
				<!---exec stored proc --->
				<cfstoredproc datasource="#variables.dsn#" procedure="spGetFusbox_Stats" returncode="yes">
					<cfprocparam cfsqltype="cf_sql_varchar" type="in" variable="@StatsPeriod" value="#arguments.StatsPeriod#">
					<cfprocparam cfsqltype="cf_sql_varchar" type="in" variable="@Mediacode" value="#arguments.Mediacode#">
						<cfprocresult resultset="1" name="qry_TotalHits">
						<cfprocresult resultset="2" name="qry_Totalusers">
						<cfprocresult resultset="3" name="qry_PageBreakdown">
						<cfprocresult resultset="4" name="qry_Top5">
				</cfstoredproc>
				
				
				<cfscript>
				//copy resultsets into return structure
				strPageStats.qry_TotalHits = qry_TotalHits;
				strPageStats.qry_Totalusers = qry_Totalusers;
				strPageStats.qry_PageBreakdown = qry_PageBreakdown;
				strPageStats.qry_Top5 = qry_Top5;
				//copy sql status code into return structure
				strPageStats.sqlstatuscode = cfstoredproc.statusCode;
				//return structure
				return strPageStats;
				</cfscript>
				
		</cffunction>
	
</cfcomponent>
