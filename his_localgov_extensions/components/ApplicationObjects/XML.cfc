<cfcomponent hint="Function which manage import & export of XML for data Xchange">

	<!--- -------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------==--------------------------------------------------------->
	<!--- ---------------------------------------------------------=---------------------------------------->
	<cffunction name="ReadXmlConfig" access="public" output="true" returntype="xml" hint="read and parse xml file into cf data type">
		
		<cfargument name="xmlpath" required="yes" type="string" hint="name of xml document">
		<cfargument name="file" type="string" required="yes" hint="">
		
		<cfset var XMLDoc="">
		<cfset var sFile="">
	
		<cffile action="read" file="#arguments.xmlpath#\#arguments.file#" variable="sFile">
		
		<!--- parse file into var--->
		<cfset XMLDoc = XMLParse(sFile)>

		<!---return var --->
		<cfreturn XMLDoc>

	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------==--------------------------------------------------------->
	<!--- ---------------------------------------------------------=---------------------------------------->
	<cffunction name="ReadXml" access="public" output="true" returntype="xml" hint="read and parse xml file into cf data type">
		<cfargument name="URL" type="string" required="yes" hint="web address to xml file">
		<cfargument name="UseProxy" type="boolean" required="no" hint="decide if method needs to perfom request through the proxy server" default="0">
		
			<cfset var XMLDoc="">
		
				<cftry>	
					<!---check which version of CF is making the request --->
					<cfif arguments.UseProxy EQ 1>
					<!---Perform HTTP GET reques through the proxy server --->
						<cfhttp url="#arguments.URL#" method="GET" resolveUrl="false" proxyserver="192.168.1.12" proxyport="8080" proxyuser="hisproxy" proxypassword="C0ldfusion" throwonerror="yes" timeout="60"/>
					<cfelse>
						<!---perform http get request to return xml file content --->
						<cfhttp url="#arguments.URL#" method="GET" resolveUrl="false" throwonerror="yes" timeout="60"/>
					</cfif>
					
					<!--- parse file into var--->
					<cfset XMLDoc = XMLParse(trim(cfhttp.filecontent))>
						
						<cfcatch type="any">
							<cfrethrow>  
						</cfcatch>
					
			</cftry>
			<!---return var --->
			<cfreturn XMLDoc>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------==--------------------------------------------------------->
	<!--- ---------------------------------------------------------=---------------------------------------->
		<cffunction name="EmailError" access="public" output="true" hint="email alert for HTTP error">
			<cfargument name="Url" required="yes" type="string">
			<cfargument name="error" required="yes" type="any">
			<cfargument name="message" required="no" type="string" default="">
		
			<cfmail from="his.webmaster@hgluk.com" to="b.halper@hgluk.com" subject="HTTP Error : Coud not connect to XML Doc" type="html">
				URL: #arguments.Url#
				<p>
				<cfdump var="#arguments.error#"></p>
			</cfmail>
		</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------==--------------------------------------------------------->
	<!--- ---------------------------------------------------------=---------------------------------------->
	
			<!--- begin CreateNewsFeed() Function --->
		<cffunction name="CreateRSS" access="public" output="false" returntype="any" hint="create RSS feed based on qry">
			<cfargument name="qry" type="query" required="yes" hint="data to create feed from"> 
			<cfargument name="title" type="string" required="yes" hint= "title string for channel"> 
			<cfargument name="link" type="string" required="yes" hint="link string for channel"> 
			<cfargument name="description" type="string" required="yes" hint="description string for channel">
			<cfargument name="docs" type="string" required="yes" hint="path to rss docs"> 
			<cfargument name="imageurl" type="string" required="yes" hint="url for image for channel"> 
			 
				<cfscript>	 
				 //set channel attributes
				 var DateToday = DateFormat(Now(), "ddd dd mmm yyy") & " " & TimeFormat(Now(), "HH:mm:ss");
				 var xmldoc = "";
				 </cfscript>
				
				<cfxml variable="xmldoc" casesensitive="yes">
					<cfoutput>
						<!--RSS generated by hgluk.com on #Now()#-->
						<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">
						<!---Define channel/doc details --->
						<channel>
							<title>#XMLFormat(arguments.title)#</title>	
							<link>#arguments.link#</link> 
							<description>#XMLFormat(arguments.description)#</description>
							<language>en-gb</language>
   							 <docs>#arguments.docs#</docs>
							<lastBuildDate>#DateToday#</lastBuildDate>
								<cfif Len(arguments.imageurl)> 
									<image>
										<title>#arguments.title#</title>
										<url>#arguments.imageurl#</url>
										<link>#arguments.link#</link>
								  </image>
								 </cfif>
						</channel>
							
							<cfloop query="arguments.qry">
								<item>
									<title>#XMLFormat(arguments.qry.title)#</title>        
										<description><![CDATA[#arguments.qry.description#]]></description>
										<link>#arguments.link#</link>
										<cfif Len(arguments.qry.author)>
											<author>#arguments.qry.author#</author>
										</cfif>
										<cfif Len(arguments.qry.pubDate)>
											<pubDate>#arguments.qry.pubDate#</pubDate>
											</cfif>
								</item> 
							</cfloop>
							
				</rss>
				</cfoutput>
				</cfxml>
				<cfreturn xmldoc>
			</cffunction>		
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------==--------------------------------------------------------->
	<!--- ---------------------------------------------------------=---------------------------------------->
	<cffunction name="DownloadXML" access="public" output="false" hint="Get All XML Files present on our FTP server">
		<cfargument name="FTPServerDetails" required="yes" type="struct" hint="pass in strurcture with details of ftp server (IP, username, password)">
		<cfargument name="localpath" type="string" required="yes" hint="path to store XML files">
			
			<cfscript>
			var qrydirlist ="";
			var strFTP = arguments.FTPServerDetails;
			var myConn="";
			</cfscript>
			
			<!--- Open connection to FTP Server --->
			<cfftp action="open" server="#strFTP.IPAddress#" username="#strFTP.username#" 
			password="#strFTP.password#" timeout="300" passive="no"  connection="myConn">
		
			<!--- read directory --->
			<cfftp action="getcurrentdir" connection="myConn">
		
			<!---turn file listing into qry object --->
			<cfftp connection="myConn" action="listdir" directory="#cfftp.returnvalue#" name="qrydirlist" stoponerror="Yes">
	
				<!---loop over directory ---->
				<cfloop query="qrydirlist">
					<!---Download all files  --->
					<cfftp action="getfile"  connection="myConn" remotefile="#qrydirlist.name#" localfile="#arguments.localpath##qrydirlist.name#" 
					stopOnError="no">
				</cfloop>
				
				 <!---Close connection ----> 
				<cfftp action = "close" connection="myConn" stopOnError="no">
				
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------==--------------------------------------------------------->
	<!--- ---------------------------------------------------------=---------------------------------------->

	<cffunction name="Struct2Xml" access="public" returntype="xml" hint="turn struct object into XML document" output="false">
		<cfargument name="str" required="yes" type="struct" hint="structure object ">	
		<cfargument name="idcolumn" required="yes" type="string" hint="name of primary key column ">	
		<cfargument name="parentelement" required="yes" type="string" hint="name of parent element">
		<cfargument name="childelement" required="yes" type="string" hint="name of child element">
		<cfargument name="complexNode" required="no" type="string" hint="name of complex data type nested in nested structure" default="">
		
			<cfscript>
			var SrtResults = arguments.str;
			var i ="";
			var childitem="";
			var arrItem ="";
			var xmlvar="";
			</cfscript>
		 
				<cfxml variable="xmlvar">
				<cfoutput>
				<#arguments.parentelement#> 
				  <!---loop over parent structure ---->
					<cfloop collection="#SrtResults#" item="i">
                  		 <#arguments.childelement# id="#i#">
						 <!--- loop over nested structure --->
						  <cfloop collection="#SrtResults[i]#" item="childitem">
						  			<!---output str keys and values into XML (except that which is a nested array)--->
                                      <cfif Len(arguments.complexNode) AND childitem NEQ arguments.complexNode  AND NOT IsArray(childitem) AND childitem NEQ arguments.idcolumn>
                                      	<#lcase(childitem)#>#XMLFormat(SrtResults[i][childitem])#</#lcase(childitem)#>
                                      	<cfelseif Len(arguments.complexNode) AND IsArray(arguments.complexNode)>
												<!---loop over nested array --->
                                               	 <cfloop from="1" to="#ArrayLen(SrtResults[i][childitem])#"  index="arrItem">       
                                                          <#childitem#>#XMLFormat(SrtResults[i][childitem][arrItem])#</#childitem#>
                                              	  </cfloop>  
                                          </cfif>
                                      </cfloop>
                             	</#arguments.childelement#>   
							</cfloop>
					</#arguments.parentelement#>
 			 	</cfoutput>
				</cfxml>
				
			<cfreturn 	xmlvar>
		</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------==--------------------------------------------------------->
	<!--- ---------------------------------------------------------=---------------------------------------->
		<cffunction name="Qry2Xml" access="public" returntype="xml" hint="turn qry object into xml" output="false">
			<cfargument name="qry" type="query" required="yes" hint="qry to be tuned into XML">
			<cfargument name="parentelement" type="string" required="yes" hint="name of 1st or parent XML element">
			<cfargument name="childelement" type="string" required="yes" hint="name of  XML child element">
			<cfargument name="ElementList" type="string" required="no" default="" hint="list of column to be turned into xml - defaults to qry.columnlist">
			
				<cfscript>
				var i="";
				var xmlvar="";
				var lstElements ="";
				If (Len(arguments.ElementList))
					lstElements = arguments.ElementList;
				else
					lstElements = arguments.qry.columnlist;
				</cfscript>
				
				<cfxml variable="xmlvar"><cfoutput><#arguments.parentelement#>		
					<cfloop query="arguments.qry">
						<#arguments.childelement#>
							<cfloop list="#lstElements#" index="i">
									<#lcase(i)#>#XMLFormat(Evaluate(i))#</#lcase(i)#>
								</cfloop>
						</#arguments.childelement#>		
						</cfloop>	
					</#arguments.parentelement#></cfoutput></cfxml>	
		
			<cfreturn xmlvar>
		</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------==--------------------------------------------------------->
	<!--- ---------------------------------------------------------=---------------------------------------->
		<cffunction name="Xml2File" access="public" hint="write xml var into document" output="false">
			<cfargument name="XmlVar" 	required="yes" 	type="xml" hint="XML variable">
			<cfargument name="FilePath" required="yes" 	type="string" hint="full path and filename to write file to">	
			<cfargument name="FileConflict" required="no" type="string" hint="cffile name conflict attribute" default="makeunique">
			<!--- <cfargument name="Filename" required="yes" type="string" hint="name of file"> --->
			
				<cfset var XMLFile = arguments.FilePath>
					<cffile action="write" file="#XMLFile#" output="#ToString(arguments.XmlVar)#" nameconflict="#arguments.FileConflict#" charset="utf-8">
		
		</cffunction> 
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------==--------------------------------------------------------->
	<!--- ---------------------------------------------------------=---------------------------------------->
		<cffunction name="SearchXML" access="public"  output="false" returntype="array" hint="perform xpath search on xml object">
			<cfargument name="XmlVar" required="yes" 	type="xml" hint="XML variable">
			<cfargument name="xpath" required="yes" 	type="string" hint="xpath string">
			<cfargument name="criteria" required="yes" 	type="string" hint="search string">
				
				<cfscript>
				var arr = XMLSearch(arguments.XmlVar, "#arguments.xpath#[#arguments.criteria#]");
				return arr; 
				</cfscript>		
				
		</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------==--------------------------------------------------------->
	<!--- ---------------------------------------------------------=---------------------------------------->
		<cffunction name="GetElementList" access="public" returntype="string" output="false" hint="Get a comma delimted list of all elements on XML">
			<cfargument name="xmlvar" 	required="yes" 	type="xml" hint="parsed xml variable">
			<cfargument name="xpath" 	required="yes" 	type="string" hint="path to child to where elements are contianed">
			
				<cfscript>
				//get array of children
				var arrItems = XMLSearch(arguments.xmlvar, arguments.xpath);
				var i="";
				var lstElements = "";
				var keys="";
				var lstAttributes="";
				//loop over 1st array
				for (i=1;i LTE 1;i=i+1 ){
						//loop over structure (the XML Attributes) to get keys
						for (keys in (arrItems[i].xmlattributes)){
							//set child attributes(keys) into list var
							lstAttributes=ListAppend(lstAttributes, keys);
							}}
					// loop over 1st child array 
					for (i=1; i LTE arrayLen(arrItems[1].xmlchildren); i=i+1 ){
					//to get all elements(/qry columns set child items into list object 
						lstElements = listAppend(lstElements,arrItems[1].xmlchildren[i].xmlname);
						}
						//check if there are any child attributes
						if (Len(lstAttributes))
						//append child attributes to list of elements
						lstElements = listAppend(lstElements, lstAttributes);
					return lstElements;
				</cfscript>
		</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------==--------------------------------------------------------->
	<!--- ---------------------------------------------------------=---------------------------------------->
		<cffunction name="XMl2Query" access="public" returntype="query" output="false" hint="Turn xml var into qry object">
			<cfargument name="xmlvar" required="yes" type="xml" hint="xml variable">
			<cfargument name="xpath" required="yes" type="string" hint="path to child to where elements are contianed">
			<cfargument name="ChildNode" required="no" type="string" hint="name of nested child element" default="">
			<cfargument name="elementlist" required="no" type="string" hint="list of elements to be output to qry" default="">
			<cfargument name="elementattritbute" required="no" type="boolean" hint="pass value to put id in attribute" default="0">
			
			
				<cfscript>
				//get array of children
				var arrItems = XMLSearch(arguments.xmlvar, arguments.xpath);
				//var arrItems =arguments.ArrXml;
				 var lstColumns = arguments.elementlist;
				var arrIndex = "";
				var xmlChild = "";
				var lstCellValue="";
				var qry="";
				If (NOT Len(lstColumns))
				//call method to get list of columns for qry based on child elements
				lstColumns= GetElementList(arguments.xmlvar, arguments.xpath);
				//create qry object 
				qry =QueryNew(lstColumns);
				//array loop
				for (arrIndex=1;arrIndex LTE arrayLen(arrItems);arrIndex=arrIndex+1 ){
				//create a new row for each child
				QueryAddRow(qry);
				//if (arguments.elementattritbute eq 1)
				  QuerySetCell(qry, "ID", arrItems[arrIndex].xmlattributes.id);
					//array loop over children 
					for (xmlChild=1; xmlChild LTE arrayLen(arrItems[arrIndex].xmlchildren); xmlChild=xmlChild+1 ){
						//check if child element is in qry column list
						If (ListFindNoCase(lstColumns, arrItems[arrIndex].xmlchildren[xmlChild].xmlname) ){
							IF (Len(arguments.childnode) AND arrItems[arrIndex].xmlchildren[xmlChild].xmlname NEQ arguments.childnode)
								//set value into cell in qry 
								QuerySetCell(qry, arrItems[arrIndex].xmlchildren[xmlChild].xmlname, arrItems[arrIndex].xmlchildren[xmlChild].xmlText);
							Else{
								lstCellValue=ListAppend(lstCellValue, arrItems[arrIndex].xmlchildren[xmlChild].xmlText);
								QuerySetCell(qry, arrItems[arrIndex].xmlchildren[xmlChild].xmlname, lstCellValue);}
								}
								//reset cell value to empty string ready for next iteration
								lstCellValue="";
								}
						}
					return qry;
				</cfscript>
		</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------==--------------------------------------------------------->
	<!--- ---------------------------------------------------------=---------------------------------------->	
	<cffunction name="XmlMerge" access="public" returntype="any" output="false" hint="merge xml documents passed in structure">
		<cfargument name="str" 	 required="yes" type="struct" hint="structure of xml doc">
		<cfargument name="xPath" required="yes" 	type="string" hint="Path in xml to children">
				 
           <cfscript>
           	var i="";
           	var x = "";
			var xmldoc="";
            var arrXML="";
            var node ="";
			//get node names from xpath
			var rootnode =  ListGetAt(arguments.xPath, 1, "/");
			var childnode = ListGetAt(arguments.xPath, 2, "/");
            //create a new XML document
            var xmlObject = XmlNew();
            //create root element
            xmlObject.xmlroot = XmlElemNew(xmlObject, rootnode);
            //loop over structure of xml doc
            for (xmldoc in str){
              arrXML = str[xmldoc].xmlroot.xmlChildren;;
              //loop over children of root
              for (i=1;i LTE arrayLen(arrXML);i=i+1 ){
				//create a new node for each job
                node = XmlElemNew(xmlObject, rootnode);
                // loop over children of child node
                for (x=1;x LTE arrayLen(arrXML[i].xmlchildren);x=x+1 ){
                   //set name of child new based on aech node in xml
                   node["#arrXML[i].xmlchildren[x].xmlname#"] = XmlElemNew(xmlObject, arrXML[i].xmlchildren[x].xmlname);
                   //assign value to child node
                   node["#arrXML[i].xmlchildren[x].xmlname#"].xmlText = arrXML[i].xmlchildren[x].xmltext;
                 }
                 arrayappend(xmlObject["#rootnode#"].xmlChildren, node);
                }
               }
              return xmlObject;
			</cfscript>

			</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------==--------------------------------------------------------->
	<!--- ---------------------------------------------------------=---------------------------------------->
		<cffunction name="Qry4RSS" access="public" output="false" returntype="query" hint="Prepare qry for RSS feed by renaming exsiting SQL columns">
				<cfargument name="qry" required="yes" type="query" hint="pass into query whose columns are to be aliased">
				<cfargument name="Title" required="yes" type="string" hint="name of column in qry">
				<cfargument name="Desc" required="yes" type="string" hint="name of column in qry">
				<cfargument name="pubDate" required="yes" type="string" hint="name of column in qry">
				<cfargument name="Author" required="no" type="string" hint="name of column in qry" default="">
						
					<cfscript> 
					var RssQry = "";
					//build up SELECT string based on arguments to re-aliased columns
					var SelectVar = arguments.Title & " AS Title, "  & arguments.Desc & " AS Description, "  & arguments.pubDate & " AS pubDate, " ;
					var authorVar =' '' ' & " AS Author ";
					if (Len(arguments.Author)) 
						authorVar =arguments.Author & " AS Author " ;
					SelectVar = SelectVar & authorVar;
					</cfscript>

						<!--- qry the incoming qry to alias existing columns  --->
						<cfquery dbtype="query" name="RssQry">
							SELECT #SelectVar#
							FROM arguments.qry
						</cfquery>
	
				<cfreturn RssQry>
		</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------==--------------------------------------------------------->
	<!--- ---------------------------------------------------------=---------------------------------------->
		<cffunction name="form2SqlXml" access="public"  output="false" returntype="any" hint="copy structure (form) into XML compatibale with MSSQL import routines">
				<cfargument name="strInput" required="yes" type="struct" hint="pass in strcuturwe which should have comma sepearted list as key value (as in an input form)">
		 
				 <cfscript>
				 var xmlvar="";
				 var item=""; 
				 var index="";
				 </cfscript>
		
					<cfxml variable="xmlvar" casesensitive="yes">
						<cfoutput>
						<!---parent element --->
						<root>
						<!--- loop over structure to get 1st child elements and attributes --->
						<cfloop collection="#arguments.strInput#" item="item">
								<structure keyname="#XmlFormat(item)#">
									<cfloop list="#arguments.strInput[item]#" index="index">
										<valuename str="#trim(XmlFormat(index))#"/>				
										</cfloop>
								</structure>
						</cfloop>
						</root>
						</cfoutput>
					</cfxml>
		 
			<cfreturn xmlvar>
		</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------==--------------------------------------------------------->
	<!--- ---------------------------------------------------------=---------------------------------------->
		<cffunction name="Array2Xml" access="public"  output="false" returntype="xml" hint="turn an array of xml children back into xml onbject">
			<cfargument name="xmlchildren" required="yes" type="array">
			<cfargument name="root" required="yes" type="string">
			<cfargument name="child" required="yes" type="string">
			
				<cfscript>
				var xmlObject = XmlNew();
				var arrXML = arguments.xmlchildren;
				var i ="";
				var node ="";
				//create root element
				xmlObject.xmlroot = XmlElemNew(xmlObject, arguments.root);
				 for (i=1;i LTE arrayLen(arrXML);i=i+1 ){
						//create a new node for each job
						node = XmlElemNew(xmlObject, arguments.child);
						// loop over children of child node
						for (x=1;x LTE arrayLen(arrXML[i].xmlchildren);x=x+1 ){
								 //set name of child new based on each node in xml
								 node["#arrXML[i].xmlchildren[x].xmlname#"] = XmlElemNew(xmlObject, arrXML[i].xmlchildren[x].xmlname);
								  //assign value to child node
								  node["#arrXML[i].xmlchildren[x].xmlname#"].xmlText = arrXML[i].xmlchildren[x].xmltext;
							 }
					}		 
                    arrayappend(xmlObject[arguments.root].xmlChildren, node);
					return xmlObject;
				</cfscript>
				
		</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------==--------------------------------------------------------->
	<!--- ---------------------------------------------------------=---------------------------------------->
	<cffunction name="xmltranslate" access="public" returntype="string" output="false" hint="place string into xml translate function">
		<cfargument name="txt" required="yes" type="string">
		
			<cfscript>
				var xmlfunction =  "translate('#arguments.txt#', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')";
				return xmlfunction;
			</cfscript>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------==--------------------------------------------------------->
	<!--- ---------------------------------------------------------=---------------------------------------->	
	<cffunction name="xml2Struct" access="public" returntype="struct" output="false" hint="read xml elements into structure">
		<cfargument name="xmlvar" required="yes" type="xml" hint="xml variable">
		
			<cfscript>
			var str = structnew();
			var xmldoc = arguments.xmlvar;
			var arrXML= "";
			var i = "";
			
			if (StructKeyExists(xmldoc, "xmlroot"))
				arrXML= xmldoc.xmlroot.xmlchildren;
			else	
				arrXML= xmldoc.xmlchildren;
			
			 for (i=1;i LTE arrayLen(arrXML);i=i+1 ){
				StructInsert(str, arrXML[i].xmlname, arrXML[i].xmltext);
			 }
			 return str;
			</cfscript>
				
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------==--------------------------------------------------------->
	<!--- ---------------------------------------------------------=---------------------------------------->
	<cffunction name="xsdDateFormat" access="public" returntype="string" output="false" hint="convert data to xsd compliant DateTime format">
				<cfargument name="date" required="yes" type="date">
					<cfreturn DateFormat(arguments.date,'yyyy-mm-dd') & 'T' & TimeFormat(arguments.date,'hh:mm:ss')>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------==--------------------------------------------------------->
	<!--- ---------------------------------------------------------=---------------------------------------->
	<cffunction name="DecodeXsdDateTime" access="public" returntype="date" output="false" hint="convert xsd compliant DateTime format to sql date">
				<cfargument name="date" required="yes" type="string">
					<cfreturn Left(arguments.date, Find("T", dt)-1)>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------==--------------------------------------------------------->
	<!--- ---------------------------------------------------------=---------------------------------------->		
	<cffunction name="generateSiteMap" output="false" returnType="xml">  
			<cfargument name="data" 		type="array"   required="true" hint="array of url's">  
			<cfargument name="lastmod"  	type="date"    required="false">  
			<cfargument name="changefreq" 	type="string"  required="false">  
			<cfargument name="priority" 	type="numeric" required="false">  
			   
			
			<cfset var xml = "">  	
			<cfset var link = "">  
			<cfset var validChangeFreq = "always,hourly,daily,weekly,monthly,yearly,never">  
			<cfset var newDate = "">  
			<cfset var tz = getTimeZoneInfo().utcHourOffset>  
			   
			<cfif structKeyExists(arguments, "changefreq") and not listFindNoCase(validChangeFreq, arguments.changefreq)>  
				<cfthrow message="Invalid changefreq (#arguments.changefreq#) passed. Valid values are #validChangeFreq#">  
			</cfif>  
		  
			<cfif structKeyExists(arguments, "priority") and (arguments.priority lt 0 or arguments.priority gt 1)>  
				<cfthrow message="Invalid priority (#arguments.priority#) passed. Must be between 0.0 and 1.0">  
			</cfif>  
			   
			<!--- reformat datetime as w3c datetime / http://www.w3.org/TR/NOTE-datetime --->  
			<cfif structKeyExists(arguments, "lastmod")>               
				<cfset newDate = dateFormat(arguments.lastmod, "YYYY-MM-DD") & "T" & timeFormat(arguments.lastmod, "HH:mm")>  
				<cfif tz gte 0>  
					<cfset newDatenewDate = newDate & "-" & tz & ":00">  
				<cfelse>  
					<cfset newDatenewDate = newDate & "+" & tz & ":00">  
				</cfif>        
			</cfif>  
			
			
			<cfoutput><cfxml variable="xml">
				  <urlset xmlns="http://www.google.com/schemas/sitemap/0.84">
				<cfloop from="1" to="#arrayLen(arguments.data)#" index="link"><url>  
						<loc>#xmlFormat(arguments.data[link])#</loc> 
						<cfif structKeyExists(arguments,"lastmod")><lastmod>#newDate#</lastmod></cfif><cfif structKeyExists(arguments,"changefreq")> <changefreq>#arguments.changefreq#</changefreq> </cfif> 
						<cfif structKeyExists(arguments,"priority")><priority>#arguments.priority#</priority></cfif> 
						</url> </cfloop></urlset>	
				</cfxml></cfoutput>
			
			
			<cfreturn xml>  
			   
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------==--------------------------------------------------------->
	<!--- ---------------------------------------------------------=---------------------------------------->
	<cffunction name="BuildSitemap" access="public" returntype="void" hint="turn menu.xml into sitemap.xml">
		<cfargument name="xmlMenu"  required="yes" type="xml">
		<cfargument name="sitepath" required="yes"  type="string" default="">
		<cfargument name="filepath" required="no"  type="string" default="">
		<cfargument name="xmlpath" 	required="no"  type="string" default="/menu/item">
		<cfargument name="changefreq" 	required="no"  type="string" default="monthly">
		<cfscript>
		var i=0;
		var x=0;
		var z=0;
		var link="";
		var lst = "";
		var aLinks = ArrayNew(1);
		var XsiteMap ="";
		var aChildren="";
		var aMenuChildren="";
		var aMenu = XMLSearch(arguments.xmlMenu, arguments.xmlpath);
			
		//loop over parent node 
		for (i=1;i LTE arrayLen(aMenu) ;i=i+1 ){
			//extract links from attributes
			link = aMenu[i].xmlattributes.link;
			//append link into return var
			arrayAppend(aLinks,link);
			//extract child node
			aMenuChildren = aMenu[i].xmlChildren;
			//loop over child nodes
			for (x=1;x LTE arrayLen(aMenuChildren) ;x=x+1 ){
				//extract 3 child node
				aChildren = aMenuChildren[x].xmlChildren;
				//loop over node
				for (z=1;z LTE arrayLen(aChildren) ;z=z+1){
					//extract links from attributes
					link = aChildren[z].xmlattributes.link;
					//append link into return var
					arrayAppend(aLinks,link);
					}
				}
			} 
			//make array a unique list
			lst = request.objApp.objString.ListUnique(ArraytoList(aLinks));
			aLinks = ListtoArray(lst);
			</cfscript>
			<cfsilent >
				<cfsavecontent variable="XsiteMap"><?xml version="1.0" encoding="UTF-8"?>
				  <urlset xmlns="http://www.google.com/schemas/sitemap/0.84">
				   <cfloop from="1" to="#arrayLen(aLinks)#" index="i">
				   <url>
					<loc><cfoutput>#arguments.sitepath##XmlFormat(aLinks[i])#</cfoutput></loc>
					<lastmod><cfoutput>#dateFormat(Now(), 'yyyy-mm-dd')#</cfoutput></lastmod>
					<changefreq>#arguments.changefreq#</changefreq>
				   </url>  
				   </cfloop>
				  </urlset></cfsavecontent>
			</cfsilent >
			<!--- write xml var 2 file---> 	  
			<cfset Xml2File(XsiteMap, arguments.filepath, "overwrite")>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------==--------------------------------------------------------->
	<!--- ---------------------------------------------------------=---------------------------------------->
	<cffunction name="BuildBreadcrumb" access="public" returntype="void" hint="turn menu.xml into breadcrumb.xml (wchih them must be edited by hand)">
	<cfargument name="xmlMenu"  required="yes" type="xml">
	<cfargument name="filepath" required="no"  type="string" default="">
	<cfargument name="xmlpath" 	required="no"  type="string" default="/menu/item">
	
	<cfscript>
	var i=0;
	var x=0;
	var z=0;
	var link="";
	var lst = "";
	var aLinks = ArrayNew(1);
	var xBreadcrumb ="";
	var aChildren="";
	var aMenuChildren="";
	var aMenu = XMLSearch(arguments.xmlMenu, arguments.xmlpath);
	</cfscript>

		<cfxml variable="xBreadcrumb">
			<breadcrumbs><cfoutput><!---loop over menu---><cfloop from="1" to="#ArrayLen(aMenu)#" index="i"> 
			<directory name="#XmlFormat(aMenu[i].xmlattributes.name)#" circuit="#lcase(ListFirst(aMenu[i].xmlattributes.link, "."))#" link="#XmlFormat(aMenu[i].xmlattributes.link)#"><cfset aMenuChildren = aMenu[i].xmlChildren><cfloop from="1" to="#ArrayLen(aMenuChildren)#" index="x"><cfset aChildren = aMenuChildren[x].xmlChildren>	<cfloop from="1" to="#ArrayLen(aChildren)#" index="z">
						<node name="#Replace(xmlFormat(aChildren[z].xmlattributes.name), "index.cfm?method=", "")#" fuseaction="#xmlFormat(aChildren[z].xmlattributes.link)#"></node></cfloop></cfloop>
			</directory></cfloop></cfoutput>
				</breadcrumbs>
		</cfxml>
		
		<cfset Xml2File(xBreadcrumb, arguments.filepath, "overwrite")>
		
</cffunction>
			
</cfcomponent>