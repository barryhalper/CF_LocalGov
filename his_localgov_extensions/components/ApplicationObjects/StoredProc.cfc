<cfcomponent displayName="storedproc">
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------>
	<!--- CONSTRUCTOR ------------------------------------------------------------------------------------------------------------------------------------------------------------------>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------>
	<cffunction name="init" access="public" output="false" returntype="storedproc" hint="Pseudo-constructor">
		<cfargument name="procedure" required="yes" type="string">
		<cfargument name="dsn" 		 required="yes" type="string">
			<cfscript>
			variables.instance 			 = structNew();
			variables.instance.procedure = arguments.procedure;
			variables.instance.dsn 		 = arguments.dsn;
			//array to hold a paramters
			variables.instance.Params	 = ArrayNew(1);
			return this;
			</cfscript>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getInstance" access="public" output="false" returntype="struct" hint="return local scope to caller">
		<cfreturn variables.instance>
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="setParam" access="public" output="false" returntype="void" hint="save structure to hold stored proc parametes into instance array">
		<cfargument name="pName" required="yes" type="string" >
		<cfargument name="pValue" required="yes" type="any">
		<cfargument name="ptype" required="yes" type="string">
			<cfset ArrayAppend(variables.instance.Params, arguments)>
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="execute" access="public" output="false" returntype="struct" hint="execute stored proc using cfstoredproc">
		<cfargument name="noResults" 	required="yes" type="numeric" default="0" >
		<cfargument name="outParam" 	required="no"  type="string"  default="" >
		<cfargument name="returncode"   required="no"  type="numeric"  default="false" >
		
			<cfset var i 					= 0>
			<cfset var r 					= 0>
			<cfset var nullValue    		= false>
			<cfset var params    			= structNew()>
			<cfset var results    			= structnew()>
			<cfset instance.proc 			= structNew()>
			
			<!--- BEGIN CFSTOREDPROC --->
			 <cfstoredproc datasource="#instance.dsn#" procedure="#instance.procedure#" returncode="#arguments.returncode#">
				<!---BEGIN CFPROCPARAM --->
				 <cfloop from="1" to="#ArrayLen(instance.Params)#" index="i"><!--- set as many params as present in instance data --->
				 <cfset params = instance.Params[i]>
					<cfif NOT Len(params.pValue) or params.pValue eq "0">
						<!--- set NULL --->
						<cfset nullValue = true >
					</cfif>
						 <cfprocparam type="in" dbvarname="@#params.pName#" value="#params.pValue#"  cfsqltype="#sqlType(params.ptype)#" null="#nullValue#" /> 
					
				</cfloop> 
			<!--- ouput paramteter --->	
			<cfif Len(arguments.outParam)>
				 	<cfprocparam type="out" variable="instance.proc.outParam" dbvarname="#arguments.outParam#" cfsqltype="cf_sql_integer"> 
				</cfif>
				<!---BEGIN CFPROCRESULT--->
				<cfif arguments.noResults><!--- get as many results as specified in argument --->
					<cfloop from="1" to="#arguments.noResults#" index="r">
						<cfset qryName = "qry_" & r>
						<cfprocresult name="results.#Evaluate('qryName')#" resultset="#r#">
							
					</cfloop>
				</cfif> 
				
			</cfstoredproc> 	
			<!-- -END CFSTOREDPROC --->
			
			<!--- copy result-sets in rtn structure --->
			<cfset instance.proc.results = results>
			<!--- set return status code --->
			<cfif structKeyExists(cfstoredproc, "statusCode")>
				<cfset instance.proc.statusCode = cfstoredproc.statusCode>
			</cfif>
			
			<cfreturn instance.proc>
	</cffunction> 
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	 <cffunction name="query" access="public" output="false" returntype="query" hint="execute stored proc using cfquery (in order to utilize cache time) - depreicated in CF8">
		<cfargument name="cacheTime"  type="any" default="#CreateTimeSpan(0,0,0,0)#">
		
			<cfset var i 					= 0>
			<cfset var qry 					= queryNew("temp")>
			<cfset var params    			= structNew()>
			
			<cfquery datasource="#instance.dsn#" name="qry" cachedwithin="#arguments.cacheTime#">
				EXEC #instance.procedure#
				<!--- set as many params as present in instance data --->
				<cfloop from="1" to="#ArrayLen(instance.Params)#" index="i">
					  <cfset params = instance.Params[i]>
						@#params.pName# = <cfif NOT Len(params.pValue) or params.pValue eq "0">NULL<cfelse>#params.pvalue#</cfif> <cfif i lt ArrayLen(instance.Params)>,</cfif>
				</cfloop>
			</cfquery>
		<cfreturn qry>
	</cffunction>  
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="sqlType" access="public" output="false" returntype="string" hint="return sql type base on value ">
		<cfargument name="ptype" required="yes" type="string">
			
			<cfscript>
			var sqlTypeString = "";
			 switch (ptype){
			 default:
			 sqlTypeString		="cf_sql_varchar";
				break;
			 case "string":
			 	sqlTypeString	="cf_sql_varchar";
				break;
			 case "numeric":
			 	sqlTypeString	="cf_sql_integer";
				break;
			case "boolean":
			 	sqlTypeString	="cf_sql_bit";
				break;	
			case "text":
			 	sqlTypeString	="cf_sql_longvarchar";
				break;		
			case "date":
			 	sqlTypeString	="cf_sql_date";
				break;	
			case "money":
			 	sqlTypeString	="cf_sql_money";
				break;		
								
			 }
			 return sqlTypeString;
			</cfscript>
			
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	
</cfcomponent>