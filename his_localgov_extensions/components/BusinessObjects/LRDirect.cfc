<cfcomponent extends="his_Localgov_Extends.components.BusinessObjectsManager" displayname="LRDirect">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="LRDirect" hint="Pseudo-constructor">
	
		<cfargument name="objAppObjs" type="any" required="yes" hint="The application manager object">
		<cfargument name="objBusObjs" type="any" required="yes" hint="The business object">

		<cfscript>
		// Call the genric init function, placing business, app, and dao objects into a local scope...
		StructAppend( variables, Super.initChild( arguments.objAppObjs, this, arguments.objBusObjs ) );
		
		//variables.qrySetLists = getSetLists();
		
		return this;
		</cfscript>
		
	</cffunction>
    
    <!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getDirectTemplates" access="public" returntype="query" output="false" hint="">
		<cfargument name="userid" type="numeric" required="yes">
		<cfargument name="templateid" type="numeric" required="no" default="0">
		
		<cfscript>
			return objDAO.getDirectTemplates(userid = arguments.userid, templateid = arguments.templateid);	 
		</cfscript>
		
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getExistingOrders" access="public" returntype="query" output="false" hint="">
		<cfargument name="userid" 		 type="numeric" required="yes">
        <cfargument name="orderStatusID" type="numeric" required="no" default="0">
		
		<cfscript>
			return objDAO.getExistingOrders(userid = arguments.userid, orderStatusID=arguments.orderStatusID);
		</cfscript>		
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="saveDirectTemplate" access="public" output="false" returntype="numeric" hint="">		
		<cfargument name="userid" 		type="numeric" required="yes">
		<cfargument name="templateid" 	type="numeric" required="no" default="0">
		<cfargument name="tempName" 	type="string" required="yes">
		<cfargument name="tempCont" 	type="string" required="yes">
        <cfargument name="replyAddress" type="string" required="yes">
		
		<cfreturn objDAO.saveDirectTemplate(argumentCollection = arguments)>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- TEMP FUNCTION --------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->		
	<cffunction name="genInitialOptoutEmail" access="public" output="no" returntype="void">
		<cfscript>
			var qryEmails = objDAO.getEmailsToGen();
			
			for(e = 1; e lte qryEmails.recordcount; e = e+1)
			{
				prebody = qryEmails.templateContent[e];
				sendTo = qryEmails.sendTo[e];
				lrdqid = qryEmails.LRDQueueID[e];
				subject = qryEmails.templateName[e];
				
				body = replacenocase(prebody, '|name|', qryEmails.tempName[e]);
				body = replacenocase(body, '|email|', sendTo);
				
				objDAO.saveGeneratedCopy(lrdqid, subject, body, 'mybemailservice@localgov.co.uk', 'mybemailservice@hgluk.com');
			}
		</cfscript>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="prepareEmail" access="public" output="no" returntype="string">
		<cfargument name="content" 	type="string" required="yes">
		<cfargument name="recip" 	type="string" required="yes">
		<cfargument name="id" 		type="numeric" required="no" default="0">
        <cfargument name="webBug" 	type="bool" required="no"    default="true">
        
	
		<cfset var retBody = '<div style="width:100%;height:auto;">'>
		<cfset retBody = retBody & content>
		<cfset retBody = retBody & '</div>
									<br><br>
									<div>
										<p>Email sent via MYB List Rental Direct service.  To opt-out of all further third party emails <a href="http://services.localgov.co.uk/services/LRDirect.cfc?method=TPEoptout&recipient=#arguments.recip#">click here</a></p>
									</div>'>
       <cfif webBug>
       	<cfset retBody = retBody & '<img src="http://services.localgov.co.uk/services/LRDirect.cfc?method=webBug&id=#arguments.id#" />'>
       </cfif>                             
		
		<cfreturn retBody>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="genQueueCopy" access="public" output="no" returntype="void">		
		<cfscript>
			
			var qryEmails = objDAO.getEmailsToGen();
			var lastorder = 0;
			
			for(e = 1; e lte qryEmails.recordcount; e = e+1)
			{
				prebody = qryEmails.templateContent[e];
				sendTo = qryEmails.sendTo[e];
				lrdqid = qryEmails.LRDQueueID[e];
				subject = qryEmails.templateName[e];
				
				body = prepareEmail(content = prebody, recip = sendTo, id = lrdqid);				
				
				objDAO.saveGeneratedCopy(lrdqid, subject, body, 'myb@hgluk.com', 'myb@hgluk.com');
				
				if (lastorder neq qryEmails.orderid[e])
				{
					strLRDOrder = objUtils.wddx(whattodo = 'wddx2cfml', dataInput = qryEmails.datasalesxml[e]);
				
					strLRDOrder.stage = 4;
					strLRDOrder.status = 'Email Copy Generating';
			
					wddx = objUtils.wddx(whattodo = 'cfml2wddx', dataInput = strLRDOrder);
			
					objDAO.updateOrder(orderid = qryEmails.orderid[e], dsxml = wddx);
				}
				
				lastorder = qryEmails.orderid[e];
			}
			
		</cfscript>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="processLRDQueue" access="public" output="no" returntype="void">
		
		<cfset var qryEmails = objDAO.getEmailsToSend()>
		
		<cfloop query="qryEmails">
			
			<cfset request.objbus.objEmail.sendNLQueue(to=qryEmails.sendTo,
												body=qryEmails.body,
												subject=qryEmails.subjectLine,
												from=qryEmails.fromAddress,
												includeHeaders=false,
												reply=qryEmails.replyAddress)>
												
			<cfset objDAO.setAsSent(qryEmails.LRDQueueID)>			
		</cfloop>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="TPEoptout" access="public" output="no" returntype="void">
		<cfargument name="recipient" type="string" required="yes">
		
		<cfset objDAO.TPEoutout(arguments.recipient)>		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="webbug" access="public" output="no" returntype="void">
		<cfargument name="id" type="numeric" required="yes">
		
		<cfset objDAO.webbug(arguments.id)>
	</cffunction>
	
	
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="createOrder" access="public" output="no" returntype="struct">
		<cfargument name="strAtts" type="struct" required="yes">
		<cfargument name="strSess" type="struct" required="yes">
		
		<cfscript>
			var strLRDOrder = structnew();
			var VATRate = strConfig.StrVars.vat_uk / 100;		
			
			strLRDOrder.userID = strSess.userdetails.userid;
			strLRDOrder.orderCreated = now();
			strLRDOrder.templateID = strAtts.templateid;
			strLRDOrder.listIDs = strAtts.listTypeIDs;
			strLRDOrder.offerCode = strAtts.offCode;			
			strLRDOrder.stage = 0;
			
			// Run the query to get de-duped counts
			qryDeDuped = objDAO.getDeDupedCount(strLRDOrder.listIDs);
			if(qryDeDuped.recordcount eq 1)
			{
				strLRDOrder.preDupeCount = qryDeDuped.numEmails[1];
				strLRDOrder.finalCount = qryDeDuped.NumUniques[1];
				
				strLRDOrder.preDiscountTotal = strConfig.StrVars.lrdcostperrecord * strLRDOrder.finalCount;
				
				// Check for entered campaign code
				codeDiscount = 0;
				if(len(trim(strLRDOrder.offerCode)))
				{
					qryCost = request.objBus.objOrders.getPriceByCampaign(strLRDOrder.offerCode, 28);
					if(qryCost.recordcount)
					{
						itemCost = qryCost.price[1];
						codeDiscount = 100-((itemCost/strConfig.StrVars.lrdcostperrecord)*100);
					}
				}
				
				// Work out the totals based on discounts
				if(codeDiscount gt strConfig.StrVars.ds_percentdiscount or (arguments.strSess.userdetails.usertypeid lte 2 and codeDiscount gt 0))
				{
					strLRDOrder.discount 			= strLRDOrder.preDiscountTotal * (codeDiscount / 100);
					//calculate discount
					strLRDOrder.TotalAfterDiscount = strLRDOrder.preDiscountTotal - strLRDOrder.discount;										
				}
				else if (arguments.strSess.userdetails.usertypeid gt 2)
				{
					//set discount value
					strLRDOrder.discount 			= strLRDOrder.preDiscountTotal * (strConfig.StrVars.ds_percentdiscount / 100) ;
					//calculate discount
					strLRDOrder.TotalAfterDiscount = strLRDOrder.preDiscountTotal - strLRDOrder.discount;
				}
				else
				{	
					strLRDOrder.discount			= 0;
					strLRDOrder.TotalAfterDiscount = strLRDOrder.preDiscountTotal;
				}
				
				// Add VAT if user in in the UK
				if	(arguments.strSess.userdetails.countryid eq 1)
					strLRDOrder.VAT = strLRDOrder.TotalAfterDiscount * VATRate;
				else
					strLRDOrder.VAT = 0;
				
				strLRDOrder.finalTotal = strLRDOrder.TotalAfterDiscount + strLRDOrder.VAT;
				strLRDOrder.finalTotal = ((round(strLRDOrder.finalTotal*100))/100);
				strLRDOrder.stage = 1; // Order being written pre payment
								
				/*// Save the order header/details and get ready for worldpay
				strLRDOrder.orderid = objDAO.commitOrder(strLRDOrder.userID, 1, '', strLRDOrder.finalTotal);
				
				// write the order line				
				thewddx = objUtils.createWDDXPacket(dataInput = strLRDOrder);
				objDAO.commitOrderLine(
										OrderID = strLRDOrder.orderid,
										ProductID = 6,
										ComponentQuantity = 1,
										dataSalesXML = thewddx,
										ComponentID	= 0,
										ListPrice = strLRDOrder.preDiscountTotal,
										ProductPercentage = 100,
										TermPrice = strLRDOrder.preDiscountTotal,
										VATRate	= strConfig.StrVars.vat_uk,
										DiscountedPrice = strLRDOrder.TotalAfterDiscount,
										AbsolutePrice = strLRDOrder.TotalAfterDiscount,
										VATAmount = strLRDOrder.VAT,	
										isInvoiceable = 1
										);
				// I don't know why this isn't set as default but there you go
				objDAO.updateOrder(orderID = strLRDOrder.orderid, orderStatusID = 1);
				*/
				
				strLRDOrder.orderid =CommitOrder(strAtts.templateid,strLRDOrder.userID,strLRDOrder.finalTotal,strLRDOrder.preDiscountTotal,strLRDOrder.TotalAfterDiscount,strLRDOrder.VAT);
				// update the orderline to contain wddx packet		
				thewddx = objUtils.createWDDXPacket(dataInput = strLRDOrder);
				///update orderline with wddx packet
				updateOrderLine(strLRDOrder.orderid ,thewddx);
				
				
				strLRDOrder.stage = 2; // Order successfully written, off to payment
				arguments.strSess.strLRDOrder = strLRDOrder;
				
				CreateDataSalesPurchaser(arguments.strSess);
				
				SaveListToTemplate(strAtts.templateid, strLRDOrder.listIDs, strLRDOrder.orderid);
			}
			else
			{
				strLRDOrder.stage = -1;
				strLRDOrder.error = 'No List counts could be found';
			}
			
			return strLRDOrder;
		</cfscript>
	</cffunction>
    
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
      <cffunction name="CommitOrder" access="private" returntype="numeric">
    		<cfargument name="templateID" 			required="yes" type="numeric">
            <cfargument name="userid" 				required="yes" type="numeric">
            <cfargument name="finalTotal" 			required="yes" type="string">
            <cfargument name="preDiscountTotal" 	required="yes" type="string">
            <cfargument name="TotalAfterDiscount" 	required="yes" type="string">
            <cfargument name="VATAmount" 			required="yes" type="string">
            
            <cfscript>
            	// Save the order header/details and get ready for worldpay
				return objDAO.commitOrder(Templateid = arguments.Templateid, 	
										userID = arguments.userID, 
										abOrderPrice = arguments.finalTotal,
										ListPrice = arguments.preDiscountTotal,
										TermPrice = arguments.preDiscountTotal,
										VATRate	= strConfig.StrVars.vat_uk,
										DiscountedPrice = arguments.TotalAfterDiscount,
										AbsolutePrice = arguments.TotalAfterDiscount,
										VATAmount = arguments.VATAmount	
										);
										
            </cfscript>
    	
    </cffunction>
    
    <!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------- --->
	<cffunction name="updateOrderLine" output="false" returntype="void" hint="upidate order line with wddx">	
    	<cfargument name="OrderID" 				type="numeric" 	required="yes">	
        <cfargument name="dataSalesXML"			type="string"  	required="yes">
        
        <cfset objDAO.updateOrderLine(arguments.OrderID, arguments.dataSalesXML)>	
      
    </cffunction>   
    
    <!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
    <cffunction name="SaveListToTemplate" output="false" returntype="void" hint="Attach List Rental Direct Template to  List">		
		<cfargument name="TemplateId" 		type="numeric" required="yes">
		<cfargument name="listIds"			type="string"  required="yes">
		<cfargument name="Orderid"			type="numeric" >
	

		 <cfset objDAO.SaveListToTemplate(arguments.TemplateId, arguments.listIds, arguments.Orderid)>	
	
	</cffunction>
    
    <!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
    <cffunction name="orderDetails" output="false" returntype="struct" hint="get order details">		
		<cfargument name="TemplateId" 		type="numeric" required="yes">
        <cfargument name="userid" 			type="numeric" required="yes">

		 <cfreturn objDAO.orderDetails(arguments.TemplateId, arguments.userid)>	
	
	</cffunction>
    
     <!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------- --->
    
	<cffunction name="callback" access="public" output="no" returntype="struct">
		<cfargument name="strAtts" type="struct" required="yes" hint="form scope posted by RBS Worldpay">
		
		<cfscript>
			var strResult = structnew();
			var invoiceFileName = "";
			strResult.error = 0;
			strResult.message = 'Unprocessed - THIS SHOULD NEVER APPEAR';
			
		
			if (structkeyexists(strAtts, 'transStatus') and strAtts.transStatus eq 'Y')
			{
				// Success!
				strOrderDetail = request.objBus.objOrders.getOrderDetail(strAtts.cartId);
				
				//ensure the amount paid is correct and the order belongs to this user!
				if(strOrderDetail.qryOrder.AbsoluteOrderPrice[1] eq strAtts.authAmount and strOrderDetail.qryOrder.userid[1] eq strAtts.M_UserID)
				{
					// Create the invoice
					invoiceFileName = request.objBus.objInvoice.saveInvoiceData(strAtts.cartId, strAtts.M_UserID, 6);
					// Set the order as paid!
					objDAO.updateOrder(orderID = strAtts.cartId, orderStatusID = 2, worldpayTransactionID = strAtts.transId);
					
					strResult.message = 'Order Completed OK';
					strResult.error = 0;
					//email user with confirmation
					emailOrder(strAtts.M_templateid, strAtts.cartId, invoiceFileName, strAtts.email );
					
				}
				else
				{
					objDAO.updateOrder(orderID = strAtts.cartId, orderStatusID = 3, worldpayTransactionID = strAtts.transId);
					strResult.message = 'Amount or user did not match';
					strResult.error = 1;
				}
			}
			else
			{
				// Failure!
				objDAO.updateOrder(orderID = strAtts.cartId, orderStatusID = 3, worldpayTransactionID = strAtts.transId);
				strResult.message = 'Payment Failed';
				strResult.error = 1;
			}
			
			return strResult;
		</cfscript>
	</cffunction>
	
    
	<cffunction name="getWaitingDirectOrders" access="public" returntype="query">
		<cfreturn objDAO.getWaitingDirectOrders()>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getDirectLists" access="public" output="false" returntype="query">    	
        <cfreturn objDAO.getDirectLists()>        
    </cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="approveLRDOrder" access="public" output="no" returntype="void">
		<cfargument name="orderid" type="numeric" required="yes">
		
		<cfscript>
			var qryOrder = request.objBus.objOrders.GetOrderByID(arguments.orderid);
			var strLRDOrder = objUtils.wddx(whattodo = 'wddx2cfml', dataInput = qryOrder.DataSalesXml[1]);
			
			UpdateTemplateStatus(strLRDOrder.TemplateID, 2);
			
			strLRDOrder.stage = 3;
			strLRDOrder.status = 'Approved, queue populated for sending';
			strLRDOrder.dateApproved = now();
			
			wddx = objUtils.wddx(whattodo = 'cfml2wddx', dataInput = strLRDOrder);
			
			objDAO.updateOrder(orderid = arguments.orderid, dsxml = wddx);			
		</cfscript>
	</cffunction>
    
    <!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
    <cffunction name="UpdateTemplateStatus" access="public" returntype="void">
		<cfargument name="TemplateID" type="numeric" required="yes">
        <cfargument name="StatusID" type="numeric" required="yes">
		<cfset objDAO.UpdateTemplateStatus(arguments.TemplateID, arguments.StatusID)>
		
	</cffunction>
    
    
    <!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
    <cffunction name="populateQueue" access="public" output="no" returntype="void">
    	<cfargument name="orderid" 		type="numeric" required="yes">
        <cfargument name="templateid" 	type="numeric" required="yes">
       
        	<cfset objDAO.populateQueue(orderid = arguments.orderid, templateid = arguments.templateid)>
    </cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="rejectLRDOrder" access="public" output="no" returntype="void">
		<cfargument name="orderid" type="numeric" required="yes">
		
		<cfscript>
			var qryOrder = request.objBus.objOrders.GetOrderByID(arguments.orderid);
			var strLRDOrder = objUtils.wddx(whattodo = 'wddx2cfml', dataInput = qryOrder.DataSalesXml[1]);
			
			UpdateTemplateStatus(strLRDOrder.TemplateID, 3);
			
			strLRDOrder.stage = 3;
			strLRDOrder.status = 'Rejected, your email template has not been approved for sending.';
			strLRDOrder.dateRejected = now();
			
			wddx = objUtils.wddx(whattodo = 'cfml2wddx', dataInput = strLRDOrder);
			
			objDAO.updateOrder(orderid = arguments.orderid, dsxml = wddx);
		</cfscript>
	</cffunction>
    
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PRIAVTE Functions ----------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="CreateDataSalesPurchaser" access="private" output="false" returntype="void">
		<cfargument name="strSession"	type="struct"  	required="yes">
		
		<cfscript>
		var qryUserDetails=objUser.getUserDetailsByID(arguments.strSession.userDetails.userID);
		// Store the logged in users details in the 'dataSalePurchaser' session structure
		if (structKeyExists(arguments.strSession.userDetails, 'userID')) {
			arguments.strSession.dataSalePurchaser				= structNew();
			arguments.strSession.dataSalePurchaser.name			= qryUserDetails.SALUTATION & " " & qryUserDetails.FORENAME & " " & qryUserDetails.SURNAME;
			arguments.strSession.dataSalePurchaser.companyname	= qryUserDetails.COMPANYNAME;
			arguments.strSession.dataSalePurchaser.address		= qryUserDetails.ADDRESS1 & " " & qryUserDetails.ADDRESS2 & " " & qryUserDetails.ADDRESS3;
			arguments.strSession.dataSalePurchaser.postcode		= qryUserDetails.POSTCODE;
			arguments.strSession.dataSalePurchaser.tel			= qryUserDetails.TEL;
			arguments.strSession.dataSalePurchaser.country		= qryUserDetails.Country;
			arguments.strSession.dataSalePurchaser.email			= qryUserDetails.username;
		}
		</cfscript>
	</cffunction>
    <!--- ----------------------------------------------------------------------------------------------------->
	<!--- PRIAVTE Functions ----------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
    <cffunction name="emailOrder" access="private" output="false" returntype="void">
    	<cfargument name="templateID" 		required="yes" 	type="string"	hint="">
        <cfargument name="orderid" 			required="yes" 	type="string"	hint="">
		<cfargument name="invoiceFilename" 	required="yes" 	type="string"	hint="">
		<cfargument name="email" 			required="yes"	type="string">
		
		<cfscript>
		var copy =  variables.objArticle.getFull(8, 95265).story;
		var subject = variables.strConfig.strVars.title & "List Rental Direct Order Confirmation";
		copy	 = replacenocase(copy, "|link|",variables.strConfig.strPaths.sitepath & "index.cfm?method=lrdirect.orderDetail&templateID=" &  arguments.templateID, "all");
		copy	 = replacenocase(copy, "|orderid|", arguments.orderid , "all");
		variables.objEmail.emailInvoice(0, arguments.invoiceFilename, variables.strConfig.strPaths.invoicedir, arguments.email, copy, subject);
		</cfscript>
    </cffunction>
    
</cfcomponent>