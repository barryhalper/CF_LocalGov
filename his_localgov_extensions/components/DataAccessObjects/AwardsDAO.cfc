<!--- 
	
	$Archive: /localgov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/DataAccessObjects/AwardsDAO.cfc $
	$Author: Ohilton $
	$Revision: 2 $
	$Date: 2/10/09 15:45 $

	Notes:
		Method naming convention:
		
		1. add<Noun>	- e.g. addArticle()
		2. update<Noun>	- e.g. updateArticle()
		3. delete<Noun>	- e.g. deleteArticle()
		4. get<Noun>	- e.g. getArticle()

--->

<cfcomponent displayname="AwardsDAO" hint="<component description here>" extends="his_Localgov_Extends.components.DAOManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="AwardsDAO" hint="Pseudo-constructor">
	
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		StructAppend( variables, Super.init( arguments.strConfig ) );

		return this;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions: *ADD* ----------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="addF1" access="public" output="false" returntype="string" hint="<description>">
		
		<cfargument name="A1" type="string" default="1">
		<cfargument name="A2" type="string" default="1">

		<cfscript>
		// Local variable declarations...
		var sRtnValue = "";

		// ...code...		
		
		return sRtnValue;		
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions: *UPDATE* -------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="updateF1" access="public" output="false" returntype="string" hint="<description>">
		
		<cfargument name="A1" type="string" default="1">
		<cfargument name="A2" type="string" default="1">

		<cfscript>
		// Local variable declarations...
		var sRtnValue = "";

		// ...code...		
		
		return sRtnValue;		
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions: *GET* ----------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getF1" access="public" output="false" returntype="string" hint="<description>">
		
		<cfargument name="A1" type="string" default="1">
		<cfargument name="A2" type="string" default="1">

		<cfscript>
		// Local variable declarations...
		var sRtnValue = "";

		// ...code...		
		
		return sRtnValue;		
		</cfscript>
		
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions: *DELETE* -------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="deleteF1" access="public" output="false" returntype="string" hint="<description>">
		
		<cfargument name="A1" type="string" default="1">
		<cfargument name="A2" type="string" default="1">

		<cfscript>
		// Local variable declarations...
		var sRtnValue = "";

		// ...code...		
		
		return sRtnValue;		
		</cfscript>
		
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PRIAVTE Functions ----------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="F2" access="private" output="false" returntype="string" hint="<description>">
	
		<cfargument name="A1" type="string" default="1">
		<cfargument name="A2" type="string" default="1">

		<cfscript>
		// Local variable declarations...
		var sRtnValue = "";

		// ...code...		
		
		return sRtnValue;		
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- Get the award ceremony list ---------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getAwardDetails" access="public" returntype="query">
		<cfargument name="awardID" type="numeric" required="yes">
		
		<cfset var qryAwardDetails = querynew('temp')>
		
		<cfstoredproc datasource="#variables.DSN7#" procedure="usp_getAwardDetails">
			<cfprocparam dbvarname="@awardID" value="#arguments.awardID#" type="in" cfsqltype="cf_sql_integer">
			
			<cfprocresult name="qryAwardDetails" resultset="1">
		</cfstoredproc>
		
		<cfreturn qryAwardDetails>
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- Get an extended version of the category struct with addition web info ---------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getWebCategory" access="public" returntype="struct">
		<cfargument name="catID" type="numeric" required="yes">
		
		<cfset var strWebCategory = structnew()>
		
		<cfstoredproc datasource="#variables.DSN7#" procedure="usp_getWebCategory">
			<cfprocparam dbvarname="@catID" value="#arguments.catID#" type="in" cfsqltype="cf_sql_integer">
			
			<cfprocresult name="strWebCategory.main" resultset="1">
			<cfprocresult name="strWebCategory.nomination" resultset="2">
			<cfprocresult name="strWebCategory.sponsor" resultset="3">
		</cfstoredproc>
		
		<cfreturn strWebCategory>
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- Lookup the ceremonyid based on a category id ----------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getCeremonyFromCategory" access="public" returntype="numeric">
		<cfargument name="catID" type="numeric" required="yes">
		
		<cfset var cerID = 0>
		
		<cfstoredproc datasource="#variables.DSN7#" procedure="usp_getCeremonyFromCategory">
			<cfprocparam dbvarname="@catID" value="#arguments.catID#" cfsqltype="cf_sql_integer" type="in">
			
			<cfprocparam dbvarname="@cerID" cfsqltype="cf_sql_integer" type="out" variable="cerID">
		</cfstoredproc>
		
		<cfreturn cerID>
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- Load a page copy record for editing -------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getPageCopy" access="public" returntype="query">
		<cfargument name="type" type="numeric" required="yes">
		<cfargument name="relID" type="numeric" required="yes">
		<cfargument name="awardID" type="numeric" required="yes">
				
		<cfset var qryPageCopy = querynew('temp')>
		
		<cfstoredproc datasource="#variables.DSN7#" procedure="usp_getPageCopy">
			<cfprocparam dbvarname="@type" value="#arguments.type#" type="in" cfsqltype="cf_sql_integer">
			<cfprocparam dbvarname="@relID" value="#arguments.relID#" type="in" cfsqltype="cf_sql_integer">
			<cfprocparam dbvarname="@awardID" value="#arguments.awardID#" type="in" cfsqltype="cf_sql_integer">
			
			<cfprocresult name="qryPageCopy" resultset="1">
		</cfstoredproc>
		
		<cfreturn qryPageCopy>
		
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- Get the details of an individual ceremony -------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getCeremonyDetails" access="public" returntype="struct">
		<cfargument name="ceremonyID" type="numeric" required="yes">
		
		<cfset var strCeremonyDetails = structnew()>
		
		<cfstoredproc datasource="#variables.DSN7#" procedure="usp_getCeremonyDetails">
			<cfprocparam dbvarname="@ceremonyID" value="#arguments.ceremonyID#" type="in" cfsqltype="cf_sql_integer">
			
			<cfprocresult name="strCeremonyDetails.main" resultset="1">
		</cfstoredproc>
		
		<cfreturn strCeremonyDetails>
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- Get a list of categories for a given ceremony ---------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getCategoryList" access="public" returntype="query">
		<cfargument name="cerID" type="numeric" required="yes">
		
		<cfset var qryCategoryList = querynew('temp')>
		
		<cfquery datasource="#variables.DSN7#" name="qryCategoryList">
			exec usp_getCategoryList #arguments.cerID#
		</cfquery>
		
		<cfreturn qryCategoryList>		
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- Look to see if a nominator has been entered before and retrieve their details -------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="nominatorLookup" access="public" returntype="query">
		<cfargument name="em" type="string" required="yes">
		
		<cfset var qryNominator = querynew('temp')>
		
		<cfif isnumeric(arguments.em)>
			<cfquery datasource="#variables.DSN7#" name="qryNominator">
				exec usp_getNominatorByID '#arguments.em#'
			</cfquery>
		<cfelse>
			<cfquery datasource="#variables.DSN7#" name="qryNominator">
				exec usp_getNominator '#arguments.em#'
			</cfquery>
		</cfif>
		
		<cfreturn qryNominator>	
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- Save a nominator record -------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="saveNominator" access="public" returntype="numeric">
		<cfargument name="nominatorID" type="numeric" required="yes">
		<cfargument name="nor_email" type="string" required="yes">
		<cfargument name="nor_name" type="string" required="yes">
		<cfargument name="nor_title" type="string" required="yes">
		<cfargument name="nor_company" type="string" required="yes">
		<cfargument name="nor_add1" type="string" required="yes">
		<cfargument name="nor_add2" type="string" required="yes">
		<cfargument name="nor_add3" type="string" required="yes">
		<cfargument name="nor_town" type="string" required="yes">
		<cfargument name="nor_county" type="string" required="yes">
		<cfargument name="nor_postcode" type="string" required="yes">
		<cfargument name="nor_country" type="string" required="yes">
		<cfargument name="nor_phone" type="string" required="yes">
		<cfargument name="nor_fax" type="string" required="yes">
		
		<cfset var thenorID = ''>
		
		<cfstoredproc datasource="#variables.DSN7#" procedure="usp_saveNominator">
			<cfprocparam dbvarname="@nominatorID" value="#arguments.nominatorID#" cfsqltype="cf_sql_integer" type="in">
			<cfprocparam dbvarname="@nor_email" value="#arguments.nor_email#" cfsqltype="cf_sql_varchar" type="in">
			<cfprocparam dbvarname="@nor_name" value="#arguments.nor_name#" cfsqltype="cf_sql_varchar" type="in">
			<cfprocparam dbvarname="@nor_title" value="#arguments.nor_title#" cfsqltype="cf_sql_varchar" type="in">
			<cfprocparam dbvarname="@nor_company" value="#arguments.nor_company#" cfsqltype="cf_sql_varchar" type="in">
			<cfprocparam dbvarname="@nor_add1" value="#arguments.nor_add1#" cfsqltype="cf_sql_varchar" type="in">
			<cfprocparam dbvarname="@nor_add2" value="#arguments.nor_add2#" cfsqltype="cf_sql_varchar" type="in">
			<cfprocparam dbvarname="@nor_add3" value="#arguments.nor_add3#" cfsqltype="cf_sql_varchar" type="in">
			<cfprocparam dbvarname="@nor_town" value="#arguments.nor_town#" cfsqltype="cf_sql_varchar" type="in">
			<cfprocparam dbvarname="@nor_county" value="#arguments.nor_county#" cfsqltype="cf_sql_varchar" type="in">
			<cfprocparam dbvarname="@nor_postcode" value="#arguments.nor_postcode#" cfsqltype="cf_sql_varchar" type="in">
			<cfprocparam dbvarname="@nor_country" value="#arguments.nor_country#" cfsqltype="cf_sql_varchar" type="in">
			<cfprocparam dbvarname="@nor_phone" value="#arguments.nor_phone#" cfsqltype="cf_sql_varchar" type="in">
			<cfprocparam dbvarname="@nor_fax" value="#arguments.nor_fax#" cfsqltype="cf_sql_varchar" type="in">
			
			<cfprocparam dbvarname="@thenorID" cfsqltype="cf_sql_integer" type="out" variable="thenorID">
		</cfstoredproc>
		
		<cfreturn thenorID>
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- Save a nomination record ------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="saveNomination" access="public" returntype="void">
		<cfargument name="catID" type="numeric" required="yes">
		<cfargument name="nomID" type="numeric" required="yes">
		<cfargument name="nom_date" type="string" required="yes">
		<cfargument name="nom_statusid" type="numeric" required="yes">
		<cfargument name="thephoto" type="string" required="yes">
		<cfargument name="nom_company" type="string" required="yes">
		<cfargument name="nom_person" type="string" required="yes">
		<cfargument name="thefile" type="string" required="yes">
		<cfargument name="nom_add1" type="string" required="yes">
		<cfargument name="nom_add2" type="string" required="yes">
		<cfargument name="nom_add3" type="string" required="yes">
		<cfargument name="nom_town" type="string" required="yes">
		<cfargument name="nom_county" type="string" required="yes">
		<cfargument name="nom_postcode" type="string" required="yes">
		<cfargument name="nom_country" type="string" required="yes">
		<cfargument name="nom_phone" type="string" required="yes">
		<cfargument name="nom_fax" type="string" required="yes">
		<cfargument name="nom_email" type="string" required="yes">
		<cfargument name="nom_description" type="string" required="yes">
		<cfargument name="thenorID" type="string" required="yes">
		
		<cfset var thedate = ''>
		
		<cfif arguments.nom_date eq ''>
			<cfset thedate = now()>
		<cfelse>
			<cfset thedate = arguments.nom_date>
		</cfif>
		
		<cfstoredproc datasource="#variables.DSN7#" procedure="usp_saveNomination">
			<cfprocparam dbvarname="@catID" value="#arguments.catID#" cfsqltype="cf_sql_integer" type="in">
			<cfprocparam dbvarname="@nomID" value="#arguments.nomID#" cfsqltype="cf_sql_integer" type="in">
			<cfprocparam dbvarname="@nom_date" value="#createodbcdate(LsDateFormat(thedate, 'dd/mmm/yyyy'))#" cfsqltype="cf_sql_date" type="in">
			<cfprocparam dbvarname="@nom_statusid" value="#arguments.nom_statusid#" cfsqltype="cf_sql_integer" type="in">
			<cfprocparam dbvarname="@thephoto" value="#arguments.thephoto#" cfsqltype="cf_sql_varchar" type="in">
			<cfprocparam dbvarname="@nom_company" value="#arguments.nom_company#" cfsqltype="cf_sql_varchar" type="in">
			<cfprocparam dbvarname="@nom_person" value="#arguments.nom_person#" cfsqltype="cf_sql_varchar" type="in">
			<cfprocparam dbvarname="@thefile" value="#arguments.thefile#" cfsqltype="cf_sql_varchar" type="in">
			<cfprocparam dbvarname="@nom_add1" value="#arguments.nom_add1#" cfsqltype="cf_sql_varchar" type="in">
			<cfprocparam dbvarname="@nom_add2" value="#arguments.nom_add2#" cfsqltype="cf_sql_varchar" type="in">
			<cfprocparam dbvarname="@nom_add3" value="#arguments.nom_add3#" cfsqltype="cf_sql_varchar" type="in">
			<cfprocparam dbvarname="@nom_town" value="#arguments.nom_town#" cfsqltype="cf_sql_varchar" type="in">
			<cfprocparam dbvarname="@nom_county" value="#arguments.nom_county#" cfsqltype="cf_sql_varchar" type="in">
			<cfprocparam dbvarname="@nom_postcode" value="#arguments.nom_postcode#" cfsqltype="cf_sql_varchar" type="in">
			<cfprocparam dbvarname="@nom_country" value="#arguments.nom_country#" cfsqltype="cf_sql_varchar" type="in">
			<cfprocparam dbvarname="@nom_phone" value="#arguments.nom_phone#" cfsqltype="cf_sql_varchar" type="in">
			<cfprocparam dbvarname="@nom_fax" value="#arguments.nom_fax#" cfsqltype="cf_sql_varchar" type="in">
			<cfprocparam dbvarname="@nom_email" value="#arguments.nom_email#" cfsqltype="cf_sql_varchar" type="in">
			<cfprocparam dbvarname="@nom_description" value="#arguments.nom_description#" cfsqltype="cf_sql_varchar" type="in">
			<cfprocparam dbvarname="@thenorID" value="#arguments.thenorID#" cfsqltype="cf_sql_integer" type="in">
		</cfstoredproc>
		
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- Load the details of a given category ------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getCategoryDetails" access="public" returntype="struct">
		<cfargument name="catID" type="numeric" required="yes">		
		
		<cfset var strCategoryDetails = structnew()>
		
		<cfstoredproc datasource="#variables.DSN7#" procedure="usp_getCategoryDetails">
			<cfprocparam dbvarname="@catID" value="#arguments.catID#" type="in" cfsqltype="cf_sql_integer">
			
			<cfprocresult name="strCategoryDetails.main" resultset="1">
			<cfprocresult name="strCategoryDetails.types" resultset="2">
		</cfstoredproc>
		
		<cfreturn strCategoryDetails>
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- Load the details of a given sponsor -------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getSponsorDetails" access="public" returntype="query">
		<cfargument name="sponID" type="numeric" required="yes">		
		
		<cfset var qrySponsorDetail = querynew('temp')>
		
		<cfstoredproc datasource="#variables.DSN7#" procedure="usp_getSponsorDetails">
			<cfprocparam dbvarname="@sponID" value="#arguments.sponID#" type="in" cfsqltype="cf_sql_integer">
			
			<cfprocresult name="qrySponsorDetail" resultset="1">
		</cfstoredproc>
		
		<cfreturn qrySponsorDetail>
	</cffunction>
</cfcomponent>