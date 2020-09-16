<cfcomponent extends="his_Localgov_Extends.components.DAOManager" displayname="LRDirectDAO">
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="LRDirectDAO" hint="Pseudo-constructor">
		
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>	
		structAppend( variables, Super.init( arguments.strConfig ) );

		return this;
		</cfscript>
		
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
	<cffunction name="getExistingOrders" access="public" output="no" returntype="query">
		<cfargument name="userid" 		 type="numeric" required="yes">
        <cfargument name="orderStatusID" type="numeric" required="no" default="0">
		
		<cfset var qryOrders = querynew('temp')>
			
		<cfquery name="qryOrders" datasource="#variables.dsn5#">
			exec usp_getLRDorders @userid = #arguments.userid# <cfif arguments.orderStatusID neq 0 >, @orderStatusID = #arguments.orderStatusID#</cfif>
		</cfquery>
		
		<cfreturn qryOrders>
	</cffunction>
    
    
    <!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
    <cffunction name="deleteTemplate" access="public" output="false" deleteTemplate>
    	
        <cfargument name="id" type="numeric" >
			
		<cfquery  datasource="#variables.dsn5#">
			exec usp_LRDDeleteTemplate #arguments.id#
		</cfquery>
		
        
	</cffunction>
    
    
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="saveDirectTemplate" access="public" output="false" returntype="numeric" hint="">		
		<cfargument name="userid" type="numeric" required="yes">
		<cfargument name="templateid" type="numeric" required="no" default="0">
		<cfargument name="tempName" type="string" required="yes">
		<cfargument name="tempCont" type="string" required="yes">
        <cfargument name="replyAddress" type="string" required="yes">
		
		<cfset var id=0>
        
        <cfstoredproc datasource="#variables.dsn5#" procedure="usp_saveDSDTemplate">
        	<cfif arguments.templateid neq 0>
            	<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@tempid" 	value="#arguments.Templateid#">
            <cfelse>
            	<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@tempid" 	value="#arguments.Templateid#" null="yes">
            </cfif>
            
            <cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@userid" 		value="#arguments.userid#">
            <cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@tempName" 		value="#arguments.tempName#">
            <cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@tempCont" 		value="#arguments.tempCont#">
           <cfif LEN(replyAddress)>
            <cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@replyAddress" 	value="#arguments.replyAddress#">
              <cfelse>
            	 <cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@replyAddress" 	value="#arguments.replyAddress#" null="yes">
            </cfif>
        	<cfprocparam type="out" cfsqltype="cf_sql_integer" 	dbvarname="@NewTemplateID" 	variable="id"> 
        
        </cfstoredproc>
        
        <cfreturn id>
        
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getDirectLists" access="public" output="false" returntype="query">
    	
        <cfset var qryLists = querynew('temp')>
			
		<cfquery name="qryLists" datasource="#variables.dsn1#">
			exec usp_getDirectSetLists
		</cfquery>
		
		<cfreturn qryLists>
        
	</cffunction>
	
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getDeDupedCount" access="public" output="no" returntype="query">
		<cfargument name="listIDs" type="string" required="yes">
		
		<cfset var qryCounts = querynew('temp')>
			
		<cfquery name="qryCounts" datasource="#variables.dsn2#">
			exec sp_DS_GetNumberEmailaddress @setListID = '#arguments.listIDs#'
		</cfquery>
		
		<cfreturn qryCounts>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="commitOrder" output="false" returntype="numeric" hint="Commits order header">		
		<cfargument name="Templateid" 			type="numeric" required="yes">
        <cfargument name="userID" 				type="numeric"  required="yes">
		<cfargument name="paymentMethod"		type="string"  required="no" default="1">
		<cfargument name="abOrderPrice"			type="string"  required="yes">
        <cfargument name="ProductID" 			type="numeric" 	required="no" default="6">
		<cfargument name="ComponentQuantity" 	type="numeric" 	required="no" default="1">
		<cfargument name="ComponentID"			type="numeric"  required="no" default="0">
		<cfargument name="ListPrice"			type="string"  	required="yes"> 
		<cfargument name="ProductPercentage"	type="string"  	required="no" default="100"> 
		<cfargument name="TermPrice"			type="string"  	required="yes">	
		<cfargument name="VATRate"				type="string"  	required="yes"> 
		<cfargument name="DiscountedPrice"		type="string"  	required="yes"> 
		<cfargument name="AbsolutePrice"		type="string"  	required="yes"> 
		<cfargument name="VATAmount"			type="string"  	required="yes"> 
		<cfargument name="isInvoiceable"		type="numeric"  required="no" default="1">
				
		<cfset var orderID= 0>
        
		<cfstoredproc datasource="#variables.DSN5#" procedure="usp_Save_LRD_Order" >
        	<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@Templateid" 		value="#arguments.Templateid#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@UserId" 			value="#arguments.userID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@PaymentMethod"	 	value="#arguments.paymentMethod#">
			<cfprocparam type="in" 	cfsqltype="cf_sql_float" 	dbvarname="@abOrderPrice" 		value="#arguments.abOrderPrice#">
            <cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@ProductID" 			value="#arguments.productID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@Quantity" 			value="#arguments.ComponentQuantity#">
			<cfprocparam type="in" 	cfsqltype="cf_sql_integer" 	dbvarname="@ComponentID" 		value="#arguments.ComponentID#">			
			<cfprocparam type="in" 	cfsqltype="cf_sql_money" 	dbvarname="@ListPrice" 			value="#arguments.ListPrice#"> 			
			<cfprocparam type="in" 	cfsqltype="cf_sql_float" 	dbvarname="@ProductPercentage" 	value="#arguments.ProductPercentage#"> 	
			<cfprocparam type="in" 	cfsqltype="cf_sql_money" 	dbvarname="@TermPrice" 			value="#arguments.TermPrice#">			
			<cfprocparam type="in" 	cfsqltype="cf_sql_float" 	dbvarname="@VATRate" 			value="#arguments.VATRate#"> 
			<cfprocparam type="in" 	cfsqltype="cf_sql_money" 	dbvarname="@DiscountedPrice" 	value="#arguments.DiscountedPrice#"> 
			<cfprocparam type="in" 	cfsqltype="cf_sql_money" 	dbvarname="@AbsolutePrice" 		value="#arguments.AbsolutePrice#"> 
			<cfprocparam type="in" 	cfsqltype="cf_sql_money" 	dbvarname="@VATAmount" 			value="#arguments.VATAmount#"> 
			<cfprocparam type="in" 	cfsqltype="cf_sql_bit" 		dbvarname="@isInvoiceable" 		value="#arguments.isInvoiceable#"> 
			<cfprocparam type="out" cfsqltype="cf_sql_integer" 	dbvarname="@OrderID" 			variable="orderID"> 
		</cfstoredproc>
		
		<cfreturn orderID>
	
	</cffunction>
	
    
    <!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------- --->
	<cffunction name="updateOrderLine" output="false" returntype="void" hint="upidate order line with wddx">	
    	<cfargument name="OrderID" 				type="numeric" 	required="yes">	
        <cfargument name="dataSalesXML"			type="string"  	required="yes">
        
        <cfstoredproc datasource="#variables.DSN5#" procedure="usp_Update_LRD_Orderline" >
        	
        	<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@OrderID" 			value="#arguments.OrderID#">
			<cfprocparam type="in"  cfsqltype="cf_sql_varchar" 	dbvarname="@DataSalesXML"	 	value="#arguments.dataSalesXML#">
        </cfstoredproc>
    </cffunction>    
    
    <!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------- --->
	<cffunction name="orderDetails" access="public" output="false" returntype="struct" hint="get order detail and email stats">	
    	<cfargument name="TemplateId" 		type="numeric" required="yes">
        <cfargument name="Userid" 		type="numeric" required="yes">
        
        <cfset var s = structNew()>
        
        <cfstoredproc datasource="#variables.DSN5#" procedure="usp_Get_LRD_OrderDetail" >
        	<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@Templateid" 	value="#arguments.Templateid#">
            <cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@Userid" 		value="#arguments.Userid#">
        	<cfprocresult name="s.qryOrder" resultset="1">
            <cfprocresult name="s.qryStats" resultset="2">
        </cfstoredproc>
        
        <cfreturn s>
    </cffunction>    
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- --------------------------------------------------------------------------------------------------
	<cffunction name="commitOrderLine" output="false" returntype="numeric" hint="Commits order line">		
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
	
	</cffunction>--->
    
    <!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
    <cffunction name="SaveListToTemplate" output="false" returntype="void" hint="Attach List Rental Direct Template to  List">		
		<cfargument name="TemplateId" 		type="numeric" required="yes">
		<cfargument name="listIds"			type="string"  required="yes">
		<cfargument name="Orderid"			type="numeric" >
	

		<cfstoredproc datasource="#variables.DSN5#" procedure="usp_LRDSaveTemplatelists" >
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@TemplateId" 	value="#arguments.TemplateId#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@OrderID"	 	value="#arguments.Orderid#">
			<cfprocparam type="in"  cfsqltype="CF_SQL_VARCHAR" 	dbvarname="@listIds"		value="#arguments.listIds#">
		</cfstoredproc>
	
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="updateOrder" output="false" returntype="numeric" access="public" hint="Update the Order and subscription status">
		<cfargument name="orderID" 				type="numeric" required="yes">	
		<cfargument name="orderStatusID"     	type="numeric" required="no" default="0">
		<cfargument name="worldpayTransactionID"type="numeric" required="no" default="0">
		<cfargument name="dsxml" type="string" required="no" default="">

		<cfset var qryUpdateOrder = queryNew("temp")>

		<cfquery name="usp_UpdateLRDOrder" datasource="#variables.dsn5#">
			EXEC usp_UpdateLRDOrder
				@OrderID = #arguments.orderID#
				, @OrderStatusID 			= <cfif arguments.orderStatusID>#arguments.orderStatusID#<cfelse>NULL</cfif>
				, @WorldpayTransactionID 	= <cfif arguments.worldpayTransactionID>#arguments.worldpayTransactionID#<cfelse>NULL</cfif>
				, @datasalesxml = <cfif len(arguments.dsxml)>'#arguments.dsxml#'<cfelse>NULL</cfif>
		</cfquery>	

		<cfreturn arguments.OrderID>
	</cffunction>
	
	
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getWaitingDirectOrders" access="public" returntype="query">
		<cfset var qryQueue = querynew('temp')>
			
		<cfquery name="qryQueue" datasource="#variables.dsn5#">
			exec usp_getWaitingLRDOrders
		</cfquery>
		
		<cfreturn qryQueue>
	</cffunction>
	
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="populateQueue" access="public" returntype="void" output="no">
		<cfargument name="orderid" type="numeric" required="yes">
		<cfargument name="templateid" type="numeric" required="yes">
	
		<cfstoredproc datasource="#variables.DSN5#" procedure="usp_populateLRDQueue" returncode="yes">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@orderid" 	value="#arguments.orderid#">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@templateid"	value="#arguments.templateid#">
			
		</cfstoredproc>
	</cffunction>
	
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="TPEoutout" access="public" returntype="void" output="no">
		<cfargument name="recipient" type="string" required="yes">
		
		<cfstoredproc datasource="#variables.DSN2#" procedure="sp_DS_OptOutTPE" returncode="no">
			<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" dbvarname="@email" value="#arguments.recipient#" null="no">
		</cfstoredproc>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="webbug" access="public" output="no" returntype="void">
		<cfargument name="id" type="numeric" required="yes">
		
		<cfstoredproc datasource="#variables.DSN5#" procedure="usp_setLRDirectEmailOpened" returncode="no">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@id" value="#arguments.id#" null="no">
		</cfstoredproc>
	</cffunction>
	
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getEmailsToGen" access="public" returntype="query" output="false">
		<cfset var qryGenList = querynew("temp")>
					
		<cfquery datasource="#variables.DSN5#" name="qryGenList" maxrows="200">
			EXEC usp_getLRDToGenerate
		</cfquery>
					
		<cfreturn qryGenList>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getEmailsToSend" access="public" returntype="query" output="false">
		<cfset var qrySendList = querynew("temp")>
					
		<cfquery datasource="#variables.DSN5#" name="qrySendList" maxrows="200">
			EXEC usp_getLRDEmailsToSend
		</cfquery>
					
		<cfreturn qrySendList>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="setAsSent" access="public" returntype="void">
		<cfargument name="id" type="numeric" required="yes">
		
		<cfstoredproc datasource="#variables.DSN5#" procedure="usp_setLRDEmailAsSent" returncode="no">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@lrdqid" value="#arguments.id#" null="no">
		</cfstoredproc>
	</cffunction>
	
    <!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
    <cffunction name="UpdateTemplateStatus" access="public" returntype="void">
		<cfargument name="TemplateID" type="numeric" required="yes">
        <cfargument name="StatusID" type="numeric" required="yes">
		
		<cfstoredproc datasource="#variables.DSN5#" procedure="dbo.usp_LRD_UpdateTemplateStatus" returncode="no">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@TemplateID" value="#arguments.TemplateID#" >
            <cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname="@StatusID" value="#arguments.StatusID#" >
		</cfstoredproc>
	</cffunction>
    
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="saveGeneratedCopy" access="public" returntype="void" output="no">
		<cfargument name="lrdqid" type="numeric" required="yes">
		<cfargument name="subject" type="string" required="yes">
		<cfargument name="body" type="string" required="yes">
		<cfargument name="from" type="string" required="yes">
		<cfargument name="reply" type="string" required="yes">
		
		<cfstoredproc datasource="#variables.DSN5#" procedure="usp_saveGeneratedLRD" returncode="no">
			<cfprocparam type="in"  cfsqltype="cf_sql_integer" 	dbvarname="@lrdqID" 	value="#arguments.lrdqid#">
			<cfprocparam type="in"  cfsqltype="CF_SQL_VARCHAR" 	dbvarname="@subject"	value="#arguments.subject#" null="no">
			<cfprocparam type="in"  cfsqltype="CF_SQL_VARCHAR" 	dbvarname="@body"	value="#arguments.body#" null="no">
			<cfprocparam type="in"  cfsqltype="CF_SQL_VARCHAR" 	dbvarname="@from"	value="#arguments.from#" null="no">
			<cfprocparam type="in"  cfsqltype="CF_SQL_VARCHAR" 	dbvarname="@reply"	value="#arguments.reply#" null="no">
		</cfstoredproc>
	</cffunction>
	
</cfcomponent>