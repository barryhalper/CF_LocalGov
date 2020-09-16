<cfcomponent displayname="DataSales" hint="<component description here>" extends="his_Localgov_Extends.components.BusinessObjectsManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="DataSales" hint="Pseudo-constructor">
	
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
	<!--- PUBLIC Functions ------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getVariables" access="public" output="false" returntype="struct" 
				hint="returns varaiables cope of this object">
		<cfreturn variables>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getSetListTypes" access="public" output="false" returntype="query" 
				hint="return a query containing the set list types">
		<cfreturn objDAO.getSetListTypes()>	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="getSetLists" access="public" output="false" returntype="query" 
				hint="return a query containing the set list, based on data provided">
		
		<cfargument name="refresh" 	  type="boolean" required="false" default="0">
		
		<cfscript>
		// Local variable declarations...
		var qrySetLists = "";
		
		if (StructKeyExists(variables, "qrySetLists") AND NOT arguments.refresh)
			// ...code...		
			qrySetLists = variables.qrySetLists;
		else{
			qrySetLists = objDAO.getSetLists();	
			variables.qrySetLists=qrySetLists;
			}
		
		return qrySetLists;		
		</cfscript>
		
		<cfreturn qry>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="getSetListByID" access="public" output="false" returntype="query" 
				hint="return a query containing the set list info ">
		
		<cfargument name="ListTypeID" type="string" required="false" default="0">
		 
		<cfreturn objUtils.queryOfquery(getSetLists(), '*', 'p_setlist_id IN (#arguments.listTypeID#)')>
		
	</cffunction>
    
  
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getOrder" access="public" output="false" returntype="query" 
				hint="return a query containing the order for a specified order id">
		
		<cfargument name="orderID" 	type="string" 	required="true">
				
		<cfreturn objDAO.getOrder(arguments.orderID)>
		
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getOrders" access="public" output="false" returntype="query" 
				hint="return a query containing the orders, to be used for the admin search">
				
		<cfargument name="person_name" 			type="string" 	required="true">
		<cfargument name="company_name" 		type="string" 	required="true">
		<cfargument name="seed" 				type="string" 	required="true">
		<cfargument name="orderID" 				type="string" 	required="true">
		<cfargument name="purchaser_address" 	type="string" 	required="true">
		
		<cfreturn objDAO.getOrders(orderID=			arguments.orderID)>
		
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="processOrder" access="public" output="false" returntype="array"
				hint="Process a succesfull Order and return array of lists and file to calling page">
		<cfargument name="strSession"	type="struct"  	required="yes">			
		<cfargument name="orderID"		type="numeric" 	required="yes">
		<cfargument name="statusID"		type="numeric"  required="yes">	
		<cfargument name="OrderPath"	type="string"   required="no" default="#strConfig.StrPaths.DirPath#datasales\setlists\OrderID_#arguments.orderID#\">	
	
			<cfscript> 
			var arrLists 	= arrayNew(1);
			var arrFileName = arrayNew(1);
			//set order to completed
			updateOrderLineStatus(arguments.orderID,arguments.statusID );
			//get set list that have been ordered
			arrLists 		= getSetListsFromOrder(getOrder(arguments.orderID));
			//seed the list
			arrLists 		= insertSeed(arrLists, arguments.orderID, strSession);
			//Create files and set into array fro attachments 
			arrFileName 	= generateFile(arrLists, arguments.orderID,  arguments.OrderPath);
			
			// add invoice to attachments 
			ArrayAppend( arrFileName, strConfig.StrPaths.invoicedir & strSession.datasalepurchaser.INVOICEFILE);
			
			//request.objAPP.objUtils.dumpabort(arrFileName);
			
			// email customer sevices
			objEmail.emailCSDataSales(arguments.orderID, arguments.strSession, arrFileName);
			return 	arrLists;
			</cfscript>		
					
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="commitOrder" output="false" returntype="struct" 
			hint="Commit the order and order line">
		
		<cfargument name="strSession"			type="struct" required="yes">
		<cfargument name="payment_method"		type="numeric"  required="yes">
		
		<cfscript>
		var userID= 		0;
		var orderID= 		0;
		var orderLineIDs= 	"";
		var PENDING=		1;
		var i=				0;
		var thisVAT	= 0;
		
		if (structKeyExists(arguments.strSession.userDetails, "userID"))
			userID= arguments.strSession.userDetails.userID;
		
		// todo: encapsulate in transaction block
		
		//commit order
		orderID= objDAO.commitOrder( 
								userID=				userID,
								PaymentMethod=		arguments.payment_method,
								dataPurchaserXML=	objUtils.createWDDXPacket(dataInput=arguments.strSession.dataSalePurchaser),
								abOrderPrice = arguments.strSession.strdatasalestotal.TOTALAFTERSUBDISCOUNT
							);
		
		for (i=1; i lte arrayLen(arguments.strSession.dataSalesLists); i=i+1) {
			
			if (arguments.strSession.dataSalesLists[i].TOTALVAT eq 0)
				thisVAT = 0;
			else
				thisVAT = strConfig.strVars.vat_uk;
			
			//commit orderline
			orderLineID= objDAO.commitOrderLine( 
									orderID =			orderID,
									productID =			5,
									ComponentQuantity =	1,									
									dataSalesXML =		objUtils.createWDDXPacket(dataInput=arguments.strSession.dataSalesLists[i]),
									ComponentID = 0,
									ListPrice = arguments.strSession.dataSalesLists[i].CALCULATEDPRICE,
									ProductPercentage = 100,
									TermPrice = arguments.strSession.dataSalesLists[i].CALCULATEDPRICE,
									VATRate = thisVAT,
									DiscountedPrice = arguments.strSession.dataSalesLists[i].TOTALAFTERDISCOUNT,
									AbsolutePrice = arguments.strSession.dataSalesLists[i].TOTALAFTERDISCOUNT,
									VATAmount = arguments.strSession.dataSalesLists[i].TOTALVAT,
									isInvoiceable = 1
								);
			orderLineIDs= listAppend(orderLineIDs, orderLineID);
		}
		
		strRtn.orderID= 		orderID;
		strRtn.orderLineIDs=	orderLineIDs;
		
		return strRtn;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="commitFilename" output="false" returntype="void" 
			hint="Commit the filename of the generated list to the orderline table">
		<cfargument name="arr" type="array" required="yes" hint="array containg struct of filenames and orlineid">
				
		<cfset objDAO.commitFilename(arguments.arr)>				

	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="commitSeedOrder" output="false" returntype="void" 
		hint="Commits the seed and order ids to the lookup table">
		
		<cfargument name="seedId" 		type="numeric" required="yes">
		<cfargument name="orderLineId"	type="numeric" required="yes">
		<cfargument name="qry"			type="query" required="yes">
		
		<cfset arguments.seedXml = objUtils.createWDDXPacket(dataInput=arguments.qry)>
		<!--- <cfdump var="#arguments#"><cfabort> --->
		<cfset objDAO.commitSeedOrder(argumentCollection=arguments)>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- --------------------------------------------------------------------------------------------------
	<cffunction name="addSeedtoSession" output="false" returntype="void" 
		hint="turns the query that holds the seed into xml via wddx and stored it into the session">
		
		<cfargument name="strSession" 		type="struct" required="yes">
		<cfargument name="qry" 				type="query" required="yes">
		<cfargument name="ListId"				type="numeric" required="yes">
		
		<cfscript>
			var i				= 0;
			for (i=1; i lte arrayLen(arguments.strSession.dataSalesLists); i=i+1) {
					if (arguments.strSession.dataSalesLists[i].ListTypeid eq ListId){
						arguments.strSession.dataSalesLists[i].seeds = objUtils.createWDDXPacket(dataInput=arguments.qry);
						break;
						}
				
		</cfscript>
		
	</cffunction>--->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="commitSetList" output="false" returntype="void" 
		hint="Commits setlists to the db">
		
		<cfargument name="p_setlist_id" type="numeric" required="yes">
		<cfargument name="name"			type="string" required="yes">
		<cfargument name="description"	type="string" required="yes">
		<cfargument name="cost"			type="numeric" required="yes">
		
		<cfset objDAO.commitSetList(
								arguments.p_setlist_id, 
								arguments.name,
								arguments.description,
								arguments.cost
							)>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="updateOrderLineStatus" output="false" returntype="void" 
			hint="Update order status in the order line table for a specified order id">
		
		<cfargument name="orderID"		type="numeric" required="yes">
		<cfargument name="statusID"	type="numeric"  required="yes">
		
		<cfscript>
			return objDAO.updateOrderLineStatus( 
								orderID=	arguments.orderID,
								statusID=	arguments.statusID
							);
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="getSetList" access="public" output="false" returntype="query" 
				hint="return a query containing the set list, based on data provided">
		
		<cfargument name="listTypeId" 	type="string" 	required="true">
		
		<cfscript>
		// Local variable declarations...
		var qrySetList = "";
		
		qrySetList= 	objDAO.getSetListData(listTypeId = arguments.listTypeId);
		
		return qrySetList;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="getSetListsFromOrder" access="public" output="true" returntype="array" 
				hint="return an array containing a query that represents each list purchased">
		
		<cfargument name="qryOrder" 	type="query" 	required="true">
		
		<cfscript>
		// Local variable declarations...
		var arrSetLists		= arrayNew(1);
		var qry				= arguments.qryOrder;
		var str				= structNew();
		var i				= 0;
		var qrySetList		= "";
		</cfscript>

		<cfloop query="qry">
			
			<cfwddx action="wddx2cfml" input="#qry.dataSalesXML#" output="str">
			<cfscript>
			i							= qry.currentRow;	
			//insert into array a struct for each set list ...
			arrSetLists[i]				= str;
			//struct contains query
			//get set list data
			qrySetList					= getSetListData(listTypeID= 	arrSetLists[i].listTypeID);
			arrSetLists[i].qrySetList	= prepareDataForUser(arrSetLists[i].commMethods, qrySetList); 
			//struct contains orline							
			arrSetLists[i].orderLineID	= qry.orderlineid;
			</cfscript>
		</cfloop>

		<cfreturn arrSetLists>		
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="getSetListData" access="public" output="false" returntype="query" 
				hint="return a query containing the set list for a given list type if">
		<cfargument name="listTypeID"	type="numeric" required="true">
		
		<cfscript>
		var qrylist = objDAO.getSetListData(listTypeID); 
		if (ListContainsNocase(qrylist.columnlist, "OtherFunctions")){
			//rewrite query to turn extra funtions into extra columns
			qrylist = objUtils.CreateExtraColumns(qrylist, 'OtherFunctions', 'Function', 4);
			}	
		return 	qrylist;
		</cfscript>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="prepareDataForUser" access="public" output="false" returntype="query" 
				hint="return a query containing the set list for a given list type id">
		<cfargument name="strComm"	type="struct" required="true">
		<cfargument name="qry"		type="query" required="true">
			
		<cfscript>
		var columns2Remove 	= "";
		var qrylist 			= arguments.qry;
		var lstColumns4SetList 	= qrylist.columnList;
		var lstColumns2Remove 	= listAppend(strConfig.strVars.ds_addressColumns, "Tel,Fax");
		var i=0;
		//loop over list of column's to remove
		for (i=1;i lte listLen(lstColumns2Remove);i=i+1)
		{
		//if column is in qry get position in column list
			pos	= listFindNoCase(lstColumns4SetList, listGetAt(lstColumns2Remove,i));
			if (pos)
			{
				//if present			
				lstColumns4SetList = listDeleteAt(lstColumns4SetList,pos);			
			}
		}
		
		//loop over array of comm methods
		for (x in strComm)
		{
		//evalute comm method for set list
			switch (x)
			{
				case 1:
				{
					//add address column names to column list
					lstColumns4SetList = listAppend(lstColumns4SetList,strConfig.strVars.ds_addressColumns );
					break;
				}
				case 2:
				{
					//add tel to columns
					lstColumns4SetList = listAppend(lstColumns4SetList, 'tel');
					break;
				}
				case 3:
				{
					//add fax to columns
					lstColumns4SetList = listAppend(lstColumns4SetList, 'fax');
					break;
				}
			}	
		}
		return objutils.queryofquery(qrylist, lstColumns4SetList);
	</cfscript>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="getOrgTypeIDfromListTypeID" access="public" output="false" returntype="numeric" 
				hint="return a the organisation type id from a specified list type id">
		
		<cfargument name="listTypeID"	type="numeric" required="true">
		
		<!--- todo: add caching... --->		
		<cfreturn objDAO.getOrgTypeIDfromListTypeID(arguments.listTypeID)>	
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="getListTypeIDFromOrgTypeID" access="public" output="false" returntype="numeric" 
				hint="return a the list type id from a specified organisation type id">
		
		<cfargument name="OrgTypeID"	type="numeric" required="true">
		
		<!--- todo: add caching... --->		
		<cfreturn objDAO.getListTypeIDFromOrgTypeID(arguments.OrgTypeID)>	
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="getOfficerFunctions" access="public" output="false" returntype="query" 
				hint="return a query containing the the officer functions">
		
		<cfscript>
		// Local variable declarations...
		var qryOfficerFunctions = "";

		// ...code...		
		qryOfficerFunctions 	= objDirectory.GetFunctions();
		
		return qryOfficerFunctions;		
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="generateFile" access="public" output="true" returntype="array" 
				hint="generates a physical file and returns an array containing the file(s) location">
		
		<cfargument name="arrLists" 	type="array" 	required="true">
		<cfargument name="orderID" 		type="numeric" 	required="true">
		<cfargument name="outputPath" 	type="string" 	required="true">
		<cfargument name="delimited" 	type="string" 	required="false" default=",">
		
		<cfscript>
		var arrFilename  =	arrayNew(1);
		var strLists	 =  structNew();
		</cfscript>
		
		<cfif not directoryExists(arguments.outputPath)>
			<!---create folder to store order --->
			<cfdirectory action="create" directory="#arguments.outputPath#">
		</cfif>
		
		<cfscript>
		for(i=1; i lte arrayLen(arrLists); i=i+1)
		{
			//create filename
			arrFilename[i]= "setlist_o" & arguments.orderID & "_" & replace(arrLists[i].listName, '/', '_','ALL');
			arrFilename[i] = replace(arrFilename[i],' ','_','ALL');
			arrFilename[i] = replace(arrFilename[i],'(','_','ALL');
			arrFilename[i] = replace(arrFilename[i],')','','ALL');
			arrFilename[i] = replace(arrFilename[i],'__','_','ALL');
									
			//build column lists for each query
			strLists = buildColumnLists(arrLists[i].qrySetList);
		
			//PHYISICALLY STORE DATA IN FILES 
			if (arrLists[i].format eq 1)
			{
				//create excel document
				variables.objUtils.Query2Excel(query=	arrLists[i].qrySetList, 
											columnList=	"#strLists.columnList#",
											headerList=	"#strLists.headerList#",
											file=		outputPath & arrFilename[i]
											);
				arrFilename[i] = 	arrFilename[i] & ".xls"	;				
			}
			else
			{
				//create CSV document
				variables.objUtils.QueryToCSV( query=		arrLists[i].qrySetList, 
												columnList=	"#strLists.columnList#",
												headerList=	"#strLists.headerList#",
												action=		"write",
												file=		outputPath & arrFilename[i],
												delimiter=	arguments.delimited
												);
				arrFilename[i] = 	arrFilename[i] & ".csv"	;								
			}							
			//add filename to db							
			//objDAO.commitFilename(orderLineID= 	arrLists[i].orderLineID, fileName=arrFilename[i]);
			arrLists[i].filename = arrFilename[i];
			
			//add path of file to the return array so they can be used as attachments		
			arrFilename[i] = outputPath & arrFilename[i];
		}
		//add filenames to db
		commitFilename(arrLists);
		
		return arrFilename;
		</cfscript>
		
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="insertSeed" access="public" output="true" returntype="array" 
				hint="inserts the seed instance (record) into the set list.  It also commits the seed instance to the respective database table.">
		
		<cfargument name="arrSetLists" 	type="array" 		required="yes" >
		<cfargument name="orderId" 		type="numeric" 	required="true">
		<cfargument name="strSession" 	type="struct" 		required="true">
		

		<cfscript>
		var arrNoOfSeeds	= arrayNew(1);
		var noOfSeeds		= 2;  // default, 550 or less records.
		var seedPos			= 0;
		var	i				= 0;
		var j				= 0;
		var k				= 0;
		var curList			= 0;
		var value			= "";
		
		// Determine the number of required seeds based on the the number of records...
		for (curList=1; curList lte arrayLen(arguments.arrSetLists); curList=curList+1)
		{
			records	= arguments.arrSetLists[curList].qrySetList.recordCount;
			
			// Determine the number of seeds required...
			if (records lte 550)
				noOfSeeds	= 2;
			else if (records gte 551 and records lte 1500)
				noOfSeeds	= 3;
			else
				noOfSeeds	= 4;		
				
			// get required base seeds...
			qrySeedList			= getBaseSeeds(noOfSeeds,arguments.arrSetLists[curList].listTypeId);
			
			// get the set list
			qrySetList			= arguments.arrSetLists[curList].qrySetList;
			
			//loop over the seed instances
			for (i=1; i lte qrySeedList.recordCount; i=i+1)
			{
				
				//add a new row into which the seed data will be populated
				queryAddRow(qrySetList,1);
				
				//loop over the set list column list to determine the column name for data retrieval
				for (j=1; j lte listLen(qrySetList.columnList); j=j+1)
				{
					//if the column exists in the seed list, get the data from the seed and add to set list
					if (listFindNoCase(qrySeedList.columnList,listGetAt(qrySetList.columnList,j),','))
						querySetCell(qrySetList,listGetAt(qrySetList.columnList,j),qrySeedList[listGetAt(qrySetList.columnList,j)][i]);
						
					//append the order id and set list id to the first line of the address as a Room number
					if (listFindNoCase(qrySeedList.columnList,'address1',',') AND listFindNoCase(qrySetList.columnList,'address1',','))
					{
						value = 'Room ' & arguments.orderId & '-' & arguments.arrSetLists[curList].listTypeId & ', ' & qrySeedList.address1[i];
						querySetCell(qrySetList,'address1',value);		
					}
					 
				}
			
				//add bogus data for organisation and functions to make result set more accurate
				k = randRange(1,qrySetList.recordCount); //random number to extract bogus data from set list query
								
				if (listFindNoCase(qrySetList.columnList,'jobtitle',','))
					querySetCell(qrySetList,'jobtitle',qrySetList.jobtitle[k]);
				
				if (listFindNoCase(qrySetList.columnList,'jobfunction',','))
					querySetCell(qrySetList,'jobfunction',qrySetList.jobfunction[k]);
				
				// Record the seed's relationship with the orderline...
				commitSeedOrder(qrySeedList.p_baseseed_id[i], arguments.arrSetLists[curList].orderLineID, qrySeedList);		
				
				// add seed to sesssion datasales xml
				//addSeedtoSession(arguments.StrSession, qrySetList, qrySeedList.listTypeID);
				
			}
				
			//reorder the query, now that the seeds are in place...
			if (listFindNoCase(qrySetList.columnList, "surname"))
				qrySetList	= objUtils.queryOfQuery(qrySetList, "*", "0=0", "surname");
			else
				qrySetList	= objUtils.queryOfQuery(qrySetList, "*", "0=0", "organisation");
									
			// Update the set list with the seeded one...
			arguments.arrSetLists[curList].qrySetList = qrySetList;
			
			
			
		}
				
		return arguments.arrSetLists;
		</cfscript>
	</cffunction>			
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getSeedInstances" access="public" output="true" returntype="query" 
				hint="return a query containing all seed instances">
		
		<cfreturn objDAO.getSeedInstances()>
					
	</cffunction>		
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getBaseSeeds" access="public" output="true" returntype="query" 
				hint="return a query containing the base seeds, used to generate seed instances">
		<cfargument name="noOfSeeds" 	required="yes"	type="numeric" >
		<cfargument name="listTypeId" 	required="no"	type="numeric" default="0" >
		
		<cfreturn objDAO.getBaseSeeds(arguments.noOfSeeds,arguments.listTypeId)>
	
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getSeedDetail" access="public" returntype="query" output="false">
		<cfargument name="seedId"  type="numeric"  required="true">
		
		<cfreturn objDAO.getSeedDetail(arguments.seedId)>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="calculateQuote" access="public" output="true" returntype="struct" 
				hint="calculates the cost of the selected lists">
		
		<cfargument name="strSession" 	type="struct" 	required="true">
		<cfargument name="listTypeIDs" 	type="string" 	required="true" hint="list of setlist id's">
		<cfargument name="listType" 	type="numeric" 	required="true" hint="indentify recordset type, 1 for all records and 2 for unique (deduped) dataset">

		<cfscript>
		// Local variable declarations...
		var listTypeid			= 0;
		var cost				= 0;
		var qryDedupedList		= "";
		var strReturn			= structNew();
		var strCost				= structNew();
		var outputFilename		= "";
		var noofrecords			= 0;
		var arrLists			= listToArray(arguments.listTypeIDs);			
		var CostPerRecord		= variables.strConfig.strVars.costperrecord;
	
		strReturn.all			= structNew();
		strReturn.deduped		= structNew();
		strReturn.filename		= "";
		

		// 1. Obtain number of records, based on supplied data...
		// 2. Obtain unit cost for the supplied data...
		
		for (i=1; i lte arrayLen(arrLists); i=i+1) {
					
			// Calculate the cost for each list and deduct discount for multiple communication methods.
			strCost 	= getCostPerList(arguments.strSession, arrLists[i]);
		
			// Assign the list total and discount to the session variable
			arguments.strSession.dataSalesLists[i].TotalAfterDiscount	= 	strCost.TotalAfterDiscount;
			arguments.strSession.dataSalesLists[i].Discount			 	= 	strCost.DiscountApplied;

			// Total Cost
			cost		= cost + strCost.TotalAfterDiscount;
			// Total number of records
			noofrecords	= noofrecords + strCost.totalRows;
		}
		
		// 3. Determine records and cost for all records...
		if (arguments.listType eq 1) {
			strReturn.all.recordCount		= noofrecords;
			strReturn.all.cost				= cost; // * strReturn.all.recordCount;
			strReturn.deduped.recordCount	= 0;
			strReturn.deduped.cost			= 0; // * strReturn.deduped.recordCount;
			
			strReturn.finaltotal 			= cost;
		}

		if (arguments.listType eq 2) {
			strReturn.deduped.recordCount	= noofrecords;
			strReturn.deduped.cost			= cost; // * strReturn.deduped.recordCount;
			strReturn.all.recordCount		= 0;
			strReturn.all.cost				= 0; // * strReturn.all.recordCount;
			
			strReturn.finaltotal 			= cost;
		}
		
		// 4. Return structure containing calulations...
		return strReturn;		
		</cfscript>
		
	</cffunction>	 
 	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="updateFormat" access="public" output="false" returntype="void" 
				hint="Updates the list format in the session scope">
		
		<cfargument name="strSession" 	type="struct" required="true">
		<cfargument name="idx" 		type="numeric" required="true">
		<cfargument name="formatId" type="numeric" required="true">

		<cflock scope="SESSION" type="EXCLUSIVE" timeout="#createTimeSpan(0,0,0,10)#">
			<cfset arguments.strSession.dataSalesLists[arguments.idx].format = arguments.formatId>
		</cflock>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="updateComm" access="public" output="false" returntype="void" 
				hint="Updates the list format in the session scope">
		
		<cfargument name="strSession" 	type="struct" 	required="true">
		<cfargument name="idx" 			type="numeric" 	required="true">
		<cfargument name="commMethod" 	type="numeric" 	required="true">
		<cfargument name="noOfUses" 	type="numeric"	required="true">

		<cflock scope="SESSION" type="EXCLUSIVE" timeout="#createTimeSpan(0,0,0,10)#">
			
			<cfscript>
			if (arguments.noOfUses eq 0)
			{
				structDelete(arguments.strSession.dataSalesLists[arguments.idx].commMethods,arguments.commMethod);
			}
			else
			{
				arguments.strSession.dataSalesLists[arguments.idx].commMethods[arguments.commMethod] = arguments.noOfUses;
			}
			</cfscript>
			
		</cflock>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="addToBasket" access="public" output="false" returntype="boolean" 
				hint="Updates the user's basket with desired list">
		
		<cfargument name="strSession" 	type="struct" required="true">
		<cfargument name="listTypeIDs" 	type="string" required="true"/>
		<cfargument name="listType" 	type="string" required="true"/>
		<cfargument name="commMethods" 	type="string" required="true"/>
		<cfargument name="format" 		type="string" required="false" default=""/>
		
		<!--- <cfdump var="#arguments#"><cfabort> --->
		
		<cfscript>
			var i = 0;
			var j = 0;
			var n = 0;
			var listsInBasket = "";
			var listTypeId = 0;
			var strList = StructNew();
			var arrLists = ListToArray(arguments.listTypeIDs);
			
			//First clear the currently stored lists in user's session
			arguments.strSession.dataSalesLists = arrayNew(1);
				
			//ONLY ADD to BASKET IF IT HAS LESS THAN 5 ELEMENTS			
			if (ArrayLen(arguments.strSession.dataSalesLists) lt 10) 
			{
				
				//create a list of setlist ids already present in basket
				/*for (n=1; n lte ArrayLen(arguments.strSession.dataSalesLists); n=n+1){
					listsInBasket = listAppend(listsInBasket,arguments.strSession.dataSalesLists[n].listTypeID);
					}*/
					
				//loop over listid that need to be added to the basket	
				for (i=1; i lte arrayLen(arrLists); i=i+1)
				{
					//check this list is not already present in basket
					if (NOT listFind(listsInBasket,arrLists[i]))
					{
						//**ADD TO BASKET 
						strList.format 		= 1;
						strList.listTypeId	= arrLists[i];
						strList.listType	= arguments.listType;
						strList.basePrice	= objUtils.queryofquery(qrySetLists, "*", "p_setlist_id=" & strList.listTypeId).cost;
						strList.calculatedPrice	= strList.basePrice;
						strList.listName		= getSetListById(strList.listTypeId).name;
						
						//if list name eq
						if (strList.listTypeId gte 25 and strList.listTypeId neq 96)
							strList.listName =strList.listName & " (Council Officers)";
						
						//build a structure of communication methods
						strList.commMethods	= structNew();
						for (j=1; j lte listLen(arguments.commMethods); j=j+1){
							strList.commMethods[listGetAt(arguments.commMethods,j)] = 1;
							}
						//append structure to basket array
						ArrayAppend(arguments.strSession.dataSalesLists,Duplicate(strList));
					}	
				}		
			}
			return false;
		</cfscript>		
			
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="deleteFromBasket" access="public" output="false" returntype="boolean" 
				hint="Updates the user's basket with desired list">
		
		<cfargument name="strSession" 	type="struct" required="true">
		<cfargument name="arrID" 		type="string" required="true"/>

			<cfreturn ArrayDeleteAt(arguments.strSession.dataSalesLists, arrID)>

	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="emptyBasket" access="public" output="false" returntype="boolean" 
				hint="Empties the user's basket">
		
		<cfargument name="strSession" 	type="struct" required="true">

		<cfscript>
			StructDelete(arguments.strSession,"dataSalesLists");
			StructDelete(arguments.strSession,"strdatasalestotal");
			StructDelete(arguments.strSession,"datasalepurchaser");
		</cfscript>
		
		<cfreturn true>
				
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------>
	<cffunction name="getSetListByFunction" access="public" returntype="query" output="false" 
				hint="return all job functions">
		<cfargument name="FunctionID" required="no" type="string" default="">	
		
		<cfscript>
		return objDAO.getSetListByFunction(arguments.FunctionID);	 
		</cfscript>
		
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="commitBaseSeed" access="public" returntype="numeric" output="false"
		hint="commit the base seed to the dao">
	
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
		<cfargument name=	"email"  			required="no" type="string" default="">
		<cfargument name=	"setlist"  			required="yes" type="string" default="">
		<cfargument name=	"organisation"  required="yes" type="string">
		
		<cfreturn objDAO.commitBaseSeed(argumentCollection=arguments)>		
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="deleteBaseSeed" access="public" returntype="void" output="false"
		hint="delete the base seed ">
	
		<cfargument name="id" required="yes" type="numeric">
		
		<cfset objDAO.deleteBaseSeed( arguments.id )>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="deleteSetList" access="public" returntype="void" output="false"
		hint="delete the set list">
	
		<cfargument name="p_setlist_id" required="yes" type="numeric">
		
		<cfset objDAO.deleteSetList( arguments.p_setlist_id )>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getUnitCost" access="public" output="false" returntype="numeric" 
				hint="returns the unit cost for the given band">
	
		<cfargument name="listTypeID" type="numeric" required="true">
		<cfargument name="noofrecords" 	type="numeric" 	required="true" default="0">

		<cfscript>
		// Local variable declarations...
		var CostPerRecord 	= variables.strConfig.strVars.costperrecord;
		var BaseCostEquation =  CostPerRecord * arguments.noofrecords;
		
		return Round(BaseCostEquation);
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="SetListBasePrice" access="public" output="false" returntype="void" 
			hint="update list cost in db & return the based cost equation">
		
		<cfset objDAO.SetListBasePrice(variables.strConfig.strVars.costperrecord)>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getCommCostsPerList" access="public" output="false" returntype="struct" 
				hint="returns a struct containing the totol cost of a particalr list as well as the total tel cost and fax cost">
		<cfargument name="listTypeID" 	type="numeric" 	required="true">
		
		<cfscript>
		var	strReturn 		= structNew();
		var qryList   		= getSetListByID(arguments.listTypeID);
		
		strReturn.TotalRows = qryList.numrecords;
		strReturn.TotalCost = qryList.cost;
		strReturn.TotalTel 	= qryList.TotalTel;
		strReturn.TotalFax 	= qryList.TotalFax;
		
		return strReturn;
		</cfscript>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getCostPerList" access="public" output="false" returntype="struct" 
				hint="returns a struct containing the list total after discount and the discount">
		<cfargument name="strSession" 	type="struct" 	required="true">
		<cfargument name="listTypeID" 	type="numeric" 	required="true">
	
		<cfscript>
		// Local variable declarations...
		var x						= 0;
		var i						= 0;
		var strReturn				= structNew();
		var CommDiscount			= 0;
		var CostPerRecord			= CostPerRecord(listTypeID);
		//get prices for a specfic list
		var strList					= getCommCostsPerList(arguments.listTypeID);
		var strComms				= structNew();
		//get intial cost of set list 
		var TotalBeforeDiscount		= 0;
		var TotalRows				= 0;
		
		//get comm methods for this data list based on user's selection
		for (i=1; i lte arrayLen(arguments.strSession.dataSalesLists); i=i+1)
		{
			if (arguments.strSession.dataSalesLists[i].ListTypeId eq arguments.listTypeID)
			{
				strComms = arguments.strSession.dataSalesLists[i].commMethods;
				break;
			}
		}
		
		//loop over methdos and ad price of each comm that has been selected
		for (x in strComms)
		{
			if (x eq 1) //address
			{
				TotalRows = (TotalRows + strList.TotalRows)*strComms[x];
			}
			
			if (x eq 2) //telephone
			{
				TotalRows = (TotalRows + strList.TotalTel)*strComms[x];
			}
			
			if (x eq 3) //facsimile aka fax for you thickos!
			{
				TotalRows = (TotalRows + strList.TotalFax)*strComms[x];
			}
			
			
		}
		//calculate price (Total number of records X the cost per record)
		TotalBeforeDiscount = TotalRows * CostPerRecord;
		
		/*if (arrayLen(arguments.strSession.dataSalesLists) eq 2)
		{
			//if user has selected 2 lists apply 5% disc
			CommDiscount = 5;
		}
		else if (arrayLen(arguments.strSession.dataSalesLists) gte 3)
		{
		//if user has selected 3 lists apply 10% disc
			CommDiscount = 10;
		}*/
		//deduct the discount from the total
		TotalAfterDiscount = (TotalBeforeDiscount) - (TotalBeforeDiscount * (CommDiscount / 100));

		strReturn.TotalAfterDiscount 	= Round(TotalAfterDiscount);
		strReturn.DiscountApplied 		= CommDiscount;
		strReturn.TotalRows 			= TotalRows;
		
		return strReturn;	
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="setOrderSummary" access="public" output="true" returntype="any" 
				hint="calculate order summary based on final total, user's country of resindence and login status">

		<cfargument name="strSession"	type="struct"  	required="yes">
		<cfargument name="finalTotal"	type="numeric"  required="yes">			
		
		<cfscript>
		var i 	= 0;
		var vat = 0;
		//qryUserDetails = "";
		var strReturn = StructNew();
		strReturn.VAT=0;
		strReturn.StandardRatedTotal=0;
		strReturn.ZeroRatedTotal=0;
		
		//is user logged in
		strReturn.TotalBeforeDiscountAndVAT = arguments.finalTotal;
		
		//check if user is entitled to 20% discount (subscribers only)
		if (arguments.strSession.userdetails.usertypeid gt 2)
		{
			//set discount value
			strReturn.subDiscount 			= strReturn.TotalBeforeDiscountAndVAT * (strConfig.StrVars.ds_percentdiscount / 100) ;
			//calculate discount
			strReturn.TotalAfterSubDiscount = strReturn.TotalBeforeDiscountAndVAT - strReturn.subDiscount;
			//set VAT if user is in UK
			strReturn.VAT = CalculateVAT( arguments.strSession, true );
			}
		else
		{	
			strReturn.subDiscount 			= 0;
			strReturn.TotalAfterSubDiscount = strReturn.TotalBeforeDiscountAndVAT;
			strReturn.VAT = CalculateVAT( arguments.strSession, false );
		}
		
		//calculate totals of how much has a been charged for standard rate of VAT and 0 rate
		if (strReturn.VAT){
			for (i=1; i lte arrayLen(arguments.strSession.dataSalesLists); i=i+1){
				if (arguments.strSession.dataSalesLists[i].totalVat)
					strReturn.StandardRatedTotal = strReturn.StandardRatedTotal + arguments.strSession.dataSalesLists[i].TotalAfterDiscount;
				else
					strReturn.ZeroRatedTotal = strReturn.ZeroRatedTotal + arguments.strSession.dataSalesLists[i].TotalAfterDiscount;	
			}
		}
		else{
			strReturn.StandardRatedTotal = 0;
			strReturn.ZeroRatedTotal = strReturn.TotalAfterSubDiscount;
		}
		//CALCULATE VALUE AFTER VAT
		strReturn.finalTotal = strReturn.TotalAfterSubDiscount + strReturn.VAT;
		//set final total into session
		arguments.strSession.strDataSalesTotal = strReturn;
		
		//objutils.dumpabort(strReturn);
		
		CreateDataSalesPurchaser(arguments.strSession);
		
		return strReturn;
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
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="CalculateVAT" access="public" output="true" returntype="numeric" 
				hint="Adds VAT to all lists except 'Label'">

		<cfargument name="strSession"		type="struct"  	required="yes">
		<cfargument name="applyDiscount"	type="boolean"  required="no" defualt="false">
		
		<cfscript>
		// Local variable declarations...
		var VATRate = strConfig.StrVars.vat_uk / 100;
		var arrListArr = ArrayNew(1); //array that holds value of vat for each list
		var discount = 0;
		
		// Check whether the dataSales session structure exists...
		if (not structKeyExists(arguments.strSession, "dataSalesLists"))
			arguments.strSession.dataSalesLists = arrayNew(1);

		for (i=1; i lte arrayLen(arguments.strSession.dataSalesLists); i=i+1){
			//if applicable set discount value
			If (arguments.applyDiscount){
				arguments.strSession.dataSalesLists[i].discount = 	arguments.strSession.dataSalesLists[i].calculatedprice * (strConfig.StrVars.ds_percentdiscount / 100);
				//Total = calcuatlted price - discount
				arguments.strSession.dataSalesLists[i].TotalAfterDiscount = arguments.strSession.dataSalesLists[i].calculatedprice - arguments.strSession.dataSalesLists[i].discount;
			}
			
			
		//set VAT value	
		 arguments.strSession.dataSalesLists[i].TotalVat = 0;
		 	//check user's country
		 	if	(arguments.strSession.userdetails.countryid eq 1){
				//check if list is vatable
				if (arguments.strSession.dataSalesLists[i].format NEQ 3 ){
					//calucalte vat value (Total Vat = Total after discount * 17%)
					arguments.strSession.dataSalesLists[i].TotalVat=arguments.strSession.dataSalesLists[i].TotalAfterDiscount * VATRate;
					//put value value into arra
			 		ArrayAppend(arrListArr, arguments.strSession.dataSalesLists[i].TotalVat);
					
			  }
		 	}	
		}
		//get VAT total
		TotalVat = ArraySum(arrListArr);
		//objUtils.dumpabort(arrListArr);
		return TotalVat;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="buildColumnLists" returntype="any" access="public" output="false" 
				hint="build list of columns and a list of coloumn headers required for CSV">
		<cfargument name="qrySetList" type="query" required="no">
		<cfscript>
		var str 		= structNew();
		var lstColumns 	= lCase(qrySetList.columnlist);
		var arrColumns 	= listToArray(lstColumns);
		var i 			= 0;
		var NoFunction 	= 0;
		
		str.columnList 	= "";
		str.headerList 	= "";
		
		//check if person columns are present
		if (listFindNoCase(lstColumns, "surname"))
		{
			str.columnList =   listAppend(str.columnList, "title,forename,surname,suffix,jobtitle");
			str.headerList =   listAppend(str.headerList,"Title,Forename,Surname,Suffix,Job Title");
		}
		//check if company name is present
		if (listFindNoCase(lstColumns, "organisation"))
		{
			str.columnList =   listAppend(str.columnList, "organisation");
			str.headerList =   listAppend(str.headerList, "Organisation");
		}
		//check if address columns are present
		if (listFindNoCase(lstColumns, "address1"))
		{
			str.columnList =   listAppend(str.columnList, strConfig.strVars.ds_addressColumns);
			str.headerList =   listAppend(str.headerList, "Address 1,Address 2,Address 3,Town,County,Postcode Outer, Postcode Inner");
		}
		//check if tel is present
		if (listFindNoCase(lstColumns, "tel"))
		{
			str.columnList =   listAppend(str.columnList, "tel");
			str.headerList =   listAppend(str.headerList, "Tel");
		}
		//check if fax is present
		if (listFindNoCase(lstColumns, "fax"))
		{
			str.columnList =   listAppend(str.columnList, "fax");
			str.headerList =   listAppend(str.headerList, "Fax");
		}
		//check if job function is present
		if (listFindNoCase(lstColumns, "jobfunction"))
		{
			str.columnList =   listAppend(str.columnList, "jobFunction");
			str.headerList =   listAppend(str.headerList, "Job Function");
		}
		
		//loop over array of column names
		for (i=1;i lte arrayLen(arrColumns);i=i+1)
		{
			//count out how many other 'function' columns are present 
			if ((arrColumns[i] contains "function") and (arrColumns[i] neq "jobFunction") and (arrColumns[i] neq "OtherFunctions"))
			{
				NoFunction = NoFunction + 1;
				//append other function columns
				str.columnList =   listAppend(str.columnList, "Function#NoFunction#");
				str.headerList =   listAppend(str.headerList, "Function #NoFunction#");
			}
		}
		//return struct containing lists		
		return  str;
		</cfscript>

	</cffunction>
	
	
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------>
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
	<cffunction name="saveDirectTemplate" access="public" output="false" returntype="void" hint="">		
		<cfargument name="userid" type="numeric" required="yes">
		<cfargument name="templateid" type="numeric" required="no" default="0">
		<cfargument name="tempName" type="string" required="yes">
		<cfargument name="tempCont" type="string" required="yes">
		
		<cfset objDAO.saveDirectTemplate(argumentCollection = arguments)>
	</cffunction>
     <!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
    <cffunction name="CostPerRecord" access="public" output="false" returntype="any">
   		<cfargument name="listTypeID" 	type="numeric" 	required="true">
    		
			<cfreturn getSetListByID(listTypeID).CostPerRecord>
            
    </cffunction>
    
    
</cfcomponent>