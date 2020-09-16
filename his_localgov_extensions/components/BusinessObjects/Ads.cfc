<!--- 
	
	$Archive: /localgov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/BusinessObjects/Ads.cfc $
	$Author: bhalper $
	$Revision: 33 $
	$Date: 29/03/10 12:04 $

--->

<cfcomponent displayname="Ads" hint="Advertising-related functions, inheriting any common business-related functions." extends="his_Localgov_Extends.components.BusinessObjectsManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- FUNCTION: init()... --------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Ads" hint="Pseudo-constructor">
	
		<cfargument name="objAppObjs" type="any" required="yes" hint="The application manager object">
		
		<cfscript>
		// Call the genric init function, placing business, app, and dao objects into a local scope...
		StructAppend( variables, Super.initChild( arguments.objAppObjs, this ) );
		//variables.strAdSelects = GetAdSelects();
		variables.sourcepath 	 = variables.strConfig.StrPaths.sitedir & variables.strConfig.StrPaths.adlogodir;
		variables.qryGetAllAds    = getAllAds();
		return this;
		</cfscript>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions ------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetVariables" access="public" output="false" returntype="struct" hint="">
		<cfreturn variables>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetAdSelects" access="public" output="false" returntype="struct" hint="returns mutilple result sets to be used in the various ad select forms">
		<cfif NOT StructKeyExists(variables, "strAdSelects")>
			<cfreturn objDAO.GetAdSelects()>
		<cfelse>
			<cfreturn variables.strAdSelects>
		</cfif>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetAllAds" access="public" output="false" returntype="query" hint="returns all ads">
		<cfargument name="refreshQuery" type="boolean" required="no" default="0" hint="Use this argument to refresh the ads query object">
			<cfset var qry  ="">
		<!--- if the key exists in the variables structure and the refreshQuery argument is false, acess the recordset from memory --->
		<cfif StructKeyExists(variables, "qryGetAllAds") AND NOT arguments.refreshQuery>
			<cfset qry= variables.qryGetAllAds >
		<cfelse>
			<cfset qry= objDAO.getAllAds()>
			<cfset variables.qryGetAllAds= qry>
		</cfif>
		
		<cfreturn qry>
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetAdsinSectors" access="public" output="false" returntype="query" hint="returns ads that have sectors">
		<cfargument name="refreshQuery" type="boolean" required="no" default="0" hint="Use this argument to refresh the ads query object">
		
		<cfset var qry  ="">
		<!--- if the key exists in the variables structure and the refreshQuery argument is false, acess the recordset from memory --->
		<cfif StructKeyExists(variables, "qryAdsinSectors") AND NOT arguments.refreshQuery>
			<cfset qry= variables.qryAdsinSectors >
		<cfelse>
			<cfset variables.qryAdsinSectors = objDAO.GetAdsinSectors()>
			<cfset qry= variables.qryAdsinSectors>
		</cfif>
		
		<cfreturn qry>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetAdsforOutput" access="public" output="false" returntype="query" hint="returns query for the right ad to be output">
		<cfargument 	name="circuit" 		required="yes" 	type="string">
		<cfargument 	name="fuseaction" 	required="yes" 	type="string">
		<cfargument 	name="adtypeid" 	required="yes" 	type="numeric">
		<cfargument 	name="positionID" 	required="no" 	type="numeric" default="0">
		<cfargument 	name="topicid" 		required="no" 	type="string" default="0">
		<cfargument 	name="sectors" 		required="no" 	type="string" default="0">
		
		<cfscript>
		 var qryAdsinSectors = querynew("temp");
		 //var qrySectors 	 = querynew("temp");
		 var qryAds 		 	 = querynew("temp");
		 var posID 			 	 = "";
		 
		  //check that there is position for this ad
		 If (arguments.positionID)
		 	// start building the sql string
		 	posID = "AND positionid = #arguments.positionID#";
		/* If (arguments.circuit NEQ 'events' AND arguments.circuit NEQ 'jobs' AND arguments.circuit NEQ 'business'AND arguments.circuit NEQ 'newsletter')
		 	arguments.circuit = 'home';*/	
		if (arguments.topicid){
				posID = posID & " AND topicid = " & arguments.topicid;
			}
			
		//if ad is right tile and user has performerd a job sectors search.........
		 if (listFind("jobs.AdvSearchaction,news.sector", fuseaction) and Len(arguments.sectors) and  adtypeid eq 15){
		 		qryAds = request.objApp.objutils.QueryOfQuery(GetAdsinSectors(),"*","circuit_name = '#arguments.circuit#' AND f_adtype_id = #arguments.adtypeid# #posID# AND f_sector_id IN (#arguments.sectors#)" , "date_start");
		 	//request.objApp.objutils.dumpabort(qryAds);
		 }
		 
		 if (NOT qryAds.recordcount)
		   //if ads query has not yet been run or ads in sectors has not found anything, get all normal ads
		   qryAds = request.objApp.objutils.QueryOfQuery(variables.qryGetAllAds,"*","circuit_name = '#arguments.circuit#' AND f_adtype_id = #arguments.adtypeid# #posID#", "date_start");
		
		
		return qryAds;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="OutputAd" access="public" output="true" returntype="struct" hint="outputs the ad on the localgov website">
		<cfargument 	name="qryAds" 		required="yes" 		type="query">
		<cfargument 	name="circuit" 		required="yes" 		type="string">
		<cfargument 	name="adtypeid" 	required="yes" 		type="numeric">
		<cfargument 	name="positionID" 	required="no" 		type="numeric" default="0">
		<cfargument 	name="AdlinkURL" 	required="yes" 		type="string">
		<cfargument 	name="width" 		required="no" 		type="string" default="120">
		<cfargument 	name="height" 		required="no" 		type="string" default="150">
		<cfargument 	name="topicid" 		required="no" 		type="string" default="0">
		<cfargument name="strSession" required="yes" type="struct">
			
		<cfscript>
		 var strReturn 			=	Structnew();
		 var outputstring 		=   getAdForPage(argumentCollection=arguments);
		 var item 				= CreateUUID();
		 strReturn.isSticky	= false;
		</cfscript>
				
			<cfsavecontent variable="strReturn.imagevar">
				<cfoutput>	
					<cfif  ListLast(outputstring, ".") eq "swf">
							<!--- create js to load falsh movie --->
							<cfsavecontent variable="flashcontentvar">
								<script type="text/javascript">
	   								swfobject.embedSWF("#outputstring#", "flashad#item#", "#arguments.width#", "#arguments.height#", "7.0.0");
	  					  		</script>
							</cfsavecontent>
								
							<cfhtmlhead text="#flashcontentVar#"/>
							<div id="flashad#item#"></div>
					
					<cfelse>
					#outputstring#
					</cfif>
				</cfoutput>
			</cfsavecontent> 	
		<cfset strReturn.imagevar = Replace(strReturn.imagevar, "ord=[timestamp]", "ord=#RandRange(1000000, 9999999)#", "all")>
		<cfreturn strReturn >
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="doCFLog" access="private" returntype="void">
	   <cfargument name="text" type="string" required="yes">
	   <cfargument name="file" type="string" required="yes">
	   
	   <cflog text="#arguments.text#" file="#arguments.file#">
	</cffunction>
	
	<cffunction name="getAdForPage" access="public" returntype="string" hint="requires query object for this page and returns string from 1st element in a randomised array of ads">
		<cfargument 	name="qryAds" 		required="yes" 	type="query">
		<cfargument 	name="circuit" 		required="yes" 	type="string">
		<cfargument 	name="AdlinkURL" 	required="yes" 	type="string">
		<cfargument 	name="width" 			required="no" 	type="string" default="120">
		<cfargument 	name="height" 		required="no" 	type="string" default="150">
		<cfargument name="strSession" required="yes" type="struct">
		
		<cfscript>
		var arrImages = ArrayNew(1); /* array to hold struc of immges to hold image and id */
		var strImages = ""; /* struct to hold image and id */
		var i              		= 0;
		var qry 		 		= arguments.qryAds;
		var link		 		= "";
		var image      			= "";
		var path				= "";
		var returnString   		= "";
		
		//BEGIN LOOP
		for (i = 1; i lte qry.recordcount; i = i +1){
			
			//doCFLog(text="getAdForPage Loop - interation #i#", file="LoopLog");
			//ensure datatype is boolean
			externallyHosted  = JavaCast("boolean", qry.externallyHosted[i]);
			
			//check if file is present if ad is internally hosted
			if (FileExists("#strConfig.strPaths.sitedir##strConfig.strPaths.adlogodir##qry.source[i]#") or externallyHosted ){
				//set transfer protocol based of link
				 if  ( Find("@",qry.website[i]) )
					 qry.website[i] = "mailto:#qry.website[i]#";
				else
					qry.website[i] = "http://#qry.website[i]#" ;
			
				//set image path		
				if 	(NOT qry.externallyHosted[i]){
					path =request.strSiteConfig.strPaths.sitepath & request.strSiteConfig.strPaths.adlogopath;
				}
				else
					path = "";
			
				//set var that will form link of adver		
				 link ="#arguments.AdlinkURL#&adid=#qry.ADID[i]#&userid=1&circuit=#arguments.circuit#&website=#URLEncodedFormat(qry.website[i])#";	
				  //set image into var
				  image = qry.source[i];	
				  //test = qry.source[i];	
				 //set var that now contain full HTML for image - incl. img and href tags
				  if (NOT ListContainsNoCase(image, "<script") and ListLast(image, ".") neq "swf"  ){
			 	 		image = '<img src="#path##image#" border="0" width="#arguments.width#" />';
			 			image = ' <a href="#link#" rel="nofollow"> ' & image & '</a>';
			 			}	
			 	else if (ListLast(image, ".") eq "swf")
			 			image = 	strConfig.strPaths.sitepath & request.strSiteConfig.strPaths.adlogopath & image;
			 	
			 	//append alll images into array
				 strImages = structNew();
				 strImages.Image = image;
				 strImages.adid = qry.ADID[i];;
				 arrayAppend(arrImages, strImages);
				}
			}
			// END LOOP
			//randomise array
			If (ArrayLen(arrImages)){
				CreateObject( "java","java.util.Collections" ).Shuffle(arrImages);
				//return 1st element of array
				returnString =arrImages[1].image;
				logAd(strSession, arrImages[1].adid, cgi.REMOTE_HOST, cgi.SCRIPT_NAME, arguments.circuit);
				}
				
			
			
			return returnString ;
		</cfscript>		
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="OutputNewsLetterAd" access="public" output="true" returntype="string" hint="creates html for an advert on the localgov newsletter">
		<cfargument 	name="qryAds" 		required="yes" 	type="query">
		<cfargument 	name="adtypeid" 	required="yes" 	type="numeric">
		<cfargument 	name="positionID" 	required="no" 	type="numeric" default="0">
		<cfargument 	name="AdlinkURL" 	required="yes" 	type="string">
		<cfargument 	name="width" 		required="no" 	type="string" default="120">
		<cfargument 	name="height" 		required="no" 	type="string" default="150">
		<cfargument 	name="topicid" 		required="no" 	type="string" default="0">
		
		
		<cfscript>
 		var imagevar = "";
		var qryResults = arguments.qryAds;
		var sitepath = "http://www.localgov.co.uk/";
		</cfscript>	
		
		<cfsavecontent variable="imagevar">
			
			
			<cfif qryResults.source CONTAINS ".swf">
			  <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab##version=7,0,19,0" width="120" height="240" title="test">
                  <param name="movie" value="#qryResults.source#">
                  <param name="quality" value="high">
                  <embed src="" quality="high" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" width="#arguments.width#" height="#arguments.height#"></embed>
			  </object>
			
			
			<cfelse>
				<cfif Len(qryResults.source)>
				<a href="#arguments.AdlinkURL#&adid=#qryResults.ADID#&userid=1&circuit=newsletter&website=#URLEncodedFormat('http://#qryResults.website#')#"><img src="#sitepath#/view/adsmedia/#qryResults.source#" border="0" alt="Click to view sponsor's website"></a>
				</cfif>
			</cfif>
			
		
		</cfsavecontent>
		
			<cfif adtypeid eq 15>
				<cfset imagevar = "<p>" & imagevar & "<p>">
			</cfif>
		
	
		<cfreturn imagevar>
	</cffunction>
	
	
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="outputKeywordAd" access="public" output="false" returntype="string" hint="outputs the ad on the localgov website">
		<cfargument 	name="keywords" 		required="yes" 	type="string">
		<cfargument 	name="circuit" 			required="yes" 	type="string">
		
		 <cfscript>
		 var qry ='';
		 var qryResults ='';
 		 var imagevar ='';
		 // In other words get all the keyword ads (regardless of the circuit they're in) that match the searched itiem.
		 If (arguments.circuit EQ '')
		 	arguments.circuit = 'All';
		 If (arguments.circuit NEQ 'events' AND arguments.circuit NEQ 'jobs' AND arguments.circuit NEQ 'business')
		 	arguments.circuit = 'home';
		 // Call the DAO object passing it the arguments
		 qryResults = objDAO.outputKeywordAd(arguments.keywords, arguments.circuit);
		</cfscript>	
		
		<cfif qryResults.P_AD_ID NEQ "">
			<cfsavecontent variable="imagevar">
				<cfsetting showdebugoutput="no">
				<cfoutput><div align="left">Sponsored Links</div></cfoutput>
				<hr noshade="noshade" size="1">
				<cfloop query="qryResults">
					<cfscript>
						//doCFLog(text="outputKeywordAd Loop #qryResults.currentrow#", file="LoopLog");
					</cfscript>					
					<cfoutput>
						<table width="100%" cellpadding="0" cellspacing="0" onmouseover="this.style.filter='alpha(opacity=90)'; this.style.opacity='0.9';" onmouseout="this.style.filter='alpha(opacity=50)'; this.style.opacity='0.5';" style="opacity: 0.5; filter:alpha(opacity=50);">
						<tr>
							<td>
								<div class="text"><a href="#qryResults.WEBSITE#" target="_blank"><img src="#variables.strConfig.strPaths.sitepath##variables.strConfig.strPaths.adlogopath##qryResults.source#" 
								 border="0" /></a>								</div>							</td>
						</tr>
						</table>
					</cfoutput>
				</cfloop>
			</cfsavecontent> 
		</cfif>

		<cfreturn imagevar>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetAdDetails" access="public" output="false" returntype="query" hint="return all data on a specific ad">
		<cfargument name="adid" type="numeric" required="yes"> 
		<cfreturn objDAO.GetAdDetails(arguments.adid)>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetKeywordAdDetails" access="public" output="false" returntype="query" hint="return all data on a specific Keyword ad">
		<cfargument name="keyword_id" type="numeric" required="yes"> 
		
		 <cfscript>
		//call and return dao method
		return objDAO.GetKeywordAdDetails(arguments.keyword_id);
		</cfscript>	  
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<cffunction name="UpdateCompaniesQuery" access="public" output="false" returntype="void" hint="Used to updaet the company query, predominately used to after updating the companies table">
		<cfargument name="qCompanies" type="struct" required="yes">
		<cfargument name="nCompanyID" type="numeric" required="yes">
		<cfargument name="new_company_name" type="string">
		
		<cfscript>
		newrow = queryaddrow(arguments.qCompanies['qryCompanies']);
		querysetcell(arguments.qCompanies['qryCompanies'], 'companyid', arguments.nCompanyID);
		querysetcell(arguments.qCompanies['qryCompanies'], 'company_name', arguments.new_company_name);
		</cfscript>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="CommitAd" access="public" output="false" returntype="Numeric" hint="Insert/update ad details">
		
		<cfargument name="AdID" required="no" type="numeric" default="0">
		<cfargument name="companyID" 		required="yes" 	type="numeric">
		<cfargument name="adName" 			required="no" 	type="string" default="">
		<cfargument name="circuitID" 		required="yes" 	type="string">
		<cfargument name="adtypeID" 		required="yes" 	type="numeric">
		<cfargument name="positionID" 		required="yes"  type="numeric">
		<cfargument name="source" 			required="no"  	type="string">
		<cfargument name="start_date" 		required="yes" 	type="date">
		<cfargument name="end_date" 		required="yes"  type="date">
		<cfargument name="adLink" 			required="yes"  type="string">
		<cfargument name="hid_stickyness" 	required="yes"  type="boolean">
		<cfargument name="topicid" 			required="no"   type="numeric" default="0">
		<cfargument name="sectors" 			required="no"   type="string" default="">
		<cfargument name="sourceType" 		required="no"   type="string" default="File">
		
		<cfscript>
		var rtnValue  				= 0;
		var PColumn 				= "p_ad_id";
		var newfilename			= "";
		var SQLstring				="";
		var SQLSelect       		= "UPDATE tblAdverts SET ";
		var SQLWhere				= "WHERE p_ad_id = "  ;
		var MimeType				= "image";
		var ExternallyHosted 	= 0;
		var apostrophe			= chr(39);
		if (arguments.sourceType eq "Pdf")
			MimeType			= "pdf";
		
		
		If (Find("http://", arguments.adLink))
			arguments.adLink = Replace(arguments.adLink,"http://", "", "All");
		
		//Commit Ad to DB
		rtnValue 			= objDAO.CommitAd(argumentcollection=arguments);
	
		//UPLOAD FILES
		If (LISTCONTAINS("File,Pdf",arguments.sourceType) and Len(form.source)){
				
			//upload logo	
			newfilename = objUtils.UploadImage(arguments.source, variables.sourcepath, MimeType);		 
		 }
		else 
		if (arguments.sourceType neq "File" and len(arguments.source)){
				newfilename = evaluate(arguments.source);
				newfilename = replace(newfilename, apostrophe, "", "all");
				//set string to upload filename
				  ExternallyHosted = 1;
			}
		
		 //check if file has been upload
			  if (Len(newfilename)){
				//set string to upload filename
				 SQLString = SQLString & SQLSelect & "source='#newfilename#',  ExternallyHosted = #ExternallyHosted# " & SQLWhere & rtnValue;
				 
				 if (arguments.sourceType eq "Pdf")
						SQLString = SQLString & SQLSelect & "website='#variables.strConfig.strPaths.sitepath##variables.strConfig.strPaths.adlogopath##newfilename#'"  & SQLWhere & rtnValue;
				 
				 //call method to upload file
				 objDAO.query(SQLString, variables.strConfig.strVars.dsn1);
				 }

		
 		//refresh ads 
		variables.qryGetAllAds= request.objbus.objAds.GetAllAds(1);
		return rtnValue;
		</cfscript>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<cffunction name="CommitKeyword" access="public" output="false" returntype="numeric" hint="Insert/update keyword ad details">
		
		<cfargument 	name="KeywordAdID" 	required="no" 	type="numeric" default="0">
		<cfargument 	name="ADID"			required="no"  	type="numeric" default="0">
		<cfargument 	name="keyword" 		required="yes" 	type="string">
		<cfargument 	name="companyID" 	required="yes" 	type="numeric">
		<cfargument 	name="circuitID" 	required="yes" 	type="string">
		<cfargument 	name="source" 		required="yes"  type="string">
		<cfargument 	name="start_date" 	required="yes" 	type="date">
		<cfargument 	name="end_date" 	required="yes"  type="date">


		<cfscript>
		var rtnValue  		= 0;
		var newfilename		= "";
		var SQLstring		="";
		var SQLSelect       = "UPDATE tblAdverts SET ";
		var SQLWhere		= "WHERE p_ad_id = "  ;
		//Commit Keyword Ad to DB
		rtnValue 			= objDAO.CommitKeyword(argumentcollection=arguments);
		
		//UPLOAD FILES
		If (Len(form.source)  ){
		  //upload logo
		 newfilename = objUtils.UploadImage(arguments.source, variables.sourcepath, 'image');
		 //check if file has been upload
		  if (Len(newfilename)){
		  	//set string to upload filename
		  	 SQLString = SQLString & SQLSelect & "source='#newfilename#' " & SQLWhere & rtnValue;
			 //call method to upload file
			 objDAO.query(SQLString, variables.strConfig.strVars.dsn1);
			 }
		}
		 
		//refresh ads
		request.objbus.objAds.GetAllAds(true);
		return rtnValue;
		</cfscript>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="Commit_LinkAd" access="public" output="false" returntype="boolean" hint="Inserts the ad/user details when the user hits an ad on the site">
		<cfargument	name="adid"			required="yes"	type="numeric">
		<cfargument name="userid"		required="no"	type="numeric">
		<cfargument name="circuit" 		required="yes" 	type="string">
		<cfargument	name="ipAddress"	required="yes"	type="string">

		<cfreturn objDAO.Commit_LinkAd(arguments.adid, arguments.userid, arguments.circuit, arguments.ipAddress)>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="deleteAd" access="public" output="false" returntype="boolean" hint="delete specific ad">
		<cfargument name="ID" type="numeric" required="yes">
		<cfset qry = false>
		
		<cfset qry = objDAO.deleteAd(arguments.ID)>
		<cfset variables.qryGetAllAds= request.objbus.objAds.GetAllAds(1)>
		<cfreturn qry>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="deleteKeywordAd" access="public" output="false" returntype="boolean" hint="delete specific keyword ad">
		<cfargument name="ID" type="numeric" required="yes">
		
		<cfreturn objDAO.deleteKeywordAd(arguments.ID)>
	</cffunction>	
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetAdverts" access="public" output="false" returntype="query" hint="call method to return ads " >
		<!--- <cfargument name="keywords"  type="string" required="yes">
		<cfargument name="productid" type="string" required="no"  default="#variables.strConfig.strVars.newsproductids#"> --->
		
		<cfargument name="companyID" 	required="yes" 		type="numeric">
		<cfargument name="adtypeID" 	required="yes" 		type="numeric">
		<cfargument name="positionID" 	required="yes" 		type="numeric" >
		<cfargument name="circuitID" 	required="yes" 		type="string">
		<cfargument name="end_date" 	required="yes" 		type="date">
		<cfargument name="adLink" 		required="yes"  	type="string">
		<cfargument name="isSector" 	required="yes"  	type="boolean" default="false">
		
		<cfscript>
		var qry= "";
		
		if (arguments.isSector)
			qry = objDAO.GetSectorsAdverts(arguments.companyID, arguments.adtypeID, arguments.positionID, arguments.end_date, arguments.adLink);
		else
			qry = objDAO.GetAdverts(argumentcollection=arguments);
		
		
		return qry;
		</cfscript>
	</cffunction>		
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="AdminSearchAds" access="public" output="false" returntype="query" hint="call method to return results for the keyword ads" >
		<cfargument name="keywords"  type="string" required="yes">
		
		<cfscript>
		return objDAO.AdminSearchAds(arguments.keywords);
		</cfscript>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="saveAdViews" access="public" output="false" returntype="boolean" hint="save ad views to DB" >
		<cfargument name="viewedAds" type="query" required="yes">
		
		<cfscript>
			return objDAO.saveAdViews(viewedAds);
		</cfscript>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetAdvertViews" access="public" output="false" returntype="query" hint="call method to return results for the adver views" >
		<cfargument name="adid" type="numeric" required="no" default="0">
		<cfargument name="justcount" type="numeric" required="no" default="0">
		
		<cfscript>
			return objDAO.GetAdvertViews(arguments.adid, arguments.justcount);
		</cfscript>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!---  ---------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="logAd" access="public" returntype="void" output="true" hint="log request" >
			<cfargument name="strsession" 		required="yes" type="struct">
			<cfargument name="id" 				required="yes" type="numeric">		
			<cfargument name="remote_host" 	required="yes" type="string">
			<cfargument name="script_name" 		required="yes" type="string">
			<cfargument name="circuit" 			required="no" type="string" default="">
				
                
                <cftry>
				<cfscript>
				if (NOT StructKeyExists(session, "viewedAds"))
					arguments.strsession.viewedAds = queryNew("adid,viewedDate,circuit,remote_host,script_name");
					
					queryAddRow(arguments.strsession.viewedAds);
					querySetCell(arguments.strsession.viewedAds, 'adid', arguments.id);
					querySetCell(arguments.strsession.viewedAds, 'circuit', arguments.circuit);
					querySetCell(arguments.strsession.viewedAds, 'vieweddate', now());
					querySetCell(arguments.strsession.viewedAds, 'remote_host', arguments.remote_host);
					querySetCell(arguments.strsession.viewedAds, 'script_name', arguments.script_name);
				</cfscript>
                <cfcatch></cfcatch>
                </cftry>
		</cffunction>
			
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PRIAVTE Functions ----------------------------------------------------------------------------------->
	<!--- --------------------------------------------------------------------------------------------------
	<cffunction name="Ads2AdsinSectors" access="private" output="false" returntype="query" hint="perform query of query to join ads to ads in sectors" >
		<cfargument name="qryAds"  		   type="query" required="yes">
		<cfargument name="qryAdsinSectors"  type="query" required="yes">
		<cfargument name="sectors" 			required="no" 	type="string" default="0">
		 
		 <cfset var qryJoinAds = queryNew("temp")>
		 
		 <cfquery name="qryJoinAds" dbtype="query">
		 SELECT * 
		 FROM	qryAds , qryAdsinSectors 
		 WHERE	qryAds.Adid = qryAdsinSectors.f_ad_id 
		 AND	qryAdsinSectors.f_sector_id IN (#arguments.sectors#)
		 </cfquery>	 
		
		<cfreturn qryJoinAds>
	</cffunction>--->
</cfcomponent>
