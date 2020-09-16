<cfcomponent displayname="Topics" hint="Topic business object functions" extends="his_Localgov_Extends.components.BusinessObjectsManager">
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR -------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Topics" hint="Pseudo-constructor">
		<cfargument name="objAppObjs" 		type="any" 	   required="yes" hint="The application manager object">
		<cfargument name="objBusObjs" type="any" required="yes" hint="The business objects">
		<cfscript>
		// Call the genric init function, placing business, app, and dao objects into a local scope...
		structAppend( variables, Super.initChild( arguments.objAppObjs, this, arguments.objBusObjs ) );
	
		//variables.qryTopics = GetTopics();
		return this;
		</cfscript>
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions --------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getVariables" access="public" output="false" returntype="struct" hint="">
		<cfreturn variables>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="GetTopics" access="public" output="false" returntype="query" hint="returns topics">
		<cfargument name="refresh" required="no" type="boolean" default="false">
		
		<cfscript>
		var qryTopics = "";
		
		if(structKeyExists(variables, "qryTopics") and not arguments.refresh)
			qryTopics = variables.qryTopics;
		else{
			variables.qryTopics =  objDAO.GetTopics();
			qryTopics = variables.qryTopics; 
			}
		return 	qryTopics;
		
		</cfscript>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="GetTopicName" access="public" output="false" returntype="string" hint="returns topics">
		<cfargument name="id" required="yes" type="numeric" >
		
		<cfset GetTopics()>
		<cfreturn objUtils.QueryOfquery(variables.qryTopics, "*", "p_topic_id=#arguments.id#").topic>
				
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------>
	<cffunction name="GetArticlesByTopicID" access="public" output="false" returntype="query" hint="returns topics">
		<cfargument name="topicId" required="yes" type="numeric" >
		
		<cfreturn objDAO.GetArticlesByTopicID(arguments.topicId)>
				
	</cffunction>
		
</cfcomponent>