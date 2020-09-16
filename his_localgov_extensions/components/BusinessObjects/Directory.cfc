<!--- 
	
	$Archive: /localgov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/BusinessObjects/Directory.cfc $
	$Author: Bhalper $
	$Revision: 22 $
	$Date: 13/05/09 16:55 $

--->

<cfcomponent displayname="Directory" hint="Directory (MYB) Business Functions"  extends="his_Localgov_Extends.components.BusinessObjectsManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Directory" hint="Pseudo-constructor">
	
		<cfargument name="objAppObjs" type="any" required="yes" hint="The application manager object">
		<cfargument name="objBusObjs" type="any" required="yes" hint="The business object">

		<cfscript>
		// Call the genric init function, placing business, app, and dao objects into a local scope...
		StructAppend( variables, Super.initChild( arguments.objAppObjs, this, arguments.objBusObjs ) );
		// GetLookUps() = GetLookUps();
		//variables.qryAttributes = GetAttributes();
		//variables.qryPeople = GetAllPeople();
		return this;
		</cfscript>
		
	</cffunction>

		<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions ------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetVariables" access="public" output="false" returntype="struct" hint="return local scope to caller">
		<cfreturn variables/>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetOrganisations" access="public" output="false" returntype="query" hint="return all orgaistaions">
		<cfreturn objDAO.GetOrganisations()/>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetOrgTypeName" access="public" output="false" returntype="string" hint="return all orgaistaions">
		<cfargument name="orgtypeID" required="yes" type="numeric">
		<cfscript>
		var qry = objUtils.QueryOfQuery(objDAO.GetOrganisations(), 'PubType As OrgType', "OrganisationTypeID=#arguments.orgtypeID# GROUP BY PubType,OrganisationTypeID");
		return qry.OrgType;
		</cfscript>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	
	<cffunction name="GetAllPeople" access="public" output="false" returntype="query" hint="return all people">
		
		<cfset var qryTmp = QueryNew("fullname, organisation")>
		<cfif StructKeyExists(variables, "qryPeople")>
			<cfset qryTmp = variables.qryPeople>
		<cfelse>
			<cfset qryPeople = objDAO.GetAllPeople()>
			 <cfloop query="qryPeople">
				<!--- filter out dirty data, needed because db contains inconsistent values... --->
				<cfset sName = Trim( REReplace( Trim(qryPeople.fullname), "\+|\(|\)", "", "all" ) )>
				<cfif objUtils.CountWords(sName) GT 1>
					<cfset QueryAddRow(qryTmp)>
					<cfset QuerySetCell(qryTmp, "fullname", sName)>
					<cfset QuerySetCell(qryTmp, "organisation", qryPeople.organisation)>
				</cfif>
			</cfloop> 
			
			<cfset variables.qryPeople = objDAO.GetAllPeople()>
			
		</cfif>
		
		<cfreturn qryTmp/>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetLookUps" access="public" output="false" returntype="query" hint="return all orgaistaions">
		<cfargument name="LookUPID" required="no" type="string" default="1,2,3,6,8,9,10,11,12,14,15,16,17,18">
		<cfreturn objDAO.GetLookUps(arguments.LookUPID)>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetOrgDetails" access="public" output="false" returntype="struct" hint="return all  orgaistaions details">
		<cfargument name="orgID" required="no" type="numeric" default="0">
		<cfargument name="lstAttributeID" required="no" type="string" default="#variables.strConfig.strVars.lstDetailAttributeID#">
		<cfargument name="orgName" required="no" type="string" default="">
		<cfargument name="orgType" required="no" type="string" default="">
		
		<cfscript>
		var strReturn		= StructNew();
		var sqlwhere		="";
		var qryOrg 			= QueryNew("OrganisationID");  
		strReturn.blCabinet	= false;
		strReturn.blStatus	= true;
		arguments.orgname = objString.SqlSafe(ObjString.StripHTML(arguments.orgname));
		
		if (arguments.orgID gt 0){
			qryOrg 				= FilterOrganisations("*","OrganisationID=#arguments.orgID#");
			arguments.orgType   = qryOrg.OrganisationType;
		} 
		
		
		else
		// If the organisation ID is zero, i.e. unknown, and an organisation name was supplied, determine it's org id...
		if (arguments.orgID eq 0 AND Len(arguments.orgName)   ) {
			
			qryOrg = FilterOrganisations("*","upper(ORGANISATION)=upper('#arguments.orgName#') OR upper(PUBLISHEDNAME)=upper('#arguments.orgName#')");
			
			
			// if the organisation was found, use it to query DAO...
			if (qryOrg.RecordCount){
				arguments.orgID = qryOrg.OrganisationID;
				arguments.orgType =qryOrg.organisationtype;}
			// if not, try a fuzzy lookup...
			else {
				sqlwhere = 	"upper(ORGANISATION) LIKE upper('%#arguments.orgName#%')";
				if (Len(arguments.orgType))
					sqlwhere = sqlwhere & "AND upper(organisationtype)=upper('#arguments.orgType#')";
					
				qryOrg = FilterOrganisations("*",sqlwhere);
				
				arguments.orgID = qryOrg.OrganisationID;
				arguments.orgType =qryOrg.organisationtype;
			}
		}
	
		//if process as return an int (an orgainisation) has returned, run qry to get details
		if (qryOrg.recordcount eq 1 and IsNumeric(arguments.orgID) )
			strReturn = GetOrgFromDAO(arguments.orgID, arguments.orgType);
		else
		if (NOT qryOrg.recordcount)
			//set empty qry into return struct
			strReturn.blStatus	= false;
		
			
		strReturn.qryOrg=qryOrg;
			
			
		
		return strReturn;
		</cfscript>
		
		
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="FilterOrganisations" access="public" output="false" returntype="query" hint="return specific orgaistaions based on input critiria">
		<cfargument name="Select"  type="string"  required="no" default="*">
		<cfargument name="Where"   type="string"   required="no" default="0=0">
		<cfargument name="orderBy" type="string" required="no" default="">
		
		<cfscript>
		var qry = "";
		qry=objDAO.GetOrganisations();
		//call method to perform QofQ
		qry = objUtils.QueryOfQuery(qry, arguments.Select, arguments.Where, arguments.orderBy);
		return qry;
		</cfscript>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="SearchOrganisations" access="public" output="false" returntype="query" hint="search organisation based on">
		<cfargument name="OrgTypeID"  type="numeric" required="no" default="0">
		<cfargument name="Keywords"   type="string"  required="no" default="">
			<cfset arguments.keywords = objString.SqlSafe(ObjString.StripHTML(arguments.keywords))>
			<cfreturn objDAO.GetOrgSearch(arguments.OrgTypeID, arguments.Keywords)/>
			
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetAttributes" access="public" output="false" returntype="query" hint="return all attributes">
		<cfif StructKeyExists(variables, "qryAttributes")>
			<cfreturn variables.qryAttributes>
		<cfelse>
			<cfreturn objDAO.GetAttributes()/>
		</cfif>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetPerson" access="public" output="false" returntype="query" hint="return all details for a specific person">
	  <cfargument name="PersonID" required="no" type="numeric" default="0">
	  
           <cfreturn objDAO.GetPerson(arguments.PersonID).qryPerson>
			
       </cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="PersonLookUp" access="public" output="false" returntype="query" hint="return all details for a specific person based on name">
	  
	  <cfargument name="Fullname" required="no" type="string" default="">

           <cfscript>	 
              var person = Replace(objString.SqlSafe(ObjString.StripHTML(arguments.Fullname)), "~", "", "all");
			  var lstSals = ListChangeDelims(variables.strConfig.strVars.quick_link_salutations, '|');
			  //replace any saluations in list
			  person = Trim(REReplaceNoCase(person,lstSals, "","ALL"));
			  return objDAO.SearchPerson(FullName=person );
			</cfscript> 	
       </cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="ReOrderOrgDetails" access="public" returntype="boolean" output="false" hint="re order one of queries held in the structure of org details">
		<cfargument name="StrOrg"  required="yes" type="struct">
		<cfargument name="qryname" required="yes" type="string">
		<cfargument name="OrderBy" required="yes" type="string">
			
			<cfscript>
			var blreturn =1;
			var str = arguments.StrOrg;
			//work out which query to reorder
			var qry = evaluate("str.#arguments.qryname#");
			try {
			//perform qry of qry
			qry = objUtils.QueryOfQuery(qry, "*", "0=0", arguments.orderBy);
			//put qry back into struct
			StructInsert(str, arguments.qryname, qry, "yes");
			}
			catch(Any Exception){
				blreturn =0;}
			
			return blreturn;
			</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetFunctions" access="public" returntype="query" output="false" hint="return all job functions">
		<cfargument name="TypeID"     required="no" type="Numeric" default="0">
		<cfargument name="FunctionID" required="no"  type="string" default="">		 
			<cfreturn objDAO.GetFunctions(arguments.TypeID,arguments.FunctionID)/>
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetPersonFormSelects" access="public" returntype="struct" output="false" hint="return a strcuture of results sets required for person search">
		
		<cfscript>
		var strReturn 	= Structnew();
		var lstOrgType  = "Associations|Central, Regional & International Government|Coroners|Crematoria|Emergency Services - Ambulance|Emergency Services - Fire|Emergency Services - Police|Health Authoritites|High Sheriffs|Lord-Lieutenants|Parish Council Associations|Political Parties|Port Health Authorities|Probation Officers|RDAs";					
		var i = 0;					
		var qryFunctions=GetFunctions();
		//strReturn.qryOrganisations=objUtils.QueryOfQuery(GetOrganisations(), "*", "OrganisationTypeID NOT IN (2,3) AND OrganisationType IS NOT NULL AND Organisation NOT IN ('-', '...', '')") ;	
		strReturn.qryOfficerFunctions 	 = objUtils.QueryOfQuery(qryFunctions, "*", "FunctionTypeID=1");
		strReturn.qryCouncillorFunctions = objUtils.QueryOfQuery(qryFunctions, "*", "FunctionTypeID=2 ORDER BY function");		
		strReturn.qryParties			 = objUtils.QueryOfQuery(objDAO.GetOrganisations(), "*", "OrganisationTypeID=10 AND Organisation NOT IN ('-', '...')");		
		strReturn.OrgTypes				 =  lstOrgType;			
		return 	strReturn;
		</cfscript>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetOrgFormSelects" access="public" returntype="struct" output="false" hint="return a strcuture of results sets required for organisation search">
		
		<cfscript>
		var strReturn = Structnew();
		strReturn.qryOrganisations	=objUtils.QueryOfQuery(GetOrganisations(), "*", "OrganisationTypeID =5") ;	
		strReturn.qryCouncilTypes	=objUtils.QueryOfQuery( GetLookUps(), "*", "LookupID =1");
		strReturn.qryCountries	 	=objUtils.QueryOfQuery( GetLookUps(), "*", "LookupID =14");
		strReturn.qryAssoc	 		=objUtils.QueryOfQuery(GetlookUps(), "*", "LookUPID=4");	
		strReturn.qryCentral	 	=objUtils.QueryOfQuery(GetlookUps(), "*", "LookUPID=6");
		strReturn.OrgTypes			=objUtils.QueryOfQuery(GetOrganisations(), "PubType As OrgType, OrganisationTypeID", "InOrgSearch = 1 GROUP BY PubType,OrganisationTypeID");	
		return 	strReturn;
		</cfscript>
	
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetOrgSearchSelects" access="public" returntype="struct" output="false" hint="return a strcuture of results sets required for organisation search">
		<cfargument name="orgtypeid" required="yes" type="numeric">
		
		<cfscript>
		var strReturn = Structnew();	
		strReturn.qryCountries=querynew("temp");
		strReturn.qryTypes=querynew("temp");
		strReturn.qryRegions=querynew("temp");
		//get country, depending on organisation
		if (ListFind("4,8,9,11,12,13,14", arguments.orgtypeid)){
			strReturn.qryCountries	 	=objUtils.QueryOfQuery( GetLookUps(), "*", "LookupID =14");
			}
		//set region or type look ups based on orgnisation type
		switch (arguments.orgtypeid){
			//auditors
			case 1:
			strReturn.qryCountries	 	=objUtils.QueryOfQuery( GetLookUps(), "*", "LookupID =14 and datavalue <> 'Isles'" );
			break;
			//coroners
			case 4:{
			strReturn.qryTypes=objUtils.QueryOfQuery( GetLookUps(), "*", "LookupID=1");
			strReturn.qryRegions=objUtils.QueryOfQuery( GetLookUps(), "*", "LookupID=20");
			break;}
			//cremetoria
			case 6:{
			strReturn.qryTypes=objUtils.QueryOfQuery( GetLookUps(), "*", "LookupID =17");
			strReturn.qryRegions=objUtils.QueryOfQuery( GetLookUps(), "*", "LookupID=18");}
			break;
			//emergency service
			case 7:
			strReturn.qryTypes=objUtils.QueryOfQuery( GetLookUps(), "*", "LookupID=15");
			break;
			//health authority
			case 8:
			strReturn.qryTypes=objUtils.QueryOfQuery( GetLookUps(), "*", "LookupID=16 and datavalue <> 'Regional'");
			break;
			//housing associations
			case 9:
			strReturn.qryTypes=objUtils.QueryOfQuery( GetLookUps(), "*", "LookupID=13");
			break;
			//port health
			case 11:
			strReturn.qryTypes=objUtils.QueryOfQuery( GetLookUps(), "*", "LookupID=21");
			break;
			//parsish councils
			case 24:
			strReturn.qryCountries=objUtils.QueryOfQuery( GetLookUps(), "*", "LookupID =14 and datavalue NOT IN ('Isles','Northern Ireland')" );
			break;
			//lord-lieutenats
			case 25:
			strReturn.qryTypes=objUtils.QueryOfQuery( GetLookUps(), "*", "LookupID =11");
			break;
			//high sherrifs
			case 26:
			strReturn.qryTypes=objUtils.QueryOfQuery( GetLookUps(), "*", "LookupID =12");
			break;
		}
		  return strReturn;
		</cfscript>
		<!--- <cfdump var="#arguments#"><cfdump var="#strReturn#"><cfabort> --->
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetOfficersByFunction" access="public" returntype="query" output="false" hint="return all job functions">
		<cfargument name="FunctionID" required="no" type="string" default="">	
		<cfargument name="PersonName" required="no" type="string" default="">
		<cfargument name="council"    required="no" type="string" default="">
		
		<cfscript>
		
		If (Len(arguments.PersonName))
			arguments.PersonName = objString.SqlSafe(ObjString.StripHTML(arguments.PersonName));
		
		return  objDAO.GetOfficersByFunction(arguments.FunctionID, arguments.PersonName, arguments.council);	
		
			//qryReturn = variables.objUtils.queryofquery(qryReturn, "*", " Fullname  LIKE  '%A%' ");
			//qryReturn = variables.objUtils.queryofquery(qryReturn, "*", " fullName = ''");
		
		//objUtils.dumpabort(qryReturn);
			 
		 	 
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetCouncillors" access="public" returntype="query" output="false" hint="return all job functions">
		<cfargument name="FunctionID" required="no" type="string" default="">
		<cfargument name="Party"    required="no" type="string" default="">
		<cfargument name="PersonName" required="no" type="string" default="">	
		
		<cfscript>
		var PersonID="";
		var qryReturn=querynew("temp");
		var qry="";
		var strResult=StructNew();
		//check if user has searched for a name
		if (Len(arguments.PersonName)){
			arguments.PersonName = objString.SQLSafe(ObjString.StripHTML(arguments.PersonName));
			//run verity search
			strResult=objsearch.getCollectionSearch(arguments.PersonName);
			//objString.SQLSafesearch has returned any results
			if (strResult.qryResults.recordcount){
				//run QofQ to get the ID of only the peeople returned
				qry=objUtils.QueryOfQuery(strResult.qryResults, 'custom2 AS personID', 'custom1=#chr(39)#People#chr(39)#');
				PersonID=ValueList(qry.personID);
				//run sql query based on people and function id(s)
				qryReturn =objDAO.GetCouncillors(arguments.FunctionID,arguments.Party,PersonID );
			 	}
			}	
		 else
			//run sql query based on function id(s)
			 qryReturn =objDAO.GetCouncillors(arguments.FunctionID,arguments.Party);	
			 
		return qryReturn;	 
		</cfscript>
			
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="SearchCouncillors" access="public" returntype="query" output="false" hint="return all councillors based on search cirteria">
		<cfargument name="FunctionID" 	required="no" type="string" default="">
		<cfargument name="Party"    	required="no" type="string" default="">
		<cfargument name="PersonName" 	required="no" type="string" default="">	
		<cfset arguments.PersonName =objString.SqlSafe(ObjString.StripHTML(arguments.PersonName))>
		<cfreturn objDAO.GetCouncillorsByName(argumentcollection=arguments)/>
			
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="SearchCouncils" access="public" output="false" returntype="query" hint="perform search for Council based on attribute data">
			<cfargument name="OrgID"  		  required="no" type="string" default="" >
			<cfargument name="CouncilType"    required="no" type="string" default="" >	
			<cfargument name="Country"     	  required="no" type="string" default="">
			<cfargument name="Councilname"    required="no" type="string" default="">
			
			<cfset arguments.Councilname=objString.SQLSafe(ObjString.StripHTML (arguments.Councilname))>
			<cfreturn objDAO.GetCouncilSearch(argumentcollection=arguments)/>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetCouncilsAlphaSelects" access="public" output="false" returntype="struct" hint="return struct contain qry's needed for A-Z counils">
			<cfargument name="Alpha"  		  required="no" type="string" default="A" >
			<cfargument name="CouncilType"    required="no" type="string" default="" >	
			<cfargument name="Country"     	  required="no" type="string" default="">
			
			<cfscript>
			var str 						   = StructNew();
			str.StrFormSelects				   = StructNew();
			str.StrFormSelects.qryCouncilTypes = objUtils.QueryOfQuery(GetLookUps(), "*", "LookupID =1");
			str.StrFormSelects.qryCountries	   = objUtils.QueryOfQuery( GetLookUps(), "*", "LookupID =14");
			str.StrFormSelects.qryAlpha			= FilterOrganisations('DISTINCT alpha', 'organisationtypeid= 5');
			return str;
			</cfscript>
			
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="SearchPersons" access="public" output="false" returntype="query" hint="perform search for persons based on orgtype"> 
			<cfargument name="OrgType"     required="no" type="string" default="" >
			<cfargument name="PersonName"  	required="no" type="string" default="" >	
		
			<cfset arguments.PersonName = objString.SqlSafe(ObjString.StripHTML(arguments.PersonName))/>
			<cfreturn objDAO.SearchPerson(arguments.OrgType, arguments.PersonName)/>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetCouncilOfficerFunctions" access="public" returntype="query" output="false" hint="return a query containing council functions">
		
		<cfreturn objDAO.GetCouncilOfficerFunctions()>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="SearchAssoc" access="public" output="false" returntype="query" hint="perform search for associations based on section"> 
			<cfargument name="Keyword"    required="no" type="string" default="" >
			<cfargument name="sector"     required="no" type="string" default="" >
			
			<cfset arguments.Keyword = objString.SqlSafe(ObjString.StripHTML(arguments.Keyword))>
			<cfreturn objDAO.GetAssocSearh(argumentcollection=arguments)/>
				
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="SearchCentralGov" access="public" output="false" returntype="query" hint="perform search for Central gov org based on sector"> 
			<cfargument name="Keyword"    required="no" type="string" default="" >
			<cfargument name="sector"     required="no" type="string" default="" >
			<cfset arguments.Keyword = objString.SqlSafe(ObjString.StripHTML(arguments.Keyword))>
			<cfreturn objDAO.GetCentralGovSearh(argumentcollection=arguments)/>
				
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="StatSelects" access="public" output="false" returntype="struct" hint="return struct of qry needed for council stats select menus">
	  <cfscript> 
	  var str			= GetCouncilsAlphaSelects();
	  str.qryCoStats	= objDAO.GetCountryStats();
	  str.qryStats 		= objUtils.QueryOfQuery( GetLookUps(), "*", "LookupID =19");
	  return str;
	  </cfscript>
			
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="ConstituencySelects" access="public" output="false" returntype="struct" hint="return struct of qry needed for Constiuency search select menus">
	  <cfscript> 
	  var strReturn			= structNew();
	  strReturn.qryCountry	= objUtils.QueryOfQuery( GetLookUps(), "*", "LookupID =14 AND Datavalue <> 'Isles' ");
	  strReturn.qryParties	= objUtils.QueryOfQuery(objDAO.GetOrganisations(), "*", "OrganisationTypeID=10 AND Organisation NOT IN ('-', '...')");
	  return strReturn;
	  </cfscript>
			
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetStats" access="public" output="false" returntype="query" hint="return council statistics based on type">
		<cfargument name="stattype" 	type="string"  required="no" default="">
		<cfargument name="country"  	type="string"  required="no" default="">
		<cfargument name="counciltype"  type="string"  required="no" default="">
		<cfargument name="orderby"  	type="string"  required="no" default="">
		
			<cfscript>
			var SQLWhere = "0=0";
			var qryStats 	= objDAO.GetStats(arguments.stattype);
			// Store order by column in session due to new ajax pagination	
			if (Len(arguments.orderby))
				session.cStatsOrderColumn = arguments.orderby;
			//append country to where clause
			if (Len(arguments.country))
					SQLWhere = SQLWhere & " AND country=" & chr(39) & arguments.country & chr(39);
			//append council type to where clause
			if (Len(arguments.counciltype))
					SQLWhere = SQLWhere & " AND council_type=" & chr(39) & arguments.counciltype & chr(39);		
			//if where clause has been appended to then run qryofqry
			If (SQLWhere neq "0=0")
					qryStats	= objUtils.QueryOfQuery(qryStats, "* ", SQLWhere);
			//if order by cluase has been passed, run method to reorder
			if (isdefined('session.cStatsOrderColumn') and Len(session.cStatsOrderColumn) and listfindnocase(qryStats.columnlist, session.cStatsOrderColumn))
					qryStats	= OrderStats(qryStats, session.cStatsOrderColumn);
			else if (isdefined('session.cStatsOrderColumn'))
				structdelete(session, 'cStatsOrderColumn');
			return 	qryStats;
			</cfscript>
		
			
	</cffunction>
  <!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetPoliticalCompStats" access="public" output="false" returntype="query" hint="return council statistics based on type">
		<cfargument name="country"  	type="string"  required="no" default="">
		<cfargument name="counciltype"  type="string"  required="no" default="">
		<cfargument name="orderby"  	type="string"  required="no" default="">
		
			<cfscript>
			var SQLWhere = "0=0";
			var qryStats 	= objDAO.GetPoliticalCompStats(arguments.country);
			
			// Store order by column in session due to new ajax pagination
			if (Len(arguments.orderby))
				session.cStatsOrderColumn = arguments.orderby;			
			//append country to where clause
			if (Len(arguments.counciltype))
					SQLWhere = SQLWhere & " AND council_type=" & chr(39) & arguments.counciltype & chr(39);		
			//if where clause has been appended to then run qryofqry
			If (SQLWhere neq "0=0")
					qryStats	= objUtils.QueryOfQuery(qryStats, "* ", SQLWhere);
			//if order by cluase has been passed, run method to reorder
			if (isdefined('session.cStatsOrderColumn') and Len(session.cStatsOrderColumn) and listfindnocase(qryStats.columnlist, session.cStatsOrderColumn))
					qryStats	= OrderStats(qryStats, session.cStatsOrderColumn);
			else if (isdefined('session.cStatsOrderColumn'))
				structdelete(session, 'cStatsOrderColumn');
			return 	qryStats;
			</cfscript>
		
			
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="OrderStats" access="public" returntype="query" output="false" hint="ReOrder Stats qry: pass in column name, to re-oder (cannot be done in SQL as dynamic cross tab)">
		<cfargument name="qryStat" 		 required="yes" type="query">
		<cfargument name="columnName" required="yes" type="string">
			
			<cfscript>
			//create arry to hold values used in order by
			var arr= ArrayNew(1);
			var qryStats = arguments.qryStat;
			//remove '_' from columnName to find in attribute data
			var column = Replace(arguments.columnName, '_', ' ', 'all');  
			//get data type of column
			
			var datatype = objUtils.QueryOfQuery(GetAttributes(), 'datatypecode', "upper(Attribute) =  upper('#column#')").datatypecode;
		
			if (DataType eq 'TEXT' OR  arguments.columnName eq 'council')
				//reorder qry by orgimnal column
				qryStat=objUtils.QueryOfQuery(arguments.qryStat, '*', '0=0 ORDER BY #arguments.columnName#');
			else {
				//create new column casting it, and popolate with orginal's value
				//update qry tol hold new column
				QueryAddColumn(qryStats, 'PubSeq', 'INTEGER', arr);
				//reorder qry using qryofqry
				qryStat=objUtils.QueryOfQuery(arguments.qryStat, '*', '0=0 ORDER BY #arguments.columnName# DESC');
			}
			
			
					
			return qryStat;
			</cfscript>
			
	</cffunction> 
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetAttributeOrder" access="public" output="false" returntype="query" hint="return the default order by clause for an attribute column - either 'DESC' OR ASC ">
		<cfargument name="attributeName" required="yes" type="string">
	
		<cfscript>
		var str = 'ASC';
		var qry = objUtils.QueryOfQuery(variables.qryAttributes, 'datatypecode', 'Attribute = #chr(39)##arguments.attributeName##chr(39)#');
		if (ListFind("INTEGER,FLOAT", qry.datatypecode))
			str =  'DESC';
		return 	str;
		</cfscript>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
		<cffunction name="GetConstituencySearch" access="public" output="false" returntype="query" hint="return results of search in Constituency">
		<cfargument name="ConstituencyType" required="yes" type="string">	
		<cfargument name="searchtype" 	    required="yes" type="string">
		<cfargument name="keywords" 		required="no" type="string" default="">	
		<cfargument name="Country" 		    required="no" type="string" default="">	
		<cfargument name="party" 		    required="no" type="string" default="">	
		<cfargument name="class" 		    required="no" type="string" default="">	
		<cfargument name="councillink" 		required="no" type="string" default="">	
		<cfset arguments.Keyword = objString.SqlSafe(ObjString.StripHTML(arguments.Keyword))>
		<cfreturn objDAO.GetConstituencySearch(argumentcollection=arguments)/>
		

	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetGazetteer" access="public" output="false" returntype="query" hint="return results of search in Gazetteer">
		<cfargument name="town" 		required="no" type="string" default="">	
		<cfset arguments.town = objString.SqlSafe(ObjString.StripHTML(arguments.town))>
		<cfreturn objDAO.GetGazetteer(arguments.town)/>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getCabinetOptions" access="public" output="false" returntype="query" hint="return results of  councils by Cabinet Option">
		<cfreturn objDAO.getCabinetOptions()/>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getReOranisation" access="public" output="false" returntype="query" hint="return results of  local gov reOrganisation">
		<cfreturn objDAO.getReOranisation()/>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
		<cffunction name="Abbreviation2Attribute" access="public" output="false" returntype="string" hint="return name of attribute based on Abbreviation">
		<cfargument name="OrgnisationTypeID" required="yes" type="numeric">	
		<cfargument name="abbreviation" 	 required="yes" type="string">
		
		<cfscript>
		
		var qryOrgs = objUtils.QueryOfQuery(GetOrganisations(), "DISTINCT Organisation", "Abbreviation='#Ucase(arguments.abbreviation)#' AND OrganisationTypeID=#arguments.OrgnisationTypeID#" );
		//return 
		if (qryOrgs.recordcount eq 1 and Len(qryOrgs.Organisation))
			return qryOrgs.Organisation;
		else
			return arguments.abbreviation;
		</cfscript>

	</cffunction>
	
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetRelatedArticles" access="public" output="false" returntype="query" hint="return related articles for a specific organisation">
		<cfargument name="strOrg" required="yes" type="struct" hint="striuct holding all org details">
			
			<cfscript>
			var criteria = "";
			var lstNotSearch = "Coroner,Cremetoria,HighSheriffs,Lord-Lieutenants,ParishCouncilsAssociation,PortHealthAuthority,Registrar"; 
			var qryRelatedArticles = QueryNew("temp");
			
			if (NOT ListFind(lstNotSearch,arguments.strOrg.orgtype)){
				
				switch (arguments.strOrg.orgtype){
					case "council":{
						// retrieve search creiteria from council's short name
						criteria = arguments.strOrg.qryaddress.Altname;
						break;
						}
					case "CentralGovernment": case "Association":{
						// retrieve search creiteria from org name and abreviation
						criteria = arguments.strOrg.qryaddress.Organisation;
							if (Len(arguments.strOrg.qryaddress.abbreviation))
							criteria = criteria & " OR " & arguments.strOrg.qryaddress.abbreviation; 
						break;
						}
					default:{
					 criteria = arguments.strOrg.qryaddress.Organisation;
					 }	
				}
			 }
			 If (Len(criteria)){
			 	//search collection for articles
				qryRelatedArticles = objSearch.getCollectionSearch(criteria & " AND cf_custom1=News").qryResults;
				qryRelatedArticles = objUtils.queryofquery(qryRelatedArticles, "*", "0=0", "Custom3 DESC");
			 }
			 
			return	 qryRelatedArticles;
			</cfscript>
			
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetPersonRelatedArticles" access="public" output="false" returntype="query" hint="return related articles for a specific person">
		<cfargument name="fullname" required="yes" type="string" hint="name of person details">
			
			<cfscript>
			var qryR = objSearch.getCollectionSearch('#arguments.fullname# AND cf_custom1=News').qryResults;
			return objUtils.queryofquery(qryR, "*, Custom2 as Newsid", "0=0", "Custom3 DESC");  
			</cfscript>
			
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PRIAVTE Functions ----------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="HasCabinet" access="public" returntype="boolean" output="false" hint="evaluate if Organisation has any cabinet data to display">
		<cfargument name="Attributes" required="yes" type="query" hint="qry of attribute data">
		
			<cfset var blReturn = true>
			<!--- loop over recordset --->	
			<cfloop query="arguments.Attributes">
				<!---Get to position of cabinet option --->
				<cfif (attributeID eq 53) >
					<!---Check if cabinet option is null --->
					<cfif NOT Len(AttributeData)>
						<!--- if no cabint option, move to next row (cabinet members count)--->
						<cfif (attributeID[CurrentRow+1] eq 54) >
							<!---Check if cabinet has any members--->
							<cfif AttributeData[CurrentRow+1] EQ 0>
								<!---set boolean--->
								<cfset blReturn = false> 
							</cfif>
							<cfbreak>
						</cfif>			
					</cfif>
				</cfif>
			</cfloop>
		<cfreturn blReturn/> 
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetCouncilDetails" access="public" returntype="struct" output="false" hint="return call from DAO to get council">
		<cfargument name="OrgID"    		required="yes" 	type="numeric">
		
		<cfscript>
		var strCouncil		   =objDAO.GetCouncilDetails( 
				arguments.orgID, variables.strConfig.strVars.lstDetailAttributeID);
		strCouncil.blCabinet    =HasCabinet(strCouncil.qryAttributes);
		strCouncil.qryTopogrpahy = objUtils.QueryOfQuery(strCouncil.qryAttributes, "*", 'AttributeID IN (35,36)');
		strCouncil.qryFandF      = objUtils.QueryOfQuery(
				strCouncil.qryAttributes, "*", 'AttributeID NOT IN (35,36,53,52,54,125,126,127,128,129,130,131,132)');
		strCouncil.qryFinance    =  objUtils.QueryOfQuery(
				strCouncil.qryAttributes, "*", 'AttributeID IN (125,126,127,128,129,130,131,132)');
		
		return  strCouncil;
		</cfscript>
		<!--- <cfdump var="#strCouncil#"><cfabort> --->
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetParishDetails" access="public" returntype="struct" output="false" hint="return call from DAO to get parish details">
		<cfargument name="OrgID"    		required="yes" 	type="numeric">
		
		<cfset var strparish		  		 =objDAO.GetParishDetails(arguments.orgID)>
		<cfset strparish.strParishCouncils=Structnew()>
		<!---loop over parish asscoications--->
		<cfoutput query="strparish.qryParishes" group="district">
			<cfset StructInsert(strparish.strParishCouncils, district, objUtils.QueryOfQuery(
				strparish.qryParishes, "OrganisationID,Organisation ", "district='#district#' GROUP BY OrganisationID,Organisation"))>
		</cfoutput>
		
		<cfreturn strparish/>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<cffunction name="GetHome" access="public" returntype="struct" output="false" hint="return various qry's to be used on directory home page">
		<cfscript>
		var strReturn = StructNew();
		strReturn.qryCopyStat = variables.objArticle.GetFull(id=75265, type=7, resolve=0);
		strReturn.qryOrg = objDAO.GetSampleEntry(variables.strConfig.strVars.directory_org_sample_id);
		strReturn.qryCopy = variables.objArticle.GetFull(id=44357, type=7, resolve=0);
		//strReturn.qryPerson  = GetPerson(variables.strConfig.strVars.directory_person_sample_id);
		
		return strReturn;
		</cfscript>
	</cffunction>
	
	
	<cffunction name="GetCouncilControl" access="public" returntype="struct" output="false" hint="Return details on what party (if any) controls wach council across the country">
		<cfargument name="FilterParty1" required="yes" type="string">
		<cfargument name="FilterParty2" required="yes" type="string">
		<cfargument name="refresh" type="boolean" required="no" default="0" hint="Use this argument to refresh the council control data from memory">
		
		<cfscript>
			var strReturn = StructNew(); //New structure to hold data to be returned
			var whereSQL = "";
			
			SetCouncilControl(argumentCollection=arguments); //Set Council data
			
			/*
				Make a copy of structure holding full council control data as we do not want
				to modify the original data as it will be used again. If StructCopy method is
				not used, a refrence to the original structure in memory is created
			*/
			strReturn = StructCopy(variables.strCouncilControl);
			
			if(len(arguments.FilterParty1) OR len(arguments.FilterParty2))
			{
				if(len(arguments.FilterParty1))
				{
					whereSQL = whereSQL & "PartyID = #arguments.FilterParty1#";
				}
				
				if(len(arguments.FilterParty1) AND len(arguments.FilterParty2))
				{
					whereSQL = whereSQL & " OR ";
				}
				
				if(len(arguments.FilterParty2))
				{
					whereSQL = whereSQL & "PartyID = #arguments.FilterParty2#";
				}
				
				strReturn.qryGetCouncilControl = objUtils.QueryofQuery(variables.strCouncilControl.qryGetCouncilControl, "*", "#whereSQL#");
			}
			
			return strReturn;
		
		</cfscript>
		
		<!--- <cfdump var="#variables.strCouncilControl#"><cfabort> --->
		<!--- <cfreturn objDAO.GetCouncilControl(arguments.FilterParty)> --->
	</cffunction>
	
	<cffunction name="GetElectionCouncilControl" access="public" returntype="struct" output="false" hint="Return details on what party (if any) controls wach council across the country">
		<cfargument name="FilterParty1" required="yes" type="string">
		<cfargument name="FilterParty2" required="yes" type="string">
		<cfargument name="viewType" 	required="no" type="numeric" default="0">
		<cfargument name="NextElection" required="yes" type="string">
		<cfargument name="refresh" type="boolean" required="no" default="1" hint="Use this argument to refresh the council control data from memory">
		
		<cfscript>
			var strReturn = StructNew(); //New structure to hold data to be returned
			var whereSQL = "";
			
			SetElectionCouncilControl(argumentCollection=arguments); //Set Council data
			
			/*
				Make a copy of structure holding full council control data as we do not want
				to modify the original data as it will be used again. If StructCopy method is
				not used, a refrence to the original structure in memory is created
			*/
			strReturn = StructCopy(variables.strElectionCouncilControl);
			
			if(arguments.viewType gt 1)
			{
				if (arguments.viewType eq 2)
					whereSQL = whereSQL & "councilID in (#valuelist(strReturn.qryChangers.councilID, ',')#)";
					
				if (arguments.viewType eq 3)
					whereSQL = whereSQL & "councilID not in (#valuelist(strReturn.qryChangers.councilID, ',')#)";
				
				if (arguments.viewType eq 4)
					whereSQL = whereSQL & "attributeData = 'County'";
					
				if (arguments.viewType eq 5)
					whereSQL = whereSQL & "attributeData = 'Unitary'";
				
				if(len(arguments.FilterParty1) OR len(arguments.FilterParty2))
					whereSQL = whereSQL & " AND (";
			}
			
			if(len(arguments.FilterParty1) OR len(arguments.FilterParty2))
			{
				if(len(arguments.FilterParty1))
				{
					whereSQL = whereSQL & "PartyID = #arguments.FilterParty1#";
				}
				
				if(len(arguments.FilterParty1) AND len(arguments.FilterParty2))
				{
					whereSQL = whereSQL & " OR ";
				}
				
				if(len(arguments.FilterParty2))
				{
					whereSQL = whereSQL & "PartyID = #arguments.FilterParty2#";
				}
				
				if(arguments.viewType gt 1)
					whereSQL = whereSQL & ")";
			}
			
			if (whereSQL eq '')
				whereSQL = '1 = 1';
			
			strReturn.qryGetCouncilControl = objUtils.QueryofQuery(variables.strElectionCouncilControl.qryGetCouncilControl, "*", "#whereSQL#");
			
			return strReturn;
		
		</cfscript>
		
		<!--- <cfdump var="#variables.strCouncilControl#"><cfabort> --->
		<!--- <cfreturn objDAO.GetCouncilControl(arguments.FilterParty)> --->
	</cffunction>
    
    <!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
    <cffunction name="GetElectionResultsForChart" access="public" returntype="struct" output="false" hint="Return data and colorlist based ouncil election results">
    	<cfargument name="qry" required="yes" type="query" hint="pie chart dataset">
    		<cfscript>
            var str = structnew();
			str.qrybefore 		=  	objUtils.queryofquery(qry, 'PartyName, cnt', "STATUS = 'before'", 'partyname');
			str.qryafter 		=   objUtils.queryofquery(qry, 'PartyName, cnt', "STATUS = 'after'", 'partyname');
			str.lstColorBefore	=  	partyColourList(str.qrybefore );
			str.lstColorAfter	=  	partyColourList(str.qryafter);
			return str;
            </cfscript>		
    
    </cffunction>
    
    <!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
    <cffunction access="private" name="partyColourList" returntype="string" output="no"> 
		<cfargument name="qry" required="yes" type="query" hint="pie chart dataset">
    
		<cfscript>
		var i=0;
        var a =  arrayNew(1);
        
            for (i=1; i <= qry.recordcount; i=i+1){
                switch (qry.partyname[i]){
                        case "Conservative Party": 						arrayAppend(a, "5858FF"); break;
                        case "Labour Party": 							arrayAppend(a, "FF4252"); break;
                        case "Liberal Democrats": 						arrayAppend(a, "FEFE65"); break;
                        case "No Overall Control": 						arrayAppend(a, "FFFFFF"); break;
                        case "Ratepayer or Residents Association": 		arrayAppend(a, "451745"); break;
                        case "Democratic Unionist Party": 				arrayAppend(a, "A4A4A4"); break;
                        case "Sinn Féin": 								arrayAppend(a, "451745"); break;
                        case "Independent": 							arrayAppend(a, "000000"); break;
                        case "Social Democratic & Labour Party": 		arrayAppend(a, "050505"); break;
                        case "Unknown": 								arrayAppend(a, "660033"); break;
                    }
            }
            return 	ArrayToList(a);
       
        </cfscript>
    </cffunction>
    
    
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="SetElectionCouncilControl" access="public" output="false" returntype="void" hint="Get Council Control data for display on Google Maps">
		<cfargument name="FilterParty1" required="yes" type="string">
		<cfargument name="FilterParty2" required="yes" type="string">
		<cfargument name="NextElection" required="yes" type="string">
		<cfargument name="refresh" type="boolean" required="no" default="1" hint="Use this argument to refresh the council control data from memory">
		
		<cfscript>
			//If the structure holding the Council composition data is not in memory, retrieve from database
			variables.strElectionCouncilControl =  objDAO.GetElectionCouncilControl(FilterParty1="",FilterParty2="",NextElection=arguments.NextElection);	
		</cfscript>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="SetCouncilControl" access="public" output="false" returntype="void" hint="Get Council Control data for display on Google Maps">
		<cfargument name="FilterParty1" required="yes" type="string">
		<cfargument name="FilterParty2" required="yes" type="string">
		<cfargument name="refresh" type="boolean" required="no" default="0" hint="Use this argument to refresh the council control data from memory">
		
		<cfscript>
			//If the structure holding the Council composition data is not in memory, retrieve from database
			if (NOT StructKeyExists(variables, "strCouncilControl") OR arguments.refresh)	
				variables.strCouncilControl =  objDAO.GetCouncilControl(FilterParty1="",FilterParty2="");	
		</cfscript>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getCouncilCoOrdinates" access="public" returntype="query" output="true" hint="get geo coordinates from google for every address">
		<cfargument name="objGeoCode" 	required="yes" 	type="his_rd.library.components.utils.googleGeoCode">	
		<cfargument name="qryLocations" required="yes" 	type="query">
		<cfargument name="rowCount" 	required="yes"	type="numeric" default="#arguments.qryLocations.recordcount#">
		
		<cfscript>
			var strCoordinates  = StructNew();
			var arrCoordinates  = ArrayNew(1);
			var i 				= 0;
			var address 		= "";
			
			//*****LOOP OVER QUERY
			for(i=1; i lte arguments.rowCount; i=i+1) {
				//for each row that does not have any coordinates
				if (NOT Len(arguments.qryLocations.latitude[i]) OR NOT Len(arguments.qryLocations.longitude[i]))
				{
					address = "";
					//******* BUILD Address string *******//
					address = ListAppend(address, arguments.qryLocations.address1[i]);
					if ( Len(arguments.qryLocations.address2[i]) )
						address = ListAppend(address, arguments.qryLocations.address2[i]);
					if ( Len(arguments.qryLocations.address3[i]) )
						address = ListAppend(address, arguments.qryLocations.address3[i]);	
					if ( Len(arguments.qryLocations.address4[i]) )
						address = ListAppend(address, arguments.qryLocations.address4[i]);/*  */	
					if ( Len(arguments.qryLocations.town[i]) )
						address = ListAppend(address, arguments.qryLocations.town[i]);	
					if ( Len(arguments.qryLocations.region[i]) )
						address = ListAppend(address, arguments.qryLocations.region[i]);
					if ( Len(arguments.qryLocations.postcode[i]) )
						address = ListAppend(address, arguments.qryLocations.postcode[i]);	
					if ( Len(arguments.qryLocations.country[i]) )
						address = ListAppend(address, arguments.qryLocations.country[i]);						
					
				    //*******get geoCode data for this address *******
				    strCoordinates = arguments.objGeoCode.geocode(request.strSiteConfig.strVars.googlemapkey, address , request.strSiteConfig.strVars.useProxy);
				    //WriteOutput("#strCoordinates.statuscode#, #strCoordinates.statuscodeString#, #address#<br>");
				    
					if (strCoordinates.statuscode EQ 200)
					{
						// Add data returned from google int query object
						querySetCell(arguments.qryLocations, "longitude", strCoordinates.longitude, i);
						querySetCell(arguments.qryLocations, "latitude",   strCoordinates.latitude, i);
						querySetCell(arguments.qryLocations, "accuracy",   strCoordinates.accuracy, i);
						
						//put branchid into struct
						strCoordinates.AddressID = arguments.qryLocations.AddressID[i];
						//put place Coordinates struct into array
						arrayAppend(arrCoordinates, strCoordinates);
					}
					
					/*
					**	If a status code is returned indicating that the address was not recognised,
					**	retry but this time only use tha postcode and country in the lookup
					*/
					else if(strCoordinates.statuscode EQ 602)
					{
						address = "";
						//******* BUILD Address string using only the postcode and country this time *******//
						address = ListAppend(address, arguments.qryLocations.postcode[i]);	
						if ( Len(arguments.qryLocations.country[i]) )
						{
							address = ListAppend(address, arguments.qryLocations.country[i]);
						}
								
						//*******get geoCode data for this address *******
					    strCoordinates = arguments.objGeoCode.geocode(request.strSiteConfig.strVars.googlemapkey, address , request.strSiteConfig.strVars.useProxy);
					    //WriteOutput("#strCoordinates.statuscode#, #strCoordinates.statuscodeString#, #address#<br>");
						
						if (strCoordinates.statuscode EQ 200)
						{
							// Add data returned from google int query object
							querySetCell(arguments.qryLocations, "longitude", strCoordinates.longitude, i);
							querySetCell(arguments.qryLocations, "latitude",  strCoordinates.latitude, i);
							querySetCell(arguments.qryLocations, "accuracy",  strCoordinates.accuracy, i);
							
							//put branchid into struct
							strCoordinates.AddressID = arguments.qryLocations.AddressID[i];
							//put place Coordinates struct into array
							arrayAppend(arrCoordinates, strCoordinates);
						}	
						
						//If using just the postcode still doesn't result in valid results, just store 0
						else
						{
							// Add data returned from google int query object
							querySetCell(arguments.qryLocations, "longitude", 0, i);
							querySetCell(arguments.qryLocations, "latitude",  0, i);
							querySetCell(arguments.qryLocations, "accuracy",  0, i);
							
							/*	Create default values for Longitude, Latitude and accuracy in Coordinates structure since
							**	they will not have been returned by google service
							*/
							strCoordinates.longitude 	= 0;
							strCoordinates.latitude 	= 0;
							strCoordinates.accuracy 	= 0;
													
							//put branchid into struct
							strCoordinates.AddressID = arguments.qryLocations.AddressID[i];
							//put place Coordinates struct into array
							arrayAppend(arrCoordinates, strCoordinates);
						}
					}
					//If using just the postcode still doesn't result in valid results, just store 0
					else
					{
						// Add data returned from google int query object
						querySetCell(arguments.qryLocations, "longitude", 0, i);
						querySetCell(arguments.qryLocations, "latitude",  0, i);
						querySetCell(arguments.qryLocations, "accuracy",  0, i);
						
						/*	Create default values for Longitude, Latitude and accuracy in Coordinates structure since
						**	they will not have been returned by google service
						*/
						strCoordinates.longitude 	= 0;
						strCoordinates.latitude 	= 0;
						strCoordinates.accuracy 	= 0;
						
						//put branchid into struct
						strCoordinates.AddressID = arguments.qryLocations.AddressID[i];
						//put place Coordinates struct into array
						arrayAppend(arrCoordinates, strCoordinates);
					}
				}
				
			} 
			//******* SAVE GEO DATA FOR BRANCHES ******
			If (ArrayLen(arrCoordinates))
				SaveCoOrdinates(arrCoordinates);
				
			return qryLocations;
		</cfscript>
		
		<!--- <cfdump var="#strCoordinates#">
		<cfabort> --->
		<cfdump var="#arrCoordinates#"><!--- <cfabort> --->
		
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="SaveCoOrdinates" access="public" returntype="void" output="false" hint="save all geo locations for a range of branches">
		<cfargument name="arrCoordinates" 	required="yes"  type="array">
		
		<cfscript>
			var i 				= 0;
			var sql				="";
			//loop over array
			for(i=1; i lte ArrayLen(arguments.arrCoordinates); i=i+1) {
				sql = sql & " BEGIN UPDATE dbo.Address SET Longitude = #arguments.arrCoordinates[i].longitude#, Latitude = #arguments.arrCoordinates[i].latitude#, accuracy =#arguments.arrCoordinates[i].accuracy# WHERE AddressID = #arguments.arrCoordinates[i].AddressID# END ";
			}	
		</cfscript>
		   
		<!--- <cfset qrySaveCoordinates = > --->
		<cfreturn objDAO.SaveCoOrdinates(sql)>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PRIVATE --------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetOrgFromDAO" access="private" returntype="struct" output="false" hint="evlauate orgtype and get orgnisdation accordingly" >
		<cfargument name="orgID"   required="yes" type="numeric">
		<cfargument name="orgType" required="yes" type="string">
			
			<cfscript>
			var strReturn = StructNew();
			
			switch (arguments.orgType){
				case "council":{
					// retrieve coucil details based on id...
					strReturn= GetCouncilDetails(arguments.orgID);
					break;
					}
				case "Association":
					// retrieve association details based on id...
					strReturn= objDAO.GetAssocDetails(arguments.orgID, arguments.orgType);
					break;
				case "CentralGovernment": case "central": case "CentralGovernmentSub":
					// retrieve central details based on id...
					strReturn= objDAO.GetCentralGovDetails(arguments.orgID);
					break;	
				case "Parish Councils": case "ParishCouncilsAssociation":
					// retrieve central details based on id...
					strReturn= GetParishDetails(arguments.orgID);
					break;
				case "FireService": case "PoliceService": case "AmbulanceService":
					// retrieve central details based on id...
					strReturn= objDAO.GetEmergencyDetails(arguments.orgID);
					break;	
				case "auditor": 
					// retrieve central details based on id...
					strReturn= objDAO.GetAuditorDetails(arguments.orgID);
					break;			
				case "HousingAssociation": 	
					// retrieve central details based on id...
					strReturn= objDAO.GetHousingDetails(arguments.orgID);
					break;
					// retrieve port health authority details based on id...
				case "PortHealthAuthority":
					// retrieve central details based on id...
					strReturn= objDAO.GetPortDetails(arguments.orgID);
					break;
				default: 
					// retrieve org details based on id...
					strReturn= objDAO.GetOrgDetails(arguments.orgID, arguments.orgType);
					break;
				}
				 strReturn.orgType = arguments.orgType;
				 return strReturn;
			</cfscript>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetAllCPAs" access="public" output="false" returntype="query" hint="">
		<cfargument name="refresh" type="boolean" required="no" default="0" hint="Use this argument to refresh the query">
		
		<cfscript>
			//If the structure holding the data is not in memory, retrieve from database
			if (NOT StructKeyExists(variables, "qryCPAresults") OR arguments.refresh)	
				variables.qryCPAresults =  objDAO.GetAllCPAs();
		</cfscript>
		
		<cfreturn variables.qryCPAresults/>
	</cffunction>
	
	
</cfcomponent>