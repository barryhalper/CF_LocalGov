<!--- 
	
	$Archive: /localgov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/BusinessObjects/Invoice.cfc $
	$Author: Bhalper $
	$Revision: 8 $
	$Date: 18/08/09 16:29 $

--->

<cfcomponent displayname="Invoice" hint="" extends="his_Localgov_Extends.components.BusinessObjectsManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Invoice" hint="Pseudo-constructor">

		<cfargument name="objAppObjs" type="any" required="yes" hint="The application manager object">
		<cfargument name="objBusObjs" type="any" required="yes" hint="The business objects">
		
		<cfscript>
		// Call the genric init function, placing business, app, and dao objects into a local scope...
		StructAppend( variables, Super.initChild( arguments.objAppObjs, this, arguments.objBusObjs ) );
		
		return this;
		</cfscript>
		
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions ------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="invoiceCreated" access="public" output="true" returntype="numeric" >
		<cfargument name="invoiceID" 		type="numeric" 	required="yes">
		<cfargument name="invoiceFileName" 	type="string" 	required="yes">
		<cfargument name="invoiceDir" 		type="string" 	required="yes">
		
		<!---	-1 = file doesn't exist
				-2 = record doesn't exist
				-3 = both don't exist	--->

		<cfset var rtnCode = 1>
		
		<!--- Check whether the invoice exists... --->
		<cfif fileExists(arguments.invoiceDir & invoiceFileName)>
			<cfset rtnCode = -1>
		</cfif>

		<!--- Check whether there is a db entry... --->
		<cfif objDAO.invoiceCreated( arguments.invoiceID ) eq 0>
			<cfif rtnCode>
				<cfset rtnCode = -2>
			<cfelse>
				<cfset rtnCode = -3>
			</cfif>
		</cfif>
		
		<!--- Return the code... --->			
		<cfreturn rtnCode>			
	</cffunction>		
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="invoiceCreatedforOrder" access="public" output="true" returntype="query" >
		<cfargument name="orderID" 		type="numeric" 	required="yes">
		
		<cfreturn objDAO.invoiceCreatedforOrder( arguments.orderID )>			
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="saveInvoice" access="public" output="true" returntype="string" >
		<cfargument name="invoice" 		type="string" 	required="yes">
		<cfargument name="invoiceID" 	type="numeric" 	required="yes">
		<cfargument name="invoiceDir" 	type="string" 	required="yes">
		<cfargument name="userID" 		type="numeric" 	required="yes">
		
		<cfset invoiceFileName = "LG" & arguments.invoiceID & "-" & arguments.userID & "-" & CreateUUID() & ".htm">
				
		<cffile action= "write" 
		   file= 		"#arguments.invoiceDir##invoiceFileName#"
		   output= 		"#arguments.invoice#">
		
		<cfreturn invoiceFileName>			
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="updateInvoiceFilename" access="public" output="true" returntype="string" >
		<cfargument name="invoiceID" 		type="numeric"	required="yes">
		<cfargument name="invoiceFilename" 	type="string" 	required="yes">

		<cfreturn objDAO.updateInvoiceFileName( arguments.invoiceID, arguments.invoiceFileName )>			
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="commitInvoice" access="public" output="false" returntype="any" 
		hint="">
		
		<cfargument name="userID" 				type="numeric" 	required="yes" 	hint="The ID of the User the invoice is assigned to">
		<cfargument name="orderID" 				type="numeric" 	required="yes"	hint="">
		<cfargument name="purchase_order_no" 	type="string" 	required="yes"	hint="">
		<cfargument name="strAttr" 				type="struct" 	required="yes"	hint="">
		<cfargument name="statusCode" 		    type="string" 	required="no" default="NC" hint="The status of the invoice">
	
		<cfscript>
		var invoiceID=	0;
		var itemCost=	0;
		var finalTotal=	0;
		
		var qryInvoiceDetail= objDAO.getOrderDetailsForInvoice( arguments.orderID );
		// Resubscription/Top Ups
		if (arguments.strAttr.productid eq 3 ) {
			itemCost= 	evaluate( arguments.strAttr.launchPrice / qryInvoiceDetail.quantity );
			finalTotal= arguments.strAttr.launchPrice;
		}
		else if (arguments.strAttr.productid eq 2) {
			if (StructKeyExists(arguments.strAttr, 'hid_CorpReSubscriptionID')){
				itemCost= 	evaluate( arguments.strAttr.launchPrice / qryInvoiceDetail.quantity );
				finalTotal= arguments.strAttr.launchPrice;
			}
			else {
				itemCost= qryInvoiceDetail.SubscriptionPrice;
				finalTotal= evaluate( itemCost * qryInvoiceDetail.quantity );
			}
		}
		else {
			itemCost= qryInvoiceDetail.SubscriptionPrice;
			finalTotal= evaluate( itemCost * qryInvoiceDetail.quantity );
		}

		invoiceID = objDAO.insertInvoice( 
										arguments.userID,
										arguments.orderID, 	
										finalTotal,	
										0,
										qryInvoiceDetail.address1 & ", " & qryInvoiceDetail.address2,
										qryInvoiceDetail.postCode,
										"",
										arguments.statusCode,
										qryInvoiceDetail.subscriptionName,
										itemCost,
										qryInvoiceDetail.p_product_id,
										qryInvoiceDetail.quantity,
										purchase_order_no
									);

		return invoiceID;
		</cfscript>
		
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- get selected invoice and associated item details --->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getInvoiceDetails" access="public" output="false"  returntype="query"
		hint="query of invoice details for a supplied invoice id">
		
		<cfargument name="invoiceID" 		required="yes" 	type="numeric"	hint="This is the ID of the invoice to retrieve details for.">

		<cfreturn objDAO.getInvoiceDetails( arguments.invoiceID )>

	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="generateCSV" access="public" output="true"  returntype="string"
		hint="generates the CSV file based on the provided structure, for the accounts department.">
		
		<cfargument name="invoiceID" 			required="yes" 	type="numeric"	hint="This is the ID of the invoice to retrieve details for.">
		<cfargument name="qryInvoiceDetail"		required="yes" 	type="query"	hint="">
		<cfargument name="filepath"				required="yes" 	type="string"	hint="">
		<!--- <cfargument name="csvHeader" 	
			default="Invoice ID,Invoice Date,Customer Ref,Name,Company,Address,Detail,Unit Cost,Quantity,Cost,Pre VAT Total,VAT,Discounts,Amount Paid,Total Due" required="no" type="string"> --->

		<cfscript>
		
		var lstColumns=			arguments.qryInvoiceDetail.columnList;
		var fileName=			'LG-' & dateformat(now(), "ddmmyyyy") & '.csv';
		var file= 				arguments.filepath & fileName;
		var lstInvoiceDetails=	'';
		var strData=			structNew();
		var discount=			0;
		
		strData.name=			qryInvoiceDetail.forename & ' ' & qryInvoiceDetail.surname;
		strData.address=		qryInvoiceDetail.billingaddress & ' ' & qryInvoiceDetail.billingpostcode;
		strData.quantity=		qryInvoiceDetail.quantity;
		strData.unitCost=		qryInvoiceDetail.itemcost;
		discount=				evaluate( strData.unitCost * qryInvoiceDetail.discount_online/100 );
		strData.unitCost=		evaluate( strData.unitCost - discount );
		strData.netCost=		qryInvoiceDetail.quantity * strData.unitCost;
		strData.grossAmount=	strData.netCost * ((variables.strConfig.strVars.vat_uk/100)+1);
		strData.vat=			strData.grossAmount - strData.netCost;
		strData.description=	qryInvoiceDetail.itemdesc;
		strData.productID=		variables.strConfig.strVars.accountsProductCode; // qryInvoiceDetail.f_product_id;
		strData.status=			qryInvoiceDetail.F_PAYMENTMETHOD_ID;	// todo: replace id with name
		
		lstColumns= 			'name,address,quantity,unitCost,netCost,grossAmount,vat,description,productID,status,discount';
		lstInvoiceDetails= 		strData.name & ',' & replace(strData.address,","," ","all") & ',' & strData.quantity & ',' 
								& strData.unitCost & ',' & strData.netCost & ',' & strData.grossAmount & ',' & strData.vat & ',' 
								& strData.description & ',' & strData.productID & ',' & strData.status & ',' & discount;
		</cfscript>

		<cfif not fileExists( file )>
			<!--- Create the column header... --->
			<cffile action=		"write"  
					file=		"#file#" 
					output=		"#lstColumns#">
		</cfif>
				
		<cffile action=		"append"  
		    	file=		"#file#" 
			    output=		"#lstInvoiceDetails#" 
			    addnewline=	"Yes">

		<cfreturn fileName>

	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction  name="emailInvoice" access="public" output="false"  returntype="void"
		hint="">
		
		<cfargument name="invoiceID"		required="yes" 	type="numeric"	hint="">
		<cfargument name="invoiceFilename" 	required="yes" 	type="string"	hint="">
		<cfargument name="invoiceDir" 		required="yes"	type="string">
		<cfargument name="email" 			required="yes"	type="string">
		
		<cfset objEmail.emailInvoice( arguments.invoiceID, arguments.invoiceFilename, arguments.invoiceDir, arguments.email)>

	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction  name="emailInvoiceNonSubs" access="public" output="false"  returntype="void"
		hint="">
		<cfargument name="orderid" 			required="yes"	type="numeric" default="0">
		<cfargument name="invoiceID"		required="yes" 	type="numeric"	hint="">
		<cfargument name="invoiceFilename" 	required="yes" 	type="string"	hint="">
		<cfargument name="invoiceDir" 		required="yes"	type="string">
		<cfargument name="email" 			required="yes"	type="string">
		<cfargument name="description" 		required="no"	type="string" default="LocalGov.co.uk - Data Sales">
		<cfargument name="amounttxt" 		required="no"	type="string" default="Amount">
		<cfargument name="total" 			required="no"	type="numeric" default="0">
		
		
		<cfset var copy ="">
		
		<cfsavecontent variable="copy">
			<cf_OrderConfirm  Orderid = "#arguments.orderid#"
							  description="#arguments.description#"
							  invoiceFileName="#arguments.invoiceFilename#"
							  invoiceId="#arguments.invoiceID#"
							  amounttxt="#arguments.amounttxt#"
							  total="#arguments.total#"
							  isForEmail=true>
		</cfsavecontent> 
		
		<cfset objEmail.emailInvoice( arguments.invoiceID, arguments.invoiceFilename, arguments.invoiceDir, arguments.email, copy, arguments.description)>

	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction  name="emailCSV" access="public" output="false"  returntype="void"
		hint="">
		
		<cfargument name="invoiceID"	required="yes" 	type="numeric"	hint="">
		<cfargument name="csvFilename" 	required="yes" 	type="string"	hint="">
		<cfargument name="csvDir"		required="yes"	type="string">
		
		<cfset objEmail.emailCSV( arguments.invoiceID, arguments.csvFilename, arguments.csvDir)>

	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- <cffunction  name="generateInvoice" access="public" output="false"  returntype="void"
		hint="">
		
		<cfargument name="strSession" 			required="yes"		type="struct"   hint="">
		<cfargument name="ProductID"			required="yes" 	    type="numeric"	>
		<cfargument name="finaltotal" 			required="yes"		type="any"  hint="">
		<cfargument name="orderID" 				required="yes"		type="numeric"  hint="">
		<cfargument name="purchase_order_no"	required="yes" 	    type="numeric"	hint="">
		<cfargument name="invoiceID"			required="no" 		type="any"  	default="0">
		<cfargument name="type"					required="no" 	    type="string"	hint="">
		<cfargument name="contentFile"			required="no" 	    type="string"	default="/his_LocalGov/datasales/dsp_Invoice.cfm">
		<cfargument name="VAT"					required="no" 	    type="any"		default="0">
		<cfargument name="StandardRatedTotal"	required="no" 	    type="any"		default="0">
		<cfargument name="ZeroRatedTotal"		required="no" 	    type="any"		default="0">
	
		
		<cfscript>
		var bodycontent 				= "";
		var invoiceFileName 			= "";
		var sInvoiceFile 				= "";
		var pagecontent 				= "";
		var qryInvoiceDetail 			= "";
		var qryInvoiceCreatedforOrder 	= invoiceCreatedforOrder( arguments.orderID );
		var Confirmdescription 			="LocalGov.co.uk - MYB List Rental";	
		var email = 					arguments.strsession.userDetails.username;
		</cfscript>
	
		<!---First check whether the invoice has already been created...--->
		<cfif NOT qryInvoiceCreatedforOrder.recordCount>
						
				<cfset qryInvoiceDetail  = commitInvoiceNonSub(
																arguments.strsession, 
																arguments.ProductID, 
																arguments.orderID, 
																arguments.purchase_order_no, 
																arguments.finaltotal )>
				
				<cfsavecontent variable="bodycontent">
					<!--- use the dsp template,--->
					<cfinclude template="#arguments.contentFile#">
				</cfsavecontent>	
				
				<cfsavecontent variable="pagecontent">
					<!--- use the dsp template,--->
					
					<!--- Use for LOCAL Testing, comment out for LIVE --->
					<!--- <cfmodule template="/his_LocalGov/private/his_localgov_extensions/customtags/Invoice.cfm"
								qry ="#qryInvoiceDetail#" 
								orderbody="#bodycontent#" 
								PreVatTotal="#arguments.finaltotal#" 
								VatTotal="#arguments.VAT#"
								StandardRatedTotal="#arguments.StandardRatedTotal#"
								ZeroRatedTotal="#arguments.ZeroRatedTotal#"> --->
					
					<cf_Invoice qry ="#qryInvoiceDetail#" 
								orderbody="#bodycontent#" 
								PreVatTotal="#arguments.finaltotal#" 
								VatTotal="#arguments.VAT#"
								StandardRatedTotal="#arguments.StandardRatedTotal#"
								ZeroRatedTotal="#arguments.ZeroRatedTotal#"><!---  --->
				</cfsavecontent>
				
				
				<cfscript>
				//Retrieve the invoice details
				invoiceFileName = saveInvoice( 
									pagecontent, 
									qryInvoiceDetail.p_invoice_id, 
									strConfig.strPaths.invoiceDir, 
									arguments.strsession.userDetails.userID);
				
				//set the invoice filename and invoice id into the session
				if (qryInvoiceDetail.f_product_id eq 4 AND StructKeyExists(arguments.strSession,"dataSalePurchaser")){
					arguments.strSession.dataSalePurchaser.invoiceFile = invoiceFileName;
					arguments.strSession.dataSalePurchaser.invoiceId = qryInvoiceDetail.p_invoice_id;
					arguments.strSession.strdirectorybasket.invoiceNo = qryInvoiceDetail.invoiceNo;
					}
				else	
				if (qryInvoiceDetail.f_product_id eq 6 AND StructKeyExists(arguments.strSession,"strdirectorybasket")){
					arguments.strSession.strdirectorybasket.invoiceFile = invoiceFileName;
					arguments.strSession.strdirectorybasket.invoiceId = qryInvoiceDetail.p_invoice_id;
					arguments.strSession.strdirectorybasket.invoiceNo = qryInvoiceDetail.invoiceNo;
					Confirmdescription="LocalGov.co.uk - MYB Hard Copy Purchase";
					email= ListAppend(email, strConfig.strVars.customerservices);
					}
				
				//Update the invoice db entry with the previously generated filename
				updateInvoiceFileName(
						qryInvoiceDetail.p_invoice_id,
						invoiceFileName);
				
				//Email the invoice
				emailInvoiceNonSubs(
						 arguments.orderID,
						 qryInvoiceDetail.p_invoice_id, 
						 invoiceFileName, 
						 strConfig.strPaths.invoiceDir,
						 email, 
						 Confirmdescription,
						 "Amount",	
						 arguments.finaltotal);
								
				</cfscript>
													  
		</cfif>

	</cffunction> --->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="commitInvoiceNonSub" access="public" output="false" returntype="query" 
		hint="Commits the invoice to the DB">
		<cfargument name="strSession" 			type="struct" 	required="yes"	hint="">
		<cfargument name="ProductID" 			type="numeric" 	required="yes" >
		<cfargument name="orderID" 				type="numeric" 	required="yes"	hint="">
		<cfargument name="purchase_order_no" 	type="string" 	required="yes"	hint="">
		<cfargument name="finaltotal" 			type="any" 		required="yes"	hint="">
		<cfargument name="statusCode" 			type="string" 	required="no" default="NC" hint="The status of the invoice">
		
	
		<cfscript>
		var i=0;
		var invoiceID=	0;
		var arrInvoiceItem = ArrayNew(1);
		
		//set a struct for each invoice item	
		If (arguments.ProductID eq 6){
		 //MYB HARD COPY HAS 2 ITEMS 
		 //1: book
			arrInvoiceItem[1]=structNew();
			arrInvoiceItem[1].ItemDesc="MYB Hard Copy";
			arrInvoiceItem[1].ItemCost=arguments.finaltotal;
			arrInvoiceItem[1].quantity=arguments.strSession.strdirectorybasket.Nocopies;
			arrInvoiceItem[1].productid=6;
		//2: P & P
			arrInvoiceItem[2]=structNew();
			arrInvoiceItem[2].ItemDesc="Post & Packaging";
			arrInvoiceItem[2].ItemCost=arguments.strSession.strdirectorybasket.pandp;
			arrInvoiceItem[2].quantity=1;	
			arrInvoiceItem[2].productid=7;
			
			}
		else{
			//loop pver datas lasles array and set 1 eitem for each element
			 for (i=1; i lte arrayLen(arguments.strSession.dataSalesLists); i=i+1){
				 arrInvoiceItem[i]=structNew();
				 arrInvoiceItem[i].ItemDesc= "Set List - " & arguments.strSession.dataSalesLists[i].listName;
				 arrInvoiceItem[i].ItemCost=arguments.strSession.dataSalesLists[i].TotalAfterDiscount;
				 arrInvoiceItem[i].quantity=1;
				 arrInvoiceItem[i].productid=5;
			 
			 }	
		}	
		
		
		invoiceID = objDAO.insertInvoiceNonSub( 
										arguments.strSession.userdetails.userID,
										arguments.orderID, 	
										arguments.finaltotal,	
										0,
										"",
										"",
										"",
										arguments.statusCode,
										arguments.purchase_order_no,
										arrInvoiceItem	
									);

		return invoiceID;
		</cfscript>		
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- *** NEW FUNCTIONS *** --------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getInvoiceData" access="public" output="false" returntype="Struct" hint="Retrieve all data needed for generating the invoice">
		<cfargument name="orderID" 		type="numeric" 	required="yes">
		<cfargument name="productid" 	type="string" 	required="no" default="0">
		
		<cfscript>
			var strInvoiceData = objDAO.getInvoiceData(arguments.orderID , arguments.productid);
			var i= 0;
			
			if (arguments.productid eq 5){
			//reset product name to be that of the set list
				for (i=1; i lte strInvoiceData.qryInvoiceDetails.recordcount; i=i+1){
					querysetCell(strInvoiceData.qryInvoiceDetails, "Component", objutils.createWddxPacket("wddx2cfml", strInvoiceData.qryInvoiceDetails.datasalesxml[i]).listName, i);
				}
			}
			return strInvoiceData;
		</cfscript>
					
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="saveInvoiceData" access="public" output="false" returntype="String" hint="Save relevant data to Invoice table in DB">
		<cfargument name="orderID" 		type="numeric" 	required="yes">
		<cfargument name="UserID" 		type="numeric" 	required="yes">
		<cfargument name="productid" 	type="string" 	required="no" default="0">
		
		<cfscript>
			//Retrieve invoice data for generating invoice
			var strInvoiceData = getInvoiceData(arguments.orderID, arguments.productid);
			var invoiceID = "";
			var invoiceFilename = "";
			var newInvoiceNo = "";
			var arrNewInvoiceNo = ArrayNew(1);
			var i = 1;
		
			//Store total amount payable for invoice
			strInvoiceData.TotalDue = strInvoiceData.qryUserDetails.AbsoluteOrderPrice + strInvoiceData.qryInvoiceDetails.StandardRatedVAT;
		
			//save invoice data into db
			newInvoiceNo = objDAO.saveInvoiceData(arguments.orderID, strInvoiceData);
			strInvoiceData.newInvoiceNo = newInvoiceNo;
			//create physical invoice file
			invoiceFilename = generateInvoice(orderID, arguments.UserID, strInvoiceData);
			
			// Store id and 
			session.dataSalePurchaser.invoiceId = newInvoiceNo;
			session.dataSalePurchaser.invoiceFile = invoiceFilename;
			//Now update invoice record with the physical filename
			objDAO.updateInvoice(newInvoiceNo, invoiceFilename);
			
			return invoiceFilename;
		</cfscript>	
		
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="saveFile" access="public" output="true" returntype="string" hint="physically save the invoice document to hard drive" >
		<cfargument name="invoice" 		type="string" 	required="yes">
		<cfargument name="invoiceID" 	type="numeric" 	required="yes">
		<cfargument name="invoiceDir" 	type="string" 	required="yes">
		<cfargument name="userID" 		type="numeric" 	required="yes">
		
		<cfset invoiceFileName = "LG" & arguments.invoiceID & "-" & arguments.userID & "-" & CreateUUID() & ".htm">
				
		<cffile action= "write" 
		   file= 		"#arguments.invoiceDir##invoiceFileName#"
		   output= 		"#arguments.invoice#">
		
		<cfreturn invoiceFileName>			
	</cffunction>
		<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="generateInvoice" access="public" output="false"  returntype="string" hint="produce invoice file, create phyiscal file and return filename">
		<cfargument name="orderID" 			type="numeric" 	required="yes">
		<cfargument name="UserID" 			type="numeric" 	required="yes">
		<cfargument name="strInvoiceData" 	type="struct" 	required="yes">
		
		<cfset var invoiceContent  = "">
		<cfset var invoiceFileName = "">
		
		<cfsavecontent variable="invoiceContent">
			<cfmodule template="/his_Localgov_Extends/customtags/Invoice.cfm"  strInvoiceData = "#arguments.strInvoiceData#">
			<!--- <cfmodule template="\his_rd\library\customtags\Invoice.cfm"  strInvoiceData = "#arguments.strInvoiceData#"> --->
		</cfsavecontent>
		<cfset invoiceFilename = saveFile(invoiceContent, arguments.orderID, "#variables.strConfig.strPaths.invoiceDir#", arguments.UserID)>
	
		<cfreturn invoiceFilename>
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------
	<cffunction name="updateInvoiceFilename" access="public" output="true" returntype="string"  hint="update the invoice table with the name of the physical file">
		<cfargument name="invoiceID" 		type="numeric"	required="yes">
		<cfargument name="invoiceFilename" 	type="string" 	required="yes">

		<cfreturn instance.objDAO.updateInvoiceFileName( arguments.invoiceID, arguments.invoiceFileName )>			
	</cffunction>--->
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="updateInvoiceForExport" access="public" output="false" returntype="void" hint="mark as exported by acconnts">
		<cfargument name="lstInvoiceID" 	type="string" 	required="yes">
			
		<cfset objDAO.updateInvoiceForExport(arguments.lstInvoiceID)>
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="read" access="public" output="false" returntype="struct" hint="read html from file and get address">
		<cfargument name="filename" 	type="string" 	required="yes">
			
			<cfscript>
			var strFile 		= StructNew();
			var addressStart = 0;
			var addressEnd 	= 0;
			var addressLen 	= 0;
			
			strFile.htm = request.objApp.objUtils.ReadFile("#request.strSiteConfig.strPaths.invoiceDir##fileName#");
			
			//find the beginning of editable region (addresss) in htm
			addressStart 	= find("<!-- | EDIT ADDRESS |-->", strFile.htm) + 24;
			
			//check if html has editable region
			if (addressStart gt 24){
				//find the end of editable region in htm
				addressEnd 		= find("<!--| END |-->", strFile.htm);
				//get the lenghth of the address
				addressLen 		= addressEnd - addressStart;
				//get address and set into return structure
				strFile.address = Trim(Mid(strFile.htm, addressStart, addressLen));
			}
			else
			{
				strFile.address = '';
				strFile.olderror = 1;
			}
				
			
			return strFile;
			</cfscript>
		
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="UpdateAddress" access="public" output="false" returntype="void" hint="update address in html and resave file">
		<cfargument name="filename" type="string" 	required="yes">
		<cfargument name="strFile" 	type="struct" 	required="yes">
		<cfargument name="address" 	type="string" 	required="yes">
		
		<cfscript>
			var content = Replace(arguments.strFile.htm, arguments.strFile.address, arguments.address);
			//instance.objUtils.dumpabort(arguments);
			
			request.objApp.objUtils.WriteFile("#request.strSiteConfig.strPaths.invoiceDir##fileName#", content);
		</cfscript>
		
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction  name="reCreate" access="public" output="true"  returntype="string" hint="recreate an invioce if not present in CMS">
		<cfargument name="orderid"		required="yes" 	type="numeric"	hint="">
		<cfargument name="userid"		required="yes" 	type="numeric"	hint="">
		<cfargument name="productid"	required="yes" 	type="numeric"	hint="">
		<cfargument name="invoiceid"	required="yes" 	type="numeric"	hint="0">
		
	
		<cfscript>
		var srtInvoice = structNew();
		var	qryInvoice = "";
		var invoiceFilename = "";
		
		//save invoice data
		
		
		//1. *** NO INVOICE  ***
		If (NOT arguments.invoiceid)
			//instance.objUtils.dumpabort(srtInvoice);
			invoiceFilename = saveInvoiceData(argumentCollection=arguments);
		else{
		//2. *** Invoiceid does exist  ***
			 //get invoice data
		 	qryInvoice = getInvoiceDetails(arguments.invoiceID);
			//invoioce file name is present in db but no file
			if ( NOT FileExists( request.strSiteConfig.strPaths.invoicedir & qryInvoice.invoicefileName) 
			 
			 
			 ){
				//create file and update db record with new file
				strInvoiceData = getInvoiceData(arguments.orderID, arguments.productid);
				strInvoiceData.newInvoiceNo = qryInvoice.invoiceNo;
				//save file
				invoiceFilename = generateInvoice(orderID, arguments.UserID, strInvoiceData);
				//update db
				objDAO.updateInvoice(qryInvoice.invoiceNo,  invoiceFilename)	;
				}
						
			//file exists but not in db	
			else if (FileExists( request.strSiteConfig.strPaths.invoicedir & qryInvoice.invoicefileName) AND NOT LEN(qryInvoice.invoicefileName) ){	
				//update db with file name
				objDAO.updateInvoice(qryInvoice.invoiceNo,  qryInvoice.invoicefileName);
				invoiceFilename = qryInvoice.invoicefileName;
				}
			
			
					
			}		
		
		return invoiceFilename;
		</cfscript>
		
		
	</cffunction>
			
</cfcomponent>