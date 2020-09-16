<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/ApplicationObjects/utils.cfc $
	$Author: Bhalper $
	$Revision: 28 $
	$Date: 28/07/10 12:43 $

--->

<cfcomponent displayname="Utils" hint="General purpose functions / useful utilities, including a number of functions that can be used within cfscript." >

	<cfscript>
		this.breaks = Chr(13) & Chr(10);
		this.tab    = Chr(9);
		this.os     = Server.OS.Name;
	</cfscript>
	
	<!--- ----------------------------------------------------------------------------------------------
	<cffunction name="UpdateWithoutRefresh" access="public" returntype="void" hint="Function can be used to run application code without perform a page refresh" >
		
		<cfargument name="ScopeVar" type="any" required="yes">
		<cfsetting enablecfoutputonly="true">

		<cfset Evaluate("#Arguments.ScopeVar#") = "">
		<cfcontent type="image/gif" file="#variables.AddImgPath#">

	</cffunction>
	--->

	<!--- -------------------------------------------------- --->
	<!--- QueryToCsv --->
	<!--- -------------------------------------------------- --->
	<cffunction name="QueryToCsv" access="public" output="no" returntype="string" hint="Converts a query to CSV.">

		<!--- Function Arguments --->
		<cfargument name="query"       required="yes" type="query"   hint="The query to convert.">
		<cfargument name="columnList"  required="no"  type="string"  hint="Comma-delimited list of the query columns.">
		<cfargument name="action"      required="no"  type="string"  default="return" hint="Return or write the CSV string in a file.">
		<cfargument name="headerFirst" required="no"  type="boolean" default="yes"  hint="Set column names at first row.">
		<cfargument name="headerList"  required="no"  type="string"  hint="Comma-delimited list of the CSV columns names.">
		<cfargument name="delimiter"   required="no"  type="string"  default=";" hint="Character(s) that delimited the fileds.">
		<cfargument name="enclosed"    required="no"  type="string"  default=""""  hint="Character(s) that enclosed the field.">
		<cfargument name="empty"       required="no"  type="string"  default="" hint="String that replace a empty field.">
		<cfargument name="file"        required="no"  type="string"  default="#ExpandPath(".")#\query.csv" hint="Pathname of the CSV file to write.">
		<cfargument name="charset"     required="no"  type="string"  default="ISO-8859-1"  hint="The character encoding in which the CSV file contents is encoded.">

		<cfscript>
		/* Default variables */
		var i = 0;
		var n = 0;
		var h = 0;
		var csv = "";
		var row = "";

		/* Set query column names */
		if(Len(arguments.columnList))
			cols = ListToArray(LCase(arguments.columnList));
		else                                  
			cols = ListToArray(LCase(arguments.query.columnList));

		/* Set column names at first row */
		if(arguments.headerFirst EQ "yes")
		{
			if(IsDefined("arguments.headerList")) headers = ListToArray(arguments.headerList);
			else                                  headers = cols;

			for(h=1; h LTE ArrayLen(headers); h=h+1)
			{
				row = row & arguments.enclosed & Trim(headers[h]) & arguments.enclosed;

				if(h LT ArrayLen(headers))
					row = row & arguments.delimiter;
			}

			csv = row & this.breaks;
			row = "";
		}

		/* Loop over query rows */
		for(i=1; i LTE arguments.query.recordcount; i=i+1)
		{
			/* Loop over query columns */
			for(n=1; n LTE ArrayLen(cols); n=n+1)
			{
				if(IsString(arguments.query[cols[n]][i]))
				{
					if(arguments.query[cols[n]][i] EQ "") content = arguments.empty;
					else                                  content = arguments.query[cols[n]][i];
					//WriteOutput("#content#<br>");
				}

				else
					content = "";
					
				//WriteOutput("#arguments.enclosed#");
				row = row & arguments.enclosed & content & arguments.enclosed;

				//WriteOutput("#arguments.delimiter#<br>");
				if(n LT ArrayLen(cols))
					row = row & arguments.delimiter;
			}

			csv = csv & row & this.breaks;
			row = "";
		}

		/* Return or write the CSV string in a file*/ 
		switch(arguments.action)
		{
			case "return": return csv; break;
			case "write":  WriteFile(arguments.file & ".csv", Trim(csv), arguments.charset); break;
		}
		</cfscript>
		
		<!--- <cfdump var="#csv#"><cfabort> --->

	</cffunction>
	<!--- ------------------------------------------------------------------------------------- --->
	<!--- ------------------------------------------------------------------------------------- --->
	<!--- ------------------------------------------------------------------------------------- --->
	<cffunction name="Query2Excel" access="public" returntype="void"  output="false" 
				hint="Converts a query to excel-ready format">
		<cfargument name="query" 			required="yes" type="query"   hint="The query to use">
		<cfargument name="columnList"  		required="no"  type="string"  default="#query.columnList#" hint=" The columns of the query">
		<cfargument name="headerList" 		required="no"  type="string"  default="#query.columnList#" hint="A list of headers">
		<cfargument name="file"        	   	required="no"  type="string"  default="#ExpandPath(".")#\query.csv" hint="Pathname of the CSV file to write.">
		
		
		<!--- 
			The modified method below creates the Excel file without using ANY HTML
			This means that the file is created faster and is of smaller size and is loaded
			by MS Excel much faster as it is essentially just a txt file. Using any HTML for 
			formatting will make the file a saved web page which is why it becomes so large 
			and slow to load
		--->
		<cfscript>
			var i = 0;
			var j = 0;
			var k = 0;	
			var colValue = "";	
			var HTMLData = "";
			var TabChar = Chr(9);
			var NewLine = Chr(13) & Chr(10);
					
			for (i=1; i lte listLen(arguments.headerList); i=i+1)
			{
				HTMLData 	= HTMLData & "#listGetAt(arguments.headerList,i)##TabChar#";
			}
			HTMLData = HTMLData & "#NewLine#";
			
			for (j=1; j lte arguments.query.recordcount; j=j+1)
			{
				
				for (k=1; k lte listLen(arguments.columnList); k=k+1)
				{
					colValue	= arguments.query[listGetAt(arguments.columnList,k)][j];
					
					if (not len(colValue))
					{
						colValue="";
					} 
					
					if (isNumeric(colValue) and len(colValue) gt 10)
					{
						colValue="'#colValue#";
					} 
					
					HTMLData = HTMLData & "#colValue##TabChar#";
				}
				
				HTMLData = HTMLData & "#NewLine#";
			}
			
			WriteFile(arguments.file & ".xls", trim(HTMLData), "ISO-8859-1" );
		</cfscript>

		
		<!--- ORIGINAL METHOD
		<cfscript>
			/*var i = 0;
			var j = 0;
			var k = 0;	
			var colValue = "";	
			var HTMLData = "";*/
					
			HTMLData = HTMLData & "<table border='1'><tr align='center'>";
	
			for (i=1; i lte listLen(arguments.headerList); i=i+1)
			{
				HTMLData 	= HTMLData & "<td ><h2>#listGetAt(arguments.headerList,i)#</h2></td>";
			}
			
			HTMLData = HTMLData & "</tr>";
			
			for (j=1; j lte arguments.query.recordcount; j=j+1)
			{
									
				HTMLData = HTMLData & "<tr>";
				
				for (k=1; k lte listLen(arguments.columnList); k=k+1)
				{
					colValue	= arguments.query[listGetAt(arguments.columnList,k)][j];
					
					if (not len(colValue))
					{
						colValue="&nbsp;";
					} 
					
					if (isNumeric(colValue) and len(colValue) gt 10)
					{
						colValue="'#colValue#";
					} 
					
					HTMLData = HTMLData & "<td>#colValue#</td>";
				}
				
				HTMLData = HTMLData & "</tr>";
			}
			
			HTMLData = HTMLData & "</table>";
			
			WriteFile(arguments.file & ".xls", trim(HTMLData) );
		</cfscript> --->
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="XSSProtection" access="public" returntype="void" output="true" hint="Used to guard against Cross-Site Scripting (XSS), to be placed at the top of posting pages. Ref: CFDJ Sept-04, p16">
	
		<cfif NOT Len(cgi.HTTP_REFERER) OR NOT FindNoCase(cgi.HTTP_HOST,cgi.HTTP_REFERER)>
			
			<cfoutput><h3>Post action aborted!</h3>
			<br />
			<p>Post from foreign host detected!</p></cfoutput>
			<cfabort>
									
		</cfif>
			
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getLocalHost" returntype="string" output="false">
	
		<cfscript>
		var sLocalHost = "";
			
		try {	
			sLocalHost = CreateObject("java","java.net.InetAddress").getLocalHost();
			sLocalHost = ListGetAt(fakeServerNames,ListFind(realServerNames,sLocalHost));
		} catch (Any except) {
			sLocalHost = "";
		}
		
		return sLocalHost;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="createWDDXPacket" returntype="any" output="false" hint="stores the data in a wddx packet">
		<cfargument name="whattodo" type="string" default="cfml2wddx">
		<cfargument name="dataInput" type="any" required="yes">
		
		<cfwddx action="#whattodo#" input="#dataInput#" output="wddxPack">
		
		<cfreturn wddxPack/>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="validIpAddress" returntype="boolean" output="false">
	
		<cfargument name="IPAddressRanges"  required="No" type="string" hint="Comma-seperated IP address.  Last octect range can be specified using hyphen, e.g. 145.36.163.0-255">
		
		<cfargument name="ValidIPAddressRanges" default="64.119.147.160-191,145.36.163.0-35">
		
		<cfscript>
		var aValidOctet = ArrayNew(1);
		var thisRange = 0;
		var aValidIPAddressRanges = ListToArray(Arguments.ValidIPAddressRanges, ",");
		var aRemote_Addr_Octets = ListToArray(CGI.REMOTE_ADDR, ".");
		var aValidRange = "";
		
		aValidOctet[1]=false;aValidOctet[2]=false;aValidOctet[3]=false;
		
		// Loop through all IP addresses...
		for (thisRange=1; thisRange LTE ArrayLen(aValidIPAddressRanges); thisRange=thisRange+1) {
			// Decompose into component octets...
			aValidIPAddress_Octets = ListToArray(aValidIPAddressRanges[thisRange], ".");
			
			// Loop through each octet, validating agianst a decomposed CGI.REMOTE_ADDR...
			for (thisOctet=1; thisOctet LTE 4; thisOctet=thisOctet+1) {
				if (thisOctet LT 4)  {
					if ( aRemote_Addr_Octets[thisOctet] eq aValidIPAddress_Octets[thisOctet] )
						aValidOctet[thisOctet] = true;
					else
						aValidOctet[thisOctet] = false;
				
				// Check the last octet for any ranges specified...
				} else if (thisOctet EQ 4) {
					
					for (thisOctet=1; thisOctet LTE 3; thisOctet=thisOctet+1)
						if (aValidOctet[thisOctet]) bValid=true; else bValid=false;
					
					// If all the previous octets were valid...
					if (bValid) {
						aValidRange=ListToArray(aValidIPAddress_Octets[thisOctet],"-");
						// ...validate the last against any ranges specified...
						if (ArrayLen(aValidRange) GT 1) {
							if ( aRemote_Addr_Octets[thisOctet] GTE aValidRange[1] AND aRemote_Addr_Octets[thisOctet] LTE aValidRange[2] )
								return true;
						// ...or the octet itself...
						} else
							if ( aRemote_Addr_Octets[thisOctet] eq aValidIPAddress_Octets[thisOctet] )
								return true;
						
					}
				}	
			}
		}
		// If we've got here, then the remote IP address must be invalid...
		return false;
		</cfscript>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
 	<cffunction name="GetLocal" access="public" hint="sets the locale for marketing chunks" output="false">
	
		<cfargument name="sLocale" default="UK" type="string">
		<cfargument name="thisLocale" required="yes" hint="locale of users machine" type="string" default="">
		<cfset var thisLang = "">
		
		<cfparam name="HTTP_ACCEPT_LANGUAGE_List" default="zh,zh-cn,zh-tw,zh-hk,zh-sg,en-ca,en-jm,en-bz,en-tt,ja,ko,es-ar,es-co,es-mx,es-gt,es-cr,es-pa,es-ve,es-pe,es-ec,es-cl,es-uy,es-py,es-bo,es-sv,es-hn,es-ni,es-pr,ts,vi">
		
		<!--- loop through US ones if not it's default UK --->
		<cfloop list="#HTTP_ACCEPT_LANGUAGE_List#" index="thisLang" delimiters=",">
		
			<cfif thisLang EQ arguments.thisLocale>
				<cfset arguments.sLocale = "US">
				<cfbreak>
			</cfif>
			
		</cfloop>
		
		<cfreturn sLocale>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getFileSize" returntype="numeric" output="false">
	
		<cfargument name="dir" required="yes" type="string">
		<cfargument name="filter" required="yes" type="string">
		
		<cfset var myDir = "">
		<cfdump var="#arguments#">
		<cfdirectory name="myDir" action="list" directory="#Arguments.dir#" filter="#Arguments.filter#">
		
		<cfreturn myDir.size>
		
	</cffunction>

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getDiskSpace" returntype="string" access="public" hint="Returns disk space info, in GB" output="false">
		<cfargument name="Drive" default="C" required="no" type="string">
		<cfargument name="Type" default="0" type="numeric" hint="0=free; 1=total" required="no">
		
		<Cfset var FSO = "">
		<cfset var thisDrive = "">
		<Cfset var sSpace = "">
		<cftry>
			<cfobject TYPE="COM" CLASS="Scripting.FileSystemObject" NAME="FSO" ACTION="CONNECT">
			<cfcatch type="ANY">
				<cfobject TYPE="COM" CLASS="Scripting.FileSystemObject" NAME="FSO" ACTION="CREATE">
			</cfcatch>
		</cftry>
	
		<cfloop collection="#FSO.Drives#" ITEM="thisDrive">
			<cfscript>
			if (thisDrive.DriveLetter eq Arguments.Drive) {
				if (Arguments.Type EQ 0) {
					if (thisDrive.isReady AND ISNumeric(thisDrive.FreeSpace) ) {
						sSpace = round(evaluate(thisDrive.FreeSpace / 1024 / 1024 / 1024));
						break;
					}
				} else {
					if (thisDrive.isReady AND ISDefined("thisDrive.TotalSize")) {
						sSpace = round(evaluate(thisDrive.TotalSize / 1024 / 1024 / 1024));
						break;
					}
			   } 
			}
			</cfscript>
		</CFLOOP>
	
		<cfreturn sSpace>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction
	name="Pagination" access="public" returntype="struct" 
	hint="Allows clients to navigation through a recordset using either 'Next Record' or 'Page by Page, returns a structure to the calling page">
	
		<!--- Define arguments --->
		<cfargument name="QueryRecordCount" type="numeric" required="true" hint="CF query object 'recordcount'">
		<cfargument name="RowsPerPage" type="numeric" required="true" hint="The number of rows to be displayed by the page">
		<cfargument name="StartRow" type="numeric" required="true" hint="The value of the row which the page begins at">
		
	
		<!--- set return results into structure --->
		<cfscript>
		var strNav = StructNew();
		var RowStart = arguments.StartRow;
		var NumRows = arguments.RowsPerPage;
		var TotalRows = arguments.QueryRecordCount;
		var EndRow = Min(RowStart + RowsPerPage  - 1, TotalRows);
		var StartRowNext = EndRow + 1;
		var StartRowBack = RowStart - NumRows;
		strNav["StartRow"]=RowStart;
		strNav["TotalRows"]=TotalRows;
		strNav["RowsPerPage"]=arguments.RowsPerPage;
		strNav["EndRow"]=EndRow;
		strNav["StartRowNext"]=StartRowNext;
		strNav["StartRowBack"]=StartRowBack;
		return strNav;
		</cfscript>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- <cffunction name="Str2QueryString" access="public" returntype="string" output="false" hint="turn structure key value pairs into url query string">
		<cfargument name="str" required="yes" type="struct">	
			<cfscript>
			var i="";
			var querystring="";
			for(i in arguments.str){
			 querystring = querystring & "&amp;" & i & "=" & arguments.str[i];
			}
			return querystring;
			</cfscript>
	
	</cffunction>
	 --->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getServerMemory" returntype="numeric" access="public" hint="Returns server memory in MB" output="false">
		<cfargument name="Type" default="0" type="numeric" hint="0=free; 1=total" required="no">
		
		<cfscript>
		var runtime = CreateObject("java","java.lang.Runtime").getRuntime();
		switch (Arguments.Type) {
			case 0 : return Round(runtime.freeMemory() / 1024 / 1024);
			case 1 : return Round(runtime.maxMemory() / 1024 / 1024);
		}
		</cfscript>
		
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="structGetValueFromKeys" access="public" returntype="string" output="false" hint="return value of a specfic key whose name is contained in structure">
			<cfargument name="str" required="yes" type="struct">
			<cfargument name="structkey" required="yes" type="string">
				
				<cfscript>
				var returnvalue="";
				var i="";
				//loop over struct
				for (i in arguments.str){
				//if key contains string specficed...
				  if (i contains arguments.structkey AND Len(arguments.str[i]))
				  	//set into return var
					returnvalue = arguments.str[i];
				}
				return returnvalue;
				</cfscript>
				
		</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="qry2Struct" access="public" returntype="struct" hint="turn qry results into structure" output="false">
		<cfargument name="qryobject" required="yes" type="query" hint="qry object">	
			
			<cfscript>
			var qry = arguments.qryobject;
			var strResults = StructNew();
			var srtRow ="";
			var str = StructNew();
			var i ="";
			</cfscript>
			
				<cfloop query="qry">
					 <!--- loop over qruery a create a strcuture for each row --->
						<cfset srtRow= StructNew()>
						<!--- loop over list of columns in qry --->
						<cfloop list="#qry.columnlist#" index="i">
							<!--- insert name of column and its value into str --->
								<cfset StructInsert(srtRow, i, evaluate(i))> 
						</cfloop>	
						<!--inest row str into main str --->
						<cfset StructInsert(strResults, qry.JobID, srtRow, "yes")/>
				</cfloop>
		
			<cfreturn strResults>
	</cffunction> 

	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="execute" returntype="void">
		<cfargument name="name" required="yes" type="string">
		<cfargument name="args" required="yes" type="string">
		<cfargument name="outputFile" required="yes" type="string">
		<cfargument name="timeout" default="100" required="no">
	
		<cfexecute 
			name = "#Arguments.name#"
			arguments = "#Arguments.args#" 
			outputFile = "#Arguments.outputFile#"
			timeout = "#Arguments.timeout#">
		</cfexecute>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="flush" returnType="void" output="true">
		<cfargument name="interval"  type="numeric" required="false">
		<cfif isDefined("interval")>
			<cfflush interval="#interval#">
		<cfelse>
			<cfflush>
		</cfif>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="abort" output="false" returnType="void">
		<cfargument name="showError" type="string" required="false">
		<cfif isDefined("showError") and len(showError)>
			<cfthrow message="#showError#">
		</cfif>
		<cfabort>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="dump" returntype="boolean" output="yes">
	  <cfargument name="var" type="any" default="nothing to output">
	  <cfdump Var="#arguments.var#">
	  <cfreturn true>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="dumpabort" access="public">
	  <cfargument name="var" type="any" default="nothing to output">
	  <cfargument name="expand"   required="no" type="boolean" default="yes">
	  <cfdump Var="#arguments.var#" expand="#arguments.expand#">
	  <cfabort>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="cfcookie" returntype="boolean" output="yes">
	  <cfargument name="name" 	 type="string" 	required="yes">
	  <cfargument name="value" 	 type="string" 	required="yes">
	  <cfargument name="expires" type="string" 	required="no" default="never">
		<cfcookie name="#arguments.name#" value="#arguments.value#" expires="#arguments.expires#" >
	  <cfreturn true>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="location" returntype="boolean" output="no">
	  <cfargument name="url" 	 	type="string" hint="url of relocation">
	  <cfargument name="addtoken"   type="boolean" default="false">
	  <cflocation url="#arguments.url#" addtoken="#arguments.addtoken#">
	  <cfreturn true>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="http" access="public" returntype="struct" hint="Returns cfhttp structure">
		<cfargument name="urlstring" 	required="yes" type="string">
		<cfargument name="useProxy"  	required="no" default="no">
		<cfargument name="timeout"   	required="no" default="60">
		<cfargument name="method"    	required="no" default="get">
		<cfargument name="resolveUrl"   required="no" default="no">
		<cfargument name="charset"   	required="no" default="utf-8">
		
			<cfif arguments.useProxy>
				<cfhttp url="#arguments.urlstring#" timeout="#arguments.timeout#" method="#arguments.method#" proxyserver="192.168.1.12" proxyport="8080" proxyuser="coldfusion" proxypassword="C0ldfusion" throwonerror="yes" resolveUrl="#arguments.resolveUrl#" charset="#arguments.charset#"></cfhttp>
				
			<cfelse>
				<cfhttp url="#arguments.urlstring#" timeout="#arguments.timeout#" method="#arguments.method#" resolveUrl="#arguments.resolveUrl#" charset="#arguments.charset#"></cfhttp>
				
			</cfif>
			<cfreturn cfhttp> 
		</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->		
	<cffunction name="wddx" returntype="any" output="false" hint="stores the data in a wddx packet">
		<cfargument name="whattodo" type="string" default="cfml2wddx">
		<cfargument name="dataInput" type="any" required="yes">
		
		<cfset var wddxPack = "">
		<cfwddx action="#whattodo#" input="#dataInput#" output="wddxPack">
		
		<cfreturn wddxPack/>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="QueryOfQuery" access="public"  returntype="query" output="false" hint="Perform qry on qry object">
			<cfargument name="qry" required="yes" type="query" hint="qry object to be searched">
			<cfargument name="columns" required="yes" type="string" hint="list of column to be returned in qry of qrys">
			<cfargument name="WhereClause" required="no" type="string" hint="sql filter operator for qry of qrys" default="0=0">
			<cfargument name="OrderBy" required="no" type="string" hint="sql order statement for qry of qrys" default="">
			<cfargument name="Maxrows" required="no" type="numeric" hint="sql order statement for qry of qrys" default="0">
			
				<cfset var QryofQry = queryNew("temp")>
					
					<!--- <cftry> --->
						<cfif arguments.Maxrows>
                            <cfquery name="QryofQry" dbtype="query" maxrows="#arguments.Maxrows#">
                                SELECT #arguments.columns#
                                FROM arguments.qry
                                WHERE #PreserveSingleQuotes(arguments.WhereClause)#
                                <cfif Len(arguments.OrderBy)>
                                    ORDER BY #arguments.OrderBy#
                                </cfif>
                            </cfquery>
                            <cfelse>
                                <cfquery name="QryofQry" dbtype="query">
                                SELECT #arguments.columns#
                                FROM arguments.qry
                                WHERE #PreserveSingleQuotes(arguments.WhereClause)#
                                <cfif Len(arguments.OrderBy)>
                                    ORDER BY #arguments.OrderBy#
                                </cfif>
                            </cfquery>
                            
                        </cfif>
                        
                        <!--- <cfcatch type="any">
                        	<cflog text="Message: #cfcatch.message# Detail: #cfcatch.Detail# query string: #cgi.QUERY_STRING# columns: #arguments.columns# where clause: #arguments.WhereClause#" file="queryofquery">
                        </cfcatch>
                        
                    </cftry> --->

				<cfreturn QryofQry>
		</cffunction>	
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<cfscript>
	function cleanBody(body) {
		var b = REReplace(arguments.body, "<[^>]*>", "", "All");
		b = REReplace(b, "\([^>]*\)", "", "All");
		return b;
	}
	</cfscript>
	
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<cffunction access="public" name="BuildURL" output="false" returntype="string" hint="returns full url from CGI variables">
		<cfset var sURL = "">
		<cfset var concat = "">
		<cfset var i = 0>
		<cfif CGi.QUERY_STRING neq "">
			<cfset sURL = CGI.SCRIPT_NAME>
			<cfset concat = "?">
			<cfloop collection="#URL#" item="i">
				<cfset sURL = sURL & concat & i & "=" & evaluate(i)>
				<cfset concat = "&">
			</cfloop>
		<cfelse>
			<cfset sURL = CGI.SCRIPT_NAME>
		</cfif>
		<cfreturn sURL>
	</cffunction>
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<cffunction access="public" name="ListCompare" output="false" returntype="string" hint="Compares one list against another to find the elements in the first list that don't exist in the second list">
		<!--- Arguments --->
		<cfargument name="List1" type="string" required="true"/>
		<cfargument name="List2" type="string" required="true"/>
		<cfargument name="Delim1" type="string" required="false" default=","/>
		<cfargument name="Delim2" type="string" required="false" default=","/>
		<cfargument name="Delim3" type="string" required="false" default=","/>
		<!--- Declarations --->
		<cfset var TempList = ""/>
		<cfset var i = 0/>
		<!--- Script --->
		<cfscript>
		/* Loop through the full list, checking for the values from the partial list.
		* Add any elements from the full list not found in the partial list to the
		* temporary list
		*/
		for (i=1; i LTE ListLen(List1, "#Delim1#"); i=i+1)
		{
		if (NOT ListFindNoCase(List2, ListGetAt(List1, i, Delim1), Delim2))
		{
		   TempList = ListAppend(TempList, ListGetAt(List1, i, Delim1), Delim3);
		}
		}
		return TempList;
		</cfscript>
	</cffunction>
	<!--- ---------------------------------------------------------------------------------------------------------------->
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- FUNCTION: GetDimensions()... --------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetDimensions" returntype="struct" access="public">
		<cfargument name="ImageSource" required="yes" type="string" hint="pass into full directory path to image">
	
		<cfscript>
		// Create a Java Toolkit and Image object...
		var oToolkit = CreateObject("java","java.awt.Toolkit");
		var oImage = CreateObject("java","java.awt.Image");
		var stImageDimensions = StructNew();
		
		try {
			oImage = oToolkit.getDefaultToolkit().getImage(Arguments.ImageSource);
			
			StructInsert( stImageDimensions,"Width",oImage.getWidth() );
			StructInsert( stImageDimensions,"Height",oImage.getHeight() );
			oImage.flush();

		} catch (Any except) { }
		
		return stImageDimensions;		
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- FUNCTION: WebSeriveAvailable... --------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="WebSeriveAvailable" access="public" returntype="boolean" hint="Returns true if a web serivce is currently running.">
		<cfargument name="WEBSERVICEURL" required="yes" type="string">
		<cfhttp url="#arguments.WEBSERVICEURL#" timeout="2"></cfhttp>
		<cfif cfhttp.FileContent EQ "Connection Failure">
			<cfreturn false>
		<cfelse>
			<cfreturn true>
		</cfif>
	</cffunction>	
	
	
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="UploadImage" access="public" output="false" returntype="string" hint="Upload image and update data">
		<cfargument name="FileName" type="string" required="true" hint="Name of file form field">
		<cfargument name="DirPath"  type="string" required="true" hint="Fully qualified path of directory to store file">
		<cfargument name="FileType" type="string" required="false" hint="Type of file to upload, either 'pdf' 'image' or 'word'" default="image/jpg, image/jpeg, image/gif,application/x-shockwave-flash">
				
			<cfscript>
			 var NewFilename="";
			 var PosLastDot="";
			 var Ext="";
			 var PosEndLeftStr="";
			 var LeftStr="";
			 var SQLString = "";
			 
			 switch (arguments.FileType){
				case "pdf":
					FileType="application/pdf, plain/txt";
					break;
				case "image":
					FileType="image/jpg, image/jpeg, image/pjpeg, image/gif, application/x-shockwave-flash";
					break;
				case "word":
					FileType="application/msword, plain/txt";
					break;	
							
			 }
			</cfscript>
				
			<!--- In order to allow mac user to upload , read file into bianry object 1st 
			<cffile action="readbinary" file="#trim(arguments.FileName)#" variable="objBinary">--->

			<!--- if binary object has size greater than 2, continue upload 
			<cfif Len(objBinary) GT 2>---> 
				<cftry>
				<!--- upload image file --->
				<cffile action="upload" destination="#Trim(arguments.DirPath)#" filefield="#arguments.filename#" nameconflict="makeunique" accept="#FileType#"> 
					<!--- Check that file was sent to server and 
					that method requires file data to be saved to DB --->
					<cfif File.FileWasSaved >
						
						<cfscript>
						NewFilename = File.ServerFile;
						//remove any blank space or special characters from file name
						NewFilename = Replace(NewFilename, " ", "", 'all');
						NewFilename = Replace(NewFilename, "/", "", 'all');
						NewFilename=  Replace(NewFilename, "\", "", 'all');
						NewFilename = Replace(NewFilename, "*", "", 'all');
						NewFilename = Replace(NewFilename, ":", "", 'all');
						NewFilename = Replace(NewFilename, ";", "", 'all');
						//remove all dots(.) from file except those from the file extension
						if (ListLen(NewFilename, "." GT 2)){
							// get position of last dot(.)
							PosLastDot = Find(".", Reverse(NewFilename));
							//set var to hold extension string
							Ext =  Right(NewFilename, PoslastDot);
							//set position of last charchter in string up to last dot(.)
							PosEndLeftStr = Len(NewFilename) - PoslastDot;
							//remove all dots(.) from part of string whcih does not contain the file extension			
							LeftStr = ReplaceList(Left(NewFilename, PosEndLeftStr), ".", "");
							//concatenate left string with dots removed to file extenstion
							NewFilename = LeftStr & ext;}
					</cfscript>
					
					<!---Rename file to new name --->
					<cffile action="rename" source="#Trim(arguments.DirPath)##File.ServerFile#" destination="#Trim(arguments.DirPath)##NewFilename#">
					
				</cfif>	
					<cfcatch></cfcatch>
				</cftry>
			
		<cfreturn NewFilename>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="CountWords" access="public" output="false" returntype="numeric" hint="">

		<cfargument name="sWord" required="yes" type="string" hint="">
		<cfset var nNoOfWords = 0>
		
		<cfloop from="1" to="#len(arguments.sWord)#" index="i">
			<cfif find(" ", arguments.sWord, i )>
				<cfset nNoOfWords=nNoOfWords+1>
			</cfif>
		</cfloop>
		
		<cfreturn nNoOfWords>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getAllSessions" access="public" returntype="struct" output="false" hint="use java class to return all sessions in an application">
		<cfargument name="AppName" required="yes" type="string" hint="">	
			<!--- <cfreturn createObject("java", "coldfusion.runtime.SessionTracker").getSessionCollection(arguments.appName)> --->
			
			
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetContentFromInclude" returntype="string" output="false" hint="stores the data in a wddx packet">
		<cfargument name="filepath" type="string" required="yes" hint="full name and path to of file">
			<cfset var sReturn ="">
		
				<cfsavecontent variable="sReturn">
					<cfinclude template="#arguments.filepath#">
				</cfsavecontent>
		<cfreturn sReturn/>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="browserDetect" returntype="string" output="false" access="public" hint=""> 
		<cfargument name="strCgi" type="struct" required="yes" hint="pass in cgi scope">
		<cfscript>
			/**
		 * Detects 40+ browsers.
		 * 
		 * @return Returns a string. 
		 * @author John Bartlett (jbartlett@strangejourney.net) 
		 * @version 1, September 30, 2005 
		 */
		
		
		var loc=0;
		var i=0;
		var b=0;
		var tmp="";
		var browserList="";
		var currBrowser="unknown";
		
		// Avant Browser (Not all Avant browsers contain "Avant" in the string)
		loc=findNoCase("Avant",arguments.strCgi.HTTP_USER_AGENT);
		if(loc GT 0) {
			loc=listFindNoCase(arguments.strCgi.HTTP_USER_AGENT,"MSIE"," ");
			if(loc GT 0) {
				tmp=listGetAt(arguments.strCgi.HTTP_USER_AGENT,loc + 1," ");
				currBrowser =  "Avant " & left(tmp,len(tmp) - 1);
			}
		}
	
		// PocketPC
		if(findNoCase("Windows CE",arguments.strCgi.HTTP_USER_AGENT)) return "PocketPC";
	
		// Misc (browser x.x)
		browserList="Acorn Browse,Check&Get,iCab,Netsurf,Opera,Oregano,SIS";
		for (b=1; b lte listLen(BrowserList); b=b+1) {
			currBrowser=listGetAt(browserList,b);
			loc=listFindNoCase(arguments.strCgi.HTTP_USER_AGENT,currBrowser," ");
			if(loc GT 0) return currBrowser & " " & listGetAt(arguments.strCgi.HTTP_USER_AGENT,loc + 1," ");
		}
	
		// Misc (browser/x.x)
		BrowserList="Amaya,AmigaVoyager,Amiga-AWeb,Camino,Chimera,Contiki,cURL,Dillo,DocZilla,edbrowse,Emacs-W3,Epiphany,Firefox,IBrowse,iCab,K-Meleon,Konqueror,Lynx,Mosaic,NetPositive,Netscape,OmniWeb,Opera,Safari,SWB,Sylera,W3CLineMode,w3m,WebTV";
		for (b=1; b LTE ListLen(BrowserList); b=b+1) {
			currBrowser=listGetAt(browserList,b);
			loc=findNoCase(currBrowser,arguments.strCgi.HTTP_USER_AGENT);
			if(loc GT 0) {
				// Locate Browser version in string
				for(i=1;i lte listLen(arguments.strCgi.HTTP_USER_AGENT," ");i=i+1) {
					if(lCase(left(listGetAt(arguments.strCgi.HTTP_USER_AGENT,i," "),len(currBrowser) + 1)) eq "#CurrBrowser#/") 
					currBrowser = currBrowser & " " & listLast(listGetAt(arguments.strCgi.HTTP_USER_AGENT,i," "),"/");
				}
			}
		}
	
		// Misc (browser, no version)
		browserList="BrowseX,ELinks,Links,OffByOne,BlackBerry";
		for(b=1; b lte listLen(BrowserList); b=b+1) {
			currBrowser=listGetAt(browserList,b);
			if(findNoCase(currBrowser,arguments.strCgi.HTTP_USER_AGENT) gt 0) 
			currBrowser =  currBrowser;
		}
	
		// Mozila (must be done after Firefox, Netscape, and other Mozila clones)
		loc=findNoCase("Gecko",arguments.strCgi.HTTP_USER_AGENT);
		if(loc GT 0) {
			// Locate revision number in string
			for(i=1;i lte listLen(arguments.strCgi.HTTP_USER_AGENT," ");i=i+1) {
				if(lCase(left(listGetAt(arguments.strCgi.HTTP_USER_AGENT,i," "),3)) eq "rv:") 
				currBrowser = "Mozilla " & val(listLast(ListGetAt(arguments.strCgi.HTTP_USER_AGENT,i," "),":"));
			}
		}
	
		// IE (Must be last due to other browsers "spoofing" it.
		loc=listFindNoCase(arguments.strCgi.HTTP_USER_AGENT,"MSIE"," ");
		if(Loc GT 0) {
			tmp=listGetAt(arguments.strCgi.HTTP_USER_AGENT,loc + 1," ");
			currBrowser =  "MSIE " & left(tmp,len(tmp) - 1);
		}
	
		// Unable to detect browser
		return currBrowser;
	
	</cfscript>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="ClientPlatform" access="public" returntype="struct" hint="return client's operating system and browser" output="no">
		<cfargument name="strCgi" required="yes" type="struct" hint="pass in cgi.http_user_agent">
		
			<cfscript>
			var strClientPlatform = StructNew();
			// copy user agent into local variable
			var agent = strCgi.http_user_agent;
			//retrive  os from user agent string 
			strClientPlatform.browser ="";
			strClientPlatform.OS_PART="";
			strClientPlatform.OStype ="";
			strClientPlatform.OS="";
			strClientPlatform.browserVersion = "";
			
			if (ListLen(agent) eq 1)
				strClientPlatform.OS_PART = agent;
			else
			if (ListLen(agent) eq 2)
			strClientPlatform.OS_PART = ListGetAt(agent,2,"(");
			// retrive type of opertating systems
			If (ListLen(agent, ";") GTE 3  )  
			 strClientPlatform.OStype = ListGetAt(agent,3,";");
			 else
			  strClientPlatform.OStype = agent;
			
			strClientPlatform.OS_Part = ListGetAt(strClientPlatform.OS_Part,1,")");
			//set operating system into structure
			if (Find("Mac",strClientPlatform.OS_Part) OR Find("PowerPC",strClientPlatform.OS_Part))
				strClientPlatform.OS = "mac";
			else
				strClientPlatform.OS = "pc";
			//set browser into structure	
			if (agent CONTAINS "MSIE")
			{
				strClientPlatform.browser="IE";
				strClientPlatform.browserVersion = ListGetAt(strClientPlatform.OS_PART,2,';');
			}
			else if (agent CONTAINS "netscape")
				strClientPlatform.browser="netscape";
			else if (agent CONTAINS "Opera")
				strClientPlatform.browser="Opera";	
			else if (agent CONTAINS "firefox")
				strClientPlatform.browser="firefox";
			else if (agent CONTAINS "safari")
				strClientPlatform.browser="safari";	
			else
				strClientPlatform.browser="other";
			
			 return strClientPlatform;
			</cfscript>
			
		
		
	</cffunction>
	
	<!---Begin IsWebSpider() Function --->
	<cffunction name="IsWebSpider" returntype="boolean" access="public" hint="determines whether client (http_user_agent) is a web sider or not" output="no">
		<cfargument name="browser" type="string" required="yes" hint="pass the http_user_agent as argument">
				
				<!---Set default value for return var --->
				<cfset var blReturn = 0>
				<!--- Set known web spiders into list var ---> 
				<cfset var lstWebSipiders = "Webinator,Googlebot,Yahoo,ia_archiver,Trend,Crawler,msnbot,DTAAgent,cyberalert,LCC-LDL-C-60SP1-H-L,Slurp,TurnitinBot/2.0,libwww-perl,Poco,Gaisbot/3.0+,i586-pc-mingw32msvc,linuxindexer,heritrix,Ask Jeeves,bingbot,seakbot,Baiduspider,Feedfetcher-Google,Mediapartners-Google">
				
				<!--- Loop over list  to evaluate if  browser's name contains the name of a web spider --->
				<cfloop list="#lstWebSipiders#" index="i">
					<cfscript>
					if (arguments.Browser CONTAINS i)
						 blReturn = 1;
						 </cfscript>
					</cfloop>

			<cfreturn blReturn>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------- --->
	<!--- ------------------------------------------------------------------------------------- --->
	<!--- ------------------------------------------------------------------------------------- --->
	<cffunction name="WriteFile" access="public" output="no" hint="Write a file.">

		<!--- Function Arguments --->
		<cfargument name="file"    required="yes" type="string" hint="Pathname of the file to write.">
		<cfargument name="output"  required="yes" type="string" hint="Content of the file to be created.">
		<cfargument name="charset" required="no"  type="string" hint="The character encoding in which the file contents is encoded." default="utf-8">

		<cfif FindNoCase("Windows", this.os)>
			<cfset arguments.file = Replace(arguments.file, "/", "\", "ALL")>
		<cfelse>
			<cfset arguments.file = Replace(arguments.file, "\", "/", "ALL")>
		</cfif>

		<cffile action     = "write"
				file       = "#arguments.file#"
				output     = "#arguments.output#"
				charset    = "#arguments.charset#"
				addNewLine = "no">

	</cffunction>
	<!--- ------------------------------------------------------------------------------------- --->
	<!--- ------------------------------------------------------------------------------------- --->
	<!--- ------------------------------------------------------------------------------------- --->
	<cffunction name="ReadFile" access="public" output="no" returntype="string" hint="Write a file.">

		<!--- Function Arguments --->
		<cfargument name="file"    required="yes" type="string" hint="">
		
		<cfset var filedata="">
		
		<cfif FindNoCase("Windows", this.os)>
			<cfset arguments.file = Replace(arguments.file, "/", "\", "ALL")>
		<cfelse>
			<cfset arguments.file = Replace(arguments.file, "\", "/", "ALL")>
		</cfif>

		<cffile action     = "read"
				file       = "#arguments.file#"
				variable   = "filedata">
		
		<cfreturn filedata>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------- --->
	<!--- ------------------------------------------------------------------------------------- --->
	<!--- ------------------------------------------------------------------------------------- --->
	<cffunction name="DeleteFile" access="public" output="no" returntype="void" hint="delete a file.">
		<cfargument name="file"    required="yes" type="string" hint="">
		<cffile action="delete" file= "#trim(arguments.file)#">
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------- --->
	<!--- ------------------------------------------------------------------------------------- --->
	<!--- ------------------------------------------------------------------------------------- --->
	<cffunction name="MoveFile" access="public" output="no" returntype="void" hint="delete a file.">
		<cfargument name="source"    	  required="yes" type="string" hint="">
		<cfargument name="destination"    required="yes" type="string" hint="">
		<cffile action="move" source="#arguments.source#" destination="#arguments.destination#">
	</cffunction>
	
	<!--- ------------------------------------------------------------------------------------- --->
	<!--- ------------------------------------------------------------------------------------- --->
	<!--- ------------------------------------------------------------------------------------- --->
	<cffunction name="IsString" access="private" output="no" returntype="boolean" hint="Checked if the specified object is a string.">

		<!--- Function Arguments --->
		<cfargument name="object" required="yes" type="any" hint="The object to check.">

		<cftry>
			<cfset temp = Len(arguments.object)>
			<cfreturn true>

			<!--- Return false if the object is not a string --->
			<cfcatch type="coldfusion.runtime.CfJspPage$ComplexObjectException">
				<cfreturn false>
			</cfcatch>
		</cftry>

	</cffunction>
	<!--- ------------------------------------------------------------------------------------- --->
	<!--- ------------------------------------------------------------------------------------- --->
	<!--- ------------------------------------------------------------------------------------- --->
	<cffunction name="CreateExtraColumns" access="public" returntype="query" output="false" hint="Create additional columns in existing query based on list data in cell">
	<cfargument name="qry" 				required="yes" type="query"  hint="qry to manipulate">
	<cfargument name="colomnName"   	required="yes" type="string" hint="column that contains list ">
	<cfargument name="NewColomnName"  	required="yes" type="string" hint="name of new colomn(s) ">
	<cfargument name="NoExtraCols"  	required="yes" type="numeric" hint="no of new columns to create ">
	
	<cfscript>
		var arrNoElements = arraynew(1);
		var arrNULL = arraynew(1);
		var NoCols = arguments.NoExtraCols;
		var i = 0;
		var j = 0;
	</cfscript>
		
	
		<!---loop over qry--->
		<cfloop query="arguments.qry">
			<cfscript>
			//set array with values in cell that contains list
			ArrayAppend(arrNoElements, ListLen( evaluate(arguments.colomnName) ) );
			//append array with empty strings for inital value of newly created columns
			ArrayAppend(arrNULL, "");
			</cfscript>
		</cfloop>
	
		<!--- check the maximumn no of elements in the lists/cells--->
		<cfif ArrayMax(arrNoElements) LTE NoCols>
			<cfset NoCols = ArrayMax(arrNoElements)>
		</cfif>
			
		<!--- create a loop to iterate as many times as there will be new columns---> 
		<cfloop from="1" to="#NoCols#" index="i">
			<!--- Add new columns to existing qry --->
			<cfset QueryAddColumn(arguments.qry, "#arguments.NewColomnName##i#", "VarChar", arrNULL)>	
		</cfloop>
		
		<!---loop over updated qry--->
		<cfloop query="arguments.qry">
			<!--- loop over each element in list held in cell --->
			<cfloop from="1" to="#NoCols#" index="j">
				<cfif j LTE listLen(  evaluate(arguments.colomnName) )>
					<!--- Update cell of new column with data in list---> 
					<cfset QuerySetCell(arguments.qry, "#arguments.NewColomnName##j#",  ListGetAt(evaluate(arguments.colomnName), j),  arguments.qry.currentrow)>
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfreturn arguments.qry>
	</cffunction>
	<!--- --------------------------------------------------------------------------------------------------------------- --->
	<!--- --------------------------------------------------------------------------------------------------------------- --->
	<!--- --------------------------------------------------------------------------------------------------------------- --->	
	<cffunction name="queryRowToStruct" access="public" output="false" returntype="struct" hint="I make a row of a query into a structure.">
  		<cfargument name="qry" type="query" required="true" hint="I am the query to be converted" />
  
  		<cfscript>
   			//by default, do this to the first row of the query
   			var row = 1;
  			//a var for looping
   			var i = 1;
   			//the columns to loop over
   			var cols = listToArray(qry.columnList);
   			//the struct to return
   			var strReturn = structNew();
   			//if there is a second argument, use that for the row number
   			if (arrayLen(arguments) GT 1)
   			{
    			row = arguments[2];
   			}
   			//loop over the cols and build the struct from the query row
   			for(i = 1; i lte arrayLen(cols); i = i + 1)
   			{
    			strReturn[cols[i]] = qry[cols[i]][row];
   			}  
   			//return the struct
   			return strReturn;
  		</cfscript>
  
 	</cffunction>
	<!--- --------------------------------------------------------------------------------------------------------------- --->
	<!--- --------------------------------------------------------------------------------------------------------------- --->
	<!--- --------------------------------------------------------------------------------------------------------------- --->	
	<cffunction name="randomiseArray" access="public" output="false"  returntype="void" hint="randomly sorting an array using java class">
		<cfargument name="arr" required="yes" type="array" hint="the array to randomise.">
		 <cfset CreateObject( "java","java.util.Collections" ).Shuffle(arguments.arr) />
	</cffunction>
	
	
	<!--- --------------------------------------------------------------------------------------------------------------- --->
	<!--- --------------------------------------------------------------------------------------------------------------- --->
	<!--- --------------------------------------------------------------------------------------------------------------- 	
	<cffunction name="getRandomRow" access="public" output="false" returntype="void" hint="geta a single randomly seletct row from a query">
		<cfargument name="qry" required="yes" type="query" hint="the query to select from">
			
			<cfloop query="arguments.qry">
  					 <cfset querySetCell(arguments.qry,"sorter",rand(),currentRow)>
			</cfloop>
			<cfdump var="#arguments.qry#"><cfabort>
			<cfset arguments.qry = QueryOfQuery(arguments.qry, "*", "0=0", "sorter", 1)>
			
	</cffunction>--->
	
	<!--- --------------------------------------------------------------------------------------------------------------- --->
	<!--- --------------------------------------------------------------------------------------------------------------- --->
	<!--- --------------------------------------------------------------------------------------------------------------- --->	
	<cffunction name="collectionNumDocs" access="public" output="false" returntype="numeric" hint="returns no of documents in ">
		<cfargument name="collection" required="yes" type="string" hint="collection name">
			<cfset var qryCollections = querynew("name")>
			<cfset var num = 0>
			<cfcollection action="list" name="qryCollections">
			<cfset num =Queryofquery(qryCollections, "*", "lower(NAME)=Lower('his_LocalGov')").docCount>
			
			<cfif IsNumeric(num)>
				<cfreturn num>
				<cfelse>
				<cfreturn 0>
			</cfif>  
			
	</cffunction>
	<!--- --------------------------------------------------------------------------------------------------------------- --->
	<!--- --------------------------------------------------------------------------------------------------------------- --->
	<!--- --------------------------------------------------------------------------------------------------------------- --->	
	<cffunction name="refreshCfcStub" returntype="void" output="false" hint="refresh cfc stubs">
		<cfargument name="cfc" hint="full http path of cfc" type="string">
		
		<cfobject type="JAVA"
          action="Create"
          name="factory"
          class="coldfusion.server.ServiceFactory">
   
		<cfset RpcService = factory.XmlRpcService>
		
		<cfset RpcService.refreshWebService(cfc)>
	</cffunction>
	<!--- --------------------------------------------------------------------------------------------------------------- --->
	<!--- --------------------------------------------------------------------------------------------------------------- --->
	<!--- --------------------------------------------------------------------------------------------------------------- --->	
  	<cfscript>
		/**
		* This function takes URLs in a text string and turns them into links.
		* Version 2 by Lucas Sherwood, lucas@thebitbucket.net.
		* Version 3 Updated to allow for ;
		*
		* @param string      Text to parse. (Required)
		* @param target      Optional target for links. Defaults to "". (Optional)
		* @param paragraph      Optionally add paragraphFormat to returned string. (Optional)
		* @return Returns a string.
		* @author Joel Mueller (lucas@thebitbucket.netjmueller@swiftk.com)
		* @version 3, August 11, 2004
		*/
		function ActivateURL(string) {
			var nextMatch = 1;
			var objMatch = "";
			var outstring = "";
			var thisURL = "";
			var thisLink = "";
			var    target = IIf(arrayLen(arguments) gte 2, "arguments[2]", DE(""));
			var paragraph = IIf(arrayLen(arguments) gte 3, "arguments[3]", DE("false"));
			
			do {
				objMatch = REFindNoCase("(((https?:|ftp:|gopher:)\/\/)|(www\.|ftp\.))[-[:alnum:]\?%,\.\/&##!;@:=\+~_]+[A-Za-z0-9\/]", string, nextMatch, true);
				if (objMatch.pos[1] GT nextMatch OR objMatch.pos[1] EQ nextMatch) {
					outString = outString & Mid(String, nextMatch, objMatch.pos[1] - nextMatch);
				} else {
					outString = outString & Mid(String, nextMatch, Len(string));
				}
				nextMatch = objMatch.pos[1] + objMatch.len[1];
				if (ArrayLen(objMatch.pos) GT 1) {
					// If the preceding character is an @, assume this is an e-mail address
					// (for addresses like admin@ftp.cdrom.com)
					if (Compare(Mid(String, Max(objMatch.pos[1] - 1, 1), 1), "@") NEQ 0) {
						thisURL = Mid(String, objMatch.pos[1], objMatch.len[1]);
						thisLink = "<A HREF=""";
						switch (LCase(Mid(String, objMatch.pos[2], objMatch.len[2]))) {
							case "www.": {
								thisLink = thisLink & "http://";
								break;
							}
							case "ftp.": {
								thisLink = thisLink & "ftp://";
								break;
							}
						}
						thisLink = thisLink & thisURL & """";
						if (Len(Target) GT 0) {
							thisLink = thisLink & " TARGET=""" & Target & """";
						}
						thisLink = thisLink & ">" & thisURL & "</A>";
						outString = outString & thisLink;
						// String = Replace(String, thisURL, thisLink);
						// nextMatch = nextMatch + Len(thisURL);
					} else {
						outString = outString & Mid(String, objMatch.pos[1], objMatch.len[1]);
					}
				}
			} while (nextMatch GT 0);
				
			// Now turn e-mail addresses into mailto: links.
			outString = REReplace(outString, "([[:alnum:]_\.\-]+@([[:alnum:]_\.\-]+\.)+[[:alpha:]]{2,4})", "<A HREF=""mailto:\1"">\1</A>", "ALL");
				
			if (paragraph) {
				outString = ParagraphFormat(outString);
			}
			return outString;
		}
		</cfscript>
        <!--- --------------------------------------------------------------------------------------------------------------- --->
		<!--- --------------------------------------------------------------------------------------------------------------- --->
		<!--- --------------------------------------------------------------------------------------------------------------- --->	
        <cffunction name="isMobile" returntype="boolean" access="public" hint="Returns true if client request i smade from a mobile device">
            <cfargument name="cgiScope" required="yes" type="struct" />
            <cfset var bl = false>
            <cfif reFindNoCase("android|avantgo|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino",arguments.cgiScope.HTTP_USER_AGENT) GT 0 OR reFindNoCase("1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|e\-|e\/|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(di|rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|xda(\-|2|g)|yas\-|your|zeto|zte\-",Left(arguments.cgiScope.HTTP_USER_AGENT,4)) GT 0>
            <cfset bl = true>
            </cfif>
            <cfreturn bl>
		</cffunction>
    	<!--- --------------------------------------------------------------------------------------------------------------- --->
		<!--- --------------------------------------------------------------------------------------------------------------- --->
		<!--- --------------------------------------------------------------------------------------------------------------- --->	
</cfcomponent>