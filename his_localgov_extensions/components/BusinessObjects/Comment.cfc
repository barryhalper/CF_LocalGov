<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/COMPONENTS/BusinessObjects/Comment.cfc $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 8/08/07 10:06 $

--->

<cfcomponent displayname="Comment" hint="Comment-related business object functions" extends="his_Localgov_Extends.components.BusinessObjectsManager">

	<!---   ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Comment" hint="Pseudo-constructor">
		<cfargument name="objAppObjs" type="any" required="yes" hint="The application manager object">
		<cfargument name="objBusObjs" type="any" required="yes" hint="The application manager object">

		<cfscript>
		// Call the genric init function, placing business, app, and dao objects into a local scope...
		StructAppend( variables, Super.initChild( arguments.objAppObjs, this, arguments.objBusObjs ) );
		
		//variables.qryProfanities = getProfanities();
		
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
	<cffunction name="getProfanities" access="public" output="false" returntype="query" 
		hint="returns a query containing all profanities">
		<cfargument name="refresh" 	required="yes" type="boolean" default="0">
		<cfscript>
		var qryReturn=querynew("temp");
		if (structKeyExists(variables, "qryProfanities") AND NOT arguments.refresh)
			qryReturn = variables.qryProfanities;
		else{
			variables.qryProfanities = objDAO.getProfanities();
			qryReturn = variables.qryProfanities;
		}
		return 	qryReturn;
		</cfscript>
		
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="postComment" access="public" output="false" returntype="numeric" 
		hint="post the comment to the dao">
		<cfargument name="userID" 	required="yes" type="numeric">
		<cfargument name="comment" 	required="yes" type="string">
		<cfargument name="email" 	required="yes" type="string">
		<cfargument name="name" 	required="yes" type="string">
		<cfargument name="newsid"	required="yes" type="numeric">
		
		<cfscript>
		var bl = false;
		bl = objDAO.postComment( arguments.userID, arguments.comment, arguments.email, arguments.name, arguments.newsid );
		FlushComments();
		return bl;
		</cfscript>
	
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="updateCommentStatus" access="public" returntype="boolean" output="false"
		hint="update the comment's status">
	
		<cfargument name=	"commentid" required="yes" type="string">
		<cfargument name=	"statusid"  required="yes" type="string">
		
		<cfreturn objDAO.updateCommentStatus( arguments.commentid, arguments.statusid )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="commitProfanity" access="public" returntype="boolean" output="false">
		 <cfargument name="comment" required="yes" type="string">
		  <cfargument name="id" required="no" type="numeric" default="0">
			 
			  <cfscript>
			   //filter comment before commit
				var bl =  objDAO.commitProfanity( arguments.id,  arguments.comment);
				getProfanities(1);
				return bl;
			   </cfscript>
			   
          </cffunction>

	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="deleteProfanity" access="public" returntype="void" output="false"
		hint="delete the profanity and update the query stored in memory">
	
		<cfargument name="id" required="no" type="numeric" default="0">
		
		<cfset objDAO.deleteProfanity( arguments.id )>
		<cfset getProfanities(1)>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="updateComment" access="public" returntype="boolean" output="false"
		hint="update the comment">
	
		<cfargument name=	"commentid" required="yes" type="string">
		<cfargument name=	"comment"  required="yes" type="string">
        <cfargument name=	"statusId"  required="no" type="numeric" default="0">
		
		<cfscript>
		var bl = false;
		bl = objDAO.updateComment( arguments.commentid, arguments.comment, arguments.statusId );
		//FlushComments();
		return bl;
		</cfscript>
	
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getCommentsByArticleID" access="public" output="false" returntype="query" 
		hint="returns a query containing the comment by article id">
		
		<cfargument name="newsid" required="yes" type="numeric">
		<cfargument name="statusid" required="no" type="numeric" default="2" hint="approved">
		
		<cfreturn objDAO.getCommentsByArticleID( arguments.newsid, arguments.statusid )>

	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getComment" access="public" output="false" returntype="query" 
		hint="returns a query containing the comment, by comment id">
		
		<cfargument name="commentid" required="no" type="numeric" default="0">

		<cfreturn objDAO.getComment( arguments.commentid )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="isProfane" access="public" output="false" returntype="boolean" 
		hint="return true if profanity is found in string">
		
		<cfargument name="comment" required="yes" type="string" >

		<cfscript>
		var qryProfanities = getProfanities();
		var bl = false;
		var i= 			0;
		var j= 			0;
		var filtered= 	"";
		var curWord= 	"";
		var singular= 	"";
		var plural= 	"";
		
		for (i=1; i lte listLen(arguments.comment, " "); i=i+1) {
			curWord= listGetAt(arguments.comment, i, " ");
			
			for (j=1; j lte qryProfanities.recordCount; j=j+1) {
				// check singular and plural versions of the profanity...
				baseWord= qryProfanities.profanity[j];
				if (lcase(right(baseWord, 1)) eq "s") {
					singular=	URLEncodedFormat(mid(baseWord, 1, len(baseWord)-1));
					plural= 	URLEncodedFormat(baseWord);
				} else {
					singular=	URLEncodedFormat(baseWord);
					plural= 	URLEncodedFormat(baseWord & "s");
				}
				
				if ( reFindNoCase("#plural#|#singular#", curWord) ) {
					bl = true;
					break;
				}
			}
			if (bl)
			 break;
			
		}		
		return bl;
		</cfscript>
		
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="filterProfanities" access="public" output="false" returntype="string" 
		hint="returns a string containing the filtered version of the comment, replacing profanitied with ***">
		
		<cfargument name="comment" required="yes" type="string" >

		<cfscript>
		var qryPro= 	getProfanities();
		var i= 			0;
		var j= 			0;
		var filtered= 	"";
		var curWord= 	"";
		var singular= 	"";
		var plural= 	"";
		var pos=		0;
		
		for (i=1; i lte listLen(arguments.comment, " "); i=i+1) {
			curWord= listGetAt(arguments.comment, i, " ");
			
			for (j=1; j lte qryPro.recordCount; j=j+1) {
				// check singular and plural versions of the profanity...
				baseWord= qryPro.profanity[j];
				if (lcase(right(baseWord, 1)) eq "s") {
					singular=	URLEncodedFormat(mid(baseWord, 1, len(baseWord)-1));
					plural= 	URLEncodedFormat(baseWord);
				} else {
					singular=	URLEncodedFormat(baseWord);
					plural= 	URLEncodedFormat(baseWord & "s");
				}
				
				pos = reFindNoCase( "([:punct:]*)(#URLENCODEDFORMAT(baseWord)#)([:punct:]*)", curWord );
				
				if ( pos eq 1  ) {
					
					curWord = rereplaceNoCase(
								trim(curWord), 
								"([:punct:]*)(#URLENCODEDFORMAT(baseWord)#)([:punct:]*)", 
								"" & repeatString("*", len(curWord)) & "", 
								"all"	);
					
					break;
				}
				if ( pos gt 1  ) {
					curWord = rereplaceNoCase(
								trim(curWord), 
								"('|"")(#URLENCODEDFORMAT(baseWord)#)('|"")", 
								repeatString("*", len(curWord)), 
								"all"	);
					break;
				}
			}
			filtered= filtered & curWord & " ";
		}		
		return filtered;
		</cfscript>
		
	</cffunction>
    <!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->	
    
	<cffunction name="getAllCommentsForCMS" access="public" output="false" returntype="query" 
		hint="">
	
		<cfreturn objDAO.getAllCommentsForCMS( )>
	
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
    
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	
	<cffunction name="FlushComments" access="public" output="false" returntype="void" 
		hint="rest comments held in memory to a later version">
			<cfset variables.objArticle.getNewsHomeContent().qryUserComments = objDAO.getAllComments()>	
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	
</cfcomponent>