<cfcomponent displayname="OrdersDAO" output="false" extends="his_Localgov_Extends.components.DAOManager">
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="OrdersDAO" hint="Pseudo-constructor">
	
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		StructAppend( variables, Super.init( arguments.strConfig ) );
		
		return this;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction  name="AdminSelects" access="public" returntype="struct" output="false">
		
		<cfset var str = StructNew()>
		
		<cfstoredproc datasource="#variables.DSN5#" procedure="usp_getAdminOrderSelects">
			<cfprocresult resultset="1" name="str.qryProducts">
			<cfprocresult resultset="2" name="str.qryPayment">
			<cfprocresult resultset="3" name="str.qryStatus">
		</cfstoredproc>
		
		<cfreturn str>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getOrderDetail" access="public" output="false" returntype="struct" hint="get order and seeds">
		
		<cfargument name="orderID" 	type="string" 	required="true">
		
		<cfset var strOrder = StructNew()> 
		
		<cfstoredproc datasource="#variables.DSN5#" procedure="usp_GetOrderDetail">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@orderID" value="#arguments.orderID#">
				<cfprocresult resultset="1" name="strOrder.qryOrder">
				<cfprocresult resultset="2" name="strOrder.qrySeeds">
		</cfstoredproc>
		
		<cfreturn strOrder>
		
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction  name="AdminSearch" access="public" returntype="query" output="false">
		<cfargument name="username" 	type="string"  required="false" default="" > 
		<cfargument name="company" 		type="string"  required="false" default="" > 
		<cfargument name="orderid" 	  	type="string" required="false" default="0" >
		<cfargument name="oldorderid" 	type="string" required="false" default="0" >
		<cfargument name="invoiceNo" 	type="string" required="false" default="" >
		<cfargument name="dateStart" 	type="string"  required="false" default="0" > 
		<cfargument name="dateEnd" 		type="string" required="false" default="" > 
		<cfargument name="orderStatus"	type="numeric" required="false" default="0" > 
		<cfargument name="payment" 		type="numeric" required="false" default="0" > 
		<cfargument name="Person" 		type="string" required="false" default="" > 
		<cfargument name="productid" 	type="string" required="false" default="" >
		<cfargument name="isso" 		type="numeric" required="no" default="0">
		
			
			<cfset var qrySearchOrders = "">
			<cfquery name="qrySearchOrders" datasource="#variables.DSN5#" cachedwithin="#CreateTimeSpan(0,0,0,20)#">
				EXEC usp_AdminSearchOrders
				@username 	 =	<cfif Len(arguments.username)>'#arguments.username#'<cfelse>NULL</cfif>,
				@company 	 =	<cfif Len(arguments.company)>'#arguments.company#'<cfelse>NULL</cfif>,
				@orderid 	 = 	<cfif arguments.orderid>#arguments.orderid#<cfelse>NULL</cfif>,
				@oldorderid  = 	<cfif arguments.oldorderid>#arguments.oldorderid#<cfelse>NULL</cfif>,
				@invoiceno  = 	<cfif len(arguments.invoiceNo)>'#arguments.invoiceNo#'<cfelse>NULL</cfif>,
				@productid   = 	<cfif arguments.productid>#arguments.productid#<cfelse>NULL</cfif>,	
				@dateStart =  <cfif Len(arguments.dateStart)>#CreateODBCDate(LsDateFormat(arguments.dateStart, 'dd/mmm/yyyy'))#<cfelse>NULL</cfif>,
				@dateEnd =  <cfif Len(arguments.dateEnd)>#CreateODBCDate(LsDateFormat(arguments.dateEnd, 'dd/mmm/yyyy'))#<cfelse>NULL</cfif>,
				@orderStatus =	<cfif arguments.orderStatus>#arguments.orderStatus#<cfelse>NULL</cfif>,
				@payment	 = 	<cfif arguments.payment>#arguments.payment#<cfelse>NULL</cfif>,
				@Person	 	 = 	<cfif Len(arguments.Person)>#arguments.Person#<cfelse>NULL</cfif>,
				@isso	 	 = 	<cfif arguments.isso>#arguments.isso#<cfelse>NULL</cfif>
			</cfquery>
	
		<cfreturn qrySearchOrders>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="commitBookOrder" output="false" returntype="numeric" 
		hint="Commits book order ">
		
		<cfargument name="UserID" 					type="numeric" required="yes">
		<cfargument name="PaymentMethod"			type="numeric" required="yes">
		<cfargument name="ProductID" 				type="numeric" required="yes">
		<cfargument name="Quantity" 				type="numeric" required="yes">
		<cfargument name="OrderLineStatus"			type="numeric" required="yes">
		<cfargument name="campaignCode"				type="any"	required="yes">
		<cfargument name="AbsoluteOrderPrice" 		type="numeric" required="yes">
		<cfargument name="ListPrice" 				type="numeric" required="yes">
		<cfargument name="TermPrice" 				type="numeric" required="yes">
		<cfargument name="VATAmount" 				type="numeric" required="yes">
		<cfargument name="DiscountedPrice" 			type="numeric" required="yes">
		<cfargument name="addressXml"				type="any" 	required="no" default="">
		<cfargument name="isInvoiceable" 			type="numeric" required="yes">
		<cfargument name="pandP"					type="numeric" 	required="no" default="0">
		
		<cfset var newOrderid = 0>
		
		<cftransaction>
			<!--- Save the order header --->
			<cfstoredproc datasource="#variables.dsn5#" procedure="usp_SaveOrder" returncode="yes">
				<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@UserId" 				value="#arguments.userID#">
				<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@PaymentMethod"			value="#arguments.paymentMethod#">
				<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@OrderStatusID"			value="#arguments.OrderLineStatus#">
				<cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@DataPurchaserXML"		value="">
				<cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@EuVATNumber"	 		value="" null="true">
				<cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@ShippingAddressXML" 	value="#arguments.addressXML#">
				<cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@CampaignCode"	 		value="#arguments.campaignCode#">
				<cfprocparam type="in"  cfsqltype="cf_sql_money"  	dbvarname="@AbsoluteOrderPrice"		value="#arguments.AbsoluteOrderPrice#">
				<cfprocparam type="in"  cfsqltype="cf_sql_bit" 		dbvarname="@IsUpgrade"				value="0">
				<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@BaseOrderID"			value="0">
				<cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@PurchaseOrderNumber"	value="0">
				<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@ProductID"				value="#arguments.ProductID#">
				<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@isSO"					value="0">
				<cfprocparam type="in" 	cfsqltype="cf_sql_varchar" 	dbvarname="@uuid" 					value="">
				<cfprocparam type="out" cfsqltype="cf_sql_integer" 	dbvarname="@OrderID" 				variable="newOrderID"> 
			</cfstoredproc>		
			
			<!--- Save the order line for the book product --->
			<cfstoredproc datasource="#variables.dsn5#" procedure="usp_SaveOrderLine" returncode="yes">	
				<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@OrderId" 			value="#newOrderID#">
				<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@ProductID" 			value="#arguments.productID#">
				<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@Quantity" 			value="#arguments.Quantity#">
				<cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@DataSalesXML" 		value="">
				<cfprocparam type="in" 	cfsqltype="cf_sql_integer" 	dbvarname="@ComponentID" 		value="3">			
				<cfprocparam type="in" 	cfsqltype="cf_sql_money" 	dbvarname="@ListPrice" 			value="#arguments.ListPrice#"> 			
				<cfprocparam type="in" 	cfsqltype="cf_sql_float" 	dbvarname="@ProductPercentage" 	value="100">
				<cfprocparam type="in" 	cfsqltype="cf_sql_money" 	dbvarname="@TermPrice" 			value="#arguments.TermPrice#">			
				<cfprocparam type="in" 	cfsqltype="cf_sql_float" 	dbvarname="@VATRate" 			value="0"> 
				<cfprocparam type="in" 	cfsqltype="cf_sql_money" 	dbvarname="@DiscountedPrice" 	value="#arguments.DiscountedPrice#"> 
				<cfprocparam type="in" 	cfsqltype="cf_sql_money" 	dbvarname="@AbsolutePrice" 		value="#arguments.DiscountedPrice#"> 
				<cfprocparam type="in" 	cfsqltype="cf_sql_money" 	dbvarname="@VATAmount" 			value="#arguments.VATAmount#"> 
				<cfprocparam type="in" 	cfsqltype="cf_sql_bit" 		dbvarname="@isInvoiceable" 		value="#arguments.isInvoiceable#">
				<cfprocparam type="out" cfsqltype="cf_sql_integer" 	dbvarname="@OrderLineID" 		variable="OrderLineID"> 
			</cfstoredproc>
			
			<!--- Save the order line for the postage product --->
			<cfstoredproc datasource="#variables.dsn5#" procedure="usp_SaveOrderLine" returncode="yes">	
				<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@OrderId" 			value="#newOrderID#">
				<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@ProductID" 			value="#arguments.productID#">
				<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@Quantity" 			value="1">
				<cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@DataSalesXML" 		value="">
				<cfprocparam type="in" 	cfsqltype="cf_sql_integer" 	dbvarname="@ComponentID" 		value="4">			
				<cfprocparam type="in" 	cfsqltype="cf_sql_money" 	dbvarname="@ListPrice" 			value="#arguments.pandP#"> 			
				<cfprocparam type="in" 	cfsqltype="cf_sql_float" 	dbvarname="@ProductPercentage" 	value="0">
				<cfprocparam type="in" 	cfsqltype="cf_sql_money" 	dbvarname="@TermPrice" 			value="#arguments.pandP#">			
				<cfprocparam type="in" 	cfsqltype="cf_sql_float" 	dbvarname="@VATRate" 			value="0"> 
				<cfprocparam type="in" 	cfsqltype="cf_sql_money" 	dbvarname="@DiscountedPrice" 	value="#arguments.pandP#"> 
				<cfprocparam type="in" 	cfsqltype="cf_sql_money" 	dbvarname="@AbsolutePrice" 		value="#arguments.pandP#"> 
				<cfprocparam type="in" 	cfsqltype="cf_sql_money" 	dbvarname="@VATAmount" 			value="0.00"> 
				<cfprocparam type="in" 	cfsqltype="cf_sql_bit" 		dbvarname="@isInvoiceable" 		value="#arguments.isInvoiceable#">
				<cfprocparam type="out" cfsqltype="cf_sql_integer" 	dbvarname="@OrderLineID" 		variable="OrderLineID"> 
			</cfstoredproc>
		</cftransaction>
		
		<cfreturn newOrderid>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="updateOrderLineStatus" output="false" returntype="void" 
			hint="Update order line status">
		
		<cfargument name="orderID"	type="numeric" required="yes">
		<cfargument name="statusID"	type="numeric"  required="yes">
		
		<cfstoredproc datasource="#variables.DSN1#" procedure="sp_UpdateOrderLineStatus" returncode="yes">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@OrderId" 	value="#arguments.orderID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@StatusID" 	value="#arguments.statusID#">
		</cfstoredproc>		
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->

	<cffunction name="getOrderTotals" output="false" returntype="query" 
			hint="return the sums of orders for a particular product">
		<cfargument name="productid" type="numeric" required="no" default="4"	>
		
		<cfset var qryTotals = "">
		<cfquery datasource="#variables.DSN1#" name="qryTotals">
			EXEC sp_getOrderSumTotals #arguments.productid#
		</cfquery>
		<cfreturn qryTotals>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getOrderTotalsbyMonth" output="false" returntype="query" access="public" hint="return the sums of orders for a particular product">
		<cfargument name="productid" type="numeric" required="no" default="4"	>
		
		<cfset var qryTotals = "">
		<cfquery datasource="#variables.DSN1#" name="qryTotals">
			EXEC sp_getOrderSumTotalsbyMonth #arguments.productid#
		</cfquery>
		<cfreturn qryTotals>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- NEW FUNCTIONS ---------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getOrderPrice" access="public" output="false" returntype="Struct" hint="return price of a product based on campaign code">
		<cfargument name="campaignCode" type="string"  required="yes">
		<cfargument name="productID"  	type="numeric" required="yes">
		<cfargument name="quantity"  	type="numeric" required="yes">
		<cfargument name="termID"  		type="numeric" required="yes" hint="The term ID for the product which tells you what duration the order covers">
		
		<cfset var strOrder = StructNew()>
		<cfset var qryGetOrderPrice 	= queryNew("temp")>
		<cfset var qryGetPostageRates 	= queryNew("temp")>
		<cfset var discountedPrice = 0>
		
		<cfstoredproc procedure="usp_GetOrderPrice" datasource="#variables.dsn5#">	
			
			<cfif Len(trim(arguments.campaignCode))>
				<cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@CampaignCode" 	value="#arguments.campaignCode#">
			<cfelse>
				<cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@CampaignCode" 	value="" null="true">
			</cfif>
			
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@ProductID" 		value="#arguments.productID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@Quantity" 		value="#arguments.quantity#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@TermID" 		value="#arguments.termID#">
					
			<cfprocresult resultset="1" name="strOrder.qryGetOrderPrice">
			<cfprocresult resultset="2" name="strOrder.qryGetPostageRates">
		</cfstoredproc>
		
		<cfoutput query="strOrder.qryGetOrderPrice">
			<cfset discountedPrice = discountedPrice + strOrder.qryGetOrderPrice.DiscountedPrice>
		</cfoutput>
		
		<cfset strOrder.ProductPrice = discountedPrice>
		
		<cfreturn strOrder>
	</cffunction>
	
	<!------------------------------------------------------------------------------------------------------------------------------------------------------------------- --->
	<!--- --------------------------------------------------------------------------------------------------------------------------------------------------------------- --->
	<!--- --------------------------------------------------------------------------------------------------------------------------------------------------------------- --->
	<cffunction name="saveOrder" output="false" returntype="numeric" access="public" hint="Commits order">
		<cfargument name="productid" 			type="numeric" 	required="yes">
		<cfargument name="paymentMethodID" 		type="numeric" 	required="yes">
		<cfargument name="orderStatusID" 		type="numeric" 	required="yes">
		<cfargument name="userID" 				type="numeric" 	required="yes">
		<cfargument name="dataPurchaserXML"		type="string" 	required="no" default="">
		<cfargument name="euVATNumber"			type="string" 	required="yes">
		<cfargument name="campaignCode"			type="string" 	required="yes">
		<cfargument name="shippingAddressXML" 	type="string"	required="no" default="0">
		<cfargument name="isUpgrade" 			type="numeric" 	required="no"	default="0"	hint="indicates whether this order is an upgrade">
		<cfargument name="baseOrderID" 			type="numeric" 	required="no"	default="0" hint="ID of order that is been upgraded">
		<cfargument name="AbsoluteOrderPrice" 	type="numeric" 	required="no"	default="0" hint="">
		<cfargument name="PurchaseOrderNumber"	type="string"	required="yes">
		<cfargument name="strSession" 			type="struct"	required="yes" 	hint="str of the session scope">
		<cfargument name="isSO"					type="numeric"	required="no" default="0">
		
		<cfset var OrderID= 0>
		
		<cfstoredproc datasource="#variables.dsn5#" procedure="usp_SaveOrder" returncode="yes">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@UserId" 				value="#arguments.userID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@PaymentMethodID"		value="#arguments.paymentMethodID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@OrderStatusID"			value="#arguments.OrderStatusID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@DataPurchaserXML"		value="#arguments.dataPurchaserXML#">
			
			<cfif arguments.euVATNumber EQ 0>
				<cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@EuVATNumber"	 	value="" null="true">
			<cfelse>
				<cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@EuVATNumber"	 	value="#arguments.euVATNumber#">
			</cfif>
			
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@ShippingAddressXML" 	value="#arguments.shippingAddressXML#">
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@CampaignCode"	 		value="#arguments.campaignCode#">
			<cfprocparam type="in"  cfsqltype="cf_sql_money"  	dbvarname="@AbsoluteOrderPrice"		value="#arguments.AbsoluteOrderPrice#">
			<cfprocparam type="in"  cfsqltype="cf_sql_bit" 		dbvarname="@IsUpgrade"				value="#arguments.isUpgrade#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@BaseOrderID"			value="#arguments.baseOrderID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@PurchaseOrderNumber"	value="#arguments.PurchaseOrderNumber#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@ProductID"				value="#arguments.ProductID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@isSO"					value="#arguments.isSO#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@uuid" value="#arguments.strSession.strSubscribe.uuid#">
			
			<cfprocparam type="out" cfsqltype="cf_sql_integer" 	dbvarname="@OrderID" 				variable="OrderID"> 
		</cfstoredproc>
		
		<cfscript>
			if (cfstoredproc.statusCode NEQ 0)
				OrderID = 0;
		</cfscript>
			
		<cfreturn OrderID>
	
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="saveOrderLine" output="false" returntype="numeric" hint="Commits orderline">
		
		<cfargument name="OrderID" 				type="numeric" 	required="yes">
		<cfargument name="ProductID" 			type="numeric" 	required="yes">
		<cfargument name="ComponentQuantity" 	type="numeric" 	required="yes">
		<cfargument name="dataSalesXML"			type="string"  	required="yes">
		<!--- <cfargument name="shippingAddressXML" 	type="string"	required="no" default="0"> --->
		<cfargument name="ComponentID"			type="numeric"  required="yes">			
		<cfargument name="ListPrice"			type="string"  	required="yes"> 			
		<cfargument name="ProductPercentage"	type="string"  	required="yes"> 	
		<cfargument name="TermPrice"			type="string"  	required="yes">			
		<cfargument name="VATRate"				type="string"  	required="yes"> 
		<cfargument name="DiscountedPrice"		type="string"  	required="yes"> 
		<cfargument name="AbsolutePrice"		type="string"  	required="yes"> 
		<cfargument name="VATAmount"			type="string"  	required="yes"> 
		<cfargument name="isInvoiceable"		type="numeric"  required="yes">
		
		<cfset var OrderLineID= 0>
		
		<cfstoredproc datasource="#variables.dsn5#" procedure="usp_SaveOrderLine" returncode="yes">
			
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@OrderId" 			value="#arguments.orderID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@ProductID" 			value="#arguments.productID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@Quantity" 			value="#arguments.ComponentQuantity#">
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@DataSalesXML" 		value="#arguments.dataSalesXML#">
<!--- 			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@ShippingAddressXML" value="#arguments.shippingAddressXML#"> --->
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
		
		<cfreturn OrderLineID>
	
	</cffunction>
	
    <!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!---Create Web Subscription - only called from website    ------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
    <cffunction name="createWebSubscription" output="false" returntype="numeric" access="public" hint="Create a subscription entry for user">
    	<cfargument name="OrderID" 					type="numeric" 	required="yes">
		<cfargument name="UserID" 					type="numeric" 	required="yes">
        <cfargument name="ProductID" 				type="numeric" 	required="yes">
        <cfargument name="AllowableSubscribers" 	type="numeric" 	required="yes">
        
        <cfset var newSubID= 0>
        <cfstoredproc datasource="#variables.DSN5#" procedure="usp_SaveWebSubscription_New" >
        	<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@UserId" 				value="#arguments.UserID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@ProductID" 				value="#arguments.productID#">
            <cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@OrderID" 				value="#arguments.OrderID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@AllowableSubscribers"	value="#arguments.AllowableSubscribers#">
            <cfprocparam type="out" cfsqltype="cf_sql_integer" 	dbvarname="@newSubID" variable="newSubID"> 
        </cfstoredproc>
        
        <cfreturn newSubID>
    </cffunction>
    
    
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="createSubscription" output="false" returntype="numeric" access="public" hint="Create a subscription entry for user">
		<cfargument name="OrderID" 				type="numeric" 	required="yes">
		<cfargument name="UserID" 				type="numeric" 	required="yes">
		<cfargument name="ProductID" 			type="numeric" 	required="yes">
		<cfargument name="SubscriptionStatusID" type="numeric" 	required="yes">
		<cfargument name="StartDate" 			type="String" 	required="yes">
		<cfargument name="EndDate" 				type="String" 	required="yes">
		<cfargument name="isCurrent" 			type="numeric" 	required="no"	default="1">
		<cfargument name="AllowableSubscribers" type="numeric" 	required="yes">
		<cfargument name="notes" type="string" required="no" default="">
		
		<cfset var OrderLineID= 0>
		
		<cfstoredproc datasource="#variables.DSN5#" procedure="usp_SaveWebSubscription" returncode="yes">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@UserId" 				value="#arguments.UserID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@ProductID" 				value="#arguments.productID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@SubscriptionStatusID"	value="#arguments.subscriptionStatusID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@OrderId" 				value="#arguments.OrderID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_date" 	dbvarname="@StartDate"				value="#CreateODBCDate(DateFormat(arguments.StartDate,'dd/mmm/yyyy'))#">
			<cfprocparam type="in"  cfsqltype="cf_sql_date" 	dbvarname="@EndDate" 				value="#CreateODBCDate(DateFormat(arguments.EndDate,'dd/mmm/yyyy'))#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@IsCurrent" 				value="#arguments.isCurrent#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@AllowableSubscribers" 	value="#arguments.AllowableSubscribers#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@notes" value="#arguments.notes#">
			
			<cfprocparam type="out" cfsqltype="cf_sql_integer" 	dbvarname="@newSubID" variable="newSubID"> 
		</cfstoredproc>
		
		<cfscript>
			if (cfstoredproc.statusCode NEQ 0)
				newSubID = 0;
		</cfscript>
		
		<cfreturn newSubID>
		
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="updateOrder" output="false" returntype="numeric" access="public" hint="Update the Order and subscription status">
		<cfargument name="orderID" 				type="numeric" required="yes">
		<cfargument name="subscriptionID"		type="numeric" required="no" default="0">	
		<cfargument name="orderStatusID"     	type="numeric" required="no" default="0"> 
		<cfargument name="subscriptionStatusID"	type="numeric" required="no" default="0">
		<cfargument name="worldpayTransactionID"type="numeric" required="no" default="0">

		<cfset var qryUpdateOrder = queryNew("temp")>

		<cfquery name="qryUpdateOrder" datasource="#variables.dsn5#">
			EXEC usp_UpdateOrder
				@OrderID = #arguments.orderID#
				, @SubscriptionID 			= <cfif arguments.subscriptionID>#arguments.subscriptionID#<cfelse>NULL</cfif>
				, @OrderStatusID 			= <cfif arguments.orderStatusID>#arguments.orderStatusID#<cfelse>NULL</cfif>
				, @SubscriptionStatusID 	= <cfif arguments.subscriptionStatusID>#arguments.subscriptionStatusID#<cfelse>NULL</cfif>
				, @WorldpayTransactionID 	= <cfif arguments.worldpayTransactionID>#arguments.worldpayTransactionID#<cfelse>NULL</cfif>
		</cfquery>	

		<cfreturn arguments.OrderID>
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="CancelOrder" output="false" returntype="numeric" access="public" hint="Cancel an order that has had its payment cancelled or declined">
		<cfargument name="OrderID" 				type="numeric" required="yes">
		<cfargument name="OrderStatusID"     	type="numeric" required="yes"> 
		<cfargument name="WorldpayTransactionID"type="numeric" required="no" default="0">
		<cfargument name="UserID" 				type="numeric" required="yes">
		<cfargument name="IsRenewal" 			type="numeric" required="no" default="0">

		<cfset var qryCancelOrder = queryNew("temp")>

		<cfquery name="qryCancelOrder" datasource="#variables.dsn5#">
			EXEC usp_CancelOrder
				@OrderID = #arguments.orderID#
				, @OrderStatusID 			= <cfif arguments.orderStatusID>#arguments.orderStatusID#<cfelse>NULL</cfif>
				, @WorldpayTransactionID 	= <cfif arguments.worldpayTransactionID>#arguments.worldpayTransactionID#<cfelse>NULL</cfif>
				, @UserID					= #arguments.UserID#
				, @IsRenewal 				= <cfif arguments.IsRenewal>#arguments.IsRenewal#<cfelse>NULL</cfif>
		</cfquery>	

		<cfreturn arguments.OrderID>
		
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="SaveSubStatus" output="false" returntype="Numeric" access="public" hint="Save any changes to the status of an existing subscription">
		<cfargument name="SubscriptionID" 				type="numeric" 	required="yes">
		<cfargument name="SubscriptionStatusID" 		type="numeric" 	required="yes">
		<cfargument name="CurrentSubscriptionPeriodID" 	type="numeric" 	required="yes">
		<cfargument name="SubscriptionEndDate"			type="String"	required="yes">
		<cfargument name="isCurrent" 					type="string" 	required="no" default="">
		<cfargument name="notes" type="string" required="no" default="">
		
		<cfset var qrySaveSubStatus = queryNew("temp")>

		<cfquery name="qrySaveSubStatus" datasource="#variables.dsn5#">
			EXEC usp_SaveSubscriptionStatus
				@SubscriptionID 				= #arguments.SubscriptionID#
				, @SubscriptionStatusID 		= #arguments.SubscriptionStatusID#
				, @CurrentSubscriptionPeriodID 	= #arguments.CurrentSubscriptionPeriodID#
				, @SubscriptionEndDate			= #CreateODBCDate(DateFormat(arguments.SubscriptionEndDate,'dd/mm/yyyy'))#
				, @isCurrent 					= <cfif Len(trim(arguments.isCurrent))>#arguments.isCurrent#<cfelse>NULL</cfif>
				, @notes						= <cfif Len(trim(arguments.notes))>'#arguments.notes#'<cfelse>NULL</cfif>
		</cfquery>	
		
		<cfreturn arguments.SubscriptionID>

	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="SaveSubAdjustment" output="false" returntype="Numeric" access="public" hint="Save any changes to an existing subscription">
		<cfargument name="SubscriptionID" 				type="numeric" required="yes">
		<cfargument name="CurrentSubscriptionTypeID"	type="numeric" required="yes">
		<cfargument name="NewSubscriptionTypeID" 		type="numeric" required="yes">
		<cfargument name="OrderID" 						type="numeric" required="yes">
		
		<cfset var qrySaveSubAdjustment = queryNew("temp")>

		<cfquery name="qrySaveSubAdjustment" datasource="#instance.strConfig.strVars.dsn1#">
			EXEC usp_SaveSubAdjustment
				@SubscriptionID 				= #arguments.SubscriptionID#
				, @CurrentSubscriptionTypeID 	= #arguments.CurrentSubscriptionTypeID#
				, @NewSubscriptionTypeID 		= #arguments.NewSubscriptionTypeID#
				, @OrderID	 					= #arguments.OrderID#
		</cfquery>	
		
		<cfreturn arguments.SubscriptionID>

	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="SaveNewSubPeriod" output="false" returntype="Numeric" access="public" hint="Create a new subscription period for an existing subscription">
		<cfargument name="OrderID" 					type="numeric" 	required="true">
		<cfargument name="strSession" 				type="struct"	required="true"  hint="str of the session scope">
		<cfargument name="newStartDate"				type="string"	required="true">
		<cfargument name="newEndDate"				type="string"	required="true">
		<cfargument name="isCurrent"				type="numeric"	required="true">
		<cfargument name="SubscriptionID" 			type="numeric" 	required="true">
		<cfargument name="newSubscriptionStatusID" 	type="numeric" 	required="true">
		
		<cfset var qrySaveNewSubPeriod = queryNew("temp")>

		<cfquery name="qrySaveNewSubPeriod" datasource="#variables.dsn5#">
			EXEC usp_SaveNewSubPeriod
				@SubscriptionID 		= #arguments.SubscriptionID#
				, @SubscriptionStatusID = #arguments.newSubscriptionStatusID#
				, @ProductID 			= #arguments.strSession.strSubscribe.productID#
				, @OrderID	 			= #arguments.OrderID#
				, @StartDate			= #CreateODBCDate(DateFormat(arguments.newStartDate,'dd/mmm/yyyy'))#
				, @EndDate				= #CreateODBCDate(DateFormat(arguments.newEndDate,'dd/mmm/yyyy'))#
				, @IsCurrent			= #arguments.isCurrent#
				, @UserID				= #arguments.strSession.userDetails.UserID#
		</cfquery>
		
		<!--- <cfdump var="#arguments#"><cfabort> --->	
		
		<cfreturn arguments.SubscriptionID>

	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="GetOrderByID" output="false" returntype="query" access="public" hint="Get Order By ID">
		<cfargument name="OrderID" type="numeric" required="true">
		
		<cfset var qryGetOrderByID = queryNew("temp")>

		<cfquery name="qryGetOrderByID" datasource="#variables.dsn5#">
			EXEC usp_GetOrderByID
 				@OrderID = #arguments.OrderID#
		</cfquery>	
		
		<cfreturn qryGetOrderByID>
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="GetRateFromCampaign" output="false" returntype="query" access="public" hint="Get Order By ID">
		<cfargument name="CampaignCode" type="string" required="true">
		
		<cfset var qryRate = queryNew("temp")>

		<cfquery name="qryRate" datasource="#instance.strConfig.strVars.dsn1#">
			EXEC usp_GetRateFromCampaign
 				@CampaignCode = #arguments.CampaignCode#
		</cfquery>	
		
		<cfreturn qryRate>

	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="GetProducts" output="false" returntype="query" access="public" hint="Get available products">
		
		<cfset var qryGetProducts = queryNew("temp")>

		<cfquery name="qryGetProducts" datasource="#instance.strConfig.strVars.dsn1#">
			EXEC usp_GetProducts @VATRate = #instance.strConfig.strVars.vat_uk#
		</cfquery>	
		
		<cfreturn qryGetProducts>

	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="GetRenewalProducts" output="false" returntype="struct" access="public" hint="Get available products for RENEWALS only">
		<cfargument name="CurrentProductID"	type="numeric" required="true">
		
		<cfset var renewalProducts = StructNew()>
		
		<!--- Retrieve details about the user's current subscription product and other products available for renewal --->
		<cfstoredproc datasource="#instance.strConfig.strVars.dsn1#" procedure="usp_GetRenewalProducts" >
			<cfprocparam type="in" cfsqltype="cf_sql_integer" 	dbvarname="@CurrentProductID" 	value="#arguments.CurrentProductID#">
			<cfprocparam type="in" cfsqltype="CF_SQL_FLOAT"	 	dbvarname="@VATRate"			value="#instance.strConfig.strVars.vat_uk#">
			
			<cfprocresult resultset="1" name="renewalProducts.qryCurrentProduct">
			<cfprocresult resultset="2" name="renewalProducts.qryOtherProducts">
		</cfstoredproc>
		
		<cfreturn renewalProducts>

	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="GetRenewedSubscription" output="false" returntype="Query" access="public" hint="Get any renewed subscription periods for specified subscription">
		<cfargument name="SubscriptionID" type="numeric" required="true">
		
		<cfset var qryGetRenewedSub = queryNew("temp")>

		<cfquery name="qryGetRenewedSub" datasource="#instance.strConfig.strVars.dsn1#">
			EXEC usp_GetRenewedSub #arguments.SubscriptionID#
		</cfquery>
		
		<cfreturn qryGetRenewedSub>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	
	<cffunction name="search" output="false" returntype="Query" access="public" hint="Search for matching Orders using search parameters entered">		
		<cfargument name="OrderID" 		type="String" 	required="false" default="0">
		<cfargument name="Surname" 		type="string" 	required="false" default="">
		<cfargument name="email" 		type="string" 	required="false" default="">
		<cfargument name="DateStart" 	type="string"   required="false" default="">
		<cfargument name="DateEnd" 		type="string"   required="false" default="">
		<cfargument name="CompanyName"  type="string" 	required="true"  default="">
		<cfargument name="invoiceNo" 	type="string"   required="true"  default="">
		<cfargument name="productID" 	type="string"   required="false" default="0">
		<cfargument name="worldpayid" 	type="string" 	required="false" default="0">
		<cfargument name="Postcode" 	type="string" 	required="false" default="">
			
		<cfset var qryOrders = queryNew("temp")>
		
		<cfquery name="qryOrders" datasource="#variables.dsn5#">
			EXEC usp_SearchOrders
				@OrderID		= <cfif Len(arguments.OrderID) and arguments.OrderID NEQ '0'>#arguments.OrderID#<cfelse>NULL</cfif>,
				@Surname 		= <cfif Len(arguments.Surname)>'#arguments.Surname#' <cfelse>NULL</cfif>, 
				@email 			= <cfif Len(arguments.email)> '#arguments.email#'<cfelse>NULL</cfif>,
				@DateStart		= <cfif Len(arguments.DateStart)>#CreateODBCDate(DateFormat(arguments.DateStart, 'dd/mm/yyyy'))# <cfelse>NULL</cfif> ,
				@DateEnd		= <cfif Len(arguments.DateEnd)> #CreateODBCDate(DateFormat(arguments.DateEnd, 'dd/mm/yyyy'))#<cfelse>NULL</cfif>, 
				@CompanyName	= <cfif Len(arguments.CompanyName)>'#arguments.CompanyName#' <cfelse>NULL</cfif>, 
				@invoiceNo		= <cfif Len(arguments.invoiceNo)>'#arguments.invoiceNo# '<cfelse>NULL</cfif>,
				@productID		= <cfif Len(arguments.productID) and arguments.productID neq '0'> #arguments.productID#<cfelse>NULL</cfif>,
				@worldpayid		= <cfif Len(arguments.worldpayid) and arguments.worldpayid neq '0'> #arguments.worldpayid#<cfelse>NULL</cfif>,
				@Postcode		= <cfif Len(arguments.Postcode)>'#arguments.Postcode# '<cfelse>NULL</cfif>
		</cfquery> 
		
		<cfreturn qryOrders>
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="LookUps" output="false" returntype="Struct" access="public" hint="Get lookups for Orders">
		
		<cfset var strOrderLookups = StructNew()>
			
		<!--- Retrieve lookups associated with orders --->
		<cfstoredproc datasource="#instance.strConfig.strVars.dsn1#" procedure="usp_OrderLookUps">	
			<cfprocresult resultset="1" name="strOrderLookups.qryProducts">
			<cfprocresult resultset="2" name="strOrderLookups.qryOrderStatus">
			<cfprocresult resultset="3" name="strOrderLookups.qryBaseSeeds">
		</cfstoredproc>
		
		<cfreturn strOrderLookups>
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="ChangeOrderStatus" output="false" returntype="void" access="public" hint="Change the status of an existing Order">
		<cfargument name="orderID" 			type="numeric" required="yes">	
		<cfargument name="orderStatusID"	type="numeric" required="yes"> 

		<cfset var qryChangeOrderStatus = queryNew("temp")>

		<cfquery name="qryChangeOrderStatus" datasource="#instance.strConfig.strVars.dsn1#">
			EXEC usp_ChangeOrderStatus
				@OrderID = #arguments.orderID#
				, @OrderStatusID 			= #arguments.orderStatusID#
		</cfquery>
		
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="GetRateCards" output="false" returntype="query" access="public" hint="Get List of Rate Cards">
		<cfset var qryGetRateCards = queryNew("temp")>

		<cfquery name="qryGetRateCards" datasource="#instance.strConfig.strVars.dsn1#">
			EXEC usp_GetRateCards
		</cfquery>
		
		<cfreturn qryGetRateCards>
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="GetCampaignInfo" output="false" returntype="query" access="public" hint="Get Info on Specified Campaign Code">
		<cfargument name="CampaignID"	type="numeric" required="yes">
		<cfargument name="DefaultCode"	type="numeric" required="yes">
		
		<cfset var qryGetCampaignInfo = queryNew("temp")>

		<cfquery name="qryGetCampaignInfo" datasource="#variables.DSN5#">
			EXEC usp_GetCampaignInfo
				@CampaignID = <cfif arguments.CampaignID NEQ 0>#arguments.CampaignID#<cfelse>NULL</cfif>
				, @DefaultCode = #arguments.DefaultCode#
		</cfquery>
		
		<cfreturn qryGetCampaignInfo>
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="SaveCampaign" output="false" returntype="numeric" access="public" hint="Save Changes to an Existing or New Campaign">
		<cfargument name="CampaignID"    	type="numeric"	required="yes">
		<cfargument name="CampaignCode"		type="string"	required="yes">
		<cfargument name="Campaign"			type="string"	required="yes">
		<cfargument name="RateCardID"		type="numeric"	required="yes">
		<cfargument name="DefaultCode"		type="numeric"	required="yes">
		
		<cfstoredproc procedure="usp_SaveCampaign" datasource="#instance.strConfig.strVars.dsn1#" returncode="yes">
			
			<cfif arguments.CampaignID EQ "0">
				<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@CampaignID"		value="" null="true">
			<cfelse>
				<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@CampaignID"		value="#arguments.CampaignID#">
			</cfif>
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" 		dbvarname="@CampaignCode" 	value="#arguments.CampaignCode#">
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" 		dbvarname="@Campaign"		value="#arguments.Campaign#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer"  	dbvarname="@RateCardID"		value="#arguments.RateCardID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer"  	dbvarname="@DefaultCode"	value="#arguments.DefaultCode#">

			<cfprocparam type="out" cfsqltype="cf_sql_integer" 	dbvarname="@NewID" 	variable="CampaignID">

		</cfstoredproc>
		
		<cfreturn CampaignID>
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	
	<cffunction name="OrderReport" output="false" returntype="query" access="public" hint="Runs a full report on orders placed">
		<cfargument name="productID" type="numeric" required="yes">
		<cfargument name="dateStart" type="date" required="yes">
		<cfargument name="dateEnd" type="date" required="yes">
		
		<cfset var qryOrderReport = queryNew("temp")>

		<cfquery name="qryOrderReport" datasource="#variables.DSN5#">
			EXEC usp_rpt_orderReport
				@prodID = '#arguments.productID#'
				, @start = '#lsdateformat(arguments.dateStart, 'dd-mmm-yyyy')#'
				, @end = '#lsdateformat(arguments.dateEnd, 'dd-mmm-yyyy')#'
		</cfquery>
		
		<cfreturn qryOrderReport>		
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="saveOrderNotes" output="false" access="public" hint="Save order notes">
		<cfargument name="notes" type="string" required="yes">
		<cfargument name="orderid" type="numeric" required="yes">
		
		<cfstoredproc datasource="#variables.dsn5#" procedure="usp_saveOrderNotes" >
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@orderid" value="#arguments.orderid#">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="@notes" value="#arguments.notes#">
		</cfstoredproc>
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="uuidOrderCheck" output="false" returntype="query" access="public" hint="">
		<cfargument name="uuid" type="string" required="yes">
				
		<cfset var qryUuidOrderCheck = queryNew("temp")>

		<cfquery name="qryUuidOrderCheck" datasource="#variables.DSN5#">
			EXEC usp_uuidOrderCheck
				@uuid = '#arguments.uuid#'
		</cfquery>
		
		<cfreturn qryUuidOrderCheck>	
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getPriceByCampaign" output="false" returntype="query" access="public" hint="">
		<cfargument name="campaginCode" 	type="string" 	required="yes">
		<cfargument name="productID" 		type="numeric" 		required="yes">
		<cfargument name="TermID" 			type="string" 	required="no" default="">
				
		<cfset var q = queryNew("temp")>

		<cfquery name="q" datasource="#variables.DSN8#">
			usp_GetPriceByCampaign 
				@CampaignCode = '#arguments.campaginCode#',
				@productID	  = #arguments.productID#
				<cfif LEN(arguments.TermID) AND IsNumeric(arguments.TermID)>
					, @TermID = #arguments.TermID#
				</cfif>
		</cfquery>
		
		<cfreturn q>	
	</cffunction>
</cfcomponent>