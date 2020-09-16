<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/DataAccessObjects/JobsDAO.cfc $
	$Author: Bhalper $
	$Revision: 4 $
	$Date: 6/09/07 16:37 $

	Notes:
		Method naming convention:
		
			1. commit<Noun>	- e.g. commitArticle() (encapsulates add and update methods).
			2. delete<Noun>	- e.g. deleteArticle()
			3. get<Noun>	- e.g. getArticle()


--->

<cfcomponent displayname="JobsDAO" hint="Job-related data access methods" extends="his_Localgov_Extends.components.DAOManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="JobsDAO" hint="Pseudo-constructor">
	
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		StructAppend( variables, Super.init( arguments.strConfig ) );
		
		return this;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions: *GET* ----------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetJobSelects" returntype="struct" access="public" hint="returns mutilple result sets to be used in the various job select menus" output="no">
		
		<cfscript>
		var strReturn = StructNew();
		</cfscript>

		<!-- return select list from using SQL stored procedure --->
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_GetJobSelects">
			<!--- Return Regions --->
			<cfprocresult resultset="1" name="strReturn.qryRegions">
			<!--- Return Salary Ranges --->
			<cfprocresult resultset="2" name="strReturn.qrySalaries">
			<!--- Return Contract Types --->
			<cfprocresult resultset="3" name="strReturn.qryContractTypes">	
			<!--- Return Counties --->
			<cfprocresult resultset="4" name="strReturn.qryCounties">	
			<!--- Return Job Status --->
			<cfprocresult resultset="5" name="strReturn.qryStatus">		
		</cfstoredproc>
	
	<cfreturn strReturn>
	
	</cffunction>
			
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<cffunction name="ExportJobs" access="public" output="false" returntype="query" hint="export jobs for a specific partner">
		<cfargument name="PartnerID" type="numeric">
		
		<cfset var qry="">
		
		<cfquery datasource="#variables.DSN1#" name="qry">
		 sp_ExportCurrentJobs #arguments.PartnerID#
		</cfquery>
		
		<cfreturn qry>
	</cffunction>
		
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="ImportJobs" access="public" output="false" returntype="boolean" hint="import jobs from partners">
		<cfargument name="xmldoc" 	 type="string" 	required="yes">
		<cfargument name="partnerid" type="numeric" required="yes">
		
		<cfset var blReturn=true>
		<cfset var qry="">
		
		<!--- <cftry> --->
			<cfquery datasource="#variables.DSN1#" name="qry">
		 		sp_ImportXmlJobs '#arguments.xmldoc#', #arguments.partnerid#
			</cfquery>
			<!---<cfcatch type="database">
				Handle errors here
				<cfset var blReturn=false>
			 </cfcatch> 
		</cftry>--->
		 
		<cfreturn blReturn>
	</cffunction>
		
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetJobsPartners" access="public" output="false" returntype="query" hint="exec SQL to return organistaions to import/xmprt xml to" >	
			<cfargument name="hasXml" required="no" type="boolean" default="0">		
			 <cfset var qry=Querynew("temp")>
				
				<cfquery name="qry" datasource="#variables.DSN1#">
				EXEC spGetJobPartners 
					#arguments.hasXml#
				
				</cfquery>
		
			<cfreturn qry>
		</cffunction>  
		
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetJobDetails" access="public" output="false" returntype="query" hint="exec SQL to return all data on a specific job" >	
			<cfargument name="jobid" 	required="yes" type="numeric" >
			<cfargument name="PartnerID" required="no"  type="boolean" default="0">		
				
			<cfset var qry ="">		
			
			<cfquery name="qry" datasource="#variables.DSN1#">
				EXEC sp_getJobdetails 
				@PartnerID 	= #arguments.PartnerID#, 
				@JobID		= #arguments.jobid#
				</cfquery>
		
			<cfreturn qry>
		</cffunction>  	
			
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetJobsFromIndex" access="public" output="false" returntype="query" hint="exec SQL to return jobs based on clist of Id's present in collection" >	
			<cfargument name="Uids" 	required="yes" type="string">

			<cfset var qry=Querynew("temp")>
			
			<cfquery name="qry" datasource="#variables.DSN1#">
				EXEC sp_GetJobsFromIndex 
				@UID 	= '#arguments.Uids#'
			</cfquery>
		
			<cfreturn qry>
	</cffunction>  	
			
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetFeaturedJobs" access="public" output="false" returntype="query" hint="exec SQL to return jobs ads that been sold featured positions" >	
			<cfargument name="Productid" required="yes" type="string">
		

			<cfset var qry=Querynew("temp")>	
			
			<cfquery name="qry" datasource="#variables.DSN1#">
				EXEC sp_GetFeaturedJobs 
				@Productid 	= '#arguments.Productid#'
			</cfquery>
		
			<cfreturn qry>
	</cffunction>  
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetPremierJobs" access="public" output="false" returntype="struct" hint="exec SQL to return jobs ads that been sold featured and top positions" >	
			<cfargument name="Productid" required="yes" type="string">
			
			<cfset var strReturn=StructNew()>
		
			
			<cfstoredproc datasource="#variables.DSN1#" procedure="sp_GetPremierJobs">
				<cfprocparam  cfsqltype="cf_sql_varchar" type="in" dbvarname="@Productid" value="#arguments.Productid#">
					<cfprocresult resultset="1" name="strReturn.qryFeaturedJobs">
					<cfprocresult resultset="2" name="strReturn.qryTopJob">
			</cfstoredproc>

			<cfreturn strReturn>
	</cffunction> 
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetAdminJobDetails" access="public" output="false" returntype="struct" hint="exec SQL to return all data on a specific job fro cms" >	
			<cfargument name="jobid" 	required="yes" type="numeric" >
				
			<cfset var str = StructNew()>
			<cfset str.qryjob = QueryNew('temp')>
			<cfset str.qryAdStatus = QueryNew('temp')>
			
			<cfstoredproc datasource="his_websites" procedure="sp_getAdminJobdetails">
				<cfprocparam cfsqltype="cf_sql_integer" type="in" dbvarname="@jobid" value="#arguments.jobid#">
				<cfprocresult resultset="1" name="str.qryjob">
				<cfprocresult resultset="2" name="str.qryAdStatus">
			</cfstoredproc>

		
			<cfreturn str>
		</cffunction>  	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="AdminSearchJobs" access="public" output="false" returntype="query" hint="exec SQL to return jobs " >	
			<cfargument name="Productid" required="yes" type="string">	
			<cfargument name="Keywords"  required="no"  type="string" default="">
			<cfargument name="Jobid"     required="no"  type="numeric" default="0">

			<cfset var qry=Querynew("temp")>	
			
			<cfquery name="qry" datasource="#variables.DSN1#">
				EXEC sp_AdminSearchjobs 
				@Productid 	= '#arguments.Productid#',
				@Keywords 	= '#arguments.Keywords#',
				@Jobid 	    =  #arguments.Jobid#
			</cfquery>
		
			<cfreturn qry>
	</cffunction> 
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->		
	<cffunction name="AdminSearchPartnerJobs" access="public" output="false" returntype="query" hint="exec SQL to return partner jobs " >	
		<cfargument name="PartnerID" required="no" type="numeric" default="0">	
		<cfargument name="Keyword"  required="no"  type="string" default="">
			
			<cfset var qry=Querynew("temp")>	
			
			<cfquery name="qry" datasource="#variables.DSN1#">
				EXEC sp_AdminSearchPartnerJobs 
				@PartnerID 	=<cfif arguments.PartnerID>#arguments.PartnerID#<cfelse>null</cfif>, 
				@Keyword 	= '#arguments.Keyword#'
			</cfquery>
		
			<cfreturn qry>
	</cffunction> 		
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
  
	<cffunction name="GetLatest" access="public" output="false" returntype="query" hint="Get all jobs including those of partners">
		<cfargument name="hglonly" 	 type="boolean" required="no" default="0">
		<cfargument name="productid" type="string"  required="no" default="">
		<cfargument name="refresh"   type="boolean" required="no" default="0">
		
		
		<cfscript>
		var cachetime = CreateTimeSpan(0,0,0,60);
		var qry=Querynew("temp");
		if (arguments.refresh)
			cachetime = CreateTimeSpan(0,0,0,0);
		</cfscript>
		
		
		<!--- Perform query... --->
		<cfquery name="qry" datasource="#variables.DSN1#" cachedwithin="#cachetime#">
			EXEC sp_GetLatestJobs 
			@HglOnly   = #arguments.hglonly#, 
			@productid = '#arguments.productid#'
		</cfquery>
		
		<!--- Return query... --->
		<cfreturn qry>

	</cffunction>
		
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
		<cffunction name="GetAdminLatest" access="public" output="false" returntype="query" hint="Get all jobs including those of partners">
		<cfargument name="productid" type="string"  required="no" default="">
		
		<cfset var qry=Querynew("temp")>
		
		<!--- Perform query... --->
		<cfquery name="qry" datasource="#variables.DSN1#">
			EXEC sp_GetAdminLatestJobs 
			@productid = '#arguments.productid#'
		</cfquery>
		
		<!--- Return query... --->
		<cfreturn qry>

	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="AdvSearchJobs" access="public" output="false" returntype="query" hint="perorm jobs search">
		<cfargument name="productid" 		type="string"  required="yes">
		<cfargument name="keywords"  		type="string"  required="no"   default="">
		<cfargument name="hglonly" 	 		type="boolean" required="no"  default="0">
		<cfargument name="sectorid"  		type="string"  required="no"  default="">
		<cfargument name="regionid"  		type="string"  required="no"  default="">
		<cfargument name="ContractTypeid" 	type="string"  required="no"  default="">
		<cfargument name="SalaryBandLower" 	type="numeric" required="no"  default="0">
		<cfargument name="SalaryBandUpper" 	type="numeric" required="no"  default="1000000">
		
		<cfset var qryJobs=Querynew("temp")>
	
		<!--- Perform query... --->
		<cfquery name="qryJobs" datasource="#variables.DSN1#" cachedwithin="#CreateTimeSpan(0,0,0,20)#">
			EXEC sp_SearchLocalGovjobs 
			@productid       = '#arguments.productid#',
			@HglOnly         = #arguments.hglonly#, 
			@Keyword		 = <cfif Len(arguments.Keywords)>'#arguments.Keywords#'<cfelse>NULL</cfif>,
			@sectorid  	     = <cfif Len(arguments.sectorid)>'#arguments.sectorid#'<cfelse>NULL</cfif>,
			@regionid  	     = <cfif Len(arguments.regionid)>'#arguments.regionid#'<cfelse>NULL</cfif>,
			@ContractType    = <cfif Len(arguments.ContractTypeid)>'#arguments.ContractTypeid#'<cfelse>NULL</cfif>,
			@SalaryBandLower = #arguments.SalaryBandLower#,
			@SalaryBandUpper = #arguments.SalaryBandUpper#
		</cfquery>
		
		<cfreturn qryJobs>
		
	</cffunction>	
		
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
		<cffunction name="GetEmployers" access="public" returntype="query" output="false" hint="return all Employers">
		<cfargument name="Coid" required="no" type="Numeric" default="0">
			<cfset var qry="">
			<cfquery name="qry" datasource="#variables.DSN1#">
				EXEC spGetEmployers
				<cfif arguments.Coid eq 0>NULL<cfelse>#arguments.Coid#</cfif>
			</cfquery>
			<cfreturn qry>
	</cffunction>	
		
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetCompany" access="public" output="false" returntype="query" hint="return all consultants">
		<cfargument name="blActive" 	required="no" type="boolean" default="1">
		<cfargument name="CompanyType"  required="no" type="numeric" default="6">
		<cfset var qry ="">
		<cfquery name="qry" datasource="#variables.DSN1#">
			EXEC sp_GetCompanies #arguments.blActive#, #arguments.CompanyType#
		</cfquery>
		<cfreturn qry>
	</cffunction>
		
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetCompanyDetail" access="public" output="false" returntype="query" hint="return all details for a specific consultant">
		<cfargument name="Coid" required="yes" type="Numeric">
		<cfset var qry ="">
		<cfquery name="qry" datasource="#variables.DSN1#">
			EXEC sp_GetCompanyDetail #arguments.Coid#
		</cfquery>
		<cfreturn qry>
	</cffunction>	
		
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetCompanyTypes" access="public" output="false" returntype="query" hint="return all company types for this product">
		<cfargument name="ProductID" required="yes" type="Numeric">
		<cfset var qry ="">
		<cfquery name="qry" datasource="#variables.DSN1#">
			EXEC sp_GetCompanyTypes #arguments.ProductID#
		</cfquery>
		<cfreturn qry>
	</cffunction>	
		
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetAdminCompanySearch" access="public" output="false" returntype="query" hint="search companies based on types">
		
		<cfargument name="Keywords" required="yes" type="string">
		<cfargument name="TypeID" 	required="yes" type="Numeric">
		
		<cfset var qry ="">
		<cfquery name="qry" datasource="#variables.DSN1#">
			EXEC sp_AdminSearhCompanies '#arguments.Keywords#', #arguments.TypeID#
		</cfquery>
		<cfreturn qry>
	</cffunction>	
	
		<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions: *COMMIT* -------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="CommitJob" access="public" output="false" returntype="Numeric" hint="Insert/update job details">
		
		<cfargument name="ID" 			    required="no"  type="numeric" default="0">
		<cfargument name="EmployerID" 		required="yes" type="numeric">
		<cfargument name="jobtitle"         required="yes" type="string">
		<cfargument name="reference" 		required="no"  type="string" default="">
		<cfargument name="description" 		required="no"  type="string" default="">
		<cfargument name="deadline" 		required="yes" type="date">
		<cfargument name="salary" 			required="no"  type="string"  default="">
		<cfargument name="County" 			required="yes"  type="numeric" >
		<cfargument name="ContractTypeID" 	required="no"  type="numeric" default="0">
		<cfargument name="SalaryBandLower" 	required="no"  type="numeric" default="0">
		<cfargument name="SalaryBandUpper" 	required="no"  type="numeric" default="100000">
		<cfargument name="ContactEmail" 	required="no"  type="string" default="">
		<cfargument name="Sectors" 			required="yes" type="string">
		<cfargument name="IIPLogo" 			required="no"  type="boolean" default="0">
		<cfargument name="EqOpLogo" 		required="no"  type="boolean" default="0">
		<cfargument name="PartnerID" 		required="no"  type="string" default="">
		<cfargument name="ProductID" 		required="yes" type="numeric" default="0">
		
		<cfset var sRtnValue = 0>
		
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_CommitJob">
		  <cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@JobID" value="#arguments.ID#">
		  <cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@EmployerID" value="#arguments.EmployerID#"> 
		  <cfprocparam type="in"  cfsqltype="cf_sql_varchar"    	dbvarname="@jobtitle" value="#arguments.jobtitle#"> 
		  <cfprocparam type="in"  cfsqltype="cf_sql_varchar"    dbvarname="@reference" value="#arguments.reference#">
		  <cfprocparam type="in" cfsqltype="cf_sql_longvarchar" dbvarname="@description" value="#arguments.description#"> 
		  <cfprocparam type="in"  cfsqltype="cf_sql_date" 		dbvarname="@deadline" value="#arguments.deadline#">  
		  <cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@salary" value="#arguments.salary#">
		  <cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@County" value="#arguments.County#">
		  <cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@ContractTypeID" value="#arguments.ContractTypeID#"> 
		  <cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@SalaryBandLower" value="#arguments.SalaryBandLower#"> 
		  <cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@SalaryBandUpper" value="#arguments.SalaryBandUpper#"> 
		  <cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@ContactEmail" value="#arguments.ContactEmail#"> 
		  <cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@SectorID" value="#arguments.Sectors#">  
		  <cfprocparam type="in" cfsqltype="cf_sql_bit"      	dbvarname="@IIPLogo" value="#arguments.IIPLogo#"> 
		  <cfprocparam type="in" cfsqltype="cf_sql_bit"      	dbvarname="@EqOpLogo" value="#arguments.EqOpLogo#"> 
		  <cfprocparam type="in" cfsqltype="cf_sql_varchar"  	dbvarname="@PartnerID" value="#arguments.PartnerID#"> 
		  <cfprocparam type="in" cfsqltype="cf_sql_integer"  	dbvarname="@ProductID" value="#arguments.ProductID#">
		  <cfprocparam type="out" cfsqltype="cf_sql_integer" dbvarname="@NewJobID" Variable="sRtnValue"> 
		</cfstoredproc>
		
		<cfreturn sRtnValue> 
				
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="CommitJobAd" access="public" output="false" returntype="any" hint="commit job ad details for a particular job for under 1 or many websites">
		<cfargument name="jobid" 		required="yes" type="numeric" hint="primary key of job">
		<cfargument name="Productid" 	required="yes" type="numeric" hint="">
		<cfargument name="statusid" 	required="no" type="string" >
		<cfargument name="startDate" 	required="no" type="string"  default="">
		<cfargument name="endDate" 		required="no" type="string" default="">
		<cfargument name="logo" 		required="no" type="string" default="">
		
		<cfquery datasource="#variables.DSN1#">
			EXEC sp_CommitJobAdStatus
			@jobId = #arguments.jobid#,
			@productid =#arguments.Productid#,
			@statusid = <cfif Len(arguments.statusid) and IsNumeric(arguments.statusid)>#arguments.statusid#<cfelse>NULL</cfif>,
			@startDate = <cfif Len(arguments.startDate) and isDate(arguments.startDate)>#CreateODBCDateTime(arguments.startDate)#<cfelse>null</cfif> ,
			@enddate =<cfif Len(arguments.enddate) and isDate(arguments.enddate)>#CreateODBCDateTime(arguments.enddate)#<cfelse>null</cfif>,
			@logo =<cfif Len(logo)>'#arguments.logo#'<cfelse>null</cfif>
		</cfquery>
	
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="CommitEmployer" access="public" output="false" returntype="Numeric" hint="Insert/update employer details">
		
		<cfargument name="EmployerID" required="no"  type="numeric" default="0">
		<cfargument name="company_name"  required="yes" type="string" >
		<cfargument name="email" required="yes" type="string">
		<cfargument name="website"   required="yes" type="string">
		
		<cfset var sRtnValue = 0>

		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_CommitEmployer">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" dbvarname="@EmployerID" 	value="#arguments.EmployerID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@company_name" value="#arguments.company_name#"> 
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@email" 		value="#arguments.email#"> 
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@website" 	value="#arguments.website#">
			<cfprocparam type="out" cfsqltype="cf_sql_integer" dbvarname="@EmployerID" 	variable="sRtnValue"> 
		</cfstoredproc>
		
		<cfreturn sRtnValue>
				
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="CommitCompany" access="public" output="false" returntype="Numeric" hint="Insert/update Company details">
		
		<cfargument name="id" 				required="no"  type="numeric" default="0">
		<cfargument name="CompanyTypeID"  	required="yes" type="numeric" >
		<cfargument name="company_name"  	required="yes" type="string" >
		<cfargument name="Address1"  		required="no" type="string" default="">
		<cfargument name="Address2"  		required="no" type="string" default="">
		<cfargument name="Address3"  		required="no" type="string" default="">
		<cfargument name="town"  			required="no" type="string" default="">
		<cfargument name="county"  			required="no" type="string" default="">
		<cfargument name="postcode"  		required="no" type="string" default="">
		<cfargument name="tel"  			required="no" type="string" default="">
		<cfargument name="fax"  			required="no" type="string" default="">
		<cfargument name="email" 			required="no" type="string" default="">
		<cfargument name="website"   		required="no" type="string" default="">
		<cfargument name="Profile"   		required="no" type="string" default="">
		<cfargument name="advStart"   		required="yes" type="date"  >
		<cfargument name="advEnd"   		required="yes" type="date"  >
		
		<cfscript>
		var sRtnValue = 0;
		</cfscript>
		
			<!--- <cfdump var="#arguments#"><cfabort>  --->
		
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_CommitCompany">
			 <cfprocparam type="in"  cfsqltype="cf_sql_integer" dbvarname="@Companyid" 	value="#arguments.id#">
			 <cfprocparam type="in"  cfsqltype="cf_sql_integer" dbvarname="@CompanyTypeID" 	value="#arguments.CompanyTypeID#">
			  <cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@company_name" 	value="#arguments.company_name#">
			  <cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@Address1" 	value="#arguments.Address1#">
			  <cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@Address2" 	value="#arguments.Address2#">
			  <cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@Address3" 	value="#arguments.Address3#">
			  <cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@town" 	value="#arguments.town#">
			  <cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@county" 	value="#arguments.county#">
			  <cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@postcode" 	value="#arguments.postcode#">
			  <cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@tel" 	value="#arguments.tel#">
			  <cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@fax" 	value="#arguments.fax#">
			  <cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@email" 	value="#arguments.email#">
			  <cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@website" 	value="#arguments.website#">
			  <cfprocparam type="in"  cfsqltype="cf_sql_longvarchar" dbvarname="@Profile" 	value="#arguments.Profile#">
			  <cfprocparam type="in"   cfsqltype="cf_sql_date" 		 dbvarname="@advStart" 	value="#arguments.advStart#"> 
			  <cfprocparam type="in"   cfsqltype="cf_sql_date" 		 dbvarname="@advEnd" 	value="#arguments.advEnd#">
			<cfprocparam type="out"   cfsqltype="cf_sql_integer" 	 dbvarname="@NewCompanyID" variable="sRtnValue"> 
		</cfstoredproc> 

	 <cfreturn sRtnValue>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="CommitPartnerJob" access="public" output="false" returntype="Numeric" hint="Insert/update Partner's Job details">
		
		<cfargument name="ID" 			    required="no"  type="numeric" default="0">
		<cfargument name="PartnerID" 		required="yes"  type="numeric" >
		<cfargument name="userid" 			required="yes"  type="numeric" >
		<cfargument name="Employer" 		required="yes" type="string">
		<cfargument name="jobtitle"         required="yes" type="string">
		<cfargument name="reference" 		required="no"  type="string" default="">
		<cfargument name="email" 			required="no"  type="string" default="">
		<cfargument name="description" 		required="no"  type="string" default="">
		<cfargument name="deadline" 		required="yes" type="date">
		<cfargument name="salary" 			required="no"  type="string"  default="">
		<cfargument name="County" 			required="yes" type="string" >
		<cfargument name="ContractType" 	required="no"  type="string" default="">
		<cfargument name="SalaryBandLower" 	required="no"  type="numeric" default="0">
		<cfargument name="SalaryBandUpper" 	required="no"  type="numeric" default="100000">
		<cfargument name="Sectors" 			required="yes" type="string">
		<cfargument name="joburl" 			required="no" type="string" default="">
		
		<cfset var sRtnValue = 0>
	
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_AdminCommitPartnerJob">
		    <cfprocparam type="in"  cfsqltype="cf_sql_integer" dbvarname="@id" 	value="#arguments.id#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" dbvarname="@partnerid" value="#arguments.partnerid#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" dbvarname="@userid" value="#arguments.userid#">			
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@jobtitle" value="#arguments.jobtitle#">
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@email" value="#arguments.email#">
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@employer" value="#arguments.employer#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" dbvarname="@salarybandlower" value="#arguments.salarybandlower#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" dbvarname="@SalaryBandUpper" value="#arguments.SalaryBandUpper#">
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@contracttype" value="#arguments.contracttype#">
			<cfprocparam type="in"  cfsqltype="cf_sql_date" dbvarname="@deadline" value="#LSParseDateTime(arguments.deadline)#">
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@sectors" value="#arguments.Sectors#">
			<cfprocparam type="in"  cfsqltype="cf_sql_longvarchar" dbvarname="@description" value="#arguments.description#">
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@county" value="#arguments.county#">
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@reference" value="#arguments.reference#">
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@joburl" value="#arguments.joburl#">
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" dbvarname="@salary" value="#arguments.salary#">
			<cfprocparam type="out" cfsqltype="cf_sql_integer" dbvarname="@newID" variable="sRtnValue">	
		</cfstoredproc>	
		
		<cfreturn sRtnValue> 
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions: *DELETE* -------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="deleteJob" access="public" output="false" returntype="boolean" hint="delete specific job">
		
		<cfargument name="JobID" type="numeric" required="yes">
		
		<cfstoredproc datasource="#variables.DSN1#" procedure="spDeleteJob">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@JobID" value="#arguments.jobid#">
		</cfstoredproc>
		
		<cfreturn true>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="deleteCompany" access="public" output="false" returntype="boolean" hint="delete Company job">
		
		<cfargument name="ID" type="numeric" required="yes">
		
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_DeleteCompany">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@ID" value="#arguments.id#">
		</cfstoredproc>
		
		<cfreturn true>
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="deletePartnerJob" access="public" output="false" returntype="boolean" hint="delete specific partner job">
	<cfargument name="id" type="numeric" required="yes">
		
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_AdminDeletePartnerJob">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@Uid" value="#arguments.id#">
		</cfstoredproc>
		
		<cfreturn true>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PRIAVTE Functions ----------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->

</cfcomponent>