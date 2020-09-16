<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/COMPONENTS/DataAccessObjects/GuidesDAO.cfc $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 8/08/07 10:06 $

	Notes:
		Method naming convention:
		
		1. add<Noun>	- e.g. addArticle()
		2. update<Noun>	- e.g. updateArticle()
		3. delete<Noun>	- e.g. deleteArticle()
		4. get<Noun>	- e.g. getArticle()

--->

<cfcomponent displayname="GuidesDAO" hint="Procurement guide-related Data Access methods" extends="his_Localgov_Extends.components.DAOManager" >

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="GuidesDAO" hint="Pseudo-constructor">
		
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		StructAppend( variables, Super.init( arguments.strConfig ) );
		variables.Directory = variables.strConfig.strVars.GuideDir;
		variables.Edition =variables.strConfig.strVars.GuideEdition ; 
		
		return this;
		</cfscript>
		
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions: *GET* ----------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<!---Begin FormSelects() Function --->
	<cffunction name="FormSelects" access="public" returntype="struct" output="false" hint="get all qry used to create froms ">
		
			<!---set return structure --->
			<cfset var strReturn = StructNew()>
			
			  <!--- call stored proc to return multiple resultsets --->
				<cfstoredproc datasource="#variables.dsn3#" procedure="sp_Get_Search_Selects">
					<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@strDirectory" value="#variables.Directory#"> 
						<cfprocresult resultset="1" name="strReturn.qryCountries">
						<cfprocresult resultset="2" name="strReturn.qryCategories">
						<cfprocresult resultset="3" name="strReturn.qryCoAlphas">
						<cfprocresult resultset="4" name="strReturn.qryProdAlphas">
						<cfprocresult resultset="5" name="strReturn.qryOrgSizes">
						<cfprocresult resultset="6" name="strReturn.qryProducts">
						<cfprocresult resultset="7" name="strReturn.qrylistedCountries">
				</cfstoredproc>
				
				<cfreturn strReturn>
		
	</cffunction>
	
	<!--- <cffunction name="SearchProducts" access="public" returntype="query" output="true">
		<cfargument name="keyword" type="string" required="yes">
		<cfargument name="Operator" type="string" required="yes">
		
			<cfset var qrySearch="">
			
			<!---Execute stored  proc --->
				<cfquery datasource="#variables.dsn3#" name="qrySearch">
					EXEC sp_SearchProducts
					@strDirectory = '#variables.Directory#',
					@Keyword = '#arguments.Keyword#',
					@Operator = '#arguments.Operator#'
				</cfquery>
		
		<cfreturn qrySearch>		
	</cffunction> --->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="SearchCompanies" access="public" returntype="query"  output="false" hint="search for companies"> 
		<cfargument name="Keyword"    type="string" required="no" default="">
		<cfargument name="CategoryID" type="string" required="no" default="">
		<cfargument name="ProductID"  type="string" required="no" default="">
		<cfargument name="ID"  type="string" required="no" default="">
		
	
		<cfset var qryCoSearch=""> 
			
			<!--- <!---Execute stored  proc --->
				<cfquery datasource="#variables.dsn3#" name="qryCoSearch">
					EXEC sp_SearchCompanies 
					@strDirectory = '#variables.directory#',
					@Keyword = '#trim(arguments.Keyword)#',
					@Operator = '#arguments.Operator#',
					@lstCountryCode = '#arguments.lstCountryCode#',
					@lstCategoryID = '#arguments.lstCategoryID#',
					@ProductID = #arguments.ProductID#
					<cfif IsDefined("arguments.alphaorder") AND arguments.alphaorder EQ 1>
					, @alphaOrder = 1
					</cfif>
					, @edition  = '#variables.edition#'
				</cfquery> --->
		
		<cfquery datasource="#variables.dsn3#" name="qryCoSearch" cachedwithin="#CreateTimeSpan(0,0,0,30)#">
					EXEC sp_LocalGovSearch 	
					@Edition	 = '#variables.Edition#',
					@Product 	 = <cfif Len(arguments.ProductID)>'#arguments.ProductID#'<cfelse>NULL</cfif>,
					@Category 	 = <cfif Len(arguments.CategoryID)>'#arguments.CategoryID#'<cfelse>NULL</cfif>,
					@Keyword  	 = <cfif Len(arguments.Keyword)>'#arguments.Keyword#'<cfelse>NULL</cfif>
				</cfquery>
		
		<cfreturn qryCoSearch>		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="SearchCompaniesByProduct" access="public" returntype="query"  output="false" hint="search for companies by a single product"> 
		<cfargument name="Product"    type="string" required="yes">
		
				<cfset var qryCoSearch=""> 
			
			<cfquery datasource="#variables.dsn3#" name="qryCoSearch" cachedwithin="#CreateTimeSpan(0,0,0,30)#">
					EXEC sp_LocalGovProductSearch 	
					@Edition	 = '#variables.Edition#',
					@Product 	 = '#arguments.Product#'
				</cfquery>
		
		<cfreturn qryCoSearch>		
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<cffunction name="CompanyDetails" access="public" returntype="struct"  output="false" hint="return structure that contains mutiple resultsets for a compnay's details" > 
		 <cfargument name="OrganistaionID" type="numeric" required="yes" > 
					<!---set return structure --->
					<cfset var strCompany = StructNew()>
					<cfset var qryDetails = "">
					<cfset var qryTelecom = "">
					<cfset var qryContacts = "">
					<cfset var qryProducts = "">
					<cfset var qryCategories = "">
					<cfset var qryAssoc = "">
					
					
					<!---Execute stored  proc --->
					<cfstoredproc datasource="#variables.dsn3#" procedure="sp_Get_Org_Details" returncode="yes">
						<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@strDirectory" value="#Variables.Directory#"> 
						<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@OrganistaionID" value="#arguments.OrganistaionID#">
								<cfprocresult resultset="1" name="qryDetails">
								<cfprocresult resultset="2" name="qryTelecom">
								<cfprocresult resultset="3" name="qryContacts">
								<cfprocresult resultset="4" name="qryProducts">
								<cfprocresult resultset="5" name="qryCategories">
								<cfprocresult resultset="6" name="qryAssoc">
					</cfstoredproc>
					
					<cfscript>
					if (cfstoredproc.statusCode EQ 0)
					{
					//append queries into return structure
					StructInsert(strCompany, "qryDetails", qryDetails);
					StructInsert(strCompany, "qryTelecom", qryTelecom);
					StructInsert(strCompany, "qryContacts", qryContacts);
					StructInsert(strCompany, "qryProducts", qryProducts);
					StructInsert(strCompany, "qryCategories", qryCategories);
					StructInsert(strCompany, "qryAssoc", qryAssoc);
					}
					return strCompany;
					</cfscript>
				
			</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
<cffunction name="AssocCompanies" access="public" returntype="struct"  output="false" hint="return structure that contains mutiple resultsets for a compnay's details">
				<cfargument name="OrganistaionID" type="numeric" required="yes">
					
					<!---set return structure --->
					<cfset var strAssoc = StructNew()>
					
					<!---Execute stored  proc --->
					<cfstoredproc datasource="#variables.dsn3#" procedure=" sp_Get_Assoc_Org" >
						<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@strDirectory" value="#variables.Directory#"> 
						<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@OrganistaionID" value="#arguments.OrganistaionID#">
								<cfprocresult resultset="1" name="strAssoc.qryDetails">
								<cfprocresult resultset="2" name="strAssoc.qryTelecom">
					</cfstoredproc>
	
					<cfreturn strAssoc>			
				
		</cffunction>

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PRIAVTE Functions ----------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->

</cfcomponent>