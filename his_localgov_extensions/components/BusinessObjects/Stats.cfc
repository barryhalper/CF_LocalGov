<cfcomponent displayname="Stats" hint="web sites statistics " extends="his_Localgov_Extends.components.BusinessObjectsManager">
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- FUNCTION: init()... --------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Stats" hint="Pseudo-constructor">
		<cfargument name="objAppObjs" type="any" required="yes" hint="The application manager object">
		<cfargument name="Config" type="struct" required="yes" hint="">
		
		
		<cfscript>
		// Call the genric init function, placing business, app, and dao objects into a local scope...
		StructAppend( variables, Super.initChild( arguments.objAppObjs, this ) );
	
		variables.logfilePath  	 = arguments.Config.strPaths.statsdir;
		variables.statsuploaddir = arguments.Config.strPaths.statsuploaddir;
		return this;
		</cfscript>
	</cffunction>
	
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions ------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="UpdateDNS" returntype="boolean" hint="get unknown ip address and do a dns look up for each row and update db accordingly ">
	
		<cfscript>
		var qryLogs = GetIpAddresses();
		var arrLogs =  arraynew(1);
		var sql = "";
		var sqlWhere = "";
		var addr = "";
		var i = 0;
		//loop over qry
		for ( i=1; i LTE qryLogs.recordcount; i=i+1 ){
			 if (Len(qryLogs.Ipaddress[i]) and qryLogs.Ipaddress[i] neq 'localhost'){
			   sql 	 = "INSERT INTO tblDNS (domainName,ipaddress) VALUES ( ";
			  //do dns look up
			  try{
			   domainName = DNSLookUp(qryLogs.Ipaddress[i]);
			   }
			   catch (any exception){};
			   //generate sql statment to update db
			   sql = sql &  "'" & domainName & "', '" & qryLogs.Ipaddress[i] & "')";
			   //add sql to array
			   objDAO.query(sql, variables.strConfig.strVars.dsn4); 
				//arrayAppend(arrLogs, sql); 
			} 
		}
		//If (ArrayLen(arrLogs))
			//run sql to inert data into db
			//objDAO.query(ArrayToList(arrLogs, " "), variables.strConfig.strVars.dsn4);
		
		return true;
		</cfscript>
	</cffunction> 
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getVariables" access="public" returntype="struct" output="false">
		<cfreturn variables>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="LoadServerlogs" returntype="boolean" access="public" hint="Call process to upload data from server logs ">
	
			
			<cfset var qryDirectory = "">
			<cfset var i = 0>
			<!---read directory of server logs --->
			<cfdirectory action="list" name="qryDirectory" directory="#variables.logfilePath#">
			
			<cfscript>
			//limit files to upload to those created yesterday
			qryDirectory = yesterdaysFiles(qryDirectory);
				//objUtils.dumpabort(qryDirectory);
			
			//objUtils.dumpabort(qryDirectory);
			
			If (qryDirectory.recordcount){
				for ( i=1; i LTE qryDirectory.recordcount; i=i+1 ){
					//move file into upload folder ready for DTS call
					//MoveLogFile(qryDirectory.name[i]);
					//call database to run DTS
					//uploadLog();
					ReadServerlog(logfilePath & qryDirectory.name[i]);
					}
			//move data into report table
			InsertRequestReport();
			//update dns records from any new IP address
			//UpdateDNS()
			}
			return true;
			</cfscript>	
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="LoadServerlogsDTS" returntype="boolean" access="public" hint="Call process to upload data from server logs ">
		<cfargument name="fullload" type="boolean" required="no" default="false">
			
			<cfset var qryDirectory = "">
			<cfset var i = 0>
			<!---read directory of server logs --->
			<cfdirectory action="list" name="qryDirectory" directory="#variables.logfilePath#">
			
			<cfscript>
			if (NOT arguments.fullload){
				//limit files to upload to those created yesterday
				qryDirectory = yesterdaysFiles(qryDirectory);
				//objUtils.dumpabort(qryDirectory);
			}
			If (qryDirectory.recordcount){
				for ( i=1; i LTE qryDirectory.recordcount; i=i+1 ){
					//move file into upload folder ready for DTS call
					MoveLogFile(qryDirectory.name[i]);
					//call database to run DTS
					uploadLog();
				
					}
			//move data into report table
			//InsertRequestReport();
			//update dns records from any new IP address
			//UpdateDNS()
			}
			return true;
			</cfscript>	
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="ReadServerlog" returntype="boolean" access="public" hint="Read server log files into memorry and create sql insert statement ">
		<cfargument name="filename" type="string" required="yes">
		
			<cfscript>
			var sqlString	="";
			var arrSQL 		= ArrayNew(1);
			var lstValues 	= "";
			var apostrophe	= chr(39);
			var rc 			= 0;
			var i			= 0;
			var Value		= 0;
			var	date		="";
			var	time		="";
			var	script_name	="";
			var	UserIP		="";
			var	browser		="";
			var	User_Agent	="";
			
			//read log file
			var log_data 	= objUtils.readfile(arguments.filename);
			//set log data into an array for faster looping
			var arrlog_data	= ListToArray(log_data, "#chr(13)##chr(10)#");
			//break the line
			for (rc=1; rc lte arrayLen(arrlog_data); rc=rc+1) {
				//start loop
				if (NOT left(arrlog_data[rc], 1) eq chr(35)){
					// Check that it's an actual line
						//the current line is not a valid log item, skip and go to the next line
								Value = 0;
								//set line into an array for faster looping
								arrRc = ListToArray(arrlog_data[rc], chr(32));
								//start loop
								for (i=1; i lte arrayLen(arrRc); i=i+1) {		
									Value = Value + 1;
									switch (Value) {
										case 1:
											date =apostrophe & arrRc[i] & apostrophe;
											break;
										case 2:
											time = apostrophe & arrRc[i] & apostrophe;
											break;
										case 5:	
											script_name =apostrophe & arrRc[i] & apostrophe;
											break;
										case 7:	
											UserIP =apostrophe & arrRc[i] & apostrophe;
											break;
										/*case 9:	
											browser =apostrophe & arrRc[i] & apostrophe;
											break;*/
										case 11:	
											User_Agent =apostrophe & arrRc[i] & apostrophe ;
											break;
									}
								}
								//check that request is for a template
								If (Find(".cfm", script_name)){
									//write out sql statement/.....
									sqlString = "BEGIN INSERT INTO tblServerLogs (RequestDate, Requesttime, script_name, UserIP, website) VALUES (";
									//append values to SQL
									sqlString = sqlString & "#date#,#time#,#script_name#,#UserIP#,#User_Agent#) END ";
									//set the sql statement into an array
									If (Len(UserIP))
										arrayAppend(arrSQL, sqlString );
									//clear string for next iteration
									sqlString = "";
									}
								}	
			
							}
				//execute sql
				
				objDAO.query(ArraytoList(arrSQL, " "), variables.strConfig.strVars.dsn4);		
				return true;
			</cfscript>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="AdminSearchStats" access="public"  hint="" returntype="query" output="false">
		<cfargument name="keyword" 	 required="yes" type="string">
		<cfargument name="startDate" required="yes" type="string">
		<cfargument name="dateEnd" 	 required="no" type="string" default="">
		<cfreturn objDAO.AdminSearchStats(argumentCollection=arguments)>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PRIAVTE Functions ----------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="DNSLookUp" access="private" returntype="string"  hint="pass IP Address and return domain name">
		<cfargument name="ip" required="yes" type="string">
		
		<cfscript>
		var objaddr = "";
		if (Not StructKeyExists(variables, "objClass")){
			//instatiate java class into persistant scope 
			variables.objClass	 = CreateObject("java", "java.net.InetAddress");
		}
		//get host name object
		objaddr = variables.objClass.getByName(arguments.ip);
		return objaddr.getHostName();
		</cfscript>  
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="uploadLog"  access="private" returntype="boolean" hint="Call db to run DTS and upload log ">
		<cfreturn objDAO.uploadLog()>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetIpAddresses" access="private" returntype="query"  hint="get all ip addresses stored in db">
		<cfreturn objDAO.GetIpAddresses()>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="InsertRequestReport" access="private" returntype="void"  hint="">
		<cfset objDAO.InsertRequestReport()>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="DeleteSeverLogs"  access="private" returntype="boolean" hint="Call db to run DTS and upload log ">
		<cfreturn objDAO.DeleteSeverLogs()>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="MoveLogFile"  access="private" returntype="boolean" hint="Move file to the location expected by the DTS so it can be uploaded">
		<cfargument name="logfile" required="yes" type="string">
			 
			<cfif FileExists("#logfilePath#upload.log")>
				<cffile action="DELETE" file="#logfilePath#upload.log" >
			</cfif> 
			<cffile action="copy" source="#logfilePath##arguments.logfile#" destination="#statsuploaddir#upload.log" >
			
			<cfreturn true>
	</cffunction> 
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- -----------------------------------------------------------------------------------------------------> 
	<cffunction name="yesterdaysFiles" access="private" returntype="query"  hint="filter directory data to get only those files created yesterday">
		<cfargument name="qryDir" required="yes" type="query">
		
		<cfscript>
		var today 	  = DateFormat(Now(),'dd/mm/yyyy'); 
		var daybefore = DateAdd('d', -1, Now());
		return request.objApp.objUtils.queryofquery(arguments.qryDir, "*", "datelastModified BETWEEN '#LSDateFormat(daybefore)#' AND '#LSDateFormat(today)#'");
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- -----------------------------------------------------------------------------------------------------> 
</cfcomponent>