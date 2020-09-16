<!--- 
	
	$Archive: /localgov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/DataAccessObjects/DirectoryDAO.cfc $
	$Author: Bhalper $
	$Revision: 14 $
	$Date: 31/03/10 16:51 $

	Notes:
		Method naming convention:
		
			1. commit<Noun>	- e.g. commitArticle() (encapsulates add and update methods).
			2. delete<Noun>	- e.g. deleteArticle()
			3. get<Noun>	- e.g. getArticle()

--->

<cfcomponent displayname="DirectoryDAO" hint="Article-related data access methods" extends="his_Localgov_Extends.components.DAOManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="DirectoryDAO" hint="Pseudo-constructor">
	
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		StructAppend( variables, Super.init( arguments.strConfig ) );
		
		variables.qryOrganisation = GetOrganisations();
		variables.qryCouncilTypes = GetAttributeData(25);
		//variables.qryLookups 	  = GetLookUps();
	     
		return this;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Get Functions -------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetOrganisations" access="public" output="false" returntype="query" hint="return all orgaistaions">
				
		<cfset var qry = ""> 
		<cfif StructKeyExists(variables, "qryOrganisation")>
			<cfreturn variables.qryOrganisation>
		<cfelse>
			<cfquery datasource="#variables.DSN2#" name="qry">
				EXEC sp_GetOrganisations
			</cfquery>
			<cfreturn qry>	
		</cfif>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<cffunction name="GetOrgDetails" access="public" output="false" returntype="struct" hint="return all data for a specific organisation">
		<cfargument name="OrgID"    		required="yes" 	type="numeric">
		<cfargument name="orgType" 			required="no" 	type="string" default="">
		<cfargument name="lstAttributeID" 	required="no" 	type="string" default="">  
		
			<cfscript>
			var strOrg 			 	= StructNew();
			/*var qryAddress 		 	= QueryNew("temp");
			var qryAttributes 	 	= QueryNew("temp");
			var qryPersonnel 	 	= QueryNew("temp");
			var qryRelatedCouncils  = QueryNew("temp");
			var qryTrusts 	 		= QueryNew("temp");*/
			</cfscript>
			
		 	 <cfstoredproc  datasource="#variables.DSN2#" procedure="sp_GetOrgDetails" returncode="yes">
				<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@orgID" value="#arguments.Orgid#">
				<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@OrgType" value="#arguments.OrgType#">
				<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@lstAttributeID" value="#arguments.lstAttributeID#">
				<cfprocresult resultset="1" name="strOrg.qryAttributes"> 
				<cfprocresult resultset="2" name="strOrg.qryAddress"> 
				<cfprocresult resultset="3" name="strOrg.qryPersonnel">
				<cfprocresult resultset="4" name="strOrg.qryRelatedCouncils">
				<cfprocresult resultset="5" name="strOrg.qryTrusts">
			</cfstoredproc> 
			
				<cfscript>
				/*strOrg.qryAddress 		= qryAddress;
				strOrg.qryAttributes	= qryAttributes;
				strOrg.qryPersonnel 	= qryPersonnel;
				strOrg.qryRelatedCouncils = qryRelatedCouncils;
				strOrg.qryTrusts = qryTrusts;*/
				strOrg.blStatus			= cfstoredproc.statusCode;
				return strOrg; 
				</cfscript>
			
	</cffunction>
		<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<cffunction name="GetCouncilDetails" access="public" output="false" returntype="struct" hint="return all data for a specific council">
		<cfargument name="OrgID"    		required="yes" 	type="numeric">
		<cfargument name="lstAttributeID" 	required="no" 	type="string" default="">  
		
		<cfscript>
		var strOrg 			= StructNew();
		/*var qryAddress 		= QueryNew("temp");
		var qryAttributes 	= QueryNew("temp");
		var qryOfficers 	= QueryNew("temp");
		var qryCouncillors 	= QueryNew("temp");
		var qryCommittees	= QueryNew("temp");
		var qryParl			= QueryNew("temp");
		var qryContract		= QueryNew("temp");	
		var qryPolComp		= QueryNew("temp");
		var qryCabinets		= QueryNew("temp");
		var qryHousing		= QueryNew("temp");
		var qryTopography	= QueryNew("temp");
		var qryFandF		= QueryNew("temp");
		var qryAlmo			= QueryNew("temp");
		var qryTier2Officers = QueryNew("temp");*/
		</cfscript>
	
		
		<cfstoredproc datasource="#variables.DSN2#" procedure="sp_GetCouncilDetails" returncode="yes">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@orgID" value="#arguments.Orgid#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@lstAttributeID" value="#arguments.lstAttributeID#">
				<cfprocresult resultset="1" name="strOrg.qryAttributes"> 
				<cfprocresult resultset="2" name="strOrg.qryAddress"> 
				<cfprocresult resultset="3" name="strOrg.qryOfficers">
				<cfprocresult resultset="4" name="strOrg.qryCouncillors"> 
				<cfprocresult resultset="5" name="strOrg.qryCommittees"> 
				<cfprocresult resultset="6" name="strOrg.qryParl"> 
				<cfprocresult resultset="7" name="strOrg.qryContract">
				<cfprocresult resultset="8" name="strOrg.qryPolComp">
				<cfprocresult resultset="9" name="strOrg.qryCabinets">
				<cfprocresult resultset="10" name="strOrg.qryHousing">
				<cfprocresult resultset="11" name="strOrg.qryAlmo">
				<cfprocresult resultset="12" name="strOrg.qryTier2Officers">
		</cfstoredproc>
		
		<cfscript>
		/*strOrg.qryAddress 		=qryAddress;
		strOrg.qryAttributes	=qryAttributes;
		strOrg.qryOfficers 		=qryOfficers;
		strOrg.qryCouncillors 	=qryCouncillors;
		strOrg.qryCommittees 	=qryCommittees;
		strOrg.qryParl 			=qryParl;
		strOrg.qryContract 		=qryContract;
		strOrg.qryPolComp 		=qryPolComp;
		strOrg.qryCabinets 		=qryCabinets;
		strOrg.qryHousing 		=qryHousing;
		strOrg.qryAlmo			=qryAlmo;
		strOrg.qryTier2Officers =qryTier2Officers;*/
		
		strOrg.blStatus	= cfstoredproc.statusCode;		
		return strOrg; 
		</cfscript>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<cffunction name="GetOrgSearch" access="public" output="false" returntype="query" hint="return organisations based on organisation type">
		<cfargument name="orgTypeid" required="no" type="numeric" default="0">
		<cfargument name="Keyword"  required="no" type="string" default="">
			
		<cfset var qry = QueryNew("temp")>
		
		<cfquery datasource="#variables.DSN2#" name="qry" cachedwithin="#CreateTimeSpan(0,0,1,0)#">
			EXEC sp_GetOrgSearch
					@orgTypeID = <cfif arguments.orgTypeid>#arguments.orgTypeid#<cfelse>NULL</cfif>,
					@Keyword =   '#arguments.Keyword#'
		</cfquery>

		<cfreturn qry>	
			
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<cffunction name="GetAssocDetails" access="public" output="false" returntype="struct" hint="return all data for a specific Association">
		<cfargument name="OrgID"    		required="yes" 	type="numeric">
		<cfargument name="orgType" 			required="no" 	type="string" default="">
	  
		<cfscript>
		var strOrg 			 = StructNew();
		/*var qryAddress 		 = QueryNew("temp");
		var qryPersonnel 	 = QueryNew("temp");
		var qryRegional 	 = QueryNew("temp");*/
		</cfscript>
		
		 <cfstoredproc  datasource="#variables.DSN2#" procedure="sp_GetAssocDetails" returncode="yes">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@orgID" value="#arguments.Orgid#">
			<cfprocresult resultset="1" name="strOrg.qryAddress"> 
			<cfprocresult resultset="2" name="strOrg.qryPersonnel"> 
			<cfprocresult resultset="3" name="strOrg.qryRegional">
			<!--- <cfprocresult resultset="4" name="strOrg.qryPersonnel"> --->
			
		</cfstoredproc> 
		
		<cfscript>
		/*strOrg.qryAddress 		= qryAddress;
		strOrg.qryPersonnel 	= qryPersonnel;
		strOrg.qryRegional 		= qryRegional;
		strOrg.qryPersonnel		= qryPersonnel;*/
		
		strOrg.blStatus			= cfstoredproc.statusCode;
		return strOrg; 
		</cfscript>
			
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetCentralGovDetails" access="public" output="false" returntype="struct" hint="return all data for a specific Central Gov Org">
		<cfargument name="OrgID"    		required="yes" 	type="numeric">
		  	
		<cfscript>
		var strOrg 			 = StructNew();
		/*var qryAddress 		 = QueryNew("temp");
		var qryPersonnel 	 = QueryNew("temp");
		var qryExecs 	 	 = QueryNew("temp");
		var qryRegional 	 = QueryNew("temp");
		var qrySubs			 = QueryNew("temp");*/
		</cfscript>
		
		 <cfstoredproc  datasource="#variables.DSN2#" procedure="sp_GetCentralGovDetails" returncode="yes">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@orgID" value="#arguments.Orgid#">
			<cfprocresult resultset="1" name="strOrg.qryAddress"> 
			<cfprocresult resultset="2" name="strOrg.qryPersonnel"> 
			<cfprocresult resultset="3" name="strOrg.qryExecs"> 
			<cfprocresult resultset="4" name="strOrg.qrySubs">
			<cfprocresult resultset="5" name="strOrg.qryRegional">
		</cfstoredproc> 
		
		<cfscript>
		/*strOrg.qryAddress 		= qryAddress;
		strOrg.qryPersonnel 	= qryPersonnel;
		strOrg.qryExecs 		= qryExecs;
		strOrg.qryPersonnel		= qryPersonnel;
		strOrg.qryRegional		= qryRegional;
		strOrg.qrySubs			= qrySubs;*/
		
		strOrg.blStatus			= cfstoredproc.statusCode;
		return strOrg; 
		</cfscript>
			
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetParishDetails" access="public" output="false" returntype="struct" hint="return all data for a specific Parish Council Associtaion">
		<cfargument name="OrgID"    		required="yes" 	type="numeric">
		  	
		<cfscript>
		var strOrg 			 = StructNew();
		/*var qryAddress 		 = QueryNew("temp");
		var qryPersonnel 	 = QueryNew("temp");
		var qryParishes 	 = QueryNew("temp");
		var qryRegional 	 = QueryNew("temp");
		var qrySubs			 = QueryNew("temp");*/
		</cfscript>
		
		 <cfstoredproc  datasource="#variables.DSN2#" procedure="sp_GetParishDetails" returncode="yes">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@orgID" value="#arguments.Orgid#">
			<cfprocresult resultset="1" name="strOrg.qryAddress"> 
			<cfprocresult resultset="2" name="strOrg.qryPersonnel"> 
			<cfprocresult resultset="3" name="strOrg.qryParishes"> 
			
		</cfstoredproc> 
		
		<cfscript>
		/*strOrg.qryAddress 		= qryAddress;
		strOrg.qryPersonnel 	= qryPersonnel;
		strOrg.qryParishes 		= qryParishes;*/
		strOrg.blStatus			= cfstoredproc.statusCode;
		return strOrg; 
		</cfscript>
			
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<cffunction name="GetHousingDetails" access="public" output="false" returntype="struct" hint="return all data for a specific Parish Council Associtaion">
		<cfargument name="OrgID"    		required="yes" 	type="numeric">
		  	
		<cfscript>
		var strOrg 			 	= StructNew();
		/*var qryAddress 		 	= QueryNew("temp");
		var qryPersonnel 	 	= QueryNew("temp");
		var qryRelatedCouncils 	= QueryNew("temp");
		var qryTypes 			= QueryNew("temp");*/
		</cfscript>
		
		 <cfstoredproc  datasource="#variables.DSN2#" procedure="sp_GetHousingDetails" returncode="yes">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@orgID" value="#arguments.Orgid#">
			<cfprocresult resultset="1" name="strOrg.qryAddress"> 
			<cfprocresult resultset="2" name="strOrg.qryPersonnel"> 
			<cfprocresult resultset="3" name="strOrg.qryRelatedCouncils"> 
			<cfprocresult resultset="4" name="strOrg.qryTypes"> 
			
		</cfstoredproc> 
		
		<cfscript>
		/*strOrg.qryAddress 			= qryAddress;
		strOrg.qryPersonnel 		= qryPersonnel;
		strOrg.qryRelatedCouncils 	= qryRelatedCouncils;
		strOrg.qryTypes 			= qryTypes;*/
		strOrg.blStatus				= cfstoredproc.statusCode;
		return strOrg; 
		</cfscript>
			
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<cffunction name="GetEmergencyDetails" access="public" output="false" returntype="struct" hint="return all data for a specific Emergency Service">
		<cfargument name="OrgID"    		required="yes" 	type="numeric">
		  	
		<cfscript>
		var strOrg 			 = StructNew();
		/*var qryAddress 		 = QueryNew("temp");
		var qryPersonnel 	 = QueryNew("temp");
		var qryAttributes 	 = QueryNew("temp");*/
		</cfscript>
		
		 <cfstoredproc  datasource="#variables.DSN2#" procedure="sp_GetEmergencyDetails" returncode="yes">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@orgID" value="#arguments.Orgid#">
			<cfprocresult resultset="1" name="strOrg.qryAddress"> 
			<cfprocresult resultset="2" name="strOrg.qryPersonnel"> 
			<cfprocresult resultset="3" name="strOrg.qryAttributes"> 
			
		</cfstoredproc> 
		
		<cfscript>
		/*strOrg.qryAddress 		= qryAddress;
		strOrg.qryPersonnel 	= qryPersonnel;
		strOrg.qryAttributes 	= qryAttributes;*/
		strOrg.blStatus			= cfstoredproc.statusCode;
		return strOrg; 
		</cfscript>
			
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<cffunction name="GetAuditorDetails" access="public" output="false" returntype="struct" hint="return all data for a specific Parish Council Associtaion">
		<cfargument name="OrgID"    		required="yes" 	type="numeric">
		  	
		<cfscript>
		var strOrg 			 	= StructNew();
		/*var qryAddress 		 	= QueryNew("temp");
		var qryPersonnel 	 	= QueryNew("temp");
		var qryRelatedCouncils 	= QueryNew("temp");*/
		</cfscript>
		
		 <cfstoredproc  datasource="#variables.DSN2#" procedure="sp_GetAuditorDetails" returncode="yes">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@orgID" value="#arguments.Orgid#">
			<cfprocresult resultset="1" name="strOrg.qryAddress"> 
			<cfprocresult resultset="2" name="strOrg.qryPersonnel"> 
			<cfprocresult resultset="3" name="strOrg.qryRelatedCouncils"> 
			
		</cfstoredproc> 
		
		<cfscript>
		/*strOrg.qryAddress 			= qryAddress;
		strOrg.qryPersonnel 		= qryPersonnel;
		strOrg.qryRelatedCouncils 	= qryRelatedCouncils;*/
		strOrg.blStatus				= cfstoredproc.statusCode;
		return strOrg; 
		</cfscript>
			
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<cffunction name="GetPortDetails" access="public" output="false" returntype="struct" hint="return all data for a specific Parish Council Associtaion">
		<cfargument name="OrgID"    		required="yes" 	type="numeric">
		  	
		<cfscript>
		var strOrg 			 	= StructNew();
		/*var qryAddress 		 	= QueryNew("temp");
		var qryPersonnel 	 	= QueryNew("temp");
		var qryRelatedCouncils 	= QueryNew("temp");*/
		</cfscript>
		
		 <cfstoredproc  datasource="#variables.DSN2#" procedure="sp_GetPortDetails" returncode="yes">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@orgID" value="#arguments.Orgid#">
			<cfprocresult resultset="1" name="strOrg.qryAddress"> 
			<cfprocresult resultset="2" name="strOrg.qryPersonnel"> 
			<cfprocresult resultset="3" name="strOrg.qryRelatedCouncils"> 
			
		</cfstoredproc> 
		
		<cfscript>
		/*strOrg.qryAddress 			= qryAddress;
		strOrg.qryPersonnel 		= qryPersonnel;
		strOrg.qryRelatedCouncils 	= qryRelatedCouncils;*/
		strOrg.blStatus				= cfstoredproc.statusCode;
		return strOrg; 
		</cfscript>
			
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<cffunction name="GetAllPeople" access="public" output="false" returntype="query" hint="return all people">
		<cfset var qry = ""> 

		<cfquery datasource="#variables.DSN2#" name="qry" >
			EXEC sp_GetAllPeople
		</cfquery>

		<cfreturn qry>	
	</cffunction>	
