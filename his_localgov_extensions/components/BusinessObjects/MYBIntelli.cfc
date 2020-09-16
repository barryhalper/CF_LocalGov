<cfcomponent displayname="MYBIntelli" extends="his_Localgov_Extends.components.BusinessObjectsManager">
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="MYBIntelli" hint="Pseudo-constructor">
	
		<cfargument name="objAppObjs" type="any" required="yes" hint="The application manager object">
		<cfargument name="objBusObjs" type="any" required="yes" hint="The business object">

		<cfscript>
		// Call the genric init function, placing business, app, and dao objects into a local scope...
		StructAppend( variables, Super.initChild( arguments.objAppObjs, this, arguments.objBusObjs ) );
		//variables.strLookups = getLookups();
		return this;
		</cfscript>
		
	</cffunction>
	
	<cffunction name="getLookups" access="public" returntype="struct">
		<!--- Store the lookups in the variables scope to speed up page loads --->
		<cfif not structkeyexists(variables, 'strLookups')>
			<cfset variables.strLookups = objDAO.getLookups()>
		</cfif>
		
		<cfreturn variables.strLookups>
	</cffunction>
	
	<cffunction name="getRoadLookups" access="public" returntype="struct">
		<!--- Store the lookups in the variables scope to speed up page loads --->
		<cfif not structkeyexists(variables, 'strRoadLookups')>
			<cfset variables.strRoadLookups = objDAO.getRoadLookups()>
		</cfif>
		
		<cfreturn variables.strRoadLookups>
	</cffunction>
	
	<cffunction name="getNIFilters" access="public" returntype="query" hint="">
		<cfargument name="natinds" type="string" required="no" default="0">
		<cfargument name="councilids" type="string" required="no" default="0">
		<cfargument name="wBudget" type="numeric" required="no" default="0">
		
		<cfscript>
			var qry = querynew('temp');
			if(arguments.wBudget eq 0)
				qry = objDAO.getNIFilters(argumentcollection = arguments);
			else
				qry = objDAO.getNIFiltersBudget(argumentcollection = arguments);
		</cfscript>
		
		<cfreturn qry>
	</cffunction>
	
	<cffunction name="getBudgetDataByOrg" access="public" returntype="query" hint="Get basic level budget data">
		<cfargument name="minyear" type="string" required="no" default="">
		<cfargument name="maxyear" type="string" required="no" default="">
		<cfargument name="spendItems" type="string" required="no" default="">
		<cfargument name="spendGroups" type="string" required="no" default="">
		<cfargument name="organisationids" type="string" required="no" default="">
		
		<cfset arguments.organisationids = cleanArray(arguments.organisationids)>		
		
		<cfscript>
			qry = objDAO.getBudgetDataByOrg(argumentcollection = arguments);
		</cfscript>
		
		<cfreturn qry>
	</cffunction>
	
	<cffunction name="getBudgetDataByAvg" access="public" returntype="query" hint="Get basic level budget data">
		<cfargument name="minyear" type="string" required="no" default="">
		<cfargument name="maxyear" type="string" required="no" default="">
		<cfargument name="spendItems" type="string" required="no" default="">
		<cfargument name="spendGroups" type="string" required="no" default="">
		<cfargument name="avuids" type="string" required="no" default="">
		
		<cfscript>
			var qry = objDAO.getBudgetDataByAvg(argumentcollection = arguments);
		</cfscript>
		
		<cfreturn qry>
	</cffunction>
	
	<cffunction name="getBudgetDataByNI" access="public" returntype="query" hint="Get basic level budget data">
		<cfargument name="minyear" type="string" required="no" default="">
		<cfargument name="maxyear" type="string" required="no" default="">
		<cfargument name="nilist" type="string" required="no" default="">
		<cfargument name="organisationids" type="string" required="no" default="">
		
		<cfscript>
			var qry = objDAO.getBudgetDataByNI(argumentcollection = arguments);
		</cfscript>
		
		<cfreturn qry>
	</cffunction>
	
	
	<cffunction name="getRoadLengthDataByOrg" access="public" returntype="query" hint="Get basic level budget data">
		<cfargument name="minyear" type="string" required="no" default="">
		<cfargument name="maxyear" type="string" required="no" default="">
		<cfargument name="roadItems" type="string" required="no" default="">
		<cfargument name="organisationids" type="string" required="no" default="">
		
		<cfset arguments.organisationids = cleanArray(arguments.organisationids)>		
		
		<cfscript>
			qry = objDAO.getRoadLengthDataByOrg(argumentcollection = arguments);
		</cfscript>
		
		<cfreturn qry>
	</cffunction>
	
	<cffunction name="getRoadLengthDataByAvg" access="public" returntype="query" hint="Get basic level budget data">
		<cfargument name="minyear" type="string" required="no" default="">
		<cfargument name="maxyear" type="string" required="no" default="">
		<cfargument name="roadItems" type="string" required="no" default="">
		<cfargument name="avuids" type="string" required="no" default="">
		
		<cfscript>
			var qry = objDAO.getRoadLengthDataByAvg(argumentcollection = arguments);
		</cfscript>
		
		<cfreturn qry>
	</cffunction>
	
	
	
	<cffunction name="getRoadSpendDataByOrg" access="public" returntype="query" hint="Get basic level budget data">
		<cfargument name="minyear" type="string" required="no" default="">
		<cfargument name="maxyear" type="string" required="no" default="">
		<cfargument name="organisationids" type="string" required="no" default="">
		
		<cfset arguments.organisationids = cleanArray(arguments.organisationids)>		
		
		<cfscript>
			qry = objDAO.getRoadSpendDataByOrg(argumentcollection = arguments);
		</cfscript>
		
		<cfreturn qry>
	</cffunction>
	
	<cffunction name="getRoadSpendDataByAvg" access="public" returntype="query" hint="Get basic level budget data">
		<cfargument name="minyear" type="string" required="no" default="">
		<cfargument name="maxyear" type="string" required="no" default="">
		<cfargument name="avuids" type="string" required="no" default="">
		
		<cfscript>
			var qry = objDAO.getRoadSpendDataByAvg(argumentcollection = arguments);
		</cfscript>
		
		<cfreturn qry>
	</cffunction>
	
	
	
	<cffunction name="getRoadPropDataByOrg" access="public" returntype="struct" hint="Get basic level budget data">
		<cfargument name="minyear" type="string" required="no" default="">
		<cfargument name="maxyear" type="string" required="no" default="">
		<cfargument name="organisationids" type="string" required="no" default="">
		
		<cfset arguments.organisationids = cleanArray(arguments.organisationids)>		
		
		<cfscript>
			strData = objDAO.getRoadPropDataByOrg(argumentcollection = arguments);
		</cfscript>
		
		<cfreturn strData>
	</cffunction>
	
	<cffunction name="getRoadPropDataByAvg" access="public" returntype="struct" hint="Get basic level budget data">
		<cfargument name="minyear" type="string" required="no" default="">
		<cfargument name="maxyear" type="string" required="no" default="">
		<cfargument name="avuids" type="string" required="no" default="">
		
		<cfscript>
			var strData = objDAO.getRoadPropDataByAvg(argumentcollection = arguments);
		</cfscript>
		
		<cfreturn strData>
	</cffunction>
	
	
	<cffunction name="cleanArray" access="package" returntype="string">
		<cfargument name="arr" type="string" required="yes">
		
		<cfset var arrToClean = listtoarray(arguments.arr)>
		<cfset var lstToReturn = ''>
		
		<cfloop from="1" to="#arraylen(arrToClean)#" index="i">
			<cfif len(arrToClean[i]) eq 0>
				<cfset arraydeleteat(arrToClean, i)>
			</cfif>
		</cfloop>
		
		<cfset lstToReturn = arraytolist(arrToClean, ',')>
		
		<cfreturn lstToReturn>
	</cffunction>
	
</cfcomponent>