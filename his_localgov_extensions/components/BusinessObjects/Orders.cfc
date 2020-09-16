
	<!--- taken from his_websites... --->

<cfcomponent hint="control orders taken on website" displayname="Orders" extends="his_Localgov_Extends.components.BusinessObjectsManager">

<!---   ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Orders" hint="Pseudo-constructor">
		<cfargument name="objAppObjs" type="any" required="yes" hint="The application manager object">
		<cfargument name="objBusObjs" type="any" required="yes" hint="The application manager object">

		<cfscript>
		StructAppend( variables, Super.initChild( arguments.objAppObjs, this, arguments.objBusObjs ) );
		return this;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction  name="AdminSelects" access="public" returntype="struct" output="false">
		
		<cfreturn objDAO.AdminSelects()>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getOrderDetail" access="public" output="false" returntype="struct" hint="get order and seeds">
		
		<cfargument name="orderID" 	type="string" 	required="true">
				
		<cfreturn objDAO.getOrderDetail(arguments.orderID)>
		
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
		<cfargument name="isso" type="numeric" required="no" default="0">
		
		<cfreturn  objDAO.AdminSearch(argumentCollection=arguments)>	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction  name="getDirPostagePackaging" access="public" returntype="numeric" output="false" hint="return price Postage and Packing based on no of copies, country and price of the directory">
		<cfargument name="noCopies" 		type="numeric"  required="true" > 
		<cfargument name="country" 			type="string"  required="true" > 
		
		<cfscript>
		var PandPcost = 0;
		//check if country is UK
		if (arguments.country eq "United Kingdom"){
			//1-3 copies
			if (arguments.noCopies GTE 1 AND arguments.noCopies LTE 3){
				PandPcost = 20;}
			else
			//4-6 copies
			if 	(arguments.noCopies GTE 4 AND arguments.noCopies LTE 6){
				PandPcost = 45;}
			else
			//7-10 copies
			if 	(arguments.noCopies GTE 7 AND arguments.noCopies LTE 10){
				PandPcost = 70;	}
			else
			//11+ copies
			if 	(arguments.noCopies GTE 11){
				PandPcost = 100;}			
		}
		//country is outsie UK
		else{
			//1-3 copies
			PandPcost = arguments.noCopies * 45;
		}
		return PandPcost;
		</cfscript>	
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="DirOrder2Session" output="false" returntype="void" hint="Commits book order ">
		<cfargument name="strSession" 	  	type="struct"  required="true" > 
		<cfargument name="address1" 		type="string"  required="false"  default=""> 
		<cfargument name="address2" 		type="string"  required="false"  default="">
		<cfargument name="address3" 		type="string"  required="false"  default="" >
		<cfargument name="town" 			type="string"  required="false"  default="" >
		<cfargument name="county" 			type="string"  required="false"  default="" >
		<cfargument name="country" 			type="string"  required="false"  default="" >
		<cfargument name="postcode" 		type="string"  required="false"  default="" >
		
		<cfscript>
		var strTotals = objDAO.getOrderPrice(arguments.strSession.strDirectoryBasket.CampaignCode, 3, arguments.strSession.strDirectoryBasket.NoCopies, 1);
		var strShippingAddress=StructNew();
		
		arguments.strSession.strDirectoryBasket.strTotals = strTotals;
		
		arguments.strSession.strDirectoryBasket.PandP = getDirPostagePackaging(arguments.strSession.strDirectoryBasket.NoCopies, arguments.country);
		arguments.strSession.strDirectoryBasket.TotalBeforePandP = arguments.strSession.strDirectoryBasket.strTotals.productprice;
		arguments.strSession.strDirectoryBasket.Total = arguments.strSession.strDirectoryBasket.TotalBeforePandP + arguments.strSession.strDirectoryBasket.PandP;
		//addd shipping address
		strShippingAddress.address1 = arguments.address1;
		strShippingAddress.address2 = arguments.address2;
		strShippingAddress.address3 = arguments.address3;
		strShippingAddress.town 	= arguments.town;
		strShippingAddress.county   = arguments.county;
		strShippingAddress.country  = arguments.country;
		strShippingAddress.postcode = arguments.postcode;
		arguments.strSession.strDirectoryBasket.strShippingAddress = strShippingAddress;
		</cfscript>
		
	</cffunction>
	
	<cffunction name="getBookOrderPrice" access="public" output="false" returntype="struct" hint="return price of a product based on campaign code">
		<cfargument name="campaignCode" type="string" 	required="yes">
		<cfargument name="productID"   	type="numeric" 	required="yes">
		<cfargument name="quantity"  	type="numeric" 	required="yes">
		<cfargument name="strSession" 	type="Struct" 	required="yes" hint="session struct"> 
		<cfargument name="termID"  		type="numeric" 	required="no" default="1" hint="The term ID for the product which tells you what duration the order covers">
		
		<cfscript>
			var strOrder = objDAO.getOrderPrice(argumentCollection=arguments);
			
			arguments.strSession.strSubscribe.qryOrderLine 		= strOrder.qryGetOrderPrice;
			arguments.strSession.strSubscribe.qryPostageRates	= strOrder.qryGetPostageRates;
			arguments.strSession.strSubscribe.Total				= strOrder.ProductPrice;
			arguments.strSession.strSubscribe.ProductName		= strOrder.qryGetOrderPrice.Product;
			arguments.strSession.strSubscribe.ProductType		= strOrder.qryGetOrderPrice.ProductType;
			
			return arguments.strSession;
		</cfscript>

	</cffunction>
	
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="commitBookOrder" output="false" returntype="numeric" hint="Commits book order ">
		
		<cfargument name="strSession" 		type="struct" required="yes" >
		<cfargument name="ProductID" 		type="numeric" required="yes">
		<cfargument name="OrderLineStatus"  type="string" required="yes" >
		<cfargument name="PaymentMethod" 	type="numeric" required="yes" >
		
		<cfscript>
		
		arguments.Userid 			= arguments.strSession.userdetails.userid;
		arguments.PaymentMethod 	= arguments.PaymentMethod;
		arguments.isInvoiceable 	= 1;
		arguments.pandP				= arguments.strSession.strdirectorybasket.pandp;
		arguments.productID			= arguments.productID;	
		arguments.Quantity 			= arguments.strSession.strdirectorybasket.NoCopies;
		arguments.campaignCode		= arguments.strSession.strdirectorybasket.CAMPAIGNCODE;
		arguments.AbsoluteOrderPrice = arguments.strSession.strdirectorybasket.total;
		arguments.ListPrice			= arguments.strSession.strdirectorybasket.strTotals.qryGetOrderPrice.COMPONENTLISTPRICE;
		arguments.TermPrice			= arguments.strSession.strdirectorybasket.strTotals.qryGetOrderPrice.STANDARDPRODUCTTERMPRICE;
		arguments.DiscountedPrice	= arguments.strSession.strdirectorybasket.strTotals.qryGetOrderPrice.DISCOUNTEDPRICE;
		arguments.OrderLineStatus 	= arguments.OrderLineStatus;
		arguments.VATAmount			= arguments.strSession.strdirectorybasket.strTotals.qryGetOrderPrice.VATAMOUNT;
		arguments.addressXml 		= objUtils.createWDDXPacket(
										dataInput=arguments.strSession.strDirectoryBasket.strShippingAddress);
										
		return objDAO.commitBookOrder(argumentCollection=arguments);
		</cfscript>
		 
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="updateOrderLineStatus" output="false" returntype="void" 
			hint="Update order line status">
		
		<cfargument name="orderID"	type="numeric" required="yes">
		<cfargument name="statusID"	type="numeric"  required="yes">
		
		<cfset objDAO.updateOrderLineStatus(arguments.orderID,arguments.statusID)>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getOrderTotals" output="false" returntype="string" 
			hint="return the sums of orders for a particular product">
		<cfargument name="productid" type="numeric" required="no" default="4"	>
		
		<cfreturn objDAO.getOrderTotals(arguments.productid).OrderTotal>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getOrderTotalsbyMonth" output="false" returntype="query" access="public" hint="return the sums of orders for a particular product">
		<cfargument name="productid" type="numeric" required="no" default="4"	>
		
		<cfreturn objDAO.getOrderTotalsbyMonth(arguments.productid)>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- NEW FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getOrderPrice" access="public" output="false" returntype="struct" hint="return price of a product based on campaign code">
		<cfargument name="campaignCode" type="string" 	required="yes">
		<cfargument name="productID"   	type="numeric" 	required="yes">
		<cfargument name="quantity"  	type="numeric" 	required="yes">
		<cfargument name="strSession" 	type="Struct" 	required="yes" hint="session struct"> 
		<cfargument name="termID"  		type="numeric" 	required="no" default="1" hint="The term ID for the product which tells you what duration the order covers">
		
		<cfscript>
			var strOrder = objDAO.getOrderPrice(argumentCollection=arguments);
			
			arguments.strSession.strSubscribe.qryOrderLine 		= strOrder.qryGetOrderPrice;
			arguments.strSession.strSubscribe.qryPostageRates	= strOrder.qryGetPostageRates;
			arguments.strSession.strSubscribe.Total				= strOrder.ProductPrice;
			arguments.strSession.strSubscribe.ProductName		= strOrder.qryGetOrderPrice.Product;
			arguments.strSession.strSubscribe.ProductType		= strOrder.qryGetOrderPrice.ProductType;
			
			return arguments.strSession;
		</cfscript>

	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="setFinalPrice" access="public" output="false" returntype="struct" hint="return price of a product based on campaign code">
		<cfargument name="paymentType" 	type="String" required="yes">
		<cfargument name="strSession" 	type="Struct" required="yes" hint="session struct"> 
		
		<cfscript>
			var productDiscountedPrice = arguments.strSession.strSubscribe.Total; //Discounted price of product NOT including any online payment discounts
			var discountAmount = 0.00; //Discount amount after applying discount rate card (NOT including any online payment discount)
			var arrAbsolutePrice = ArrayNew(1);
			var absolutePrice = 0.00; //Absolute price of each component after applying all discounts including any online payment discounts
			var productPrice = 0.00; //Absolute price of product after applying all discounts including any online payment discounts
			var onlinePaymentDiscount = 0.00; //Amount of discount given for paying online
			var arrVATAmount = ArrayNew(1);
			var VATAmount = 0.00; //VAT to be paid on a particular component
			var totalVATAmount = 0.00; //Total VAT to be paid
		</cfscript>
	
		<!--- Loop round orderline query and calculate different prices --->
		<cfoutput query="arguments.strSession.strSubscribe.qryOrderLine">
			<cfset absolutePrice = 0.00>
			<cfset VATAmount = 0.00>
			
			<!--- Do not use any pre-existing rows for P&P in calculations. That happens later on --->
			<cfif arguments.strSession.strSubscribe.qryOrderLine.componentID NEQ 4>
		
				<!--- If user is paying by CC online, give 5% discount --->
				<cfif arguments.paymentType EQ "1">
					<cfset absolutePrice = (arguments.strSession.strSubscribe.qryOrderLine.DiscountedPrice - (10/100 * arguments.strSession.strSubscribe.qryOrderLine.DiscountedPrice))>
					<cfset QuerySetCell(arguments.strSession.strSubscribe.qryOrderLine, "AbsolutePrice", absolutePrice, currentrow)>
					<cfset productPrice = productPrice + absolutePrice>
				
				<cfelse>
					<cfset absolutePrice = arguments.strSession.strSubscribe.qryOrderLine.DiscountedPrice>
					<cfset QuerySetCell(arguments.strSession.strSubscribe.qryOrderLine, "AbsolutePrice", absolutePrice, currentrow)>
					<cfset productPrice = productPrice + absolutePrice>	
				</cfif>
			
				<!--- Now do VAT where applicable --->
				<cfif (arguments.strSession.strSubscribe.qryOrderLine.IsSubjectToFullVAT)>
					<cfif arguments.strSession.strSubscribe.EUVATNumber EQ 0 OR arguments.strSession.strSubscribe.euVATNumber EQ "">
						<!--- Make sure we always round the VAT UP --->
						<cfset VATAmount = (strConfig.strVars.vat_uk * absolutePrice)/100> <!--- request. --->
					</cfif>
					<cfset totalVATAmount = totalVATAmount + VATAmount>
				</cfif>
				<cfset QuerySetCell(arguments.strSession.strSubscribe.qryOrderLine, "VATAmount", VATAmount, currentrow)>
			
			</cfif>
			
		</cfoutput>
		
		<cfscript>
			//Setup default values for struct variables holding various calculated figures
			arguments.strSession.strSubscribe.postagePrice = 0.00;
			arguments.strSession.strSubscribe.TotalToPay = 0.00;
			arguments.strSession.strSubscribe.AbsoluteOrderPrice = 0.00;
			arguments.strSession.strSubscribe.absoluteProductPrice = 0.00;
			arguments.strSession.strSubscribe.productDiscountedPrice = 0.00;
			arguments.strSession.strSubscribe.discountAmount = 0.00;
			arguments.strSession.strSubscribe.onlinePaymentDiscount = 0.00;
			
			// Save Total VAT payable and Total Product Price so far to session  
			// as we will need to modify it when doing P&P (where applicable)
			arguments.strSession.strSubscribe.totalVATAmount = totalVATAmount;
			arguments.strSession.strSubscribe.absoluteProductPrice = productPrice;
		
			//If the user has chosen a product that includes a book, 
			//we must add a new orderline row for postage and packaging
			arguments.strSession.strSubscribe.qryOrderLine = setPostageAndPackaging(ProductID = arguments.strSession.strSubscribe.ProductID, qryOrderLine=arguments.strSession.strSubscribe.qryOrderLine, strSession = arguments.strSession);

			//Now calculate the total discount amount (NOT including any online payment discount)
			discountAmount = arguments.strSession.strSubscribe.qryOrderLine.StandardProductTermPrice - productDiscountedPrice;

			/*
				Calculate amount of discount given for payment online (5%)
				This is applied to the final discounted price of the product
				after any rate cards are applied
		 	*/
			onlinePaymentDiscount = (10/100 * productDiscountedPrice);
		
			//Now update session structure with calculated variables
			arguments.strSession.strSubscribe.productDiscountedPrice = productDiscountedPrice;
			arguments.strSession.strSubscribe.discountAmount = discountAmount;
			arguments.strSession.strSubscribe.onlinePaymentDiscount = onlinePaymentDiscount;
			arguments.strSession.strSubscribe.AbsoluteOrderPrice = (arguments.strSession.strSubscribe.absoluteProductPrice + arguments.strSession.strSubscribe.postagePrice);
			arguments.strSession.strSubscribe.TotalToPay = (arguments.strSession.strSubscribe.absoluteProductPrice + arguments.strSession.strSubscribe.postagePrice + arguments.strSession.strSubscribe.totalVATAmount);	
		</cfscript>
		
		<cfreturn arguments.strSession>
		
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="setPostageAndPackaging" access="public" output="false" returntype="query" hint="return price of a product based on campaign code">
		<cfargument name="ProductID"	type="numeric" 	required="yes">
		<cfargument name="qryOrderLine"	type="query" 	required="yes" hint="the query that contains the Orderlines. A new row will be added to this query">
		<cfargument name="strSession" 	type="struct" 	required="yes" hint="session struct"> 
		
		<cfscript>
			var VATAmount = 0.00;
			var postageAmount = 0.00;
			var countryID = 0;
			var qryPostage = "";
			var currentComponents = ValueList(arguments.qryOrderLine.ComponentID);
			
			//First determine what country the book is to be shipped to
			if(structKeyExists(arguments.strSession.strSubscribe, "strShipping") AND len(arguments.strSession.strSubscribe.strShipping.countryID))
			{
				countryID = arguments.strSession.strSubscribe.strShipping.countryID;
			}
			else
			{
				countryID = arguments.strSession.userDetails.country;
			}
			
			//If the order includes a book
			if(arguments.ProductID EQ 3)
			{
				//Now determine postage amount depending on whether book is to be shipped within UK or internationally
				if(countryID EQ 1)
				{
					//For 11 or more books, the postage is the same amount, so retrieve postage price for 11 books
					if(arguments.strSession.strSubscribe.ProductQuantity GTE 11)
					{
						qryPostage = request.objApp.objutils.QueryofQuery(arguments.strSession.strSubscribe.qryPostageRates, "UKPrice", "PostageItemsCount = 11", "");
					}
					//Otherwise retrieve postage price for exact number of books
					else
					{
						qryPostage = request.objApp.objutils.QueryofQuery(arguments.strSession.strSubscribe.qryPostageRates, "UKPrice", "PostageItemsCount = #arguments.strSession.strSubscribe.ProductQuantity#", "");
					}
					
					postageAmount = qryPostage.UKPrice;
				}
				else
				{
					//For 11 or more books, the postage is the same amount, so retrieve postage price for 11 books
					if(arguments.strSession.strSubscribe.ProductQuantity GTE 11)
					{
						qryPostage = request.objApp.objutils.QueryofQuery(arguments.strSession.strSubscribe.qryPostageRates, "InternationalPrice", "PostageItemsCount = 11", "");
					}
					//Otherwise retrieve postage price for exact number of books
					else
					{
						qryPostage = request.objApp.objutils.QueryofQuery(arguments.strSession.strSubscribe.qryPostageRates, "InternationalPrice", "PostageItemsCount = #arguments.strSession.strSubscribe.ProductQuantity#", "");
					}
					postageAmount = qryPostage.InternationalPrice;
				}			
				
				//If the P&P component has not already been added to the query
				if(ListFind(currentComponents, 4) EQ 0)
				{
					//First add a new row to query for P&P
					QueryAddRow(arguments.qryOrderLine, 1);
					
					QuerySetCell(arguments.qryOrderLine, "Component", "Postage & Packaging");
					QuerySetCell(arguments.qryOrderLine, "ComponentID", "4");
					QuerySetCell(arguments.qryOrderLine, "ComponentListPrice", postageAmount);
					QuerySetCell(arguments.qryOrderLine, "ComponentPercentage", "0");
					QuerySetCell(arguments.qryOrderLine, "STANDARDCOMPONENTTERMPRICE", postageAmount);
					QuerySetCell(arguments.qryOrderLine, "DiscountedPrice",postageAmount);
					QuerySetCell(arguments.qryOrderLine, "DiscountRate", arguments.qryOrderLine.DiscountRate[1]);
					QuerySetCell(arguments.qryOrderLine, "isDiscountable", "0");
					QuerySetCell(arguments.qryOrderLine, "isSubjectToFullVAT", "0");
					QuerySetCell(arguments.qryOrderLine, "Product", arguments.qryOrderLine.Product[1]);
					QuerySetCell(arguments.qryOrderLine, "ProductID", arguments.ProductID);
					QuerySetCell(arguments.qryOrderLine, "ProductListPrice", arguments.qryOrderLine.ProductListPrice[1]);
					QuerySetCell(arguments.qryOrderLine, "StandardProductTermPrice", arguments.qryOrderLine.StandardProductTermPrice[1]);
					QuerySetCell(arguments.qryOrderLine, "ProductType", arguments.qryOrderLine.ProductType[1]);
					QuerySetCell(arguments.qryOrderLine, "Quantity", "1");
					QuerySetCell(arguments.qryOrderLine, "AbsolutePrice", postageAmount);
					QuerySetCell(arguments.qryOrderLine, "VATAmount", "0.00");
					QuerySetCell(arguments.qryOrderLine, "isInvoiceable", "1");
				}				
			}
			
			//Update session variable holding the P&P costs
			arguments.strSession.strSubscribe.postagePrice = postageAmount;
			
		</cfscript>
		
		<!--- Return modified query --->
		<cfreturn arguments.qryOrderLine>

	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="processOrder" output="false" returntype="String" access="public" hint="execute business logic for processing an order and returns the invoice content">
		<cfargument name="paymentMethodID" 		type="numeric" 	required="yes">
		<cfargument name="orderStatusID" 		type="numeric" 	required="yes">
		<cfargument name="productid" 			type="numeric" 	required="yes">
		<cfargument name="campaignCode" 		type="string" 	required="yes">
		<cfargument name="UserID" 				type="numeric" 	required="yes">
		<cfargument name="quantity"     		type="numeric" 	required="yes">
		<cfargument name="subscriptionStatusID" type="numeric" 	required="yes">
		<cfargument name="dataSalesXML"			type="string"  	required="no" 	default="">
		<cfargument name="strSession" 			type="struct"	required="yes" 	hint="str of the session scope">
		<cfargument name="isRenewal"			type="numeric"	required="yes">
		<cfargument name="corpSubLink"			type="string"	required="yes">
		
		<cfscript>
			//Declare our variables
			var strRegistrationSelects  = "";
			var strInvoiceData			= "";
			var orderID					= "";
			var invoiceFileName			= "";
			var invoiceID				= "";
			
			
			arguments.downgrade = 0; //Variable to flag this order as a downgrade for a Corporate Subscription
			arguments.strSession.strSubscribe.SubscriptionID = 0;		//Default SubscriptionID
			
			//1. Save the order and create the subscription
			orderID = saveOrder(argumentCollection=arguments);
			
			/** 
				If the user is already a Corporate Administrator and they are renewing to a
				SINGLE Subscription product, we must create a brand new Subscription as you cannot downgrade
				in a renewal
			**/
			if(arguments.strSession.userDetails.UserTypeID EQ 5 AND arguments.strSession.strSubscribe.ProductID EQ 1)
			{
				//Mark this order as not being a renewal as we want a new sub to be created
				arguments.isRenewal = 0;
				
				//Mark the order as being a downgrade as it gets treated in a special way
				arguments.downgrade = 1;
			}
			
			/*
			**	2. Now create the user subscription if the order includes a subscription component
			** (and this is not a renewal order) and is NOT the Book only order
			*/
			if (arguments.strSession.strSubscribe.ProductType EQ "Subscription" )
			{
				////First set up start and end dates for subscription
//				
//				//If this is a downgrade renewal from Corporate Sub to Single Sub
//				if(arguments.downgrade EQ 1)
//				{					
//					/**
//					** If the current subscription period expired before today's date
//					** or it's been cancelled/deleted,
//					** start the new subscription period from today 	
//					**/
//					if (dateCompare(arguments.strSession.strAccess.endDate, now()) LT 0 OR arguments.strSession.strSubscribe.currentSubscriptionStatusID EQ 4)
//					{
//						arguments.strSession.strSubscribe.newStartDate = DateFormat(now(), 'dd/mmm/yyyy');
//					}
//					//Otherwise start it the day after the current subscription's end date
//					else
//					{
//						arguments.strSession.strSubscribe.newStartDate = DateFormat(DateAdd('d',1,arguments.strSession.strAccess.endDate), 'dd/mmm/yyyy');
//					}
//					
//					arguments.strSession.strSubscribe.newEndDate  = DateFormat(DateAdd('d',370,arguments.strSession.strSubscribe.newStartDate), 'dd/mmm/yyyy');
//					
//					/**
//					** If the start date of the new sub period is before or equal to current date,
//					** set its status to active and mark it as the most current sub period for subscriber
//					**/
//					if(DateCompare(arguments.strSession.strSubscribe.newStartDate, now()) LTE 0)
//					{
//						arguments.subscriptionStatusID = 1;
//						arguments.isCurrent = 1;
//					}
//					
//					/**
//					** Otherwise set it to suspended and do not mark it as most current sub period.
//					** This will be done by the scheduled task when it the current active sub period expires
//					**/
//					else
//					{
//						arguments.subscriptionStatusID = 2;
//						arguments.isCurrent = 0;
//					}
//				}
//				
//				//If this is just a normal new subscription order
//				else
//				{
//					arguments.strSession.strSubscribe.newStartDate = DateFormat(now(), 'dd/mmm/yyyy');
//					arguments.strSession.strSubscribe.newEndDate = DateFormat(DateAdd('d', 370, arguments.strSession.strSubscribe.newStartDate), 'dd/mmm/yyyy');
//					arguments.isCurrent = 1;
//				}
//				
//				
//				//Now create the subscription
//				arguments.strSession.strSubscribe.SubscriptionID = objDAO.createSubscription
//																	(
//																		  OrderID = orderID
//																		, UserID = arguments.UserID
//																		, ProductID = arguments.ProductID
//																		, SubscriptionStatusID = arguments.subscriptionStatusID
//																		, StartDate = arguments.strSession.strSubscribe.newStartDate
//																		, EndDate = arguments.strSession.strSubscribe.newEndDate
//																		, isCurrent = arguments.isCurrent
//																		, AllowableSubscribers = arguments.strSession.strSubscribe.allowableSubscribers
//																	);
//			}
//			
//			/**
//			** If this is a renewal order:
//			** Create new subscription period
//			**/
//			else if(arguments.isRenewal EQ 1)
//			{
//				arguments.strSession.strSubscribe.SubscriptionID = arguments.strSession.strAccess.subscriptionID;
//				
//				//Now create new subscription period
//				SaveNewSubPeriod
//				(
//					OrderID = orderID
//					, SubscriptionID = arguments.strSession.strAccess.subscriptionID
//					, strSession = arguments.strSession
//					, isUpgrade = "false"
//					, currentEndDate = arguments.strSession.strAccess.endDate
//				);

				arguments.strSession.strSubscribe.SubscriptionID = objDAO.createWebSubscription( OrderID = orderID,  
																								  UserID = arguments.UserID,
																								  ProductID = arguments.ProductID,
																								  AllowableSubscribers = arguments.strSession.strSubscribe.allowableSubscribers);
			}
			
			//3. Update user access after processing of order
			request.objBus.objAccess.setAccess(arguments.strSession, arguments.strSession.userDetails.UserID);
			
		
			/* 
			**	If user's payment method is by invoice, then generate and save invoice 
			**	and send confirmation email
			*/
			if(arguments.paymentMethodID EQ 3)
			{
				//4. Save invoice data
				invoiceFilename = objInvoice.saveInvoiceData(orderID, arguments.strSession.userDetails.UserID);
				
				// If this is a Corporate Subscription, commit and get the AccessCode / key...
				if (arguments.ProductID EQ 2)
				{
					//Get/Commit access code
					arguments.strSession.strSubscribe.accessCode = request.objBus.objSubscriptions.commitAccessCode(subscriptionID = arguments.strSession.strSubscribe.subscriptionID);
					
					//email access code to user
					request.objBus.objEmail.SendCorporateAccessCode
					(
						arguments.strSession.userDetails.username
						, arguments.strSession.strSubscribe.accessCode
						,  arguments.strSession.userDetails.fullname 
					);
						
				}
				else
					arguments.strSession.strSubscribe.accessCode = '';
			
				//5. Send confirmation Email		
				request.objBus.objEmail.emailNotification
				( 
					strUserDetails 		= arguments.strSession.userDetails 
					, SubscriptionID 	= arguments.strSession.strSubscribe.subscriptionID 
					, PaymentStatus 	= 4
					, ProductID 		= arguments.ProductID
					, subscribers_link 	= arguments.corpSubLink
					, admin_user 		= 1
					, corpEmail			= arguments.strSession.userDetails.username
					, attachmentPath 	=  "#variables.strConfig.strPaths.invoiceDir##invoiceFilename#"
				);
					
			}
		</cfscript>
		
		<cfreturn invoiceFilename>
		
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="saveOrder" output="false" returntype="numeric" access="public" hint="save the order and orderline and return the OrderID">
		<cfargument name="paymentMethodID" 		type="numeric" 	required="yes">
		<cfargument name="orderStatusID" 		type="numeric" 	required="yes">
		<cfargument name="productid" 			type="numeric" 	required="yes">
		<cfargument name="campaignCode" 		type="string" 	required="yes">
		<cfargument name="quantity"     		type="numeric" 	required="yes">
		<cfargument name="subscriptionStatusID" type="numeric" 	required="yes">
		<cfargument name="isUpgrade" 			type="numeric" 	required="no"	default="0"	hint="indiactes whether this order is an upgrade">
		<cfargument name="baseOrderID" 			type="numeric" 	required="no"	default="0" hint="ID of order that is been upgraded">
		<cfargument name="dataSalesXML"			type="string"  	required="no" 	default="">
		<cfargument name="strSession" 			type="struct"	required="yes" 	hint="str of the session scope">
		<cfargument name="isSO"					type="numeric"	required="no">
		<cfargument name="notes"				type="string"	required="no">
		
		<cfset var i = 1>
		
		<!--- Determine a value for the EU VAT Number argument --->
		<cfif Len(strSession.strSubscribe.euVATNumber)>
			<cfset arguments.euVATNumber = strSession.strSubscribe.euVATNumber>
		<cfelse>
			<cfset arguments.euVATNumber = 0>
		</cfif>
		
		<!--- If the ID of the user has not been passed in, it will be in the user sesssion --->
		<cfif NOT StructKeyExists(arguments, "UserID")>
			<cfset arguments.UserID	= arguments.strSession.strUser.UserID>
		</cfif>
		
		<cfset arguments.AbsoluteOrderPrice = arguments.strSession.strSubscribe.AbsoluteOrderPrice>
		<cfset arguments.PurchaseOrderNumber = arguments.strSession.strSubscribe.purchaseOrderNumber>
		
		<!--- Convert shipping address data into wddx --->
		<cfif StructKeyExists(arguments.strSession.strSubscribe, "strShipping")>
			<cfwddx action="cfml2wddx" input="#arguments.strSession.strSubscribe.strShipping#" output="arguments.shippingAddressXML">
		</cfif>
		
		<cfscript>
			//Call the DAO object to save the order and get Order ID back
			arguments.OrderID = objDAO.saveOrder(argumentCollection=arguments);
		
			/* 
				If the Order has been saved successfully (i.e. Order ID is not 0):
				1. Save the orderline which is the components of the order (e.g. subscription + book)
				2. Create a subscription for the user
			*/
			if (arguments.OrderID NEQ 0)
			{
				//Loop round Orderline query and save each component to Orderline table in turn
				for (i=1; i LTE arguments.strSession.strSubscribe.qryOrderLine.recordcount; i=i+1)
				{
					//First set up component variables from query
					arguments.ComponentID 			= arguments.strSession.strSubscribe.qryOrderLine.ComponentID[i];
					arguments.ListPrice 			= arguments.strSession.strSubscribe.qryOrderLine.ComponentListPrice[i];
					arguments.ProductPercentage 	= arguments.strSession.strSubscribe.qryOrderLine.ComponentPercentage[i];
					arguments.TermPrice 			= arguments.strSession.strSubscribe.qryOrderLine.StandardComponentTermPrice[i];
					arguments.ComponentQuantity		= arguments.strSession.strSubscribe.qryOrderLine.Quantity[i];
					
					if(arguments.strSession.strSubscribe.qryOrderLine.isSubjectToFullVAT[i] EQ 1)
					{
						arguments.VATRate 	= strConfig.strVars.vat_uk;
					}
					else
					{
						arguments.VATRate 	= 0;
					}
					
					arguments.DiscountedPrice 		= arguments.strSession.strSubscribe.qryOrderLine.DiscountedPrice[i];
					arguments.AbsolutePrice 		= arguments.strSession.strSubscribe.qryOrderLine.AbsolutePrice[i];
					arguments.VATAmount 			= arguments.strSession.strSubscribe.qryOrderLine.VATAmount[i];
					arguments.isInvoiceable 		= arguments.strSession.strSubscribe.qryOrderLine.isInvoiceable[i];
					
					//Now call function to save component to Orderline table 
					objDAO.saveOrderLine(argumentCollection=arguments);
				}
			}
		
			//Set the OrderID into the user's subscribe session structure
			arguments.strSession.strSubscribe.OrderID = arguments.OrderID;
			
		</cfscript>
		
		<cfreturn arguments.OrderID>
		
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="saveListOrder" output="false" returntype="numeric" access="public" hint="save the order and orderline and return the OrderID">
		<cfargument name="paymentMethodID" 		type="numeric" 	required="yes">
		<cfargument name="orderStatusID" 		type="numeric" 	required="yes">	
		<cfargument name="userid" 				type="numeric"	required="yes">
		<cfargument name="shippingAddress" 		type="struct"	required="yes" >
		<cfargument name="strLists" 			type="struct"	required="yes" >
		
		<cfscript>
			var i = 0;
			arguments.OrderID			 	= 0;
			arguments.productid			 	= 4;
			arguments.campaignCode 		 	= strLists.strdatasalestotal.campaignCode;
			arguments.euVATNumber 		 	= 0;
			arguments.PurchaseOrderNumber 	= "";
			vatRate						 	= 0;
			arguments.userId 			 	= arguments.UserID;
			arrBasket  						= arguments.strLists.arrListsBasket;
			
			//Convert shipping address data into wddx
			arguments.shippingAddressXML	= instance.objUtils.createWDDXPacket('cfml2wddx', arguments.shippingAddress);
			
			//Call the DAO object to save the order and get Order ID back
			arguments.AbsoluteOrderPrice 	= arguments.strLists.strDatasalesTotal.TotalAfterSubDiscount;
		</cfscript>
		
		<!---create transaction block to ensure data integrity--->
		<cftransaction action="begin">
			<cftry>  
				<cfscript>
					// save order
					arguments.OrderID  = instance.objDAO.saveOrder(argumentCollection=arguments);
					arguments.strLists.strdatasalestotal.orderID = arguments.OrderID;
					//instance.objUtils.dumpabort(arguments);
					
					//Loop round Orderline query and save each component to Orderline table in turn
					for (i=1; i LTE arrayLen(arrBasket); i=i+1){
							//work out vat rate base don order type
							If (arrBasket[i].format neq 3 and arrBasket[i].totalvat )
								vatRate 					= instance.strConfig.strVars.vat_uk;
					
							arguments.datasalesXml  		= instance.objutils.createWDDXPacket('cfml2wddx',arrBasket[i]);
							arguments.ComponentID 			= 0;
							arguments.ListPrice 			= arrBasket[i].calculatedPrice;
							arguments.ProductPercentage 	= 100;
							arguments.TermPrice 			= arrBasket[i].calculatedPrice;
							arguments.ComponentQuantity		= 1;
							
							arguments.DiscountedPrice 		= arrBasket[i].TotalAfterDiscount;
							arguments.AbsolutePrice 		= arrBasket[i].TotalAfterDiscount;//if futher discount added thi sprice would be less than DiscountedPrice
							arguments.VATAmount 			= arrBasket[i].totalvat;
							arguments.isInvoiceable 		= 1;
							arguments.VATRate 				= vatRate;
							
							//Now call function to save component to Orderline table 
							instance.objDAO.saveOrderLine(argumentCollection=arguments);	
					}
				</cfscript>
			
			<cfcatch type="any">
				<cftransaction action="rollback"/>
				<cfthrow type="Application" message="List rental order could not be inserted" detail="#cfcatch.message#">	
			</cfcatch>

			</cftry>
			
			<cftransaction action="commit"/>
		</cftransaction>
		
		<cfreturn arguments.OrderID>
	
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="createSubscription" output="false" returntype="numeric" access="public" hint="Create a subscription entry for user">
		<cfargument name="OrderID" 				type="numeric" 	required="yes">
		<cfargument name="UserID" 				type="numeric" 	required="yes">
		<cfargument name="ProductID" 			type="numeric" 	required="yes">
		<cfargument name="subscriptionStatusID" type="numeric" 	required="yes">
		
		<cfreturn instance.objDAO.createSubscription(argumentCollection=arguments)>
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="updateOrder" output="false" returntype="void" access="public" hint="Update the Order and subscription status">
		<cfargument name="orderID" 				type="numeric" required="yes">
		<cfargument name="subscriptionID"		type="numeric" required="no" default="0">	
		<cfargument name="orderStatusID"     	type="numeric" required="yes"> 
		<cfargument name="subscriptionStatusID"	type="numeric" required="no" default="0">
		<cfargument name="worldpayTransactionID"type="numeric" required="no" default="0">
		<cfargument name="strSession" 			type="struct"  required="no" hint="str of the session scope">
		
		<cfscript>
			objDAO.updateOrder(argumentCollection=arguments);
			if 	(arguments.subscriptionID)
			{
				if (StructKeyExists(arguments.strSession, "strAccess"))
			 		strSession.strAccess.status = "Active";
			
			}
		</cfscript>
		
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="CancelOrder" output="false" returntype="void" access="public" hint="Cancel an order that has had its payment cancelled or declined">
		<cfargument name="OrderID" 				type="numeric" required="yes">
		<cfargument name="OrderStatusID"     	type="numeric" required="yes"> 
		<cfargument name="WorldpayTransactionID"type="numeric" required="no" default="0">
		<cfargument name="UserID" 				type="numeric" required="yes">
		<cfargument name="IsRenewal" 			type="numeric" required="no" default="0">
		
		<cfscript>
			objDAO.CancelOrder(argumentCollection=arguments);
		</cfscript>
		
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="processAdminOrder" output="false" returntype="String" access="public" 
				hint="execute business logic for processing an order and returns the subscription ID. This function is used exclusively by admin creating a subscription">
		<cfargument name="paymentMethodID" 		type="numeric" 	required="yes">
		<cfargument name="orderStatusID" 		type="numeric" 	required="yes">
		<cfargument name="productID" 			type="numeric" 	required="yes">
		<cfargument name="campaignCode" 		type="string" 	required="yes">
		<cfargument name="quantity"     		type="numeric" 	required="yes">
		<cfargument name="subscriptionStatusID" type="numeric" 	required="yes">
		<cfargument name="dataSalesXML"			type="string"  	required="no" 	default="">
		<cfargument name="UserID" 				type="numeric"	required="yes">
		<cfargument name="strSession" 			type="struct"	required="yes" 	hint="str of the session scope">
		<cfargument name="isRenewal"			type="numeric"	required="yes">
		<cfargument name="corpSubLink"			type="string"	required="yes">
		<cfargument name="isSO"					type="numeric"	required="no">
		<cfargument name="notes"				type="string"	required="no">
		
		<cfscript>
			//Declare our variables
			var strRegistrationSelects  = "";
			var qryUser					= "";
			var orderID					= "";
			var invoiceFileName			= "";
			var subscriptionID			= 0;
			
			if(arguments.isRenewal NEQ 1)
			{
				arguments.strSession.strSubscribe.SubscriptionID = 0;		//Default SubscriptionID
			}
			
			arguments.downgrade = 0; //Variable to flag this order as a downgrade for a Corporate Subscription
			
			//Determine how many subscribers are allowed for this subscription order
			if(arguments.ProductID EQ 2)// Corporate Sub
			{
				arguments.strSession.strSubscribe.allowableSubscribers = 100;
			}
			else
			{
				arguments.strSession.strSubscribe.allowableSubscribers = 1;
			}
			//1. Retrieve details about User and put into structure
			qryUser = request.objBus.objUser.getUserDetailsByID(arguments.UserID);
			arguments.strsession.strSubscribe.strUser = objUtils.queryRowToStruct(qryUser);
		
			//2. Save the order and get Order ID back 
			orderID = saveOrder(argumentCollection=arguments);
			
			/** 
				If the user is already a Corporate Administrator and they are renewing to a
				SINGLE Subscription product, we must create a brand new Subscription as you cannot downgrade
				in a renewal
			**/
			if(qryUser.UserTypeID EQ 5 AND arguments.strSession.strSubscribe.ProductID EQ 1)
			{
				//Mark this order as not being a renewal as we want a new sub to be created
				arguments.isRenewal = 0;
				
				//Mark the order as being a downgrade as it gets treated in a special way
				arguments.downgrade = 1;
			}
			
			/*
			**	3. Now create the user subscription if the order includes a subscription component
			** (and this is not a renewal order) and is NOT the Book only order
			*/
			if ((arguments.strSession.strSubscribe.ProductType EQ "Subscription" OR arguments.strSession.strSubscribe.ProductType EQ "Package") AND arguments.isRenewal NEQ 1)
			{
				//First set up start and end dates for subscription
				
				//If this is a downgrade renewal from Corporate Sub to Single Sub
				if(arguments.downgrade EQ 1)
				{					
					/**
					** If the current subscription period expired before today's date
					** or it's been cancelled/deleted,
					** start the new subscription period from today 	
					**/
					if (dateCompare(arguments.strSession.strSubscribe.CurrentEndDate, now()) LT 0 OR arguments.strSession.strSubscribe.currentSubscriptionStatusID EQ 4)
					{
						arguments.strSession.strSubscribe.newStartDate = DateFormat(now(), 'dd/mmm/yyyy');
					}
					//Otherwise start it the day after the current subscription's end date
					else
					{
						arguments.strSession.strSubscribe.newStartDate = DateFormat(DateAdd('d',1,arguments.strSession.strSubscribe.CurrentEndDate), 'dd/mmm/yyyy');
					}
					
					arguments.strSession.strSubscribe.newEndDate  = DateFormat(DateAdd('d',370,arguments.strSession.strSubscribe.newStartDate), 'dd/mmm/yyyy');
					
					/**
					** If the start date of the new sub period is before or equal to current date,
					** set its status to active and mark it as the most current sub period for subscriber
					**/
					if(DateCompare(arguments.strSession.strSubscribe.newStartDate, now()) LTE 0)
					{
						arguments.subscriptionStatusID = 1;
						arguments.isCurrent = 1;
					}
					
					/**
					** Otherwise set it to suspended and do not mark it as most current sub period.
					** This will be done by the scheduled task when it the current active sub period expires
					**/
					else
					{
						arguments.subscriptionStatusID = 2;
						arguments.isCurrent = 0;
					}
				}
				
				//If this is just a normal new subscription order
				else
				{
					arguments.strSession.strSubscribe.newStartDate = DateFormat(now(), 'dd/mmm/yyyy');
					arguments.strSession.strSubscribe.newEndDate = DateFormat(DateAdd('d', 370, arguments.strSession.strSubscribe.newStartDate), 'dd/mmm/yyyy');
					arguments.isCurrent = 1;
				}
				
				//Now create the subscription
				arguments.strSession.strSubscribe.SubscriptionID = objDAO.createSubscription
																	(
																		OrderID = orderID
																		, UserID = arguments.UserID
																		, ProductID = arguments.ProductID
																		, SubscriptionStatusID = arguments.subscriptionStatusID
																		, StartDate = arguments.strSession.strSubscribe.newStartDate
																		, EndDate = arguments.strSession.strSubscribe.newEndDate
																		, isCurrent = arguments.isCurrent
																		, AllowableSubscribers = arguments.strSession.strSubscribe.allowableSubscribers
																		, notes = arguments.notes
																	);
			}
			
			/**
			** If this is a renewal order:
			** Create new subscription period
			**/
			else if(arguments.isRenewal EQ 1)
			{
				//arguments.strSession.strSubscribe.SubscriptionID = arguments.strSession.strAccess.subscriptionID;
				
				//Now create new subscription period
				SaveNewSubPeriod
				(
					OrderID = orderID
					, SubscriptionID = arguments.strSession.strSubscribe.SubscriptionID
					, strSession = arguments.strSession
					, isUpgrade = "false"
					, currentEndDate = arguments.strSession.strSubscribe.CurrentEndDate
				);
			}
			
		
			//4. Save invoice data
			invoiceFilename = objInvoice.saveInvoiceData(orderID, arguments.UserID);
				
			// If this is a Corporate Subscription, commit and get the AccessCode / key...
			if (arguments.ProductID EQ 2)
			{
				//Get/Commit access code
				arguments.strSession.strSubscribe.accessCode = request.objBus.objSubscriptions.commitAccessCode(subscriptionID = arguments.strSession.strSubscribe.subscriptionID);
					
				//email access code to user
				request.objBus.objEmail.SendCorporateAccessCode
				(
					qryUser.Email
					, arguments.strSession.strSubscribe.accessCode
					,  qryUser.fullname 
				);
						
			}
			else
				arguments.strSession.strSubscribe.accessCode = '';
			
			//5. Send confirmation Email		
			request.objBus.objEmail.emailNotification
			( 
				strUserDetails 		= arguments.strsession.strSubscribe.strUser
				, SubscriptionID 	= arguments.strSession.strSubscribe.subscriptionID 
				, PaymentStatus 	= 2
				, ProductID 		= arguments.ProductID
				, subscribers_link 	= arguments.corpSubLink
				, admin_user 		= 1
				, corpEmail			= qryUser.Email
				, attachmentPath 	=  "#variables.strConfig.strPaths.invoiceDir##invoiceFilename#"
			);
			
			//6. Set the subscription to local variable before deleting the strSubscribe struct from the session		
			subscriptionID = arguments.strSession.strSubscribe.subscriptionID;
			arguments.strSession = StructDelete(arguments.strSession, "strSubscribe");
			
			return subscriptionID;	
		</cfscript>
		
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="SaveSubStatus" output="false" returntype="Numeric" access="public" hint="Save any changes to an existing subscription's status">
		<cfargument name="SubscriptionID" 				type="numeric" 	required="yes">
		<cfargument name="SubscriptionStatusID" 		type="numeric" 	required="yes">
		<cfargument name="CurrentSubscriptionPeriodID" 	type="numeric" 	required="yes">
		<cfargument name="SubscriptionEndDate"			type="String"	required="yes">
		<cfargument name="notes"			type="String"	required="yes">
		
		<cfreturn objDAO.SaveSubStatus(argumentCollection=arguments)>

	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="SaveSubAdjustment" output="false" returntype="Numeric" access="public" hint="Save any mid-term adjustment/upgrade changes to an existing subscription">
		<cfargument name="SubscriptionID" 				type="numeric" 	required="yes">
		<cfargument name="CurrentSubscriptionTypeID"	type="numeric" 	required="yes">
		<cfargument name="NewSubscriptionTypeID" 		type="numeric" 	required="yes">
		<cfargument name="PreviousOrderID" 				type="numeric" 	required="yes">
		<cfargument name="PaymentMethodID" 				type="numeric" 	required="yes">
		<cfargument name="UserID" 						type="numeric"	required="yes">
		<cfargument name="CampaignCode" 				type="string"	required="yes">
		<cfargument name="EUVatNumber" 					type="string"	required="yes">
		<cfargument name="strSession" 					type="struct"	required="yes" 	hint="str of the session scope">
		
		<cfset var strOrder 	= StructNew()>
		<cfset var paymentType 	= "">
		<cfset var newOrderID	= 0>
		<cfset arguments.isUpgrade	= 1>
			
		<!--- Convert shipping address data from wddx --->
		<cfif isDefined("arguments.strSession.strSubscribe.qryCurrentOrder.ShippingAddressXML")>
			<cfwddx action="wddx2cfml" input="#arguments.strSession.strSubscribe.qryCurrentOrder.ShippingAddressXML#" output="arguments.strSession.strSubscribe.strShipping">
		</cfif>
		
		<cfscript>			
			if(arguments.PaymentMethodID EQ 1)
			{
				paymentType = "Credit Card";
			}
			else
			{
				paymentType = "Invoice";
			}
			
			/* 
			**	Depending on whether the user has opted for a pure swap in their subscription type
			**	(i.e. from Supplier to Manufacturer or vice-versa) or for an upgrade to one of the full
			**	subscription packages, the business logic will differ
			*/
			
			//If user has opted to just swap one 'Lite' sub for another, we need to just
			// modify the relevant subscription period and order data
			if(arguments.NewSubscriptionTypeID EQ 2 OR arguments.NewSubscriptionTypeID EQ 3)
			{
				arguments.OrderID = arguments.PreviousOrderID;
				instance.objDAO.SaveSubAdjustment(argumentCollection=arguments);
			}
		
			else
			{
				//If user has upgraded to the Full Subscription, we need to first cancel the current
				//subscription period before creating a new one for the full sub
				instance.objDAO.SaveSubStatus
				(
					SubscriptionID 					= arguments.SubscriptionID
					, SubscriptionStatusID 			= 4
					, CurrentSubscriptionPeriodID 	= arguments.strSession.strSubscribe.qryCurrentOrder.SubscriptionPeriodID
					, isCurrent						= 0
					, SubscriptionEndDate			= arguments.strSession.strSubscribe.qryCurrentOrder.EndDate
				);
				
				//Set up parameters needed for calculating price
				arguments.strSession.strSubscribe.productID 		= arguments.NewSubscriptionTypeID;
				arguments.strSession.strSubscribe.campaignCode 		= arguments.CampaignCode;
				arguments.strSession.strSubscribe.productQuantity 	= 1;
				arguments.strSession.strSubscribe.euVATNumber 		= arguments.EUVatNumber;
				
				arguments.strSession.strSubscribe.qryOrderLine 		= 0; 
				
				//Get Order price before P&P
				strOrder = GetOrderPrice(session.strSubscribe.campaignCode, session.strSubscribe.productID, 1);
				
				arguments.strSession.strSubscribe.qryOrderLine 		= strOrder.qryGetOrderPrice;
				arguments.strSession.strSubscribe.qryPostageRates 	= strOrder.qryGetPostageRates;
				arguments.strSession.strSubscribe.Total 			= strOrder.ProductPrice;
				arguments.strSession.strSubscribe.ProductName 		= strOrder.qryGetOrderPrice.Product;
				
				arguments.baseOrderID								= arguments.PreviousOrderID;
		
				//Now determine final figures for product, p&p, discounts, VAT, etc
				// Send payment type as "Invoice" so that no online payment discount is applied
				arguments.strSession = SetFinalPrice("Invoice", arguments.strSession);
				
				//Now process the upgrade
				newOrderID = SaveUpgradeOrder(argumentCollection=arguments);
				
				//Finally, create a new Subscription Period with the new Order
				SaveNewSubPeriod
				(
					OrderID 			= newOrderID
					, SubscriptionID 	= arguments.SubscriptionID
					, strSession 		= arguments.strSession
					, isUpgrade 		= arguments.isUpgrade
				);
			}
			
			//Finally clear the subscribe structure in session
			arguments.strSession = StructDelete(arguments.strSession,"strSubscribe");
		</cfscript>
		
		<cfreturn arguments.SubscriptionID>
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="SaveUpgradeOrder" output="false" returntype="Numeric" access="public" hint="Save upgrade to an existing subscription">
		<cfargument name="SubscriptionID"	type="numeric" required="true">
		<cfargument name="PaymentMethodID" 	type="numeric" 	required="yes">
		<cfargument name="UserID" 			type="numeric"	required="yes">
		<cfargument name="isUpgrade" 		type="numeric" 	required="yes"	hint="indiactes whether this order is an upgrade">
		<cfargument name="baseOrderID" 		type="numeric" 	required="yes" 	hint="ID of order that is been upgraded">
		<cfargument name="strSession" 		type="struct"	required="yes" 	hint="str of the session scope">
		<cfargument name="objUser" 			type="his_rd.library.components.User.User" 			required="false" 	default="#application.strObjs.objUser#">
		<cfargument name="objInvoice" 		type="his_rd.library.components.Invoice.Invoice" 	required="false" 	default="#application.strObjs.objInvoice#">
		
		<cfscript>
			//Declare our variables
			var strRegistrationSelects  = "";
			var qryUser					= "";
			var newOrderID				= "";
			var invoiceFileName			= "";
			
			arguments.OrderStatusID 		= 2;  //Default Order Status to completed
			arguments.ProductID				= arguments.strSession.strSubscribe.ProductID;
			arguments.CampaignCode			= arguments.strSession.strSubscribe.CampaignCode;
			arguments.SubscriptionStatusID 	= 2; //Default Subscription Status to suspended
			arguments.quantity 				= 1; //Upgrades can only ever have a quantity of 1
			arguments.PurchaseOrderNumber 	= arguments.strSession.strSubscribe.purchaseOrderNumber; //Purchase Order Number

			
			//1. Retrieve details about User
			qryUser = arguments.objUser.GetUserByID(arguments.UserID);
		
			//2. Save the order and get Order ID back 
			newOrderID = saveOrder(argumentCollection=arguments);
		
			//3. Save invoice data 
			invoiceFilename = arguments.objInvoice.saveInvoiceData(newOrderID, arguments.UserID);
			
			//4. Send confirmation Email
			sendConfirmationEmail
			(	
				subscriptionID 	= arguments.subscriptionID
				, orderID 		= newOrderID
				, userFullName 	= "#qryUser.forename# #qryUser.surname#"
				, userEmail 	= qryUser.Email
				, attachment 	= invoiceFilename
				, isRenewal 	= 0
				, isUpgrade		= 1
				, username 		= qryUser.Username
				, password 		= Decrypt(qryUser.Password, instance.strConfig.strVars.Encrypt_key)
			);		
		
			return newOrderID;
			
		</cfscript>

	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="SetSubscriptionDates" output="false" returntype="void" access="public" hint="Setup the start date and the end date of anew subscription period">
		<cfargument name="ImportUser" 					type="numeric"	required="true">
		<cfargument name="IsRenewal" 					type="numeric"	required="true">
		<cfargument name="CurrentStartDate" 			type="string"	required="true">
		<cfargument name="CurrentEndDate" 				type="string"	required="true">
		<cfargument name="NewDateEnd" 					type="string"	required="true">
		<cfargument name="CurrentSubscriptionStatusID"	type="string"	required="true">
		<cfargument name="strSubscribe"					type="struct"	required="true">
		
		<cfscript>
			/*
			** If an existing user is being imported from the old website, we will allow the expiry date of their 
			** subscription to be set manually. This will not be avaiilable on renewal though
			*/
			if(arguments.ImportUser EQ 1)
			{
				arguments.strSubscribe.newStartDate = DateFormat(now(), 'dd/mmm/yyyy');
				arguments.strSubscribe.newEndDate 	= DateFormat(arguments.NewDateEnd, 'dd/mmm/yyyy');
			}
			
			/* 
			**	Otherwise, determine the start date of the subscription period depending on whether there is a valid 
			**	current end date and whether that is in the future or in the past. Then calculate the new end date
			*/
			else
			{
				// If the current subscription has expired or cancelled or this is a new subscription
				if(dateCompare(arguments.CurrentEndDate, now()) LT 0 OR arguments.CurrentEndDate EQ '' OR arguments.CurrentSubscriptionStatusID EQ 4)
				{
					arguments.strSubscribe.newStartDate = DateFormat(now(), 'dd/mmm/yyyy');
				}
				// Else the current subscription period has not expired yet
				else
				{
					arguments.strSubscribe.newStartDate = DateFormat(DateAdd('d',1,arguments.CurrentEndDate), 'dd/mmm/yyyy');
				}
				arguments.strSubscribe.newEndDate = DateFormat(DateAdd('d', 370, arguments.strSubscribe.newStartDate), 'dd/mmm/yyyy');
			}
			
		</cfscript>
		
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="SaveNewSubPeriod" output="false" returntype="Numeric" access="public" hint="Create a new subscription period for an existing subscriber">
		<cfargument name="OrderID" 			type="numeric" 	required="true">
		<cfargument name="SubscriptionID"	type="numeric" 	required="true">
		<cfargument name="strSession" 		type="struct"	required="true"  hint="str of the session scope">
		<cfargument name="isUpgrade"		type="numeric"	required="false" default="false">
		<cfargument name="currentEndDate"	type="String"	required="false" hint="The end date of the current subscription">
		
		<cfscript>
			var newSubscriptionPeriodID = 0;
			
			if(arguments.isUpgrade EQ 1)
			{
				arguments.newStartDate = DateFormat(arguments.strSession.strSubscribe.qryCurrentOrder.StartDate, 'dd/mmm/yyyy');
				arguments.newEndDate  = DateFormat(arguments.strSession.strSubscribe.qryCurrentOrder.EndDate, 'dd/mmm/yyyy');
				arguments.newSubscriptionStatusID = 1;
				arguments.isCurrent = 1;
			}
			else
			{
				/**
				** If the current subscription period expired before today's date
				** start the new subscription period from today 	
				**/
				if (dateCompare(arguments.currentEndDate, now()) LT 0 OR arguments.strSession.strSubscribe.currentSubscriptionStatusID EQ 4)
				{
					arguments.newStartDate = DateFormat(now(), 'dd/mmm/yyyy');
				}
				//Otherwise start it the day after the current subscription's end date
				else
				{
					arguments.newStartDate = DateFormat(DateAdd('d',1,arguments.currentEndDate), 'dd/mmm/yyyy');
				}
				
				arguments.newEndDate  = DateFormat(DateAdd('d',370,arguments.newStartDate), 'dd/mmm/yyyy');
				
				/**
				** If the start date of the new sub period is before or equal to current date,
				** set its status to active and mark it as the most current sub period for subscriber
				**/
				if(DateCompare(arguments.newStartDate, now()) LTE 0)
				{
					arguments.newSubscriptionStatusID = 1;
					arguments.isCurrent = 1;
				}
				
				/**
				** Otherwise set it to suspended and do not mark it as most current sub period.
				** This will be done by the scheduled task when it the current active sub period expires
				**/
				else
				{
					arguments.newSubscriptionStatusID = 2;
					arguments.isCurrent = 0;
				}
			}
			
			newSubscriptionPeriodID = objDAO.SaveNewSubPeriod(argumentCollection=arguments);
		</cfscript>
		
		<cfreturn newSubscriptionPeriodID>

	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="GetOrderByID" output="false" returntype="query" access="public" hint="Get Order By ID">
		<cfargument name="OrderID" type="numeric" required="true">
		
		<cfreturn objDAO.GetOrderByID(arguments.OrderID)>
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="GetProducts" output="false" returntype="query" access="public" hint="Get available products">
		
		<cfreturn objDAO.getProducts()>

	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="GetRateFromCampaign" output="false" returntype="query" access="public" hint="Get Order By ID">
		<cfargument name="CampaignCode" type="string" required="true">
		
		<cfreturn objDAO.GetRateFromCampaign(arguments.CampaignCode)>

	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="GetRenewalProducts" output="false" returntype="struct" access="public" hint="Get available products for RENEWALS only">
		<cfargument name="CurrentProductID"	type="numeric" required="true">
		
		<cfreturn objDAO.GetRenewalProducts(arguments.CurrentProductID)>

	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="GetRenewedSubscription" output="false" returntype="Query" access="public" hint="Get any renewed subscription periods for specified subscription">
		<cfargument name="SubscriptionID" type="numeric" required="true">
		
		<cfreturn objDAO.GetRenewedSubscription(arguments.SubscriptionID)>

	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="search" output="false" returntype="Query" access="public" hint="search orders / invoices">
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
		
		<cfreturn objDAO.search(argumentCollection=arguments)>

	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="LookUps" output="false" returntype="Struct" access="public" hint="Get Lookups for Orders">
		<cfreturn objDAO.LookUps()>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="ChangeOrderStatus" output="false" returntype="void" access="public" hint="Change the status of an existing Order">
		<cfargument name="orderID" 			type="numeric" required="yes">	
		<cfargument name="orderStatusID"    type="numeric" required="yes"> 

		<cfset objDAO.ChangeOrderStatus(argumentCollection=arguments)>
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="CompleteOrder" output="false" returntype="String" access="public" hint="Execute remaining functions for completing an Order paid for by Credit Card">
		<cfargument name="orderID"  				type="numeric" 	required="yes"	/>
		<cfargument name="isRenewal"  				type="numeric" 	required="yes"	/>
		<cfargument name="subscriptionID"  			type="numeric" 	required="yes"	/>
		<cfargument name="orderStatusID"     		type="numeric" 	required="yes" 	/>	
		<cfargument name="subscriptionStatusID"		type="numeric" 	required="yes"	/>
		<cfargument name="worldpayTransactionID"	type="numeric" 	required="yes"	/>
		<cfargument name="strSession" 				type="struct" 	required="yes" 	/>
		<cfargument name="corpSubLink" 				type="string" 	required="yes" 	/>
	
		<cfscript>
			var invoiceFilename = "";
			var totalDue = 0;
			
			// 1. Retrieve current Invoice data for this order
			var strInvoiceData = request.objBus.objInvoice.getInvoiceData(arguments.orderID);			
			
			// 2. Update Order to mark it as completed and activate subscription
			//THIS IS NOW DONE ON THE CALL BACK PAGE
			//updateOrder(argumentCollection=arguments);
			
			// If the order has not already had an invoice generated for it, create one and send confirmation email
			if(NOT Len(strInvoicedata.qryUserDetails.InvoiceNo) OR NOT Len(strInvoicedata.qryUserDetails.InvoiceFileName))
			{
				// 3. Now create invoice if none has already been created
				invoiceFilename = request.objBus.objInvoice.saveInvoiceData(OrderID=arguments.orderID, UserID=session.userDetails.UserID);
				
				// 4. If this is a Corporate Subscription, commit and get the AccessCode / key...
				if (arguments.strSession.strSubscribe.ProductID eq 2)
				{
					//Get/Commit access code
					arguments.strSession.strSubscribe.accessCode = request.objBus.objSubscriptions.commitAccessCode(subscriptionID = arguments.strSession.strSubscribe.subscriptionID);
					
					//email access code to user
					request.objBus.objEmail.SendCorporateAccessCode
					(
						arguments.strSession.userDetails.username
						, arguments.strSession.strSubscribe.accessCode
						,  arguments.strSession.userDetails.fullname 
					);
						
				}
				else
					arguments.strSession.strSubscribe.accessCode = '';
				
				// 5. Send confirmation email
				objEmail.emailNotification
				( 
					strUserDetails 		= arguments.strSession.userDetails 
					, SubscriptionID 	= arguments.strSession.strSubscribe.subscriptionID 
					, PaymentStatus 	= 2
					, ProductID 		= arguments.strSession.strSubscribe.ProductID
					, subscribers_link 	= arguments.corpSubLink
					, admin_user 		= 1
					, corpEmail			= arguments.strSession.userDetails.username
					, attachmentPath 	=  "#variables.strConfig.strPaths.invoiceDir##invoiceFilename#"
				);	
			}
			
			//Otherwise, set the existing invoice filename back into memory for display purposes
			else
			{
				invoiceFilename = strInvoicedata.qryUserDetails.InvoiceFileName;
			}
			
			/**
				6. Retrieve Invoice data for this order again so that we can access the total due 
				value which has now been calculated 
			**/
			strInvoiceData = request.objBus.objInvoice.getInvoiceData(arguments.orderID);
			
			// If the total to pay is not in the session, retrieve total to pay value 
			// and set back into session
			if(NOT StructKeyExists(arguments.strSession.strSubscribe, "TotalToPay") OR arguments.strSession.strSubscribe.TotalToPay EQ "0.00")
			{
				totalDue = strInvoicedata.qryUserDetails.TotalDue;
				arguments.strSession.strSubscribe.TotalToPay = totalDue;
			}
		
			return invoiceFilename;
		</cfscript>

	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="IncompleteOrder" output="false" returntype="void" access="public" hint="Send email to support about Incomplete Order">
		<cfargument name="WorldpayTransactionID"  	type="string" 	required="yes">
		<cfargument name="objEmail" 				type="his_rd.library.components.utils.email" required="false" default="#application.strObjs.objEmail#">
		
		<cfscript>
			var toAddress		=	application.strConfig.strVars.webmaster;
			var body			= 	"A user paid for an Order on The Retail Directory through WorldPay but an error occurred on their return to the website. Their session could not be located.";
			var emailBody		= 	"";
			var from 			= 	application.strConfig.strVars.mailsender;
			var bcc				= 	"";
			var cc				= 	"";
			var subject 		= 	"Incomplete Order - Worldpay TransactionID #arguments.WorldpayTransactionID#";
			//var attachmentPath 	=   "#application.strConfig.strPaths.siteDir#\#application.strConfig.strPaths.invoiceDir##arguments.attachment#";
		</cfscript>
		
		
		<cfset arguments.objEmail.send(toAddress,body,subject,from,bcc,cc)>

	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="GetRateCards" output="false" returntype="query" access="public" hint="Get List of Rate Cards">
		<cfreturn objDAO.GetRateCards()>
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="GetCampaignInfo" output="false" returntype="query" access="public" hint="Get Info on Specified Campaign Code">
		<cfargument name="CampaignID"	type="numeric" required="yes">
		<cfargument name="DefaultCode"	type="numeric" required="no" default="0">
		
		<cfreturn objDAO.GetCampaignInfo(argumentCollection=arguments)>
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
		
		<cfreturn objDAO.SaveCampaign(argumentCollection=arguments)>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="OrderReport" output="false" returntype="query" access="public" hint="Runs a full report on orders placed">
		<cfargument name="productID" type="numeric" required="yes">
		<cfargument name="dateStart" type="date" required="yes">
		<cfargument name="dateEnd" type="date" required="yes">
				
		<cfreturn objDAO.OrderReport(argumentCollection=arguments)>
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="saveOrderNotes" output="false" access="public" hint="Save order notes">
		<cfargument name="notes" type="string" required="yes">
		<cfargument name="orderid" type="numeric" required="yes">
		
		<cfset objDAO.saveOrderNotes(arguments.notes, arguments.orderid)>
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="uuidOrderCheck" output="false" returntype="query" access="public" hint="">
		<cfargument name="uuid" type="string" required="yes">
				
		<cfreturn objDAO.uuidOrderCheck(uuid=arguments.uuid)>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getPriceByCampaign" output="false" returntype="query" access="public" hint="">
		<cfargument name="campaginCode" 	type="string" required="yes">
		<cfargument name="productID" 		type="numeric" required="yes">
		<cfargument name="TermID" 			type="string" 	required="no" default="">
				
		<cfreturn objDAO.getPriceByCampaign(argumentCollection=arguments)>
	</cffunction>
</cfcomponent>