<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetPerson" access="public" output="false" returntype="struct" hint="return all details for a specific person">
		<cfargument name="PersonID" required="yes" type="numeric">
		<cfargument name="FullName" required="no" type="string" default="">
				
		<cfset var str = StructNew()> 
		
		 <cfstoredproc datasource="#variables.DSN2#" procedure="sp_GetPersonDetails" returncode="yes">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" variable="@PersonID" value="#arguments.PersonID#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="@fullname" value="#arguments.FullName#">
			<cfprocresult name="str.qryPerson">
	 	</cfstoredproc>
		
		<!--- <cfset str.qryPerson =qryPerson>
		<cfset str.StatusCode =cfstoredproc.StatusCode>

		<cfreturn str>	 --->
		
		<cfscript>
		/* str.qryPerson =qryPerson;*/
		 str.StatusCode =cfstoredproc.StatusCode;
		 return str;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<cffunction name="SearchPerson" access="public" output="false" returntype="query" hint="return all details for a specific person">
		<cfargument name="OrgType" required="no" type="string" default="">
		<cfargument name="FullName"  required="no" type="string" default="">
		<cfset var qryPeron="">
				
		<cfquery datasource="#variables.DSN2#" name="qryPeron" cachedwithin="#CreateTimeSpan(0,0,20,0)#">
				EXEC sp_GetPeopleByFullname  
				<cfif Len(arguments.FullName)>'#arguments.FullName#'<cfelse>NULL</cfif>,
				<cfif Len(arguments.OrgType)>'#arguments.OrgType#'<cfelse>NULL</cfif>
			</cfquery>
		
		
		<cfreturn qryPeron>	
		
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetFunctions" access="public" output="false" returntype="query" hint="return all job functions">
		<cfargument name="TypeID"     required="no" type="numeric" default="0">
		<cfargument name="FunctionID" required="no" type="string" default="">		
		<cfset var qry = ""> 
		
			<cfquery datasource="#variables.DSN2#" name="qry" cachedwithin="#variables.CACHE_TIME#">
				EXEC sp_GetFunctions  
				@FunctionTypeID = <cfif arguments.TypeID eq 0>null<cfelse>#arguments.TypeID#</cfif>, 
				@FunctionID='#arguments.FunctionID#'
			</cfquery>
			<cfreturn qry>	
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetOfficersByFunction" access="public" output="false" returntype="query" hint="return all job functions">
		<cfargument name="FunctionID" required="no" type="string" default="">	
		<cfargument name="PersonName" required="no" type="string" default="">
		<cfargument name="council"    required="no" type="string" default="">
		
		<cfset var qryOff = ""> 
			<cfquery datasource="#variables.DSN2#" name="qryOff" cachedwithin="#CreateTimeSpan(0,0,0,45)#">
				EXEC sp_GetOfficersByFunction 
				@FunctionID = <cfif Len(arguments.FunctionID)>'#arguments.FunctionID#'<cfelse>NULL</cfif>,
				@personName = <cfif Len(arguments.PersonName)>'#arguments.PersonName#'<cfelse>NULL</cfif>,
				@council 	= <cfif Len(arguments.council)>'#arguments.council#'<cfelse>NULL</cfif>
			</cfquery>
			<cfreturn qryOff>	
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetCouncillors" access="public" output="false" returntype="query" hint="return all councuilllors  by function">
		<cfargument name="Functionid" required="no" type="string" default="">
		<cfargument name="Party"    required="no" type="string" default="">	
		<cfargument name="PersonID"   required="no" type="string" default="">	
		<cfset var qry = ""> 
		
			<cfquery datasource="#variables.DSN2#" name="qry" cachedwithin="#CreateTimeSpan(0,0,0,45)#">
				EXEC sp_GetCouncillors 
				@Function ='#arguments.Functionid#',
				@Party    = <cfif Len(Party) OR Party neq '0'>'#arguments.Party#'<cfelse>NULL</cfif>,
				@PersonID	='#arguments.PersonID#'
			</cfquery>
			<cfreturn qry>	
		
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetCouncilOfficerFunctions" access="public" output="false" returntype="query" hint="return a query containing council functions">

		<cfset var qryCouncilFunctions = ""> 
		
		<cfquery name="qryCouncilFunctions" datasource="#variables.DSN1#" cachedwithin="#variables.CACHE_TIME#">
		EXEC sp_GetCouncilOfficerFunctions
		</cfquery>
		
		<cfreturn qryCouncilFunctions>
				
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetCouncillorsByName" access="public" output="false" returntype="query" hint="return all councillors based on search cirteria">
		<cfargument name="Functionid" required="no" type="string" default="">
		<cfargument name="Party"    required="no" type="string" default="">	
		<cfargument name="personName"   required="no" type="string" default="">	
		<cfset var qry = ""> 
		
			<cfquery datasource="#variables.DSN2#" name="qry" cachedwithin="#CreateTimeSpan(0,0,0,45)#">
				EXEC sp_GetCouncillorsByName 
				@Function ='#arguments.Functionid#',
				@Party    = <cfif Len(arguments.Party) OR Party neq '0'>'#arguments.Party#'<cfelse>NULL</cfif>,
				@Fullname	=<cfif Len(arguments.personName)>'#arguments.personName#'<cfelse>NULL</cfif>
			</cfquery>
			<cfreturn qry>	
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetAttributeData" access="public" output="false" returntype="query" hint="return Attribute values from Attribute Data based on AttributeID">
			<cfargument name="AtributeID"  required="yes" type="string" >	
		
			<cfset var qry = ""> 
			
			<cfquery datasource="#variables.DSN2#" name="qry">
				EXEC sp_GetAttributeLookUps 
				'#arguments.AtributeID#'
			</cfquery>
			<cfreturn qry>	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetOrgByAttributeData" access="public" output="false" returntype="query" hint="return orgs based on search criteria">
			<cfargument name="OrgTypeID"      required="yes" type="numeric"  >	
			<cfargument name="AtributeID"     required="yes" type="string" >
			<cfargument name="AttributeData"  required="no" type="string" default="" >	
			<cfargument name="OrgID"  		  required="no" type="string" default="" >		
		 
			<cfset var qry = ""> 
			
			<cfquery datasource="#variables.DSN2#" name="qry" cachedwithin="#variables.CACHE_TIME#">
				EXEC sp_GetOrgDetailsByAttribute 
				@OrgTypeID 				='#arguments.OrgTypeID#',
				@SearchAttribute 		= '#arguments.AtributeID#',
				@SearchAttributeData 	='#arguments.AttributeData#',
				@OrgID					= '#arguments.OrgID#'
			</cfquery>
			<cfreturn qry>	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetCouncilSearch" access="public" output="false" returntype="query" hint="return councils based on search criteria"> 
			<cfargument name="OrgID"       	  required="no" type="string" default="">	
			<cfargument name="CouncilType"    required="no" type="string" default="">
			<cfargument name="Country"  	  required="no" type="string" default="" >	
			<cfargument name="Councilname"  required="no" type="string" default="" >
			
		 
			<cfset var qry = ""> 
			
			<cfquery datasource="#variables.DSN2#" name="qry" cachedwithin="#CreateTimeSpan(0,0,0,45)#">
				EXEC sp_GetCouncilSearch 
				@OrgID 		 =<cfif NOT Len(arguments..OrgID) or arguments.OrgID eq 0>NULL<cfelse>'#arguments.OrgID#'</cfif>,
				@CouncilType = '#arguments.CouncilType#',
				@Country 	 ='#arguments.Country#',
				@CouncilName 	 =<cfif len(arguments.Councilname)>'#arguments.Councilname#'<cfelse>NULL</cfif>
			</cfquery>
			<cfreturn qry>	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetPersonSearch" access="public" output="false" returntype="query" hint="run search to return all person(s)">
			<cfargument name="OrgTypeID" required="no" type="string" default="">	
			<cfargument name="PersonID"  required="no" type="string" default="">
			
			<cfset var qry = ""> 
			
			<cfquery datasource="#variables.DSN2#" name="qry" cachedwithin="#CreateTimeSpan(0,0,0,45)#">
				EXEC sp_GetPersonSearch 
				@OrgTypeID 	='#arguments.OrgTypeID#',
				@PersonID 	='#arguments.PersonID#'		
			</cfquery>
			<cfreturn qry>	
			
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetLookUps" access="public" output="false" returntype="query" hint="return alllook up value">
		<cfargument name="LookUPID" required="yes" type="string">
		<cfset var qry = ""> 
		<cfif StructKeyExists(variables, "qryLookups")>
			<cfreturn variables.qryLookups>
		<cfelse>
			<cfquery datasource="#variables.DSN2#" name="qry">
				EXEC sp_getLookUps 
			<!--- 	'#arguments.LookUPID#' --->
			</cfquery>
			<cfreturn qry>	
		</cfif>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetAssocSearh" access="public" output="false" returntype="query" hint="search for assocaition based on keyword(s) and section(s)">
		<cfargument name="keyword" 		 required="no" type="string" default="">	
		<cfargument name="Sector"  	     required="no" type="string" default="">
		
		<cfset var qry = ""> 
		
			<cfquery datasource="#variables.DSN2#" name="qry" cachedwithin="#CreateTimeSpan(0,0,0,45)#">
				EXEC sp_GetAssoications
				@keyword 	= <cfif Len(arguments.keyword)>'#arguments.keyword#'<cfelse>NULL</cfif>,
				@Sector  	= <cfif Len(arguments.Sector)>'#arguments.Sector#'<cfelse>NULL</cfif>
			</cfquery>
			<cfreturn qry>	
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetCentralGovSearh" access="public" output="false" returntype="query" hint="search for central gov orgs based on keyword(s) and section(s)">
		<cfargument name="keyword" 		 required="no" type="string" default="">	
		<cfargument name="Sector"  	     required="no" type="string" default="">
		
		<cfset var qry = ""> 
		
			<cfquery datasource="#variables.DSN2#" name="qry" cachedwithin="#CreateTimeSpan(0,0,0,45)#">
				EXEC sp_GetCentralGov
				@keyword 	= <cfif Len(arguments.keyword)>'#arguments.keyword#'<cfelse>NULL</cfif>,
				@Sector  	= <cfif Len(arguments.Sector)>'#arguments.Sector#'<cfelse>NULL</cfif>
			</cfquery>
			<cfreturn qry>	
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetStats" access="public" output="true" returntype="query" hint="return council statistics based on type">
		<cfargument name="Stattype" required="yes" type="string" >	
	
		<cfset var qry = ""> 
		
	    	<cfquery datasource="#variables.DSN2#" name="qry" cachedwithin="#CreateTimeSpan(0,0,5,0)#">
				EXEC sp_GetCouncilsStats
				@StatType 		= '#Trim(arguments.Stattype)#'
			</cfquery>
			
			<cfreturn qry>	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<cffunction name="GetPoliticalCompStats" access="public" output="true" returntype="query" hint="return council statistics based on type">
		<cfargument name="Country" required="no" type="string" default="">	
	
		<cfset var qry = ""> 
	
	    	<cfquery datasource="#variables.DSN2#" name="qry" cachedwithin="#CreateTimeSpan(0,0,5,0)#">
				EXEC sp_GetPolticalCompStats
				@Country 		= <cfif Len(Country)>'#Trim(arguments.Country)#'<cfelse>NULL</cfif>
			</cfquery>
			
			<cfreturn qry>	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<cffunction name="GetAttributes" access="public" output="false" returntype="query" hint="return all org attribute">
	<cfset var qry = ""> 
		<cfquery name="qry" datasource="#variables.DSN2#">
		EXEC sp_GetAttributes
		</cfquery>
	<cfreturn qry>	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetCountryStats" access="public" output="false" returntype="query" hint="return country and relevant stat type">
		
		<cfset var qry = ""> 
		
		<cfquery datasource="#variables.DSN2#" name="qry" cachedwithin="#CreateTimeSpan(0,1,0,0)#">
			EXEC sp_GetCountryStats	
		</cfquery>

		<cfreturn qry>	
			
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<cffunction name="GetConstituencySearch" access="public" output="false" returntype="query" hint="return results of search in Constituency">
		<cfargument name="ConstituencyType" required="yes" type="string">	
		<cfargument name="searchtype" 	    required="yes" type="string">
		<cfargument name="keywords" 		required="no" type="string" default="">	
		<cfargument name="Country" 		    required="no" type="string" default="">	
		<cfargument name="party" 		    required="no" type="string" default="">	
	
		
		<cfset var qry = ""> 
		
		<cfquery datasource="#variables.DSN2#" name="qry" cachedwithin="#CreateTimeSpan(0,0,0,45)#">
			EXEC sp_GetConstituencySearch	
				@ConstituencyType =	'#Trim(arguments.ConstituencyType)#',
				@searchtype 	  =	'#Trim(arguments.searchtype)#',
				@keyword		  =	<cfif Len(arguments.keywords)>'#Trim(arguments.keywords)#'<cfelse>NULL</cfif>,
				@Party			  =	<cfif Len(arguments.party)>'#Trim(arguments.party)#'<cfelse>NULL</cfif>,
				@Country		  =	<cfif Len(arguments.Country)>'#Trim(arguments.Country)#'<cfelse>NULL</cfif>
		</cfquery>

		<cfreturn qry>	
			
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetGazetteer" access="public" output="false" returntype="query" hint="return results of search in Gazetteer">
		<cfargument name="town" 		required="no" type="string" default="">	
		<cfset var qry = ""> 
			
			<cfquery datasource="#variables.DSN2#" name="qry" cachedwithin="#CreateTimeSpan(0,0,0,45)#">
			EXEC sp_GetGazetteer	
				@Town =	<cfif Len(arguments.town)>'#Trim(arguments.town)#'<cfelse>NULL</cfif>
				
		</cfquery>
			
		<cfreturn qry>	
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getCabinetOptions" access="public" output="false" returntype="query" hint="return results of  councils by Cabinet Option">
		<cfset var qry = ""> 	
			<cfquery datasource="#variables.DSN2#" name="qry" cachedwithin="#CreateTimeSpan(0,0,0,45)#">
			EXEC sp_GetCouncilsByCabinetType			
			</cfquery>	
		<cfreturn qry>	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getReOranisation" access="public" output="false" returntype="query" hint="return results of  local gov reOrganisation">
		
		<cfset var qry = ""> 	
		
		<cfquery datasource="#variables.DSN2#" name="qry" cachedwithin="#CreateTimeSpan(0,0,0,45)#">
			EXEC sp_GetReOrganisation			
		</cfquery>	
		
		<cfreturn qry>	
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetCouncilControl" access="public" returntype="struct" output="false" hint="Return details on what party (if any) controls wach council across the country">
		<cfargument name="FilterParty1" required="yes" type="string">
		<cfargument name="FilterParty2" required="yes" type="string">
		
		<!--- <cfset var qryGetCouncilControl = "">
			
		<cfquery name="qryGetCouncilControl" datasource="#variables.DSN2#">
			EXEC sp_GetCouncilControl 
				@FilterParty = <cfif Len(arguments.FilterParty)>#arguments.FilterParty#<cfelse>NULL</cfif>		
		</cfquery>	
		
		<cfreturn qryGetCouncilControl>	 --->
		
		<cfset var strCouncilControl 	= StructNew()> 
		<!--- <cfset var qryGetCouncilControl = QueryNew("temp")>
		<cfset var qryPartyList 	 	= QueryNew("temp")> --->
		
		<cfstoredproc datasource="#variables.DSN2#" procedure="sp_GetCouncilControl" returncode="yes">
			
			<cfif Len(arguments.FilterParty1)>
				<cfprocparam type="in" cfsqltype="cf_sql_integer" variable="@FilterParty1" value="#arguments.FilterParty1#">
			<cfelse>
				<cfprocparam type="in" cfsqltype="cf_sql_integer" variable="@FilterParty1" value="" null="true">
			</cfif>
			
			<cfif Len(arguments.FilterParty2)>
				<cfprocparam type="in" cfsqltype="cf_sql_integer" variable="@FilterParty2" value="#arguments.FilterParty2#">
			<cfelse>
				<cfprocparam type="in" cfsqltype="cf_sql_integer" variable="@FilterParty2" value="" null="true">
			</cfif>
			
			<cfprocresult resultset="1" name="strCouncilControl.qryGetCouncilControl"> 
			<cfprocresult resultset="2" name="strCouncilControl.qryPartyList"> 
			
 		</cfstoredproc>

		<cfreturn strCouncilControl>

	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetElectionCouncilControl" access="public" returntype="struct" output="false" hint="Return details on what party (if any) controls wach council across the country">
		<cfargument name="FilterParty1" required="yes" type="string">
		<cfargument name="FilterParty2" required="yes" type="string">
		<cfargument name="viewType" 	required="yes" type="numeric" default="0">
		<cfargument name="NextElection" required="yes" type="string">
		
		<cfset var strElectionCouncilControl 	= StructNew()> 
		<!--- <cfset var qryGetCouncilControl = QueryNew("temp")>
		<cfset var qryPartyList 	 	= QueryNew("temp")> --->
		
		<cfstoredproc datasource="#variables.DSN2#" procedure="sp_GetElectionCouncilControl" returncode="yes">
			
			<cfif Len(arguments.FilterParty1)>
				<cfprocparam type="in" cfsqltype="cf_sql_integer" variable="@FilterParty1" value="#arguments.FilterParty1#">
			<cfelse>
				<cfprocparam type="in" cfsqltype="cf_sql_integer" variable="@FilterParty1" value="" null="true">
			</cfif>
			
			<cfif Len(arguments.FilterParty2)>
				<cfprocparam type="in" cfsqltype="cf_sql_integer" variable="@FilterParty2" value="#arguments.FilterParty2#">
			<cfelse>
				<cfprocparam type="in" cfsqltype="cf_sql_integer" variable="@FilterParty2" value="" null="true">
			</cfif>
			
			<cfprocparam type="in" cfsqltype="cf_sql_date" variable="@NextEle" value="#createODBCdate(arguments.NextElection)#" >
			
			<cfprocresult resultset="1" name="strElectionCouncilControl.qryGetCouncilControl"> 
			<cfprocresult resultset="2" name="strElectionCouncilControl.qryPartyList">
			<cfprocresult resultset="3" name="strElectionCouncilControl.qryChangers">
			<cfprocresult resultset="4" name="strElectionCouncilControl.qryPieData">
			
 		</cfstoredproc>

		<cfreturn strElectionCouncilControl>

	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Commit Functions ----------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="SaveCoOrdinates" access="public" returntype="void">
		<cfargument name="sql" required="yes" type="string">
		
		<cfquery datasource="#variables.DSN2#"> 
			 #arguments.sql#
		</cfquery>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetSampleEntry" access="public" returntype="query" output="false" hint="Return details for sample entry">
		<cfargument name="OrgID"    		required="yes" 	type="numeric">
		<cfset var qrySample = "">
			
		<cfquery name="qrySample" datasource="#variables.DSN2#">
			EXEC usp_GetSampleEntry #arguments.OrgID#			
		</cfquery>	
		
		<cfreturn qrySample>	
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Delete Functions ----------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->

	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<cffunction name="GetAllCPAs" access="public" output="false" returntype="query" hint="return all people">
		<cfset var qry = ""> 
		
		<cfquery datasource="#variables.DSN2#" name="qry" >
			EXEC usp_GetMostRecentCPAs
		</cfquery>

		<cfreturn qry>	
	</cffunction>
</cfcomponent>