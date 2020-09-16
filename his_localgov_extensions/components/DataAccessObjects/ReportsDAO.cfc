<cfcomponent displayname="ReportDAO" hint="Bug/Change Request tracker related data access methods" output="false" extends="his_Localgov_Extends.components.DAOManager">

	<!--- ------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="ReportsDAO" hint="Pseudo-constructor">
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		StructAppend( variables, Super.init( arguments.strConfig ) );

		return this;
		</cfscript>
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="shippingAddress" access="public" output="false" returntype="query" hint="">
		<cfargument name="DateStart"  type="string" required="yes">
		<cfargument name="DateEnd"    type="string" required="yes">
	
		<cfset var qryShipping = queryNew("temp")>
		
			<cfquery name="qryShipping" datasource="#variables.dsn5#">
			usp_rpt_ShippingAddressByDate
			@DateStart =  #CreateODBCDate(LsDateFormat(arguments.DateStart, 'dd/mmm/yyyy'))#,
			@DateEnd   =  #CreateODBCDate(LsDateFormat(arguments.DateEnd, 'dd/mmm/yyyy'))#
			</cfquery>
		
		<cfreturn qryShipping>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="InvoiceByDate" access="public" output="false" returntype="query" hint="">
		<cfargument name="DateStart"  type="string" required="yes">
		<cfargument name="DateEnd"    type="string" required="yes">
	
		<cfset var qryinvoice = queryNew("temp")>
		
			<cfquery name="qryinvoice" datasource="#variables.dsn5#">
			EXEC usp_rpt_InvoiceByDate
			@DateStart =  #CreateODBCDate(LsDateFormat(arguments.DateStart, 'dd/mmm/yyyy'))#,
			@DateEnd   =  #CreateODBCDate(LsDateFormat(arguments.DateEnd, 'dd/mmm/yyyy'))#
			</cfquery>
		
		
		<cfreturn qryinvoice>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="InvoiceFigures" access="public" output="false" returntype="query" hint="">
		<cfargument name="DateStart"  type="string" required="yes">
		<cfargument name="DateEnd"    type="string" required="yes">
	
		<cfset var qryinvoice = queryNew("temp")>
		
			<cfquery name="qryinvoice" datasource="#variables.dsn5#">
			EXEC usp_rpt_InvoiceFiguresForDownload
			@DateStart =  #CreateODBCDate(LsDateFormat(arguments.DateStart, 'dd/mmm/yyyy'))#,
			@DateEnd   =  #CreateODBCDate(LsDateFormat(arguments.DateEnd, 'dd/mmm/yyyy'))#
			</cfquery>
		
		
		<cfreturn qryinvoice>
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Deferral" access="public" output="false" returntype="query" hint="">
		<cfargument name="DateStart"  type="string" required="yes">
	
		<cfset var qryinvoice = queryNew("temp")>
		
			<cfquery name="qryinvoice" datasource="#variables.dsn5#">
			EXEC usp_rpt_InvoiceDeferral
			@DateStart =  #CreateODBCDate(LsDateFormat(arguments.DateStart, 'dd/mmm/yyyy'))#
			</cfquery>
		
		
		<cfreturn qryinvoice>
	</cffunction>
	
</cfcomponent>