<cfcomponent hint="function for account reports" displayname="reports" extends="his_Localgov_Extends.components.BusinessObjectsManager">

	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------>
	<!--- CONSTRUCTOR ------------------------------------------------------------------------------------------------------------------------------------------------------>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------>
	<cffunction name="init" access="public" output="false" returntype="reports" hint="Pseudo-constructor">	
		<cfargument name="objAppObjs" type="any" required="yes" hint="The application objects">
		<cfargument name="objBusObjs" type="any" required="yes" hint="The business objects">
		
		<cfscript>
		// Call the genric init function, placing business, app, and dao objects into a local scope...
		StructAppend( variables, Super.initChild( arguments.objAppObjs, this ) );
		//variables.strAdSelects = GetAdSelects();
		
		return this;
		</cfscript>
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="getInstance" access="public" returntype="struct">
		<cfreturn instance>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="shippingAddress" access="public" output="false" returntype="query" hint="get shiiping address for book order">
		<cfargument name="objUser"  	type="any" required="yes">
		<cfargument name="DateStart"    type="string" required="yes">
		<cfargument name="DateEnd"      type="string" required="yes">
	 
	
		<cfscript>
		var qryReport  = objDAO.shippingAddress(arguments.DateStart, arguments.DateEnd);
		var i 		   = 0;
		var StrAddress = StructNew();	
		var strReg	   = arguments.objUser.GetRegistrationSelects();
		</cfscript>
		
		 <!--- <cfdump var="#strReg#">
		 <cfdump var="#qryReport#">
		 <cfabort>  --->
		
		<cfscript>
		for (i =1; i lte qryReport.recordcount; i=i+1){
		//set address into qry based on data held in wddx packet
			if (IsWddx(qryReport.shippingAddressxml[i]) ){
			//set packet into structure
					strAddress= request.objApp.objUtils.createWDDXPacket('wddx2cfml', qryReport.shippingAddressxml[i]);
					//set qry cells with strcuture data
					
					//QuerySetCell(qryReport, "address1", strAddress.Address1, i);	
					QuerySetCell(qryReport, "address1", strAddress.Address1, i);	
					QuerySetCell(qryReport, "address2", strAddress.Address2, i);
					If ( StructKeyExists(strAddress, "Address3") ){
						if (Len(strAddress.Address3))
						QuerySetCell(qryReport, "address2", strAddress.Address2 & ", "& strAddress.Address3 , i);
					}
					
					QuerySetCell(qryReport, "town", strAddress.town, i);
					if (structkeyexists(strAddress, 'county'))
						QuerySetCell(qryReport, "county",  objUtils.queryofquery(strReg.qryCounties, "*", "county='#strAddress.county#'").county, i);
					else if (structkeyexists(strAddress, 'countyid') and isnumeric(strAddress.countyid))
						QuerySetCell(qryReport, "county",  objUtils.queryofquery(strReg.qryCounties, "*", "countyid=#strAddress.countyid#").county, i);
					QuerySetCell(qryReport, "postcode", strAddress.postcode, i);
					if (structkeyexists(strAddress, 'countryid') and isnumeric(strAddress.countryid))
						QuerySetCell(qryReport, "country",  objUtils.queryofquery(strReg.qryCountries, "*", "p_country_id=#strAddress.countryid#").country, i);
					else
						QuerySetCell(qryReport, "country",  objUtils.queryofquery(strReg.qryCountries, "*", "country='#strAddress.country#'").country, i);
					
				}
				
		}
		
		qryReport =  objUtils.queryofquery(qryReport, "DISTINCT InvoiceID,InvoiceDate,InvoiceNo,title,Forename,Surname,address1,address2,address3,town,county,postcode,country,tel,Organisation,CampaignCode,quantity", "0=0 ");
		return qryReport;
		</cfscript>
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="InvoiceByDate" access="public" output="false" returntype="query" hint="">
		<cfargument name="DateStart"  type="string" required="yes">
		<cfargument name="DateEnd"    type="string" required="yes">
	
		<cfreturn objDAO.InvoiceByDate(arguments.DateStart, arguments.DateEnd)>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="InvoiceFigures" access="public" output="false" returntype="query" hint="">
		<cfargument name="DateStart"  type="string" required="yes">
		<cfargument name="DateEnd"    type="string" required="yes">
	
		<cfreturn objDAO.InvoiceFigures(arguments.DateStart, arguments.DateEnd)>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="Deferral" access="public" output="false" returntype="query" hint="">
		<cfargument name="DateStart"  type="string" required="yes">
		
		<cfreturn objDAO.Deferral(arguments.DateStart)>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
</cfcomponent>