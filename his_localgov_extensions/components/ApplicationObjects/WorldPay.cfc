<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/COMPONENTS/ApplicationObjects/WorldPay.cfc $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 8/08/07 10:06 $

--->

<cfcomponent hint="WorldPay-related functions.">

	<!--- -------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR -------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="WorldPay" hint="">
		
		<cfreturn this>
	
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="Available" access="public" returntype="boolean">
		<cfargument name="URL" type="string" required="yes">

		<cfhttp url="#arguments.URL#" timeout="2"></cfhttp>

		<cfif cfhttp.FileContent EQ "Connection Failure">
			<cfreturn false>
		<cfelse>
			<cfreturn true>
		</cfif>

	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- Begin ProcessResults() Function ---->
	<cffunction name="ProcessResults" access="public" returntype="struct" 
			hint="Perform online transaction: Set content returned in  WorldPay's HTTP GET in a CFML structure " output="no">
				
				<cfset var strWorldPay = StructNew()>
				<cfset var strRequestData = "">
				<cfset var lstcontent = "">
				<cfset var arrContent = "">
				<cfset var key = "">
				<cfset var i = "">
				
				<cfparam name="TransactionID" default="">
				<cfparam name="OrderTotal" default="">
				
				<cfscript>
				//Copy data sent from Worldpay as an HTTP GET Request into a structure
				strRequestData = GetHttpRequestData();
				//Copy 'Content' posted in the http request into list 
				lstcontent = strRequestData.content;
				//For looping purposes copy list into an array 
				arrContent = ListToArray(lstcontent, '&');
				//copy orginal array back into structure
				strWorldPay.arrContent = arrContent;
				</cfscript>

				<!--- Loop over list which contains the contents and extract data into structure --->	
				<cfloop list="#lstcontent#" delimiters="&" index="i">
					<cfscript>
					// Get contents of list and set into structure key	
					key = ListGetAt(i, 1, "=");
					//get value of content and set into value of structure
					if (ListLen(i, "=") GT 1)
						value =  URLDecode(ListGetAt(i, 2, "="));
					else
						value = "";
					//only place my variables into return strutcure 	
					if (key CONTAINS "MC_")
						key = Replace(key, 'MC_', '');
						//set contents into structure	
					strWorldPay[key] = value;
					</cfscript>
				</cfloop>

			
			<!--- Return Structure --->
			<cfreturn strWorldPay>
	</cffunction>
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<cffunction name="RemovePrefix" access="public" returntype="struct" output="no" hint="remove 'MC_' prefix from struckture keys and set new keys into return structure">
		<cfargument name="str" required="yes" type="struct" hint="input structure">
		
		<cfset var strReturn=StructNew()>
		<cfset var i = "">
			
		<!--loop over input structure -->
		<cfloop collection="#arguments.str#" item="i">
			 <cfscript>
			 //evaluate if keys need their names changed 
			 switch (i){
				case "MC_subemail":
					 structinsert(strReturn, "email",arguments.str[i], 1);
					 break;
				case "MC_SubCountry": 
				 structinsert(strReturn, "country",arguments.str[i], 1);
					 break;
				case "MC_Subpostcode":	 
				 structinsert(strReturn, "postcode",arguments.str[i], 1);
					 break;	 
				case "MC_SubTel":	 
				 structinsert(strReturn, "tel",arguments.str[i], 1);
					 break;	
				default:	  	 
				//remove 'MC_' prefix from input structuure	
				structinsert(strReturn, replace(i, "MC_", ""), arguments.str[i], 1);
			 }
			 </cfscript>
			 
		</cfloop>
			
		<cfreturn strReturn>
	</cffunction>
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<cffunction name="AppendPrefix" access="public" returntype="struct" output="no" hint="Append 'MC_' prefix from struckture keys and set new keys into return structure">
		<cfargument name="str" required="yes" type="struct" hint="input structure">
	
		<cfset var strReturn=StructNew()>
		<cfset var i = "">
			
			<cfloop collection="#arguments.str#" item="i">
				<cfscript> 
				//evaluate if keys need their names changed 
				 switch (i){
					case "email":
						 structinsert(strReturn, "MC_subemail",arguments.str[i], 1);
						 break;	
					 case "Country":	 
					 structinsert(strReturn, "MC_Subcountry",arguments.str[i], 1);
						 break;
					case "postcode":	 
					 structinsert(strReturn, "MC_Subpostcode",arguments.str[i], 1);
						 break;	 
					case "MC_SubTel":	 
					 structinsert(strReturn, "MC_Subtel",arguments.str[i], 1);
						 break;		 
				default:		 
				 structinsert(strReturn, "MC_#i#",arguments.str[i], 1);
				 }
				  </cfscript>
			</cfloop>
			
		<cfreturn strReturn>
	</cffunction>
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<cffunction name="WorldPayUrl" access="public" returntype="string" output="no" hint="set worldpay address into list variable and append worldpay requeired variables">
			<cfargument name="str" required="yes" type="struct" hint="input structure">
						
			<cfset var i = "">
			<cfset var worldpayurl ="https://select.worldpay.com/wcc/purchase?instId=">
			<cfset worldpayurl =worldpayurl & "#arguments.str.instId#&cartId=#arguments.str.cartId#&amount=#arguments.str.amount#&currency=#arguments.str.currency#&testMode=#arguments.str.testMode#&hideCurrency=#arguments.str.hidecurrency#">
			
			<cfloop collection="#arguments.str#" item="i">
				<cfscript>
			  //check that form variable is not a worldpay variable as they are case sensitive
					If (i NEQ "FieldNames" AND i NEQ "SUBMIT.Y" AND i NEQ "SUBMIT.x" AND i NEQ "instId" AND  i NEQ "submit" AND i NEQ "cartId" AND i NEQ "amount" AND i NEQ "currency" AND i NEQ "testMode" AND i NEQ "hideCurrency")
					//append form variables into list
					worldpayurl = Listappend(worldpayurl, "#i#=#arguments.str[i]#", '&');
				</cfscript>
			</cfloop>	
				
			<cfreturn worldpayurl>
	</cffunction>	
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
		
</cfcomponent>