<cfcomponent extends="his_Localgov_Extends.components.DAOManager">
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="MYBIntelliDAO" hint="Pseudo-constructor">	
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
			StructAppend( variables, Super.init( arguments.strConfig ) );
			return this;
		</cfscript>
		
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- Lookups --------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getLookups" access="public" returntype="struct" hint="Get all the lookups">
		
		<cfset var strLookups = structnew()>
		
		<cfstoredproc datasource="#variables.DSN2#" procedure="usp_Web_IR_getLookups" returncode="yes">
			
			<cfprocresult resultset="1" name="strLookups.qrySpendGroups">
			<cfprocresult resultset="2" name="strLookups.qrySpendItems">
			<cfprocresult resultset="3" name="strLookups.qryNatIndicators">
			<cfprocresult resultset="4" name="strLookups.qryItemNILinks">
			<cfprocresult resultset="5" name="strLookups.qryCouncilTypes">
			<cfprocresult resultset="6" name="strLookups.qryCouncilRegions">
			<cfprocresult resultset="7" name="strLookups.qryCouncils">
			<cfprocresult resultset="8" name="strLookups.qryNICouncils">
		</cfstoredproc>
		
		<cfreturn strLookups>
	</cffunction>
	
	
	<cffunction name="getRoadLookups" access="public" returntype="struct" hint="Get all the lookups">
		
		<cfset var strLookups = structnew()>
		
		<cfstoredproc datasource="#variables.DSN2#" procedure="usp_Web_IR_getRoadLookups" returncode="yes">
			
			<cfprocresult resultset="1" name="strLookups.qrySpendGroups">
			<cfprocresult resultset="2" name="strLookups.qrySpendItems">
			<cfprocresult resultset="3" name="strLookups.qryRoadTypes">
			
			<cfprocresult resultset="4" name="strLookups.qryCouncilTypes">
			<cfprocresult resultset="5" name="strLookups.qryCouncilRegions">
			<cfprocresult resultset="6" name="strLookups.qryCouncils">
		</cfstoredproc>
		
		<cfreturn strLookups>
	</cffunction>
	
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- Budget Data ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getBudgetData" access="public" returntype="query" hint="Get basic level budget data">
		<cfargument name="year" type="string" required="no" default="">
		<cfargument name="councilType" type="string" required="no" default="">
		<cfargument name="spendItem" type="numeric" required="no" default="0">
		<cfargument name="spendGroup" type="numeric" required="no" default="0">
		<cfargument name="organisationids" type="string" required="no" default="">
		
		<cfset var qryBudgetData = querynew('temp')>
		
		<cfstoredproc datasource="#variables.DSN2#" procedure="usp_Web_IR_getBugetData" returncode="yes">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@year" value="#arguments.year#" null="#iif(len(arguments.year) eq 0, true, false)#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@councilType" value="#arguments.councilType#" null="#iif(len(arguments.councilType) eq 0, true, false)#">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@spendItemID" value="#arguments.spendItem#" null="#iif(arguments.spendItem eq 0, true, false)#">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@spendGroupID" value="#arguments.spendGroup#" null="#iif(arguments.spendGroup eq 0, true, false)#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@organisationids" value="#arguments.organisationids#" null="#iif(len(arguments.organisationids) eq 0, true, false)#">
			
			<cfprocresult resultset="1" name="qryBudgetData">
		</cfstoredproc>
		
		<cfreturn qryBudgetData>
	</cffunction>
	
	
	<cffunction name="getBudgetDataByOrg" access="public" returntype="query" hint="Get basic level budget data">
		<cfargument name="minyear" type="string" required="no" default="">
		<cfargument name="maxyear" type="string" required="no" default="">
		<cfargument name="spendItems" type="string" required="no" default="0">
		<cfargument name="spendGroups" type="string" required="no" default="">
		<cfargument name="organisationids" type="string" required="no" default="">
		
		<cfset var qryBudgetData = querynew('temp')>
		
		<cfstoredproc datasource="#variables.DSN2#" procedure="usp_Web_IR_getBugetData_OrgIDs">
			<cfprocparam type="in" cfsqltype="cf_sql_bit" dbvarname="@exec" value="1">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@minyear" value="#arguments.minyear#" null="#iif(len(arguments.minyear) eq 0, true, false)#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@maxyear" value="#arguments.maxyear#" null="#iif(len(arguments.maxyear) eq 0, true, false)#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@spendItemIDs" value="#arguments.spendItems#" null="#iif(len(arguments.spendItems) eq 0, true, false)#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@spendGroupIDs" value="#arguments.spendGroups#" null="#iif(len(arguments.spendGroups) eq 0, true, false)#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@organisationids" value="#arguments.organisationids#" null="#iif(len(arguments.organisationids) eq 0, true, false)#">
			
			<cfprocresult name="qryBudgetData" resultset="1">
		</cfstoredproc>
		
		<cfreturn qryBudgetData>
	</cffunction>
	
	<cffunction name="getBudgetDataByAvg" access="public" returntype="query" hint="Get basic level budget data">
		<cfargument name="minyear" type="string" required="no" default="">
		<cfargument name="maxyear" type="string" required="no" default="">
		<cfargument name="spendItems" type="string" required="no" default="0">
		<cfargument name="spendGroups" type="string" required="no" default="">
		<cfargument name="avuids" type="string" required="no" default="">
		
		<cfset var qryBudgetData = querynew('temp')>
		
		<cfstoredproc datasource="#variables.DSN2#" procedure="usp_Web_IR_getBugetData_avg">
			<cfprocparam type="in" cfsqltype="cf_sql_bit" dbvarname="@exec" value="1">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@minyear" value="#arguments.minyear#" null="#iif(len(arguments.minyear) eq 0, true, false)#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@maxyear" value="#arguments.maxyear#" null="#iif(len(arguments.maxyear) eq 0, true, false)#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@spendItemIDs" value="#arguments.spendItems#" null="#iif(len(arguments.spendItems) eq 0, true, false)#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@spendGroupIDs" value="#arguments.spendGroups#" null="#iif(len(arguments.spendGroups) eq 0, true, false)#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@avuids" value="#arguments.avuids#" null="#iif(len(arguments.avuids) eq 0, true, false)#">
			
			<cfprocresult name="qryBudgetData" resultset="1">
		</cfstoredproc>
		
		<cfreturn qryBudgetData>
	</cffunction>
	
	
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- Road Length Data ------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getRoadLengthDataByOrg" access="public" returntype="query" hint="Get basic level budget data">
		<cfargument name="minyear" type="string" required="no" default="">
		<cfargument name="maxyear" type="string" required="no" default="">
		<cfargument name="roadItems" type="string" required="no" default="0">
		<cfargument name="organisationids" type="string" required="no" default="">
		
		<cfset var qryBudgetData = querynew('temp')>
		
		<cfstoredproc datasource="#variables.DSN2#" procedure="usp_Web_IR_getRoadLengthData_OrgIDs">
			<cfprocparam type="in" cfsqltype="cf_sql_bit" dbvarname="@exec" value="1">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@minyear" value="#arguments.minyear#" null="#iif(len(arguments.minyear) eq 0, true, false)#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@maxyear" value="#arguments.maxyear#" null="#iif(len(arguments.maxyear) eq 0, true, false)#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@roadItemIDs" value="#arguments.roadItems#" null="#iif(len(arguments.roadItems) eq 0, true, false)#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@organisationids" value="#arguments.organisationids#" null="#iif(len(arguments.organisationids) eq 0, true, false)#">
			
			<cfprocresult name="qryBudgetData" resultset="1">
		</cfstoredproc>
		
		<cfreturn qryBudgetData>
	</cffunction>
	
	<cffunction name="getRoadLengthDataByAvg" access="public" returntype="query" hint="Get basic level budget data">
		<cfargument name="minyear" type="string" required="no" default="">
		<cfargument name="maxyear" type="string" required="no" default="">
		<cfargument name="roadItems" type="string" required="no" default="0">
		<cfargument name="avuids" type="string" required="no" default="">
		
		<cfset var qryBudgetData = querynew('temp')>
		
		<cfstoredproc datasource="#variables.DSN2#" procedure="usp_Web_IR_getRoadLengthData_avg">
			<cfprocparam type="in" cfsqltype="cf_sql_bit" dbvarname="@exec" value="1">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@minyear" value="#arguments.minyear#" null="#iif(len(arguments.minyear) eq 0, true, false)#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@maxyear" value="#arguments.maxyear#" null="#iif(len(arguments.maxyear) eq 0, true, false)#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@roadItemIDs" value="#arguments.roadItems#" null="#iif(len(arguments.roadItems) eq 0, true, false)#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@avuids" value="#arguments.avuids#" null="#iif(len(arguments.avuids) eq 0, true, false)#">
			
			<cfprocresult name="qryBudgetData" resultset="1">
		</cfstoredproc>
		
		<cfreturn qryBudgetData>
	</cffunction>
	
	
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- Road Spend Data ------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getRoadSpendDataByOrg" access="public" returntype="query" hint="Get basic level budget data">
		<cfargument name="minyear" type="string" required="no" default="">
		<cfargument name="maxyear" type="string" required="no" default="">
		<cfargument name="organisationids" type="string" required="no" default="">
		
		<cfset var qryBudgetData = querynew('temp')>
		
		<cfstoredproc datasource="#variables.DSN2#" procedure="usp_Web_IR_getRoadSpendData_OrgIDs">
			<cfprocparam type="in" cfsqltype="cf_sql_bit" dbvarname="@exec" value="1">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@minyear" value="#arguments.minyear#" null="#iif(len(arguments.minyear) eq 0, true, false)#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@maxyear" value="#arguments.maxyear#" null="#iif(len(arguments.maxyear) eq 0, true, false)#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@organisationids" value="#arguments.organisationids#" null="#iif(len(arguments.organisationids) eq 0, true, false)#">
			
			<cfprocresult name="qryBudgetData" resultset="1">
		</cfstoredproc>
		
		<cfreturn qryBudgetData>
	</cffunction>
	
	<cffunction name="getRoadSpendDataByAvg" access="public" returntype="query" hint="Get basic level budget data">
		<cfargument name="minyear" type="string" required="no" default="">
		<cfargument name="maxyear" type="string" required="no" default="">
		<cfargument name="avuids" type="string" required="no" default="">
		
		<cfset var qryBudgetData = querynew('temp')>
		
		<cfstoredproc datasource="#variables.DSN2#" procedure="usp_Web_IR_getRoadSpendData_avg">
			<cfprocparam type="in" cfsqltype="cf_sql_bit" dbvarname="@exec" value="1">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@minyear" value="#arguments.minyear#" null="#iif(len(arguments.minyear) eq 0, true, false)#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@maxyear" value="#arguments.maxyear#" null="#iif(len(arguments.maxyear) eq 0, true, false)#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@avuids" value="#arguments.avuids#" null="#iif(len(arguments.avuids) eq 0, true, false)#">
			
			<cfprocresult name="qryBudgetData" resultset="1">
		</cfstoredproc>
		
		<cfreturn qryBudgetData>
	</cffunction>
	
	
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- Road Proportional Data ------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getRoadPropDataByOrg" access="public" returntype="struct" hint="Get basic level budget data">
		<cfargument name="minyear" type="string" required="no" default="">
		<cfargument name="maxyear" type="string" required="no" default="">
		<cfargument name="organisationids" type="string" required="no" default="">
		
		<cfset var strBudgetData = structnew()>
		
		<cfstoredproc datasource="#variables.DSN2#" procedure="usp_Web_IR_getRoadPropData_OrgIDs">
			<cfprocparam type="in" cfsqltype="cf_sql_bit" dbvarname="@exec" value="1">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@minyear" value="#arguments.minyear#" null="#iif(len(arguments.minyear) eq 0, true, false)#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@maxyear" value="#arguments.maxyear#" null="#iif(len(arguments.maxyear) eq 0, true, false)#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@organisationids" value="#arguments.organisationids#" null="#iif(len(arguments.organisationids) eq 0, true, false)#">
			
			<cfprocresult name="strBudgetData.qryRoadData" resultset="1">
			<cfprocresult name="strBudgetData.qrySpendData" resultset="2">
		</cfstoredproc>
		
		<cfreturn strBudgetData>
	</cffunction>
	
	<cffunction name="getRoadPropDataByAvg" access="public" returntype="struct" hint="Get basic level budget data">
		<cfargument name="minyear" type="string" required="no" default="">
		<cfargument name="maxyear" type="string" required="no" default="">
		<cfargument name="avuids" type="string" required="no" default="">
		
		<cfset var strBudgetData = structnew()>
		
		<cfstoredproc datasource="#variables.DSN2#" procedure="usp_Web_IR_getRoadPropData_avg">
			<cfprocparam type="in" cfsqltype="cf_sql_bit" dbvarname="@exec" value="1">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@minyear" value="#arguments.minyear#" null="#iif(len(arguments.minyear) eq 0, true, false)#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@maxyear" value="#arguments.maxyear#" null="#iif(len(arguments.maxyear) eq 0, true, false)#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@avuids" value="#arguments.avuids#" null="#iif(len(arguments.avuids) eq 0, true, false)#">
			
			<cfprocresult name="strBudgetData.qryRoadData" resultset="1">
			<cfprocresult name="strBudgetData.qrySpendData" resultset="2">
		</cfstoredproc>
		
		<cfreturn strBudgetData>
	</cffunction>
	
	
	
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- National Indicator data ----------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getNIFilters" access="public" returntype="query" hint="Get basic level budget data">
		<cfargument name="natinds" type="string" required="no" default="0">
		<cfargument name="councilids" type="string" required="no" default="0">
		
		<cfset var qryFilter = querynew('temp')>
			
		<cfquery name="qryFilter" datasource="#variables.DSN2#">
			exec dbo.usp_Web_IR_getCouncilToNILink @natinds = '#arguments.natinds#', @counids = '#arguments.councilids#'
		</cfquery>
		
		<cfreturn qryFilter>
	</cffunction>
	
	<cffunction name="getNIFiltersBudget" access="public" returntype="query" hint="Get basic level budget data">
		<cfargument name="natinds" type="string" required="no" default="0">
		<cfargument name="councilids" type="string" required="no" default="0">
		
		<cfset var qryFilter = querynew('temp')>
			
		<cfquery name="qryFilter" datasource="#variables.DSN2#">
			exec dbo.usp_Web_IR_getCouncilToNILinkWBudget @natinds = '#arguments.natinds#', @counids = '#arguments.councilids#'
		</cfquery>
		
		<cfreturn qryFilter>
	</cffunction>
	
	<cffunction name="getBudgetDataByNI" access="public" returntype="query" hint="Get basic level budget data">
		<cfargument name="minyear" type="string" required="no" default="">
		<cfargument name="maxyear" type="string" required="no" default="">
		<cfargument name="nilist" type="string" required="no" default="">
		<cfargument name="organisationids" type="string" required="no" default="">
		
		<cfset var qryBudgetData = querynew('temp')>
		
		<cfstoredproc datasource="#variables.DSN2#" procedure="usp_Web_IR_getBudgetData_ByNI">
			<cfprocparam type="in" cfsqltype="cf_sql_bit" dbvarname="@exec" value="1">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@minyear" value="#arguments.minyear#" null="#iif(len(arguments.minyear) eq 0, true, false)#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@maxyear" value="#arguments.maxyear#" null="#iif(len(arguments.maxyear) eq 0, true, false)#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@nilist" value="#arguments.nilist#" null="#iif(len(arguments.nilist) eq 0, true, false)#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@organisationids" value="#arguments.organisationids#" null="#iif(len(arguments.organisationids) eq 0, true, false)#">
			
			<cfprocresult name="qryBudgetData" resultset="1">
		</cfstoredproc>
		
		<cfreturn qryBudgetData>
	</cffunction>
	
</cfcomponent>