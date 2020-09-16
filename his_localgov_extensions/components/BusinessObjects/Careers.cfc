<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/COMPONENTS/BusinessObjects/Careers.cfc $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 8/08/07 10:06 $

--->

<cfcomponent displayname="Careers" hint="Career-related business object functions" extends="his_Localgov_Extends.components.BusinessObjectsManager">

	<!---   ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Careers" hint="Pseudo-constructor">
		<cfargument name="objAppObjs" type="any" required="yes" hint="The application manager object">
		<cfargument name="objBusObjs" type="any" required="yes" hint="The application manager object">

		<cfscript>
		// Call the genric init function, placing business, app, and dao objects into a local scope...
		StructAppend( variables, Super.initChild( arguments.objAppObjs, this, arguments.objBusObjs ) );
		return this;
		</cfscript>
		
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions ------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getVariables" access="public" output="false" returntype="struct" 
		hint="return local scope to caller">
		
		<cfreturn variables>
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->		
	<cffunction name="getHomeContent" access="public" output="false" returntype="struct" 
		hint="return structure of content for careers home page">
		
		<cfargument name="copyid" required="yes" type="numeric">
		
		<cfscript>
		var strRtn = StructNew();
		/*
		var qryJobs= GetFeaturedJobs();
		strRtn.qryFeaturedJobs 		= objUtils.QueryOfQuery(qryJobs, "*", 'jobstatus=#chr(39)#Featured#chr(39)#');
		strRtn.qryTopJob 			= objUtils.QueryOfQuery(qryJobs, "*", 'jobstatus=#chr(39)#Top#chr(39)#');
		strRtn.qryCopy				= variables.objArticle.GetFull(type=7, id=arguments.copyid);
		strRtn.strSelects		    = variables.strJobSelects;
		*/ 
		return 	strRtn;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->		
	<cffunction name="getCareerSections" access="public" output="false" returntype="query" 
		hint="">

		<cfreturn objDAO.getCareerSections()>
		
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->		
	<cffunction name="commitCareerSection" access="public" output="false" returntype="numeric" 
		hint="">
		<cfargument name="name" 		type="string" required="yes">
		<cfargument name="description" 	type="string" required="yes">
		<cfargument name="sectionid" 	type="numeric" required="yes">

		<cfreturn objDAO.commitCareerSection( arguments.name, arguments.description, arguments.sectionid )>
		
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->		
	<cffunction name="deleteCareerSection" access="public" output="false" returntype="void" 
		hint="">
		<cfargument name="sectionid" 	type="numeric" required="yes">

		<cfreturn objDAO.deleteCareerSection( arguments.sectionid )>
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->		
	<cffunction name="getArticleIDsInCareerSection" access="public" output="false" returntype="string" 
		hint="return a list of article ids in the specified career section">
		
		<cfargument name="sectionID" required="yes" type="numeric">
		<cfset qry = objDAO.getArticleIDsInCareerSection( arguments.sectionID )>
		<cfset lst = valueList( qry.f_article_id )>
		<cfreturn lst>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->		
	<cffunction name="getArticlesInCareerSections" access="public" output="false" returntype="query" 
		hint="return a list of article ids in the specified career section">
		
		<cfreturn objDAO.getArticlesInCareerSections()>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->

</cfcomponent>