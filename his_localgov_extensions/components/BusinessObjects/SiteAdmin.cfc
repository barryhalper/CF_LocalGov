<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/BusinessObjects/SiteAdmin.cfc $
	$Author: Ohilton $
	$Revision: 3 $
	$Date: 8/04/09 11:39 $

--->

<cfcomponent displayname="SiteAdmin" hint="Admin-related functions" extends="his_Localgov_Extends.components.BusinessObjectsManager">
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR -------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="SiteAdmin">
		<cfargument name="objAppObjs" type="any" required="yes" hint="The application objects">
		<cfargument name="objBusObjs" type="any" required="yes" hint="The business objects">
		
		<cfscript>
		 StructAppend( variables, Super.initChild( arguments.objAppObjs, this, arguments.objBusObjs ) );	
		 variables.qry_UserGroups = objDAO.getUserGroup();
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
	<cffunction name="getUserGroups" access="public" output="false" returntype="query" hint="">
		<cfreturn variables.qry_UserGroups>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="validateLogin" access="public" output="false" returntype="void" hint="validate login and set sesion if successful">
		<cfargument name="strSession" type="struct" required="yes">
		<cfargument name="email" type="string" required="yes">
		<cfargument name="password" type="string" required="yes">
		
		<cfset var qryLogin =  objDAO.validateLogin(arguments.email, arguments.password)>
		<cfset setSession(arguments.strSession, qryLogin)>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getRegStats" access="public" output="false" returntype="struct" hint="">
		<cfscript>
		strReturn = StructNew();
		strReturn.qryUsersSinceLaunch = objDAO.getUsersSinceLaunch();
		strReturn.qryTotalUsers =objDAO.getTotalUsers();
		return strReturn;
		</cfscript>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getTracking" access="public" output="false" returntype="query" hint="">
		<cfreturn objDAO.getTracking()>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="HasAccess" access="public" output="false" returntype="boolean" hint="works out if a user has access to a certain part of the admin site">
		<cfargument name="strSession" type="struct" required="yes">
		<cfargument name="AcessType"   type="string" required="yes" hint="list of groups that the user MUST be in to access">
		<cfscript>
		var bl	=false;
		var lstAdmingroups = arguments.strSession.userdetails.admingroups;
		var arrUserGourp = listToArray(lstAdmingroups, '|');
		var i=0;
		if ( listContains(lstAdmingroups, 1 ))
			bl=true;
		else{
			//loop	over array
			for (i=1;i LTE arrayLen(arrUserGourp);i=i+1 ){
				//cehck if user has access type in thier groups
				if (listfind(arguments.AcessType, arrUserGourp[i] ) )
					bl=true;
			}	
		}
		return bl;
		</cfscript>
	
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="SetUserGroups" access="public" output="false" returntype="string" hint="">
		<cfargument name="strSession" type="struct" required="yes">
		
		<cfset var lstGroupIDs = arguments.strSession.UserDetails.AdminGroups>
		<cfset var lstGroups = "">
	
			<cfloop list="#lstGroupIDs#" index="GroupID" delimiters="|">
				<cfset lstGroups = GetVariables().qry_UserGroups.admingroup[GroupID] & ", ">
			</cfloop>
		<cfset lstGroups = Mid(lstGroups, 1, Len(lstGroups)-2)>
		<cfreturn lstGroups>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="GetUsers" access="public" output="false" returntype="query" hint="">
			<cfscript>
			var qryUsers = objDAO.GetUsers();
			return objUtils.queryofquery(qryUsers, "*", "password_localgov IS NOT NULL");
			</cfscript>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getAdminUser" access="public" output="false" returntype="query" hint="">
		<cfargument name="userid" required="no" type="numeric"  default="0">
		<cfreturn objDAO.getAdminUser(arguments.userid)>
	</cffunction>
	
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- COMMITT ------------------------------------------------------------------------------------------>
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="CommitUser" access="public" output="false" returntype="numeric" hint="">
		<cfargument name="UserID" 			type="numeric" required="no" default="0">
		<cfargument name="forename" 		type="string" required="yes">
		<cfargument name="surname" 			type="string" required="yes">
		<cfargument name="username" 		type="string" required="yes">
		<cfargument name="password" 		type="string" required="yes">
		<cfargument name="lstGroups" 		type="string" required="yes">
		<cfargument name="partnerid" 		type="numeric" required="no" default="0">
		<cfargument name="confirmpw" 		type="string" required="no" default="">
		
		
			<cfscript>
			//has password
			if (Len(arguments.confirmpw))
				arguments.password = hash(arguments.password);
				
			return objDAO.CommitUser(argumentCollection=arguments);
			</cfscript> 
			
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="DeleteUser" access="public" output="false" returntype="boolean" hint="">
		<cfargument name="UserID" 			type="numeric" required="yes">
		<cfreturn objDAO.DeleteUser(arguments.UserID)>	
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- PRIAVTE Functions -------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="setSession" access="private" output="false" returntype="void" hint="set sesion data for this user based on login">
		<cfargument name="strSession" type="struct" required="yes">
		<cfargument name="qryLogin"   type="query" required="yes">
			
		<cfscript>
		arguments.strSession.IsPartner					= false;
		if (arguments.qryLogin.recordcount){
			arguments.strSession.loggedin 				 = true;
			arguments.strSession.UserDetails			 = StructNew();
			arguments.strSession.UserDetails.Fullname	 = arguments.qryLogin.forename & ' ' & arguments.qryLogin.surname;
			arguments.strSession.UserDetails.Username	 = arguments.qryLogin.Username;
			arguments.strSession.UserDetails.UserID		 = arguments.qryLogin.UserID;
			arguments.strSession.UserDetails.AdminGroups = arguments.qryLogin.AdminGroups;
		}
		if (arguments.qryLogin.AdminGroups eq 6){
			arguments.strSession.IsPartner					= true;
			arguments.strSession.UserDetails.qryPartners	= objutils.queryofquery(objjobs.GetJobsPartners(), '*', 'PartnerID = #qryLogin.PartnerID#');
			}
		</cfscript>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="setPartner" access="private" output="false" returntype="void" hint="set details of partner into user's session">
		<cfargument name="strSession" type="struct" required="yes">
				
	</cffunction>
	
	<cffunction name="gethome" access="public" output="false" returntype="struct" hint="">
		<cfreturn objDAO.gethome()>
	</cffunction>
	
</cfcomponent>