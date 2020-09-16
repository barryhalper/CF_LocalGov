<cfcomponent displayname="BlogsDAO"  hint="" extends="his_Localgov_Extends.components.DAOManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="BlogsDAO" hint="Pseudo-constructor">
	
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		StructAppend( variables, Super.init( arguments.strConfig ) );

		return this;
		</cfscript>
		
	</cffunction>

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions: *GET* ----------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<cffunction name="getBlogs" access="public" output="false" returntype="query" hint="">
	  <cfset qryBlogs ="">
		
		<cfquery name="qryBlogs" datasource="#variables.DSN1#">
			EXEC sp_getBlogs	
		</cfquery>
		
		<cfreturn qryBlogs>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<cffunction name="CommitBlogDetail" access="public" output="false" returntype="numeric" hint="">
	  <cfargument name="blogid" 			type="numeric" required="no" default="0">
	  <cfargument name="Name" 				type="string" required="yes">
	  <cfargument name="location" 			type="string" required="yes">
	  <cfargument name="author" 			type="string" required="yes">	  
	  <cfargument name="description" 		type="string" required="yes">
	  <cfargument name="image" 				type="string" required="yes">
	  <cfargument name="pubseq" 			type="numeric" required="no" default="0">
	  
	  <cfset var newid = 0>
	  
	  <cfstoredproc datasource="#variables.DSN1#" procedure="sp_CommitBlog">
		
		<cfif arguments.blogid>
		 	<cfprocparam type="in"  cfsqltype="cf_sql_integer" dbvarname="@Blogid" value="#arguments.blogid#">
	   	<cfelse>
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" dbvarname="@Blogid" value="" null="yes">
	   </cfif>
	   		
			 <cfprocparam type="in"  cfsqltype="cf_sql_varchar"    	dbvarname="@blogName" value="#arguments.Name#"> 
			 <cfprocparam type="in"  cfsqltype="cf_sql_varchar"    	dbvarname="@location" value="#arguments.location#">
			 <cfprocparam type="in"  cfsqltype="cf_sql_varchar"    	dbvarname="@description" value="#arguments.description#">
			 <cfprocparam type="in"  cfsqltype="cf_sql_varchar"    	dbvarname="@image" value="#arguments.image#">
			 <cfprocparam type="in"  cfsqltype="cf_sql_varchar"    	dbvarname="@author" value="#arguments.author#">
			 <cfprocparam type="in"  cfsqltype="cf_sql_integer"     dbvarname="@pubseq" value="#arguments.pubseq#">
			 <cfprocparam type="out" cfsqltype="cf_sql_integer" 	dbvarname="@NewID" Variable="newid"> 
		</cfstoredproc>
		
		<cfreturn newid>
	</cffunction>


	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<cffunction name="DeleteBlogDetail" access="public" output="false" returntype="void" hint="">
		 <cfargument name="blogid" 			type="numeric" required="yes" >
		
		<cfquery  datasource="#variables.DSN1#">
		  sp_DeleteBlog #arguments.blogid#
		  </cfquery>
		  
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
</cfcomponent>	