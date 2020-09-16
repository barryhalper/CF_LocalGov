<!--- 
	
	$Archive: /localgov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/DataAccessObjects/DataSalesDAO.cfc $
	$Author: Bhalper $
	$Revision: 6 $
	$Date: 27/05/10 16:39 $

--->

<cfcomponent displayname="DataSalesDAO" hint="<component description here>" extends="his_Localgov_Extends.components.DAOManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="DataSalesDAO" hint="Pseudo-constructor">
		
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		structAppend( variables, Super.init( arguments.strConfig ) );

		return this;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions: *GET* ----------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getSetListTypes" access="public" output="false" returntype="query" hint="return a query containing the set lists">
		
		<cfset var qrySetListTypes = ""> 
		
		<cfquery name="qrySetListTypes" datasource="#variables.DSN1#" cachedwithin="#variables.CACHE_TIME#">
		EXEC sp_GetSetListTypes
		</cfquery>
		
		<cfreturn qrySetListTypes>
		
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getSetList" access="public" output="false" returntype="query" hint="return a query containing the set lists">

		<cfargument name="listTypeIDs" 	type="string" required="true">
		<cfargument name="noOfRows" 	type="numeric" required="false" default="-1">
		
		<cfset var qrySetList = ""> 

		<cfquery name="qrySetList" datasource="#variables.DSN2#" maxrows="#arguments.noOfRows#" cachedwithin="#variables.CACHE_TIME#" >
		EXEC coldfusion.sp_GetPeopleForList
			@OrganisationTypeIDs= 	'#arguments.listTypeIDs#'
		</cfquery>
		
		<cfreturn qrySetList>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getSetListByOrganisation" access="public" output="false" returntype="query" hint="return a query containing the actual set list data">
		<cfargument name="organisationTypeID" 	type="numeric" required="true">
		
		<cfset var qrySetList= ""> 

		<cfquery name="qrySetList" datasource="#variables.DSN2#" >
		EXEC sp_DS_GetSetListByOrganisation
			@OrganisationTypeID= 	#arguments.organisationTypeID#
		</cfquery>
		
		<cfreturn qrySetList>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getSetListData" access="public" output="false" returntype="query" hint="return a query containing the actual set list data">
		<cfargument name="listTypeId" 	type="numeric" required="true">
		
		<cfset var qrySetList= ""> 

		<cfquery name="qrySetList" datasource="#variables.DSN2#" >
		EXEC sp_DS_GetSetListData #arguments.listTypeId#
		</cfquery>EXEC sp_DS_GetSetListData
		
		<cfreturn qrySetList>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getSetListByFunctionID" access="public" output="false" returntype="query" 
				hint="return a query containing the set lists by officer function id">
		
		<cfargument name="functionIDs" 	type="string" required="true">
		<cfargument name="noOfRows" 	type="numeric" required="false" default="-1">
		
		<cfset var qrySetListByFunctionID = ""> 
		
		<cfquery name="qrySetListByFunctionID" datasource="#variables.DSN2#" cachedwithin="#variables.CACHE_TIME#" >
		EXEC sp_DS_GetOfficersByFunction 
			@FunctionID = '#arguments.functionIDs#'
		</cfquery>

		<cfreturn qrySetListByFunctionID>
		
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getSetListByFunction" access="public" output="false" returntype="query" 
				hint="return a query containing the set lists by officer function">
		
		<cfargument name="jobfunction" 	type="string" required="true">
		<cfargument name="noOfRows" 	type="numeric" required="false" default="-1">
		
		<cfset var qrySetListByFunction = ""> 
		
		<cfquery name="qrySetListByFunction" datasource="#variables.DSN2#" cachedwithin="#variables.CACHE_TIME#" >
		EXEC sp_DS_GetCouncillors 
			@Function = '#arguments.jobfunction#'
		</cfquery>

		<cfreturn qrySetListByFunction>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getCouncils" access="public" output="false" returntype="query" 
				hint="return a query containing the set lists of coucils">
		
		<cfargument name="noOfRows" 	type="numeric" required="false" default="-1">
		
		<cfset var qryCouncils = ""> 
		
		<cfquery name="qryCouncils" datasource="#variables.DSN2#" cachedwithin="#variables.CACHE_TIME#" >
		EXEC sp_DS_GetCouncils 
		</cfquery>

		<cfreturn qryCouncils>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getSetListByCommittee" access="public" output="false" returntype="query" 
				hint="return a query containing the set lists by committee">
		
		<cfargument name="committee" 	type="string" required="true">
		<cfargument name="noOfRows" 	type="numeric" required="false" default="-1">
		
		<cfset var qrySetListByCommittee = ""> 
		
		<cfquery name="qrySetListByCommittee" datasource="#variables.DSN2#" cachedwithin="#variables.CACHE_TIME#" >
		EXEC sp_DS_GetCommittees 
			@Committee = '#arguments.committee#'
		</cfquery>

		<cfreturn qrySetListByCommittee>
		
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getOrganisations" access="public" output="false" returntype="query" 
				hint="">
		
		<cfargument name="listTypeIDs" 	type="string" required="true">
		<cfargument name="noOfRows" 	type="numeric" required="false" default="-1">
		
		<cfset var qrySetListByOrg = ""> 
		
		<cfquery name="qrySetListByOrg" datasource="#variables.DSN2#" cachedwithin="#variables.CACHE_TIME#" >
		EXEC sp_DS_GetOrganisations 
			@OrganisationTypeIDs = '#arguments.listTypeIDs#'
		</cfquery>

		<cfreturn qrySetListByOrg>
		
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getOrders" access="public" output="false" returntype="query" 
				hint="">
		
		<cfargument name="orderID" 				type="string" 	required="true">
		
		<cfset var qryOrders = ""> 
		
		<cfquery name="qryOrders" datasource="#variables.DSN1#" cachedwithin="#variables.CACHE_TIME#" >
		EXEC sp_DS_GetOrders 
			@orderID= '#arguments.orderID#'
		</cfquery>

		<cfreturn qryOrders>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="getOrgTypeIDfromListTypeID" access="public" output="false" returntype="numeric" 
				hint="return a the organisation type id from a specified list type id">
		
		<cfargument name="listTypeID"	type="numeric" required="true">
		
		<cfset var qryOrgTypeIDfromListTypeID = ""> 
		
		<cfquery name="qryOrgTypeIDfromListTypeID" datasource="#variables.DSN1#" cachedwithin="#variables.CACHE_TIME#" >
		EXEC sp_DS_getOrgTypeIDfromListTypeID
			@listTypeID= #arguments.listTypeID#
		</cfquery>

		<cfreturn qryOrgTypeIDfromListTypeID.f_organisationtype_id >	
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="getListTypeIDFromOrgTypeID" access="public" output="false" returntype="numeric" 
				hint="return a the list type id from a specified organisation type id">
		
		<cfargument name="OrgTypeID"	type="numeric" required="true">
		
		<cfset var qryListTypeIDfromOrgTypeID = ""> 
		
		<cfquery name="qryListTypeIDfromOrgTypeID" datasource="#variables.DSN1#" cachedwithin="#variables.CACHE_TIME#" >
		EXEC sp_DS_getListTypeIDfromOrgTypeID
			@OrgTypeID= #arguments.OrgTypeID#
		</cfquery>

		<cfreturn qryListTypeIDfromOrgTypeID.p_setlist_id>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getSetLists" access="public" output="false" returntype="query" hint="return a query containing the set lists">
		
		<cfargument name="ListTypeId" type="numeric" required="false" default="0">
		
		<cfset var qrySetLists = ""> 
		
		<cfquery name="qrySetLists" datasource="#variables.DSN1#" cachedwithin="#variables.CACHE_TIME#" >
		EXEC sp_DS_GetSetLists
			@ListTypeID = #arguments.ListTypeId#
		</cfquery>

		<cfreturn qrySetLists>
		
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getUnitCost" access="public" output="false" returntype="numeric" hint="return a query containing the set lists">
		
		<cfargument name="ListTypeID" type="numeric" required="true">
		
		<cfset var qryUnitCost = ""> 
		
		<cfquery name="qryUnitCost" datasource="#variables.DSN1#" cachedwithin="#variables.CACHE_TIME#">
		EXEC sp_DS_GetUnitCost
			@ListTypeID = #Arguments.ListTypeID#
		</cfquery>
		
		<cfreturn qryUnitCost.Cost>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getSeedInstances" access="public" output="true" returntype="query" 
				hint="">
		<cfset var qrySeedInstances = ""> 
		
		<cfquery name="qrySeedInstances" datasource="#variables.DSN1#">
		EXEC sp_DS_GetSeedInstances
		</cfquery>
		
		<cfreturn qrySeedInstances>
					
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getBaseSeeds" access="public" output="true" returntype="query" 
				hint="">
		<cfargument name="noOfSeeds" 	required="yes"	type="numeric" >
		<cfargument name="listTypeId" 	required="no"	type="numeric" default="0" >
		
		<cfset var getBaseSeeds = "">
		
		<cfquery name="getBaseSeeds" datasource="#variables.DSN1#" maxrows="#arguments.noOfSeeds#">
		EXEC sp_DS_GetBaseSeeds @ListTypeId = <cfif arguments.listTypeId>#arguments.listTypeId#<cfelse>NULL</cfif>
		</cfquery>
		
		<cfreturn getBaseSeeds>
					
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getOrder" access="public" output="false" returntype="query" 
				hint="">
		
		<cfargument name="orderID" 	type="string" 	required="true">
		
		<cfset var qryOrder = ""> 
		
		<cfquery name="qryOrder" datasource="#variables.DSN5#">
		EXEC usp_GetOrderByID
			@OrderID = #Arguments.orderID#
		</cfquery>
		
		<cfreturn qryOrder>
		
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getSeedDetail" access="public" returntype="query" output="false">
		<cfargument name="seedid" 	type="numeric" 	required="true">
		
		<cfset var qrySeed = ""> 
		
		<cfquery name="qrySeed" datasource="#variables.DSN1#">
		sp_DS_GetBaseSeed_ById
			@SeedId = #Arguments.seedid#
		</cfquery>
		
		<cfreturn qrySeed>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="commitOrder" output="false" returntype="numeric" 
		hint="Commits order">
		
		<cfargument name="userID" 			type="numeric" required="yes">
		<cfargument name="paymentMethod"	type="numeric" required="yes">
		<cfargument name="dataPurchaserXML"	type="string" required="yes">
		<cfargument name="abOrderPrice"		type="numeric" required="yes">
		
		
		<cfset var OrderID= 0>
		
		<cfstoredproc datasource="#variables.DSN5#" procedure="usp_SaveListOrder" returncode="yes">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@UserId" 			value="#arguments.userID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@PaymentMethod"	 	value="#arguments.paymentMethod#">
			<cfprocparam type="in"  cfsqltype="CF_SQL_VARCHAR" 	dbvarname="@dataPurchaserXML"	value="#arguments.dataPurchaserXML#">
			<cfprocparam type="in" cfsqltype="cf_sql_float" dbvarname="@abOrderPrice" value="#arguments.abOrderPrice#">
			<cfprocparam type="out" cfsqltype="cf_sql_integer" 	dbvarname="@OrderID" 			variable="OrderID"> 
		</cfstoredproc>
		
		<cfscript>
		if (cfstoredproc.statusCode NEQ 0)
			OrderID = 0;
		</cfscript>

		<cfreturn OrderID>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="commitFilename" output="false" returntype="void" 
		hint="Commits order">
		<cfargument name="arr" type="array" required="yes" hint="array containg struct of filenames and orlineid"> 
		
		<cfset var i = 0> 
		
		<cfquery datasource="#variables.DSN5#">
			<cfloop from="1" to="#ArrayLen(arguments.arr)#" index="i">	
				exec usp_SaveListFilename 
				@OrderLineID 		= #arguments.arr[i].orderLineID#, 
				@dataSalesListName = '#arguments.arr[i].filename#'
			</cfloop>
		</cfquery>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="commitSeedOrder" output="false" returntype="void" 
		hint="Commits base seed to the order">
		
		<cfargument name="seedId" 		type="numeric" required="yes">
		<cfargument name="orderLineId"	type="numeric" required="yes">
		<cfargument name="seedxml"		type="string" 	required="yes">
		
		<cfquery name="qrySeedOrder" datasource="#variables.DSN5#">
		EXEC usp_SaveSeedOrder
			@SeedID			= #arguments.seedId#,
			@OrderLineID		= #arguments.orderLineId#
		</cfquery>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="commitSetList" output="false" returntype="void" 
		hint="Commits order">
		
		<cfargument name="p_setlist_id" type="numeric" required="yes">
		<cfargument name="name"			type="string" required="yes">
		<cfargument name="description"	type="string" required="yes">
		<cfargument name="cost"			type="numeric" required="yes">
		
		<cfquery name="qrySetList" datasource="#variables.DSN1#">
		EXEC sp_DS_CommitSetList
			@p_setlist_id= 	#arguments.p_setlist_id#,
			@name= 			'#arguments.name#',
			@description= 	'#arguments.description#',
			@cost= 			#arguments.cost#
		</cfquery>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="updateOrderLineStatus" output="false" returntype="void" 
			hint="Update order line status">
		
		<cfargument name="orderID"	type="numeric" required="yes">
		<cfargument name="statusID"	type="numeric"  required="yes">
		
		<cfstoredproc datasource="#variables.DSN5#" procedure="usp_ChangeOrderStatus" returncode="yes">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@OrderId" 	value="#arguments.orderID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@StatusID" 	value="#arguments.statusID#">
		</cfstoredproc>		
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="commitOrderLine" output="false" returntype="numeric" 
		hint="Commits order">
		
		<cfargument name="OrderID" 				type="numeric" 	required="yes">
		<cfargument name="ProductID" 			type="numeric" 	required="yes">
		<cfargument name="ComponentQuantity" 	type="numeric" 	required="yes">
		<cfargument name="dataSalesXML"			type="string"  	required="yes">
		<cfargument name="ComponentID"			type="numeric"  required="yes">			
		<cfargument name="ListPrice"			type="string"  	required="yes"> 			
		<cfargument name="ProductPercentage"	type="string"  	required="yes"> 	
		<cfargument name="TermPrice"			type="string"  	required="yes">			
		<cfargument name="VATRate"				type="string"  	required="yes"> 
		<cfargument name="DiscountedPrice"		type="string"  	required="yes"> 
		<cfargument name="AbsolutePrice"		type="string"  	required="yes"> 
		<cfargument name="VATAmount"			type="string"  	required="yes"> 
		<cfargument name="isInvoiceable"		type="numeric"  required="yes">
		
		<cfset var orderLineID= 0>
		
		<cfstoredproc datasource="#variables.DSN5#" procedure="usp_SaveOrderLine" returncode="yes">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@OrderId" 			value="#arguments.orderID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@ProductID" 			value="#arguments.productID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@Quantity" 			value="#arguments.ComponentQuantity#">
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@DataSalesXML" 		value="#arguments.dataSalesXML#">
			<cfprocparam type="in" 	cfsqltype="cf_sql_integer" 	dbvarname="@ComponentID" 		value="#arguments.ComponentID#">			
			<cfprocparam type="in" 	cfsqltype="cf_sql_money" 	dbvarname="@ListPrice" 			value="#arguments.ListPrice#"> 			
			<cfprocparam type="in" 	cfsqltype="cf_sql_float" 	dbvarname="@ProductPercentage" 	value="#arguments.ProductPercentage#"> 	
			<cfprocparam type="in" 	cfsqltype="cf_sql_money" 	dbvarname="@TermPrice" 			value="#arguments.TermPrice#">			
			<cfprocparam type="in" 	cfsqltype="cf_sql_float" 	dbvarname="@VATRate" 			value="#arguments.VATRate#"> 
			<cfprocparam type="in" 	cfsqltype="cf_sql_money" 	dbvarname="@DiscountedPrice" 	value="#arguments.DiscountedPrice#"> 
			<cfprocparam type="in" 	cfsqltype="cf_sql_money" 	dbvarname="@AbsolutePrice" 		value="#arguments.AbsolutePrice#"> 
			<cfprocparam type="in" 	cfsqltype="cf_sql_money" 	dbvarname="@VATAmount" 			value="#arguments.VATAmount#"> 
			<cfprocparam type="in" 	cfsqltype="cf_sql_bit" 		dbvarname="@isInvoiceable" 		value="#arguments.isInvoiceable#"> 
			
			<cfprocparam type="out" cfsqltype="cf_sql_integer" 	dbvarname="@OrderLineID" 		variable="OrderLineID"> 
		</cfstoredproc>
		
		<cfscript>
		if (cfstoredproc.statusCode NEQ 0)
			orderLineID = 0;
		</cfscript>

		<cfreturn orderLineID>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="commitBaseSeed" access="public" returntype="numeric" output="false">
	
		<cfargument name=	"id" 			required="no" type="string" default="0">
		<cfargument name=	"title"  		required="yes" type="string">
		<cfargument name=	"forename"  	required="yes" type="string">
		<cfargument name=	"surname"  		required="yes" type="string">
		<cfargument name=	"address1"  	required="yes" type="string">
		<cfargument name=	"address2"  	required="yes" type="string">
		<cfargument name=	"address3"  	required="yes" type="string">
		<cfargument name=	"address4"  	required="yes" type="string">
		<cfargument name=	"town"  		required="yes" type="string">
		<cfargument name=	"country"  		required="yes" type="string">
		<cfargument name=	"postcode"  	required="yes" type="string">
		<cfargument name=	"tel"  			required="yes" type="string">
		<cfargument name=	"fax"  			required="yes" type="string">
		<cfargument name=	"email"  		required="yes" type="string">
		<cfargument name=	"setlist"  		required="yes" type="string">
		<cfargument name=	"organisation"  required="yes" type="string">
		
		<cfset var newid = 0>
		
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_DS_CommitBaseSeed">
			<cfprocparam dbvarname="@id" 			cfsqltype="cf_sql_integer" 	type="in" value="#arguments.id#">
			<cfprocparam dbvarname="@title" 		cfsqltype="CF_SQL_VARCHAR" 	type="in" value="#arguments.title#">
			<cfprocparam dbvarname="@forename" 		cfsqltype="CF_SQL_VARCHAR" 	type="in" value="#arguments.forename#">
			<cfprocparam dbvarname="@surname" 		cfsqltype="CF_SQL_VARCHAR" 	type="in" value="#arguments.surname#">
			<cfprocparam dbvarname="@organisation" 	cfsqltype="CF_SQL_VARCHAR" 	type="in" value="#arguments.organisation#">
			<cfprocparam dbvarname="@address1" 		cfsqltype="CF_SQL_VARCHAR" 	type="in" value="#arguments.address1#">
			<cfprocparam dbvarname="@address2" 		cfsqltype="CF_SQL_VARCHAR" 	type="in" value="#arguments.address2#">
			<cfprocparam dbvarname="@address3" 		cfsqltype="CF_SQL_VARCHAR" 	type="in" value="#arguments.address3#">
			<cfprocparam dbvarname="@address4" 		cfsqltype="CF_SQL_VARCHAR" 	type="in" value="#arguments.address4#">
			<cfprocparam dbvarname="@town" 			cfsqltype="CF_SQL_VARCHAR" 	type="in" value="#arguments.town#">
			<cfprocparam dbvarname="@country" 		cfsqltype="CF_SQL_VARCHAR" 	type="in" value="#arguments.country#">
			<cfprocparam dbvarname="@postcode" 		cfsqltype="CF_SQL_VARCHAR" 	type="in" value="#arguments.postcode#">
			<cfprocparam dbvarname="@tel" 			cfsqltype="CF_SQL_VARCHAR" 	type="in" value="#arguments.tel#">
			<cfprocparam dbvarname="@fax" 			cfsqltype="CF_SQL_VARCHAR" 	type="in" value="#arguments.fax#">
			<cfprocparam dbvarname="@email" 		cfsqltype="CF_SQL_VARCHAR" 	type="in" value="#arguments.email#">
			<cfprocparam dbvarname="@setlist" 		cfsqltype="CF_SQL_VARCHAR" 	type="in" value="#arguments.setlist#">
			<cfprocparam dbvarname="@newid" 		cfsqltype="CF_SQL_VARCHAR" 	type="out" variable="newid">
		</cfstoredproc>

		<cfreturn newid>	
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="deleteBaseSeed" access="public" returntype="void" output="false">
	
		<cfargument name="id" required="yes" type="numeric">
		
		<cfset var qryRecordSet = ""> 
		
		<cfquery name="qryRecordSet" datasource="#variables.DSN1#">
		EXEC sp_DS_DeleteBaseSeed
			@id = #arguments.id#
		</cfquery>
				
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="deleteSetList" access="public" returntype="void" output="false"
		hint="delete setlist">
	
		<cfargument name="p_setlist_id" required="yes" type="numeric">
		
		<cfset var qryRecordSet = ""> 
		
		<cfquery name="qryRecordSet" datasource="#variables.DSN1#">
		EXEC sp_DS_DeleteSetList
			@p_setlist_id = #arguments.p_setlist_id#
		</cfquery>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="addToBasket" access="public" output="false" returntype="void" hint="Updates the user's basket with desired list">
		
		<cfargument name="Attr" type="struct" required="true">
		
		<cfset var qryAddToBasket = ""> 
		
		<cfquery name="qryAddToBasket" datasource="#variables.DSN1#" cachedwithin="#variables.CACHE_TIME#">
		EXEC sp_AddToBasket
			@UserID= 		#Arguments.Attr.UserID#,
			@ListTypeID= 	#Arguments.Attr.ListTypeID#,
			@ContactType=	#Arguments.Attr.ContactType#,
			@CommMethod= 	#Arguments.Attr.CommMethod#,
			@NoOfUses= 		#Arguments.Attr.NoOfUses#,
			@SavedDate=		#CreateODBCDateTime(now())#
		</cfquery>
		
		<cfreturn qryAddToBasket>
				
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="SetListBasePrice" access="public" output="false" returntype="void" 
			hint="update list cost in db & return the based cost equation">
		<cfargument name="costPerRecord" type="numeric" required="yes">
			
		<cfquery datasource="#variables.DSN2#">
			sp_DS_CalculateSetListBasePrice #Arguments.costPerRecord#
		</cfquery>
		
	</cffunction>
	
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getDirectTemplates" access="public" output="false" returntype="query" hint="">
		<cfargument name="userid" type="numeric" required="yes">
		<cfargument name="templateid" type="numeric" required="no" default="0">
			
		<cfset var qryTemplates = querynew('temp')>
			
		<cfquery name="qryTemplates" datasource="#variables.dsn5#">
			usp_getDSDTemplates #arguments.userid#, #arguments.templateid#
		</cfquery>
		
		<cfreturn qryTemplates>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="saveDirectTemplate" access="public" output="false" returntype="void" hint="">		
		<cfargument name="userid" type="numeric" required="yes">
		<cfargument name="templateid" type="numeric" required="no" default="0">
		<cfargument name="tempName" type="string" required="yes">
		<cfargument name="tempCont" type="string" required="yes">
		
		<cfquery datasource="#variables.dsn5#">
			EXEC usp_saveDSDTemplate
				@tempid = #arguments.templateid#,
				@userid = #arguments.userid#,
				@tempName = '#arguments.tempName#',
				@tempCont = '#arguments.tempCont#'
		</cfquery>
	
	</cffunction>
</cfcomponent>