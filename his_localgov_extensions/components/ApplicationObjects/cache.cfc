<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/ApplicationObjects/cache.cfc $
	$Author: Hbehnia $
	$Revision: 11 $
	$Date: 20/01/09 15:27 $

--->

<cfcomponent displayname="Cache" hint="Caching/refreshing tool">
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR -------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="cache" hint="Pseudo-constructor">
		<cfargument name="urlscope" required="yes" type="struct">
		<cfargument name="appScope" required="yes"    type="struct"> 
		<cfargument name="cgiscope" required="yes" type="struct"> 
		<cfargument name="appPath"  required="yes" type="string"> 
	
		
		<cfscript>
			//struct that hold all private instance data in the variables scope
			instance 		 				= arguments.appscope;
			instance.dirpath  				= arguments.appPath;
			instance.cgiscope 				= arguments.cgiscope;
			instance.objAppManagerManager	= arguments.appscope.objAppManager;
			instance.objBusinessObjects   	= arguments.appscope.objBusinessObjects;
			
			switch (arguments.urlscope.refresh) 
			{
				case "1":
					reloadEntireApp();
					break;
				case "app":
					reloadApp();
					break;
				case "bus":
					reloadbus();
					break;		
				case "config":
					reloadConfig();
					break;	
				case "Objbus":
					reloadBusObj(arguments.urlscope.cfc);
					break;	
				case "ObjApp":
					reloadAppObj(arguments.urlscope.cfc);
					break;	
				case "Feeds":
					reloadNewsFeeds();
					break;
				case "map":
					reloadPoliticalMapData();
					break;				
			}
			//request.objApp.objUtils.dumpabort(arguments.urlscope.refresh);
			return this;
		</cfscript>
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="reloadEntireApp" access="private" returntype="void" hint="reload whole application">
		<cfscript>
			//StructDelete(instance, 'LocalGov');
			reloadApp();
			reloadBus();
		</cfscript>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="reloadApp" access="private" returntype="void" hint="reload all application objects">
		<cfscript>
			var basepath=    instance.dirpath;
			StructDelete(instance, 'objApp');
			
			basepath = "C:\Inetpub\wwwroot\localgov\private\";
		
			//load aplication object into memory
			instance.objAppManager = createObject("component", "his_Localgov_Extends.components.ApplicationManager").init( cgi, instance.dirpath, server, basepath );
		</cfscript>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="reloadBus" access="private" returntype="void" hint="reload all business objects">
		<cfset StructDelete(instance, 'objBusinessObjects')>
		<!--- Load Business Objects into memory...--->
		<cfset instance.objBusinessObjects = createObject("component", "his_Localgov_Extends.components.BusinessObjectsManager").init( instance.objAppManager )>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="reloadConfig" access="private" returntype="void" hint="reload config from application">
		<cfset instance.objAppManager.reInit()>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="reloadBusObj" access="public" returntype="void" hint="reload business object and therefore its DAO">
		<cfargument name="cfcname"    required="yes" type="string" hint="cfc name eg. article for objarticle ">	
		
		<cfscript>
			//concatentate cfc name with prefix
			var objname = "obj" & arguments.cfcname;
			If ( StructKeyExists(instance.objBusinessObjects, objname) )
				StructClear(instance.objBusinessObjects[objname]);
			
			if (arguments.cfcname eq "article")
				//load artilce 
				instance.objBusinessObjects["#objname#"] = createobject("component","his_Localgov_Extends.components.BusinessObjects." & arguments.cfcname).init( instance.objAppManager, FALSE, TRUE, instance.objAppManager.getSiteConfig().strVars.useProxy );
			else 
				//load business object 
				instance.objBusinessObjects["#objname#"] = createobject("component","his_Localgov_Extends.components.BusinessObjects." & arguments.cfcname).init(instance.objAppManager,instance.objBusinessObjects);			
		</cfscript>	
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="reloadAppObj" access="public" returntype="void" hint="reload business object and therefore its DAO">
	<cfargument name="cfcname"    required="yes" type="string" hint="cfc name eg. article for objarticle ">	
		
		<cfscript>
			//concatentate cfc name with prefix
			var objname = "obj" & arguments.cfcname;
			
			StructClear(instance.objAppManager[objname]);
			
			if (ListContainsNocase("xml,utils,Breadcrumb,String",  arguments.cfcname))
				instance.objAppManager["#objname#"] = createobject("component","his_Localgov_Extends.components.ApplicationObjects." & arguments.cfcname);
				//instance.objAppManager.objUtils.dumpabort(arguments);
			else
			
			if (ListContains("Error,meta",  arguments.cfcname))	
				instance.objAppManager["#objname#"] = createobject("component","his_Localgov_Extends.components.ApplicationObjects." & arguments.cfcname).init(instance.objAppManager.getSiteConfig());
			else 
			
			if (arguments.cfcname eq "RSS")
				instance.objAppManager["#objname#"] = createobject("component","his_Localgov_Extends.components.ApplicationObjects." & arguments.cfcname).init( instance.objAppManager.getSiteConfig(), instance.objAppManager.objUtils );
			else
			
			
			if (arguments.cfcname eq "SavedSearches")
					instance.objAppManager["#objname#"] = createobject("component","his_Localgov_Extends.components.ApplicationObjects." & arguments.cfcname).init(instance.objAppManager.objUtils, instance.objAppManager.objString, instance.objAppManager.getSiteConfig());		
		</cfscript>
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="reloadNewsFeeds" access="private" returntype="void">
		<cfscript>
			instance.objBusinessObjects.objArticle.getTodaysPapers(bFilter=false, useProxy=instance.objAppManager.getSiteConfig().strVars.useProxy, bForceRetrieval=true);
			instance.objBusinessObjects.objArticle.getTodaysBusinessPapers(bFilter=false, useProxy=instance.objAppManager.getSiteConfig().strVars.useProxy, bForceRetrieval=true);
		</cfscript>
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="reloadPoliticalMapData" access="private" returntype="void">
		<cfscript>
			instance.objBusinessObjects.objDirectory.GetCouncilControl(FilterParty1="", FilterParty2="", refresh=true);
		</cfscript>
	</cffunction>
</cfcomponent>