<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/DataAccessObjects/InvoiceDAO.cfc $
	$Author: Ohilton $
	$Revision: 4 $
	$Date: 8/04/09 11:40 $

--->

<cfcomponent displayname="InvoiceDAO" hint="" extends="his_Localgov_Extends.components.DAOManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="InvoiceDAO" hint="Pseudo-constructor">
		
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		StructAppend( variables, Super.init( arguments.strConfig ) );

		return this;
		</cfscript>
				
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions: ----------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="invoiceCreated" access="public" output="false" returntype="numeric" >
		<cfargument name="invoiceID" type="numeric"	required="yes">
		
		<cfset var qry = "">
		
		<cfquery name="qry" datasource="#variables.DSN1#"  >
		EXEC sp_InvoiceCreated
			@InvoiceID = #arguments.invoiceID#
		</cfquery>		 
		 
		<cfreturn qry.recordCount>
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="invoiceCreatedforOrder" access="public" output="false" returntype="query" >
		<cfargument name="orderID" type="numeric"	required="yes">
		
		<cfset var qry = "">
		
		<cfquery name="qry" datasource="#variables.DSN1#"  >
		EXEC sp_InvoiceCreatedForOrder
			@OrderID = #arguments.orderID#
		</cfquery>		 
		 
		<cfreturn qry>
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="insertInvoice" access="public" output="false" returntype="numeric" 
		hint="">
		
		<cfargument name="userID" 			type="numeric" 	required="yes" 	hint="The ID of the User the invoice is assigned to">
		<cfargument name="orderID" 			type="numeric" 	required="yes"	hint="">
		<cfargument name="totalDue"			type="any" 	required="yes"	hint="The total amount due for the invoice">
		<cfargument name="totalReceived" 	type="numeric"	required="yes"	hint="The total amount received for the invoice">
		<cfargument name="billingAddress" 	type="string" 	required="yes"	hint="I hold the billing address to update">
		<cfargument name="billingPostcode" 	type="string" 	required="yes"	hint="I hold the billing postcode to update">
		<cfargument name="invoiceFileName" 	type="string" 	required="yes"	hint="I hold the invoice number to update">
		<cfargument name="statusCode" 		type="string" 	required="yes"	hint="The status of the invoice">
		<cfargument name="ItemDesc" 		type="string" 	required="yes"	>
	 	<cfargument name="ItemCost" 		type="any" 		required="yes"	>
	 	<cfargument name="f_product_id" 	type="string" 	required="yes"	>
	 	<cfargument name="quantity" 		type="string" 	required="yes"	>
	 	<cfargument name="purchase_order_no"type="string" 	required="yes"	>
		
		<cfscript>
		var invoiceID = 0;
		var AddInvoiceNo = 0;
		//ONLY if site is live should we increment sequenetial Invoice nos.
		if (strConfig.strVars.Environment eq 'live')
			AddInvoiceNo = 1;
		</cfscript>
		
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_CommitInvoice" returncode="yes">
			
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@f_user_id"			value="#arguments.userID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@f_order_id"			value="#arguments.orderID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_money" 	dbvarname="@totalDue" 			value="#arguments.totalDue#">
			<cfprocparam type="in"  cfsqltype="cf_sql_money"  	dbvarname="@totalReceived"		value="#arguments.totalReceived#">
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar"  dbvarname="@billingAddress"		value="#arguments.billingAddress#">
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar"  dbvarname="@billingPostcode"	value="#arguments.billingPostcode#">
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar"  dbvarname="@invoiceFileName"	value="#arguments.invoiceFileName#">
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar"  dbvarname="@f_statuscode_id"	value="#arguments.statusCode#">
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar"  dbvarname="@itemDesc"			value="#arguments.itemDesc#">
			<cfprocparam type="in"  cfsqltype="cf_sql_money" 	dbvarname="@itemCost"			value="#arguments.itemCost#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer"  dbvarname="@f_product_id"		value="#arguments.f_product_id#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer"  dbvarname="@quantity"			value="#arguments.quantity#">
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar"  dbvarname="@purchase_order_no"	value="#arguments.purchase_order_no#">
			<cfprocparam type="in"   cfsqltype="cf_sql_bit"  dbvarname="@AddInvoiceNo"			value="#AddInvoiceNo#">
	
			<!--- 
			<cfprocparam type="in"  cfsqltype="cf_sql_bit"  	dbvarname="@addedToSun"			value="0">
			<cfprocparam type="in"  cfsqltype="cf_sql_bit"  	dbvarname="@creditNoteReq"		value="0">
			<cfprocparam type="in"  cfsqltype="cf_sql_bit"  	dbvarname="@creditNoteSent"		value="0">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@lastChangedBy"		value="0">
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar"  dbvarname="@accountNotes"		value="">
			--->
			
			<cfprocparam type="out" cfsqltype="cf_sql_integer" 	dbvarname="@invoiceID" 	variable="invoiceID"> 
		</cfstoredproc>
		
		<cfscript>
		if (cfstoredproc.statusCode neq 0)
			invoiceID = 0;
			
		return invoiceID;
		</cfscript>

	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="insertInvoiceNonSub" access="public" output="false" returntype="query" hint="">
		
		<cfargument name="userID" 			type="numeric" 	required="yes" 	hint="The ID of the User the invoice is assigned to">
		<cfargument name="orderID" 			type="numeric" 	required="yes"	hint="">
		<cfargument name="totalDue"			type="any" 	required="yes"	hint="The total amount due for the invoice">
		<cfargument name="totalReceived" 	type="numeric"	required="yes"	hint="The total amount received for the invoice">
		<cfargument name="billingAddress" 	type="string" 	required="yes"	hint="I hold the billing address to update">
		<cfargument name="billingPostcode" 	type="string" 	required="yes"	hint="I hold the billing postcode to update">
		<cfargument name="invoiceFileName" 	type="string" 	required="yes"	hint="I hold the invoice number to update">
		<cfargument name="statusCode" 		type="string" 	required="yes"	hint="The status of the invoice">
	 	<cfargument name="purchase_order_no" type="string" 		required="yes"	>
		<cfargument name="ItemArray"		 type="array" 	required="yes"	>
		
		<cfscript>
		var invoiceID = 0;
		var i = 0;
		var item = "";
		var AddInvoiceNo = 0;
		var qryInvoice = querynew("temp");
		//ONLY if site is live should we increment sequenetial Invoice nos.
		if (strConfig.strVars.Environment eq 'live')
			AddInvoiceNo = 1;
		</cfscript>
		
		<cfquery datasource="#variables.DSN1#" name="qryInvoice">
			DECLARE	
         		@paymentType		int,
				@invoiceNo			varchar(16),	
				@InvoiceID			int
				
				
				
				SELECT @paymentType = f_paymentmethod_id 
				FROM	tblLocalGov_Order
				WHERE p_order_id = #arguments.orderID#

				INSERT INTO tblLocalGov_Invoice (
							TotalDue,
							TotalReceived,
							f_user_id,
							f_order_id, 
							f_statuscode_id,
							DateCreated,
							BillingAddress,
							BillingPostcode,
							purchaseOrder
							)
				VALUES		(
							#arguments.totalDue#,
							#arguments.totalReceived#,
							#arguments.userID#,
							#arguments.orderID#,
							'#arguments.statusCode#',
							GetDate(),
							'#arguments.billingAddress#',
							'#arguments.billingPostcode#',
							#arguments.purchase_order_no#
							
						)

				SET @invoiceID = SCOPE_IDENTITY()
				
				
				<cfloop from="1" to="#ArrayLen(arguments.ItemArray)#" index="i">
					<cfset item = arguments.ItemArray[i]>
						--insert invoice items
						 INSERT INTO tblLocalGov_InvoiceItem (
							ItemDesc,
							ItemCost,
							f_invoice_id,
							f_product_id, 
							DateCreated,
							quantity
							)
							VALUES		
							(
							'#item.ItemDesc#',
							#item.ItemCost#,
							@invoiceID,
							#item.productid#,
							GetDate(),
							#item.quantity#					
							)
					</cfloop>
						 
				
				<cfif AddInvoiceNo>
					/*INCREMENT INVOICE NO by 1*/
					SELECT @invoiceNo = MAX(CONVERT(int, REPLACE(InvoiceNo, 'LGOV/',''))) + 1 
					FROM tblLocalGov_Invoice
					WHERE REPLACE(InvoiceNo, 'LGOV/','')  != 'Test'
					
					/*SET INVOICE NO to */
					SET @invoiceNo = 'LGOV/00' + CONVERT(varchar(7), @invoiceNo )	
					
					UPDATE tblLocalGov_Invoice
					SET	 invoiceNo = @invoiceNo
					WHERE 	p_invoice_id=@invoiceID	
				
				<cfelse>
					SET @invoiceNo = 'LGOV/Test' 
						
						
					UPDATE tblLocalGov_Invoice
					SET	 invoiceNo = @invoiceNo
					WHERE 	p_invoice_id=@invoiceID
				</cfif>
			
			
			exec sp_GetInvoiceByInvoiceID 	@invoiceID								
	</cfquery>
		
		
	<cfreturn qryInvoice>	

	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="updateInvoiceFileName" access="public" output="false" returntype="boolean" >
		<cfargument name="invoiceID" 		type="numeric"	required="yes">
		<cfargument name="invoiceFilename" 	type="string" 	required="yes">
		
		<cfquery name="qry" datasource="#variables.DSN1#"  >
		EXEC sp_UpdateInvoiceFileName
			@InvoiceID = #arguments.invoiceID#,
			@InvoiceFileName = '#arguments.invoiceFilename#'
		</cfquery>		 
		 
		<cfreturn true>
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getOrderDetailsForInvoice" access="public" output="false" returntype="query" >
		<cfargument name="orderID" 		type="numeric" 		required="yes">
		
		<cfquery name="qry" datasource="#variables.DSN1#"  >
		EXEC sp_GetOrderDetailsForInvoice
			@OrderID = #arguments.orderID#
		</cfquery>		 
		 
		<cfreturn qry>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getDSOrderDetailsForInvoice" access="public" output="false" returntype="query" >
		<cfargument name="orderID" 		type="numeric" 		required="yes">
		
		<cfquery name="qry" datasource="#variables.DSN1#"  >
		EXEC sp_GetDSOrderDetailsForInvoice
			@OrderID = #arguments.orderID#
		</cfquery>		 
		 
		<cfreturn qry>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getDS_CountOrderLineForOrder" access="public" output="false" returntype="numeric" hint="returns the count number of lists for a given order" >
		<cfargument name="orderID" 		type="numeric" 		required="yes">
		
		<cfquery name="qry" datasource="#variables.DSN1#"  >
		EXEC sp_GetDS_CountOrderLineForOrder
			@OrderID = #arguments.orderID#
		</cfquery>		 
		 
		<cfreturn qry.recordcount>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- save Invoice Item - this table holds the individual items that belong to an invoice - usually packages --->
	<!--- -------------------------------------------------------------------------------------------------
	<cffunction  name="insertInvoiceItem" access="public" output="false" returntype="string"
		hint="insert the invoice items">
		
		<cfargument name="invoiceId" 		required="yes" 	type="numeric"	hint="I hold the invoice number the item is associated with">
		<cfargument name="itemDesc"			required="yes" 	type="string"	hint="The description of the item.">
		<cfargument name="itemCost"			required="yes" 	type="numeric"	hint="The cost for the item">
		<cfargument name="quantity"			required="yes" 	type="numeric"	hint="The quantity of the item">
		<cfargument name="productId"		required="yes" 	type="numeric"	hint="ID of a package the item is linked to">

		<cfset var invoiceItemId = 0>
		
		<cfstoredproc procedure="sp_insertInvoiceItem" datasource="#variables.DSN1#">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" 	dbvarname="@invoiceID"		value="#arguments.invoiceId#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" 	dbvarname="@itemDesc" 		value="#arguments.itemDesc#" 	
				null="#IIF(len(trim(arguments.itemDesc)),DE('No'),DE('Yes'))#">
			<cfprocparam type="in" cfsqltype="cf_sql_money"		dbvarname="@itemCost" 		value="#arguments.itemCost#">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" 	dbvarname="@packageId" 		value="#arguments.packageId#" 	
				null="#IIF(arguments.packageId neq 0,DE('No'),DE('Yes'))#">
			<!--- new Invoice Item ID --->
			<cfprocparam type="out" cfsqltype="cf_sql_integer"	dbvarname="@itemId"	variable="itemId">
		</cfstoredproc>
	
		<cfreturn itemId>
	</cffunction>---->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- get selected invoice and associated item details --->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction  name="getInvoiceDetails" access="public" output="false"  returntype="query"
		hint="I return a query of invoice details for a supplied invoice id">
		
		<cfargument name="invoiceID" 		required="yes" 	type="numeric"	hint="This is the ID of the invoice to retrieve details for.">
		<cfset var qryInvoiceDetails 	= queryNew("")>
		 	
		<cfstoredproc procedure="usp_GetInvoiceByInvoiceID" datasource="#variables.DSN5#">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@InvoiceID" value="#arguments.invoiceID#">
			<cfprocresult resultset="1" name="qryInvoiceDetails">
		</cfstoredproc>
	
		<cfreturn qryInvoiceDetails>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- get user invoices --->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction  name="getInvoices" access="public" output="false" returntype="query"
		hint="returns a query of invoice details for a supplied user id and or event id" >
		
		<cfargument name="userID" 		required="no" 	type="numeric"	default="0"	hint="This is the ID of the user to return invoice details for. Default returns all users invoices">
		<cfargument name="statusCode"	required="no" 	type="string" 	default=""	hint="The status of the invoice">
				
		<cfset var qryInvoiceDetails 	= queryNew("")>
		 		 
		<cfstoredproc procedure="sp_getInvoices" datasource="#variables.DSN1#">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@userID" 		value="#arguments.userID#" 		
				null="#IIF(arguments.userID neq 0,DE('No'),DE('Yes'))#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@StatusCode" 	value="#arguments.statusCode#" 	
				null="#IIF(len(trim(arguments.statusCode)),DE('No'),DE('Yes'))#">
				
			<cfprocresult resultset="1" name="qryInvoiceDetails">
		</cfstoredproc>

		<cfreturn qryInvoiceDetails>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- get invoice statuses --->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction  name="getInvoiceStatus" access="public" output="false" hint="I return a query of invoice status" returntype="query">
		<cfset var qryInvoiceStatus 	= queryNew("")>
		 		 
		 <cfquery name="qryInvoiceStatus" datasource="#variables.DSN1#" cachedwithin="#CreateTimeSpan(0, 6, 0, 0)#" >
		SELECT statusCode, statusName, StatusDesc 
		FROM tblLocalGov_InvoiceStatus
		ORDER BY statusName
		 </cfquery>		 
		 
		<cfreturn qryInvoiceStatus>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- *** NEW FUNCTIONS *** --------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getInvoiceData" access="public" output="false" returntype="Struct" hint="Retrieve all data needed for generating the invoice">
		<cfargument name="orderID" 		type="numeric" 	required="yes">
		<cfargument name="productid" 	type="numeric" 	required="no" default="0">
		
		<cfset var strInvoiceData = StructNew()>
		
		<cfstoredproc procedure="usp_GetInvoiceData" datasource="#variables.dsn5#">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@OrderID" value="#arguments.orderID#">
			<cfif arguments.productid >
				<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@productid" value="#arguments.productid#">
			<cfelse>
				<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@productid" value="" null="yes">
			</cfif>
			
			
			<cfprocresult resultset="1" name="strInvoiceData.qryUserDetails">
			<cfprocresult resultset="2" name="strInvoiceData.qryInvoiceDetails">
		</cfstoredproc>
		
		<cfreturn strInvoiceData>
					
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="saveInvoiceData" access="public" output="false" returntype="string" hint="Save relevant date to Invoice table in DB">
		<cfargument name="orderID" 			type="numeric" 	required="yes">
		<cfargument name="strInvoiceData" 	type="struct" 	required="yes" hint="structure holding all the invoice data">
		
		<cfstoredproc datasource="#variables.dsn5#" procedure="usp_SaveInvoiceData" returncode="yes">
			
			<!--- <cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@InvoiceNo" 			value="#arguments.strInvoiceData.qryInvoiceDetails.newInvoiceNo#"> --->
			<cfprocparam type="in"  cfsqltype="cf_sql_money" 	dbvarname="@TotalDue" 			value="#arguments.strInvoiceData.TotalDue#">
			<cfprocparam type="in"  cfsqltype="cf_sql_money" 	dbvarname="@OrderID"			value="#arguments.OrderID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_money" 	dbvarname="@PreVatTotal"		value="#arguments.strInvoiceData.qryUserDetails.AbsoluteOrderPrice#">
			<cfprocparam type="in"  cfsqltype="cf_sql_money" 	dbvarname="@StandardRatedTotal"	value="#arguments.strInvoiceData.qryInvoiceDetails.StandardRatedTotal#">
			<cfprocparam type="in"  cfsqltype="cf_sql_money" 	dbvarname="@ZeroRatedTotal"		value="#arguments.strInvoiceData.qryInvoiceDetails.ZeroRatedTotal#">
			<cfprocparam type="in"  cfsqltype="cf_sql_money" 	dbvarname="@StandardRatedVAT"	value="#arguments.strInvoiceData.qryInvoiceDetails.StandardRatedVAT#">
			
			<cfprocparam type="out" cfsqltype="cf_sql_varchar" 	dbvarname="@NewInvoiceNo" variable="NewInvoiceNo"> 
		</cfstoredproc>
		
		<cfreturn NewInvoiceNo>
		
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="updateInvoice" access="public" output="false" returntype="void" hint="Update the invoice record specified with the physical filename">
		<cfargument name="newInvoiceNo" 	type="string" 	required="yes">
		<cfargument name="invoiceFilename" 	type="string" 	required="yes">
		
		<cfset var qryUpdateInvoice = queryNew("temp")>
		
		<cfquery name="qryUpdateInvoice" datasource="#variables.dsn5#">
			EXEC usp_UpdateInvoice
				@InvoiceNo 			= '#arguments.newInvoiceNo#'
				, @InvoiceFilename 	= '#arguments.invoiceFilename#'
		</cfquery>
		
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="updateInvoiceForExport" access="public" output="false" returntype="void" hint="mark as exported by acconnts">
		<cfargument name="lstInvoiceID" 	type="string" 	required="yes">
			
			<cfquery name="qryUpdateInvoice" datasource="#variables.dsn5#">
				EXEC usp_web_UpdateInvoiceForExport
					@lstInvoiceID = '#arguments.lstInvoiceID#'
			</cfquery>
		
	</cffunction>


</cfcomponent>