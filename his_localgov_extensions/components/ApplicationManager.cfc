<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/ApplicationManager.cfc $
	$Author: Ohilton $
	$Revision: 11 $
	$Date: 10/06/10 16:50 $

--->

<cfcomponent hint="application manager">
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR --------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" returntype="ApplicationManager" access="public" output="false" hint="constructure method">
		<cfargument name="cgiscope" required="yes" type="struct"  hint="cgi structure">
		<cfargument name="dirpath" required="yes" type="string"  hint="full directory path of application">
		<cfargument name="objs" required="yes" type="struct" hint="pass in structure that holds objects">
		<cfargument name="basepath" required="yes" type="string"  hint="base path to core folders and files">
		
		 <cfscript>
		// local variables....
		variables.CGIScope 	= arguments.cgiscope;
		variables.dirpath 	= arguments.dirpath;
		variables.basepath 	= arguments.basepath;
		//copy server objects
		//GetObjsFromStruct(arguments.objs);
		//variables.objConfig = CreateObject("component", "his_localgov.extends.components.config").init(variables.objXml);
		this.objxml 		= createobject("component", "his_Localgov_Extends.components.ApplicationObjects.xml");
		variables.strConfig = LoadConfig();

		// exposed, child objects...
		this.objUtils 			= createobject("component", "his_Localgov_Extends.components.ApplicationObjects.utils");
		this.objBreadcrumb 		= createobject("component", "his_Localgov_Extends.components.ApplicationObjects.breadcrumb");
		
		this.objString 			= createobject("component", "his_Localgov_Extends.components.ApplicationObjects.string");
		this.objRSS 			= createobject("component", "his_Localgov_Extends.components.ApplicationObjects.rss").init( variables.strConfig, this.objUtils, this.objString );
		this.objError 			= createobject("component", "his_Localgov_Extends.components.ApplicationObjects.error").init( variables.strConfig );
		//this.objAdmin			= createobject("component", "Admin").init();
		this.objWorldPay		= createobject("component", "his_Localgov_Extends.components.ApplicationObjects.WorldPay").init();
		this.objSavedSearches 	= createobject("component", "his_Localgov_Extends.components.ApplicationObjects.savedSearches").init(this.objUtils, this.objString, variables.strConfig);
		this.objMeta 			= createobject("component", "his_Localgov_Extends.components.ApplicationObjects.Meta").init(variables.strConfig);
		//this.objSlides 			= createobject("component", "his_rd.library.components.utils.slides").init(strConfig.strPaths.sitedir & "extends\xml\");
		this.objPaginate 		= createobject("component", "his_Localgov_Extends.components.ApplicationObjects.paginate");
		this.objGoogleGeocode	= createobject("component", "his_Localgov_Extends.components.ApplicationObjects.googlegeocode");
		this.objTwitter 		= createobject("component", "his_Localgov_Extends.components.ApplicationObjects.twitter");
	
		</cfscript> 
	
		<cfreturn this>	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions ------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->	

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- FUNCTION: GetVariables()... ----------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetVariables" access="public" returntype="struct" output="false" hint="return variables">
		<cfreturn variables>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- FUNCTION: GetSiteConfig()... ----------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetSiteConfig" access="public" returntype="struct" output="false" hint="return structure of stite configuration">
		
		<cfreturn variables.strConfig>
	</cffunction>
	
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PRIAVTE Functions ----------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- FUNCTION: GetObjsFromStruct()... ----------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetObjsFromStruct" access="private" returntype="void" hint="loop over structure and set object into var scope">
		<cfargument name="str" required="yes" type="struct">
	
		<cfscript>
		var i = "";
		//loop over struc
		for (i in arguments.str){
		if (IsObject(arguments.str[i]))
			StructAppend(variables, arguments.str);
		}
		</cfscript>
	
	</cffunction> 
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- FUNCTION: reInit()... ----------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="reInit" access="public" returntype="void" output="false" hint="reinitilaise config data">
		<cfscript>
			//clear config
			variables.strConfig ="";
			//reintialise
			variables.strConfig=LoadConfig();
		</cfscript>
	</cffunction>
	
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- FUNCTION: LoadConfig()... ----------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="LoadConfig" access="private" returntype="struct" output="false" hint="load config into structure">
		
		<cfscript>
		var objConfig = CreateObject("component", "his_Localgov_Extends.components.ApplicationObjects.config").init(variables.CGIScope , variables.dirpath, this.objXml, variables.basepath);
		var strConfig = objConfig.getSiteConfig();
		return strConfig ;
		</cfscript>
		
	</cffunction>
	
</cfcomponent>
