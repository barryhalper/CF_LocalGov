<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/COMPONENTS/DataAccessObjects/SearchDAO.cfc $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 8/08/07 10:06 $

--->

<cfcomponent displayname="SearchDAO" hint="Search-related data access methods" extends="his_Localgov_Extends.components.DAOManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="SearchDAO" hint="Pseudo-constructor">
	
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		StructAppend(variables, Super.init(arguments.strConfig));
		return this;
		</cfscript>
				
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetSectors" access="public" output="false" returntype="query" hint="return al sectors for this website">
		<cfargument name="productid" type="numeric" required="yes">
		 
		<cfset var qry ="">
		<cfquery name="qry" datasource="#variables.DSN1#">
			EXEC sp_GetSectors #arguments.productid#
		</cfquery>
		<cfreturn qry>	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetCollectionData" access="public" output="false" returntype="query" hint="return all data which is to be added to collection">
		<cfargument name="ProductID" 	required="yes" type="string" hint="list of website id's to be indexed">
		<cfargument name="startrow"  	required="no" type="numeric" default="1">	
		<cfargument name="Endrow"     	required="no" type="numeric" default="0">
		<cfargument name="AttributeID"  required="no" type="string" default="">
		
		<cfset var qry =  "">
		
		<cfstoredproc datasource="#variables.DSN1#" procedure="spBuildLocalGovContent">
			<cfprocparam cfsqltype="cf_sql_varchar" type="in" dbvarname="@ProductID" value="#arguments.ProductID#">
			<cfprocparam cfsqltype="cf_sql_varchar" type="in" dbvarname="@startrow" value="#arguments.startrow#">
			<cfprocparam cfsqltype="cf_sql_varchar" type="in" dbvarname="@Endrow" value="#arguments.Endrow#">
			<cfif Len(arguments.AttributeID)>
				<cfprocparam cfsqltype="cf_sql_varchar" type="in" dbvarname="@AttributeID" value="#arguments.AttributeID#">
			<cfelse>
				<cfprocparam cfsqltype="cf_sql_varchar" type="in" dbvarname="@AttributeID" value="" null="yes">
			</cfif>
			<cfprocresult name="qry">
		</cfstoredproc>

		<cfreturn qry>	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="SearchCollection" access="public" output="false" returntype="struct" hint="perform verity search against indexed collection">
		<cfargument name="criteria" 				required="yes" type="string" >
		<cfargument name="contextPassages" 			required="no" type="numeric" default="2" >
		<cfargument name="contextBytes" 			required="no" type="numeric" default="300" >
		<cfargument name="type" 					required="no" type="string" default="simple" >
		<cfargument name="contexthighlightbegin" 	required="no" type="string" default="">
		<cfargument name="contexthighlightend" 		required="no" type="string" default="" >
		
		 <cfscript>
		 var strReturn=		StructNew();
		 var strStatus=		StructNew(); 
		 var qryResults= 	QueryNew("author,category,categorytree,context, 
		 							custom1,custom2,custom3,custom4,key,rank, 
									recordssearched,score, size,summary,title,type,url");
		 </cfscript>
		 
		 <cftry>
			<!--- Run verity search --->
			<cfsearch 	collection=				"#variables.strConfig.strVars.VerityCollection#" 
						criteria=				"#arguments.criteria#" 
						name=					"qryResults" 
						contextPassages = 		"#arguments.contextPassages#" 
						contextBytes = 			"#arguments.contextBytes#" 
						status=					"strStatus" 
						type=					"#arguments.type#"  
						suggestions=			"always"   
						contexthighlightbegin=	"#arguments.contexthighlightbegin#" 
						contexthighlightend=	"#arguments.contexthighlightend#">
					
			<cfcatch>
				<cfrethrow>
			</cfcatch>
		</cftry>
		
		<cfscript>
		//place resultset in retur str
		strReturn.qryResults=qryResults;
		//place status in return str
		strReturn.strStatus=strStatus;
		return strReturn;
		</cfscript>
				
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions ------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetLocalGov" access="public" output="false" returntype="query" hint="exec stored proc to return all data - perform generic search across myb and his_websites">
		
		<cfargument name="keyword" required="yes" type="string" >
		<cfargument name="lstAttributeID" required="no" type="string" default="">
		
		<cfset var qry = "">
		
		<!--- <cfdump var="#arguments#"><cfabort> --->
		
		<cfquery datasource="#variables.DSN1#" name="qry" cachedwithin="#variables.CACHE_TIME#">
			EXEC sp_SearchLovGovContent
				@keyword = '#arguments.keyword#'
				<cfif len(arguments.lstAttributeID)>
				, @SearchAttribute='#arguments.lstAttributeID#'
			</cfif> 
		</cfquery> 
		<cfreturn qry>	
		
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

</cfcomponent>