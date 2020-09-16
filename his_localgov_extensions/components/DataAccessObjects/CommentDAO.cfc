<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/COMPONENTS/DataAccessObjects/CommentDAO.cfc $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 8/08/07 10:06 $

--->

<cfcomponent displayname="CommentDAO" hint="Comment-related data access methods" extends="his_Localgov_Extends.components.DAOManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="CommentDAO" hint="Pseudo-constructor">
	
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		StructAppend( variables, Super.init( arguments.strConfig ) );
		
		return this;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->		
	<cffunction name="getProfanities" access="public" output="false" returntype="query" 
		hint="">

		<cfset var qryRecordSet = ""> 
		
		<cfquery name="qryRecordSet" datasource="#variables.DSN1#">
		EXEC sp_GetProfanities
		</cfquery>
		
		<cfreturn qryRecordSet>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="postComment" access="public" output="false" returntype="numeric" 
		hint="">
		
		<cfargument name="userID" 	required="yes" type="numeric">
		<cfargument name="comment" 	required="yes" type="string">
		<cfargument name="email" 	required="yes" type="string">
		<cfargument name="name" 	required="yes" type="string">
		<cfargument name="newsid"	required="yes" type="numeric">
	
		<cfset var commentID=0>
		
		<!--- Perform Insert/Update --->
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_CommitComment">
			<cfprocparam dbvarname="@userID" 	cfsqltype="cf_sql_integer" 	type="in" value="#arguments.userID#" >
			<cfprocparam dbvarname="@comment" 	cfsqltype="cf_sql_varchar"  type="in" value="#arguments.comment#">
			<cfprocparam dbvarname="@email" 	cfsqltype="cf_sql_varchar"  type="in" value="#arguments.email#">
			<cfprocparam dbvarname="@name" 		cfsqltype="cf_sql_varchar"  type="in" value="#arguments.name#">
			<cfprocparam dbvarname="@newsid" 	cfsqltype="cf_sql_integer"  type="in" value="#arguments.newsid#">
			
			<cfprocparam dbvarname="@CommentID"	cfsqltype="cf_sql_integer" type="out" variable="commentID">
		</cfstoredproc>
		
		<!--- Return the article's ID --->
		<cfreturn commentID>
		
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="updateCommentStatus" access="public" returntype="boolean" output="false">
	
		<cfargument name=	"commentid" required="yes" type="string">
		<cfargument name=	"statusid"  required="yes" type="string">
		
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_UpdateCommentStatus">
			<cfprocparam dbvarname="@commentid" cfsqltype="cf_sql_integer" 	type="in" value="#arguments.commentid#">
			<cfprocparam dbvarname="@statusid" 	cfsqltype="cf_sql_integer" 	type="in" value="#arguments.statusid#">
		</cfstoredproc>

		<cfreturn true>				
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="commitProfanity" access="public" returntype="boolean" output="false">
	
		<cfargument name=	"id" 		required="yes" type="string">
		<cfargument name=	"profanity"  	required="yes" type="string">
		
		<cfif arguments.id neq 0>
			<cfstoredproc datasource="#variables.DSN1#" procedure="sp_UpdateProfanity">
				<cfprocparam dbvarname="@id" cfsqltype="cf_sql_integer" 	type="in" value="#arguments.id#">
				<cfprocparam dbvarname="@profanity" cfsqltype="CF_SQL_VARCHAR" type="in" value="#arguments.profanity#">
			</cfstoredproc>
		<cfelse>
			<cfstoredproc datasource="#variables.DSN1#" procedure="sp_AddProfanity">
				<cfprocparam dbvarname="@profanity" cfsqltype="CF_SQL_VARCHAR" type="in" value="#arguments.profanity#">
			</cfstoredproc>
		</cfif>

		<cfreturn true>	
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="deleteProfanity" access="public" returntype="void" output="false">
	
		<cfargument name="id" required="yes" type="numeric">
		
		<cfset var qryRecordSet = ""> 
		
		<cfquery name="qryRecordSet" datasource="#variables.DSN1#">
		EXEC sp_DeleteProfanity
			@id = #arguments.id#
		</cfquery>
				
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="updateComment" access="public" returntype="boolean" output="false">
	
		<cfargument name=	"commentid" required="yes" type="string">
		<cfargument name=	"comment"  required="yes" type="string">
        <cfargument name=	"statusID"   required="no" type="numeric" default="0">

		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_UpdateComment">
			<cfprocparam dbvarname="@commentid" cfsqltype="cf_sql_integer" 	type="in" value="#arguments.commentid#">
			<cfprocparam dbvarname="@comment" 	cfsqltype="cf_SQL_VARCHAR" 	type="in" value="#arguments.comment#">
           <cfif arguments.statusID neq 0>
            <cfprocparam dbvarname="@statusID" 	cfsqltype="cf_sql_integer" 	type="in" value="#arguments.statusID#">
            </cfif>
		</cfstoredproc>

		<cfreturn true>				
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getCommentsByArticleID" access="public" output="false" returntype="query" 
		hint="">
		
		<cfargument name="newsid" required="yes" type="numeric">
		<cfargument name="statusid" required="yes" type="numeric">
		
		<cfset var qryRecordSet = ""> 
		
		<cfquery name="qryRecordSet" datasource="#variables.DSN1#" cachedwithin="#variables.CACHE_TIME#">
		EXEC sp_GetCommentsByArticleID
			@NewsID = #arguments.newsid#,
			@StatusID = #arguments.statusid#
		</cfquery>
		
		<cfreturn qryRecordSet>
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getComment" access="public" output="false" returntype="query" 
		hint="">
		
		<cfargument name="commentid" required="no" type="numeric" default="0">
		
		<cfset var qryRecordSet = ""> 
		
		<cfquery name="qryRecordSet" datasource="#variables.DSN1#" cachedwithin="#variables.CACHE_TIME#">
		EXEC sp_GetArticleComment
			@commentid = #arguments.commentid#
		</cfquery>
		
		<cfreturn qryRecordSet>
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getAllComments" access="public" output="false" returntype="query" 
		hint="">
	
		<cfset var qryRecordSet = ""> 
		
		<cfquery name="qryRecordSet" datasource="#variables.DSN1#" >
		EXEC sp_GetNewsComments
		</cfquery>
		
		<cfreturn qryRecordSet>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->	
    
	<cffunction name="getAllCommentsForCMS" access="public" output="false" returntype="query" 
		hint="">
	
		<cfset var qryRecordSet = ""> 
		
		<cfquery name="qryRecordSet" datasource="#variables.DSN1#" >
		usp_GetLocalGov_CommentsForAdmin
		</cfquery>
		
		<cfreturn qryRecordSet>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
</cfcomponent>