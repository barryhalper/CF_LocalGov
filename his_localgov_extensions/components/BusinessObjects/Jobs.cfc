<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/BusinessObjects/Jobs.cfc $
	$Author: Bhalper $
	$Revision: 10 $
	$Date: 22/04/09 16:46 $

--->

<cfcomponent displayname="Jobs" hint="Job-related business object functions" extends="his_Localgov_Extends.components.BusinessObjectsManager">

	<!---   ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Jobs" hint="Pseudo-constructor">
		<cfargument name="objAppObjs" type="any" required="yes" hint="The application manager object">
		<cfargument name="objBusObjs" type="any" required="yes" hint="The application manager object">

		<cfscript>
		// Call the genric init function, placing business, app, and dao objects into a local scope...
		StructAppend( variables, Super.initChild( arguments.objAppObjs, this, arguments.objBusObjs ) );
		
		variables.strJobSelects = GetJobsSelects();
		variables.imagepath 	= variables.strConfig.StrPaths.sitedir & variables.strConfig.StrPaths.joblogodir;
		variables.imageCopath 	= variables.strConfig.StrPaths.sitedir & variables.strConfig.StrPaths.cologodir;
		return this;
		</cfscript>
		
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions ------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetVariables" access="public" output="false" returntype="struct" hint="return local scope to caller">
		<cfreturn variables>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="GetLatestJobs" access="public" output="false" returntype="query" hint="return jobs ads that are current">
		<cfargument name="hglonly" type="boolean" required="no" default="1">
		<cfargument name="refresh"   type="boolean" required="no" default="0">
		<cfreturn objDAO.getLatest(Arguments.hglonly, variables.strConfig.strVars.newsproductids, Arguments.refresh)>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="GetPremierJobs" access="public" output="false" returntype="struct" hint="return jobs ads that been sold featured and top positions" >
		<cfreturn objDAO.GetPremierJobs(variables.strConfig.strVars.newsproductids)>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="GetFeaturedJobs" access="public" output="false" returntype="query" hint="return jobs ads that been sold featured positions">
		<cfreturn objDAO.GetFeaturedJobs(variables.strConfig.strVars.newsproductids)>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="GetJobsPartners" access="public" output="false" returntype="query" hint="return all those organisations who have aggred to import/export jobs">
		<cfargument name="hasXml" required="no" type="boolean" default="0">	
		<cfreturn objDAO.GetJobsPartners(arguments.hasXml)>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="GetJobsSelects" access="public" output="false" returntype="struct" hint="return struct of qry's needed in for selects in search form">
		<cfif NOT StructKeyExists(variables, "strJobSelects")>
			<cfreturn objDAO.GetJobSelects()>
		<cfelse>
			<cfreturn variables.strJobSelects>
		</cfif>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="GetJobsAdminSelects" access="public" output="false" returntype="struct" hint="return struct of qry's needed in for selects in search form">
			<cfscript>
			var strReturn = StructNew();
			strReturn = variables.strJobSelects;
			If (NOT StructkeyExists(strReturn, "qryPartners"))
				StructInsert(strReturn, "qryPartners", GetJobsPartners());			
			If (NOT StructkeyExists(strReturn, "qryEmployers"))	
				StructInsert(strReturn, "qryEmployers", GetEmployers());
			
			strReturn.ArrJoTWDays 	 = getJoTWDays();
			strReturn.ArrJoTWEndDays = getJoTEndWDays(strReturn.ArrJoTWDays);
			return strReturn;
			</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="ClearEmployers" access="public" output="false" returntype="void" hint="Used to clear the employer query, predominately used to after updating the employers table">
		<cfscript>
		var strReturn = StructNew();
		strReturn = variables.strJobSelects;
		StructDelete(strReturn, "qryEmployers");
		</cfscript>
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->		
	<cffunction name="GetJobsDetails" access="public" output="false" returntype="query" hint="return all data on a specific job">
		<cfargument name="jobid" 	 type="numeric" required="yes"> 
		<cfargument name="partnerid" type="numeric" required="yes"> 
		<cfargument name="id" 		 type="string"  required="no" default="">
		
		 <cfscript>
		If (Len(arguments.id)){
		//if id string has been passed get job and partner from string 
			//get jobid from uid being the integer to the laft of the dash
			if (Find('-', arguments.id)){
				arguments.jobid 	  = Left(arguments.id, Find('-', arguments.id) - 1);
				//get partner id form uid being the integer to the right of the dash
				arguments.partnerid   =	Mid(arguments.id, Find('-', arguments.id) + 1, Len(arguments.id));
			}
		}
		//call and return dao method
		return objDAO.GetJobDetails(arguments.jobid, arguments.partnerid);
		</cfscript>	  
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
    <cffunction name="SearchJobs" access="public" returntype="query" output="false" hint="search jobs in verity and sql">
		<cfargument name="keyword" required="no" type="string" default="">	
		
		<cfscript>
		var qryReturn=querynew("temp");
		var qry="";
		var strResult=StructNew();
		
		arguments.keyword = objString.SqlSafe(ObjString.StripHTML(arguments.keyword));
		//if not keywords were present..
		if (NOT Len(keyword))
			//...return all latest jobs
			qryReturn = GetLatestJobs(0);
		else{
			//run verity search
			strResult=objsearch.getCollectionSearch(arguments.keyword);
			//check if verity search has returned any results
			if (strResult.qryResults.recordcount){
				//run QofQ to get the ID of only the jobs found in search
				qry=objUtils.QueryOfQuery(strResult.qryResults, 'custom2 AS UID', 'custom1 LIKE #chr(39)#%Jobs%#chr(39)#');
				//pass list of ids to sql 
				qryReturn=objDao.GetJobsFromIndex(ValueList(qry.Uid));	
			}	 		
		}  
		return  qryReturn;	 
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	
 	<cffunction name="AdvSearch" access="public" output="false" returntype="query" hint="perform adv search jobs">
		<cfargument name="keyword"  		type="string"  required="no"   default="">	
		<cfargument name="hglonly" 	 		type="boolean" required="no"  default="0">
		<cfargument name="productid" 		type="string"  required="no"  default="#variables.strConfig.strVars.newsproductids#">
		<cfargument name="sectorid"  		type="string"  required="no"  default="">
		<cfargument name="regionid"  		type="string"  required="no"  default="">
		<cfargument name="ContractTypeid" 	type="string"  required="yes" default="">
		<cfargument name="SalaryBandLower" 	type="string"  required="no"  default="0">
		<cfargument name="SalaryBandUpper" 	type="string"  required="no"  default="1000000">
		
 
		 <cfscript>	
		 arguments.keywords = objString.SqlSafe(ObjString.StripHTML(arguments.keywords));
		 if( ListLen(arguments.sectorid) eq objSearch.getSectors().recordcount )
			arguments.sectorid = "";
		 return objDAO.AdvSearchJobs(argumentcollection=arguments);
		 </cfscript>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="resultText" access="public" returntype="string" output="false" hint="work out result text based on search criteria">
		<cfargument name="recordcount"  	type="numeric" required="yes" >	
		<cfargument name="keyword"  		type="string"  required="no"   default="">	
		<cfargument name="sectorid"  		type="string"  required="no"  default="">
		<cfargument name="regionid"  		type="string"  required="no"  default="">
		<cfargument name="ContractTypeid" 	type="string"  required="yes" default="">
		<cfargument name="SalaryBandLower" 	type="string"  required="no"  default="0">
		<cfargument name="SalaryBandUpper" 	type="string"  required="no"  default="1000000">
		
		<cfscript>
		var qry	="";
		var lst	="";
		var resultstring    = "We have found <b>#arguments.recordcount#</b> jobs that match your search ";
		if (Len(arguments.keywords))
		resultstring 		= resultstring &  'for <b>#arguments.keywords#</b> '  ;
		//check if all sectors have been passed
		If (len(arguments.sectorid)){
			if( ListLen(arguments.sectorid) neq objSearch.getSectors().recordcount ){
				//get sectors names
				qry 	= objUtils.queryofquery(objSearch.getSectors(), "*", "SectorID IN (#arguments.sectorid#)");
				lst 	= ListChangeDelims(QuotedValueList(qry.sector), ", ");
				resultstring   	= resultstring &  '<br/>Sectors: <b>#lst#</b><br/> ';
				}
			}
		if 	(Len(arguments.regionid)){
			qry 	= objUtils.queryofquery(variables.strJobSelects.qryRegions,"*","Regionid IN (#arguments.regionid#)");
			lst		= listChangeDelims(QuotedValueList(qry.Region), ", ");
			resultstring   	= resultstring &  '<br/>Regions: <b>#lst#</b> ' ;	
		}
		if 	(Len(arguments.ContractTypeid)){
			qry 	= objUtils.queryofquery(variables.strJobSelects.qryContractTypes, "*", "ContractTypeid IN (#arguments.ContractTypeid#)");
			lst		= listChangeDelims(QuotedValueList(qry.ContractType), ", ");
			resultstring   	= resultstring &  '<br/>Contract Types: <b>#lst#</b> ' ;	
		}
			return resultstring &  '<br/>Salary Band: <b>&pound;#SalaryBandLower# - &pound;#SalaryBandUpper#</b> ' ;
		</cfscript>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<cffunction name="ExportJobs" access="public" output="false" returntype="xml" hint="create xml files for each partner who wished to recive jobs">
		<cfargument name="partnerid" required="yes" type="numeric">
			<cfreturn jobs2Xml(GetJobs4Export(arguments.partnerid))> 
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="GetJobs4Export" access="public" returntype="query" output="false" hint="return all jobs to be exportorted for a specfic partner">
		<cfargument name="partnerid" required="yes" type="numeric">
			<cfreturn objDAO.ExportJobs(arguments.partnerid)>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="ImportJobs" access="public" returntype="boolean" output="false" hint="import jobs from partners' xml">
			
			<cfscript>
			var StrMergedXml 	= Structnew();
			var xmldoc 			= "";
			var i				=0;
			var qryPartners		= GetJobsPartners(1);
			var arrLink = ArrayNew(1);
			</cfscript>
			
			
			<cfloop query="qryPartners">
			<cfset arrLink = ListToArray(qryPartners.xmllocation, "|")>
				<cfloop from="1" to="#arrayLen(arrLink)#" index="i">
					<cftry>
					<!---read file and parse into xml ---> 
					<cfset xmldoc=objxml.ReadXml(arrLink[i], strConfig.strVars.useProxy)>
					
					<!---perform insert --->
					<cfset InsertXmlJobs(qryPartners.partnerid,qryPartners.Organisation, xmldoc)>
					
						 <!---database catch--->
						<cfcatch type="database">
							<!---<cfmail from="#strConfig.strVars.mailsender#" to="#strConfig.strVars.errormailto#" subject="LocalGov xml Error" type="html">
								The xml file '#arrLink[i]#' used for imports could not be inserted into the the database.<br>
								The file is generated by #qryPartners.Organisation#
							</cfmail>--->
							
						</cfcatch>
						<!----xml catch--->
						<cfcatch type="any">
						<!----	<cfmail from="#strConfig.strVars.mailsender#" to="#strConfig.strVars.errormailto#" subject="LocalGov xml Error" type="html">
								The xml file '#arrLink[i]#' could not be parsed <br>
								The file is generated by #qryPartners.Organisation#
							</cfmail>--->
						</cfcatch>
				 </cftry>  
						
				</cfloop>
			</cfloop>
			
			<cfReturn true>
			
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->		
	<cffunction name="GetHomeContent" access="public" output="false" returntype="struct" hint="return structure of content for jobs home page">
		<cfargument name="copyid" required="yes" type="numeric">
		
		<cfscript>
		var strRtn = GetPremierJobs();
		strRtn.qryCopy				= variables.objArticle.GetFull(type=7, id=arguments.copyid);
		strRtn.strSelects		    = variables.strJobSelects;
		return 	strRtn;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="AdminSearchJobs" access="public" output="false" returntype="query" hint="call method to return jobs " >
		<cfargument name="keywords"  type="string" required="yes">
		<cfargument name="productid" type="string" required="no"  default="#variables.strConfig.strVars.newsproductids#">
		
		<cfscript>
		var qry= "";
		If (IsNumeric(arguments.keywords))
		  qry = objDAO.AdminSearchJobs(arguments.productid, '', arguments.keywords);
		 else
		  qry = objDAO.AdminSearchJobs(arguments.productid, arguments.keywords);
		 return qry;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="AdminSearchPartnerJobs" access="public" output="false" returntype="query" hint="call method to return jobs ">
		<cfargument name="partnerid" type="numeric" required="no"  default="0">
		<cfargument name="keyword"  type="string" required="yes">
		<cfreturn objDAO.AdminSearchPartnerJobs(arguments.partnerid, arguments.keyword)>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->		
	<cffunction name="GetAdminLatest" access="public" returntype="query" output="false" hint="return all jobs">
		<cfargument name="productid" type="string" required="no" default="#variables.strConfig.strVars.newsproductids#">
			<cfreturn objDAO.GetAdminLatest(arguments.productid)>
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="GetCompany" access="public" returntype="query" output="false" hint="return all Consultants">
		<cfargument name="blActive" required="no" type="boolean" default="1">
		<cfargument name="CompanyType"  required="no" type="numeric" default="6">
			<cfreturn objDAO.GetCompany(arguments.blActive,arguments.CompanyType)>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="GetCompanyDetail" access="public" returntype="query" output="false" hint="return all details for a specific consultant">
		<cfargument name="Coid" required="yes" type="Numeric">
			<cfreturn objDAO.GetCompanyDetail(arguments.Coid)>
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="GetEmployers" access="public" returntype="query" output="false" hint="return all Employers">
		<cfargument name="Coid" required="no" type="Numeric" default="0">
			<cfreturn objDAO.GetEmployers(arguments.Coid)>
	</cffunction>		
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="GetCompanyTypes" access="public" output="false" returntype="query" hint="return all company types for this product">
		<cfargument name="ProductID" required="no" type="Numeric" default="#variables.strConfig.strVars.ProductID#">
		 <cfreturn objDAO.GetCompanyTypes(arguments.ProductID)>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="GetAdminJobDetails" access="public" output="false" returntype="struct" hint="exec SQL to return all data on a specific job fro cms" >	
			<cfargument name="jobid" 	required="yes" type="numeric" >
			<cfreturn objDAO.GetAdminJobDetails(arguments.jobid)>
		</cffunction>  	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="GetAdminCompanySearch" access="public" output="false" returntype="query" hint="search companies based on types">
		
		<cfargument name="Keywords" required="yes" type="string">
		<cfargument name="TypeID" 	required="yes" type="Numeric">
		
		<cfreturn objDAO.GetAdminCompanySearch(arguments.Keywords, arguments.TypeID)>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="AdminPartnerStats" access="public" returntype="struct" output="false" hint="return structure of stats for a specfic job partner">
		<cfargument name="id" required="yes" type="numeric">
		<cfscript>
		var qryjobs				= AdminSearchPartnerJobs(arguments.id, '');
		var strStats			= StructNew();
		strStats.NoJobs			= qryjobs.recordcount;
		strStats.NoCurrentJobs	= objutils.queryofquery(qryjobs, 'COUNT (*) as NoCount', 'deadline >=#Now()#').NoCount;
		if (NOT Len(strStats.NoCurrentJobs))
			strStats.NoCurrentJobs = 0;
		
		return strStats;
		</cfscript>
		</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<cffunction name="GetRelatedArticles" access="public" output="false" returntype="query" hint="return related articles for a specific organisation">
		<cfargument name="employer" required="yes" type="string" hint="string containing employer name">
			
			<cfscript>
			//extract 1st word from epmployer's name
			var criteria = listFind(arguments.employer, 1, " ");
			var qryRelatedArticles = QueryNew("temp");
			
			 If (Len(criteria)){
			 	//search collection for articles
				qryRelatedArticles = objSearch.getCollectionSearch(criteria & " AND cf_custom1=News").qryResults;
				qryRelatedArticles = objUtils.queryofquery(qryRelatedArticles, "*, custom2 as NewsID", "0=0", "Custom3 DESC");
			 }
			
			return	 qryRelatedArticles;
			</cfscript>
			
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	  <cffunction name="getNextJoTW" access="public" returntype="struct" output="false" hint="return the date that the next job of week will begin and end">
  
		<cfscript>
		var strNextJoTW = StructNew();
		var Nextday = "";
		var Endate = "";
		var arrNext7days = arrayNew(1);
		//Today's date
		var dateToday =  now();
		//set the time of today to be midday
		var JoTWDate = CreateDateTime(datePart("yyyy", dateToday),datePart("m", dateToday), datePart("d", dateToday), 12, 0, 0 );
		var i = 0;
		
		//check if today is Thursday and before midday 
		if (DayOfWeek(dateToday) eq 5  and DateDiff('n', JoTWDate, dateToday) lt 0)
			strNextJoTW.StartDate=JoTWDate;
		
		else{
			//set array to hold days of this week with today's position being 1
			arrayAppend(arrNext7days,dateToday);
			//loop over next 6 days 
			for (i=1; i lte 6; i=i+1) {
				//get date of the next day in the loop
				Nextday		 = DateAdd("d", i,  dateToday);
				//add value of next day in loop to array
				arrayAppend(arrNext7days,Nextday);
			}
			//loop over array holding next 6 days
			for (i=1; i lte ArrayLen(arrNext7days); i=i+1) {
				//get next thursday
				if (DayOfWeek(arrNext7days[i]) eq 5)
					//set day that day of next job of the week and time to be midday
					strNextJoTW.StartDate =CreateDateTime(datePart("yyyy", arrNext7days[i]),datePart("m", arrNext7days[i]), datePart("d", arrNext7days[i]), 12, 0, 0 );
				}
				
		}
		//calucate end date of next job of the week
		EndDate = DateAdd("d",7,strNextJoTW.StartDate);
		strNextJoTW.EndDate = CreateDateTime(datePart("yyyy", EndDate),datePart("m", EndDate), datePart("d", EndDate), 11, 59, 0 );
		
		return strNextJoTW;
	  </cfscript>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getJoTWDays" access="public" returntype="array" output="false" hint="return the days that a job of the week may appear on">
		<cfscript>
		var arrJoTWdays = arrayNew(1);
		var dateToday = now();
		var Nextday = "";
		 JoTWDate = CreateDateTime(datePart("yyyy", dateToday),datePart("m", dateToday), datePart("d", dateToday), 12, 0, 0 );
		//check if today is Thursday and before midday 
		if (DayOfWeek(dateToday) eq 5 and DateDiff('n', JoTWDate, dateToday) lt 0)
			//set the next day for a JoTW to be today at midday
			arrayAppend(arrJoTWdays,JoTWDate);
			
			//loop over next 6 days 
			for (i=1; i lte 60; i=i+1) {
				//get date of the next day in the loop
				Nextday		 = DateAdd("d", i, dateToday);
				//add value of next day in loop to array
				if (DayOfWeek(Nextday) eq 5)
					arrayAppend(arrJoTWdays,CreateDateTime(datePart("yyyy", Nextday),datePart("m", Nextday), datePart("d", Nextday), 12, 0, 0 ));
			}
			return arrJoTWdays;
		 </cfscript>
		</cffunction>
			
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC COMMITS ----------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="CommitJob" access="public" output="false" returntype="Numeric" hint="Insert/update job details">
		<cfargument name="ID" 				required="no"  type="numeric" default="0">
		<cfargument name="EmployerID" 		required="yes" type="numeric" >
		<cfargument name="jobtitle"         required="yes" type="string"  >
		<cfargument name="reference" 		required="no"  type="string" default="">
		<cfargument name="description" 		required="no"  type="string" default="">
		<cfargument name="deadline" 		required="yes" type="date" >
		<cfargument name="salary" 			required="no"  type="string"  default="">
		<cfargument name="County" 			required="yes"  type="numeric">
		<cfargument name="ContractTypeID" 	required="no"  type="numeric" default="0">
		<cfargument name="SalaryBandLower" 	required="no"  type="numeric" default="0">
		<cfargument name="SalaryBandUpper" 	required="no"  type="numeric" default="100000">
		<cfargument name="ContactEmail" 	required="no"  type="string"  default="">
		<cfargument name="Sectors" 			required="yes" type="string">
		<cfargument name="IIPLogo" 			required="no"  type="boolean" default="0">
		<cfargument name="EqOpLogo" 		required="no"  type="boolean" default="0">
		<cfargument name="PartnerID" 		required="no"  type="string"  default="">
		<cfargument name="Product_ID" 		required="yes" type="string"  default="">
		<cfargument name="ImageLogo" 		required="no"  type="string" default="">
		<cfargument name="small_logo" 		required="no"  type="string" default="">		
	
		
		<cfscript>
		var rtnValue  		= 0;
		var PColumn 		= "p_job_id";
		var newfilename		= "";
		var SQLstring		="";
		var SQLSelect       = "UPDATE tblJobs SET ";
		var SQLWhere		= "WHERE p_job_id = "  ;
		var p 				= arguments.Product_ID;
		arguments.deadline =  dateFormat(arguments.deadline, "dd/mm/yyyy") & " " & TimeFormat(arguments.deadline);
		arguments.ProductID = Mid(p, Find("?", p)+1, Len(p));
		//Commit job to DB
		rtnValue 			= objDAO.CommitJob(argumentcollection=arguments);
		
		//UPLOAD FILES
		If (Len(form.ImageLogo)  ){
		  //upload logo
		 newfilename = objUtils.UploadImage(arguments.ImageLogo, variables.imagepath, 'image');
		  //check if file has been upload
		  if (Len(newfilename)){
		  	//set string to upload filename
		  	 SQLString = SQLString & SQLSelect & "LogoFileName='#newfilename#' " & SQLWhere & rtnValue;
			 //call method to upload file
			 objDAO.query(SQLString, variables.strConfig.strVars.dsn1);
			 }
		  
		  }
		//upload small logo (for home page)
		If (Len(form.small_logo)  ){
		  //upload logo
		 newfilename = objUtils.UploadImage(arguments.small_logo, variables.imagepath & "small\", 'image');
		  //check if file has been upload
		  if (Len(newfilename)){
		  	//set string to upload filename
		  	 SQLString = SQLString & SQLSelect & "small_logo='#newfilename#' " & SQLWhere & rtnValue;
			 //call method to upload file
			 objDAO.query(SQLString, variables.strConfig.strVars.dsn1);
			 }
		  
		  }
		
		 
		 return rtnValue;
		</cfscript>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="CommitJobAd" access="public" output="false" returntype="any" hint="commit job ad details for a particular job for under 1 or many websites">
		<cfargument name="jobid" 		required="yes" type="numeric" hint="primary key of job">
		<cfargument name="strform" 		required="yes" type="struct" hint="form structure">
		<cfargument name="Productids" 	required="yes" type="string" hint="list of websites">
		
			<cfscript>
			var arrProducts = ListToArray(arguments.Productids);
			var i = 0;
			// columns in form without product id's....
			var adstatus = "";
			var startdate = "";
			var enddate = "";
			var logo = "";
			var formlogo = "";
			var newfilename = "";
			var filepath = variables.imagepath & "small\";
			
			//loop over products - rows in form for each webiste
			for (i=1 ;i LTE ArrayLen(arrProducts); i=i+1 ){
				adstatus = Evaluate("arguments.strform.adstatus_#arrProducts[i]#");
				startdate = evaluate("arguments.strform.jotw_startDate_#arrProducts[i]#");
				enddate = evaluate("arguments.strform.jotw_endDate_#arrProducts[i]#");				
				logo = "arguments.strform.jotw_logo_#arrProducts[i]#";
				formlogo = "form.jotw_logo_#arrProducts[i]#";
				newfilename = "";//rest value if set in 1st iteration
			
				//check if this website has job status for the job 
				//check if logo is present
				If (Len(evaluate(formlogo)))
					//upload logo
					 newfilename = objUtils.UploadImage(formlogo, filepath, 'image');
					
				 //perform sql update
				objDAO.CommitJobAd(arguments.jobid, arrProducts[i], adstatus, startdate, enddate, newfilename);
				}
			

			return true;	
			</cfscript> 
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="CommitPartnerJob" access="public" output="false" returntype="Numeric" hint="Insert/update partner's details">
		
		<cfargument name="ID" 			    required="no"  type="numeric" default="0">
		<cfargument name="PartnerID" 		required="no"  type="string" default="">
		<cfargument name="userid" 			required="yes" type="numeric" >
		<cfargument name="Employer" 		required="yes" type="string">
		<cfargument name="jobtitle"         required="yes" type="string">
		<cfargument name="reference" 		required="no"  type="string" default="">
		<cfargument name="email" 			required="no"  type="string" default="">
		<cfargument name="description" 		required="no"  type="string" default="">
		<cfargument name="deadline" 		required="yes" type="date">
		<cfargument name="salary" 			required="no"  type="string"  default="">
		<cfargument name="County" 			required="yes" type="string" >
		<cfargument name="ContractType" 	required="no"  type="string" default="">
		<cfargument name="SalaryBandLower" 	required="no"  type="numeric" default="0">
		<cfargument name="SalaryBandUpper" 	required="no"  type="numeric" default="100000">
		<cfargument name="Sectors" 			required="yes" type="string">
		<cfargument name="joburl" 			required="no" type="string" default="">
		
		
		<cfreturn objDAO.CommitPartnerJob(argumentcollection=arguments )>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->	
	<cffunction name="CommitEmployer" access="public" output="false" returntype="Numeric" hint="Insert/update employer details">
		
		<cfargument name="EmployerID" required="no"  type="numeric" default="0">
		<cfargument name="company_name"  required="yes" type="string" >
		<cfargument name="email" required="yes" type="string">
		<cfargument name="website"   required="yes" type="string">
		
		<cfreturn objDAO.CommitEmployer( 
								arguments.EmployerID,
								arguments.company_name,
								arguments.email,
								arguments.website
							)>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="CommitCompany" access="public" output="true" returntype="numeric" hint="Insert/update company details">
		
		<cfargument name="id" 				required="no"  type="numeric" default="0">
		<cfargument name="CompanyTypeID"  	required="yes" type="numeric" >
		<cfargument name="company_name"  	required="yes" type="string" >
		<cfargument name="Address1"  		required="no" type="string" default="">
		<cfargument name="Address2"  		required="no" type="string" default="">
		<cfargument name="Address3"  		required="no" type="string" default="">
		<cfargument name="town"  			required="no" type="string" default="">
		<cfargument name="county"  			required="no" type="string" default="">
		<cfargument name="postcode"  		required="no" type="string" default="">
		<cfargument name="tel"  			required="no" type="string" default="">
		<cfargument name="fax"  			required="no" type="string" default="">
		<cfargument name="email" 			required="no" type="string" default="">
		<cfargument name="website"   		required="no" type="string" default="">
		<cfargument name="Profile"   		required="no" type="string" default="">
		<cfargument name="advStart"   		required="no" type="date" default="#Now()#" >
		<cfargument name="advEnd"   		required="no" type="date" default="#Now()#">
		<cfargument name="logo"   		    required="no" type="string" default="">
		
		
		<cfscript>
		var Returnid 		= 0;
		var newfilename		= "";
		var SQLstring		="";
		var SQLSelect       = "UPDATE tblCompanies SET ";
		var SQLWhere		= "WHERE p_company_id = "  ;

		ReturnId = objDAO.CommitCompany(id= arguments.id			,		
										CompanyTypeID= arguments.CompanyTypeID	,
										company_name= arguments.company_name 	,	
										Address1= arguments.Address1		,	
										Address2= arguments.Address2  	,	
										Address3= arguments.Address3  	,	
										town=		arguments.town  		,	
										county= arguments.county  		,	
										postcode= arguments.postcode  	,	
										tel= arguments.tel  			,	
										fax= arguments.fax  			,	
										email= arguments.email 		,	
										website= arguments.website   	,	
										profile= arguments.Profile   	,
										advStart =	 dateFormat(arguments.advStart, "dd/mm/yyyy") & " " & TimeFormat(arguments.advStart),
										advEnd	=	dateFormat(arguments.advEnd, "dd/mm/yyyy") & " " & TimeFormat(arguments.advEnd)
										);
		
		If (isDefined("form.Logo") AND Len(form.Logo)){
		  //upload logo
		 newfilename = objUtils.UploadImage(arguments.Logo, variables.imageCopath, 'image');
		  //check if file has been upload
		  if (Len(newfilename)){
		  	//set string to upload filename
		  	 SQLString = SQLString & SQLSelect & "Logo='#newfilename#' " & SQLWhere & ReturnId;
			 //call method to upload file
			 objDAO.query(SQLString, variables.strConfig.strVars.dsn1);
			 }
		}
		return ReturnId;
		</cfscript>
		
		
	
	</cffunction>	
	
	
	
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- DELETE ----------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="deleteJob" access="public" output="false" returntype="boolean" hint="delete specific job">
		
		<cfargument name="ID" type="numeric" required="yes">
		<cfreturn objDAO.deleteJob(arguments.ID)>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="deletePartnerJob" access="public" output="false" returntype="boolean" hint="delete specific job">
		<cfargument name="ID" type="numeric" required="yes">
		<cfreturn objDAO.deletePartnerJob(arguments.ID)>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="deleteCompany" access="public" output="false" returntype="boolean" hint="delete specific company">
		<cfargument name="ID" type="numeric" required="yes">
		<cfreturn objDAO.deleteCompany(arguments.ID)>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PRIAVTE Functions ----------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="Jobs2Xml" access="private" returntype="any" hint="turn qry object into xml" output="false">
			<cfargument name="qry" type="query" required="yes" hint="qry to be tuned into XML">
			<cfargument name="joburl" type="string" required="no" default="#strConfig.strPaths.sitepath#index.cfm?method=jobs.item&jobid=" >
			
				<cfscript>
				var i="";
				var xmlvar="";
				var currentid = 0;
				var lstdescription="";
				</cfscript>
						
				<cfsilent>
						 
				<cfxml variable="xmlvar"><cfoutput><jobs xmlns="http://www.localgov.co.uk" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.localgov.co.uk   #strConfig.strPaths.sitepath#extends/xml/jobs.xsd">		
				<cfloop query="arguments.qry">
						<cfif currentid neq arguments.qry.jobid>
							<cfset lstdescription = description & "<br/>" & reference & "<br/>" & salary & "<br/>">
							<cfset arguments.joburl = arguments.joburl & jobid>
							<job>
								<jobid>#arguments.qry.jobid#</jobid>
								<jobtitle><![CDATA[#arguments.qry.jobtitle#]]></jobtitle>
								<dateposted>#variables.objxml.xsdDateFormat(arguments.qry.dateposted)#</dateposted>
								<deadline>#variables.objxml.xsdDateFormat(arguments.qry.deadline)# </deadline>
								<county>#XMLFormat(arguments.qry.region)#</county>
								<iiplogo>#arguments.qry.iiplogo#</iiplogo>
								<eqoplogo>#arguments.qry.eqoplogo#</eqoplogo>
								<employer><![CDATA[#Xmlformat(arguments.qry.employer)#]]></employer>
								<salarybandlower>#arguments.qry.salarybandlower#</salarybandlower>
								<salarybandupper>#arguments.qry.salarybandupper#</salarybandupper>	
								<description><![CDATA[#Xmlformat(lstdescription)#]]></description>
								<cfif Len(arguments.qry.contracttype)><contracttype>#XMLFormat(arguments.qry.contracttype)#</contracttype></cfif>
								<joburl><![CDATA[#Xmlformat(arguments.joburl)#]]></joburl>
								<sectors>
							</cfif>
									<sector><![CDATA[#Xmlformat(arguments.qry.sector)#]]></sector>
									<cfset currentid=arguments.qry.jobid>
									<cfif arguments.qry.jobid[currentrow + 1] neq arguments.qry.jobid>
								 </sectors>
							</job></cfif>
						</cfloop></jobs></cfoutput></cfxml>	
			  </cfsilent>			
			<cfreturn xmlvar>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getSectorsMap" returntype="xml" access="public" output="false" hint="get xml sectors map for a specfic partner">
		<cfargument name="partnerName" type="string" required="yes">
			
		<cfscript>
		var docpath = strConfig.strPaths.sitedir & strConfig.strPaths.jobsectormap & arguments.partnerName &  "\"; 		return objXML.ReadXmlConfig(docpath, "sectors.xml");
		</cfscript>
	
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PRIAVTE Functions ----------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="InsertXmlJobs" access="public" returntype="void" output="false" hint="build sql insert statement from jobs xml provided by partner and pass into sql">
		  <cfargument name="partnerid"    required="yes" type="numeric">
		   <cfargument name="partnerName" required="yes" type="string">
		   <cfargument name="xdoc"        required="yes" type="xml">

		   <cfscript>
		   //initialise local vars
		   var i = 0;
		   var j=0;
		   var x = 0;
		   
		   //set delet statement
		   var deleteSql = " DELETE FROM tblXmljobs WHERE partnerid =" & arguments.partnerid;
		   //set insert statement into var
		   var InsertSql = " INSERT INTO tblXmljobs(jobid,PartnerID,jobtitle,employer,salarybandlower,salarybandupper,contracttype,dateposted,deadline,Sectors,county,reference,joburl,[description]) VALUES (";
		   //set SQL flow control expression
		   var ifSQL = "";
		   //array to hold statments
		   var arrValues=arrayNew(1);
		   //lst var to hold value part of each insert statement
		   var lstValues = "";
		   var apostrophe=chr(39);
		   var desc = "";
		   //array of nodes in xml doc
		   var arrNodes = arguments.xdoc.xmlroot.xmlChildren;
		   var sql = "";
		   var arrSectorsNode=ArrayNew(1);

			
			
				   //BEGIN LOOP OVER ARRAY NODES
		   for (i=1;i LTE arrayLen(arrNodes);i=i+1 ){
		      ifSQL= " IF NOT EXISTS (SELECT * FROM tblXmljobs WHERE partnerid =" & arguments.partnerid & " AND  jobid = ";
			 //set list variable to contain values of each node (job) 
			 lstValues = listAppend (lstValues, arrNodes[i].jobid.xmltext);
			 lstValues = listAppend (lstValues, partnerid);
			 lstValues = listAppend (lstValues, apostrophe & Trim(  Replace(left(arrNodes[i].jobtitle.xmltext,250), apostrophe, '#apostrophe##apostrophe#', "all")) & apostrophe );
			 lstValues = listAppend (lstValues, apostrophe & trim(  Replace ( Left(arrNodes[i].employer.xmltext, 150), apostrophe, '#apostrophe##apostrophe#', "all")) & apostrophe );
			 lstValues = listAppend (lstValues, arrNodes[i].salarybandlower.xmltext);
			 lstValues = listAppend (lstValues, arrNodes[i].salarybandupper.xmltext);
			 lstValues = listAppend (lstValues, apostrophe & Trim(Replace(  Left( arrNodes[i].contracttype.xmltext, 150),apostrophe, '#apostrophe##apostrophe#', "all")) & apostrophe);
			 if (Find('+', arrNodes[i].dateposted.xmltext)){//check if date contain +0100 in string
			 	lstValues = listAppend (lstValues, createodbcDate(arrNodes[i].dateposted.xmltext) );
			 	lstValues = listAppend (lstValues,  createodbcDate(arrNodes[i].deadline.xmltext));
			 }
			 else{
				lstValues = listAppend (lstValues,  apostrophe & DateFormat(LSParseDateTime(arrNodes[i].dateposted.xmltext) , 'dd-mm-yyyy' ) & apostrophe );
			 	lstValues = listAppend (lstValues,  apostrophe & DateFormat(LSParseDateTime(arrNodes[i].deadline.xmltext), 'dd-mmm-yyyy' ) & apostrophe);
			 }
			 for (j=1;j LTE arrayLen(arrNodes[i].xmlChildren);j=j+1 ){
				if (arrNodes[i].xmlChildren[j].xmlName Eq "sectors")
					arrSectorsNode = arrNodes[i].xmlChildren[j].xmlChildren;
			}
			 //set list of sectors into var
			
			 //map sectors
			 lstValues = listAppend (lstValues, apostrophe &  LEFT ( MapPartnerSectors( arrSectorsNode, arguments.partnerName) , 1000) & apostrophe );	
			 //objutils.dumpabort(lstValues);
			 //reset list of sectors for next interation
			 //lstSectors = "";
			 lstValues = listAppend (lstValues, apostrophe & LEFT (arrNodes[i].county.xmltext, 100) & apostrophe );
			 lstValues = listAppend (lstValues, apostrophe & LEFT (arrNodes[i].reference.xmltext, 50) & apostrophe );
			 lstValues = listAppend (lstValues, apostrophe &  LEFT (arrNodes[i].joburl.xmltext, 150) & apostrophe );
			 //set description into var esacping any apostrophes
			 desc = Trim(Replace(arrNodes[i].description.xmltext, apostrophe, '#apostrophe##apostrophe#', "all") );
			 
			 //remove <CDATA> tags
			 desc = replace(desc, "<![CDATA[", "");
			 desc = replace(desc, "]]", "");
			 //put description into list of insert values
			 lstValues = listAppend (lstValues, apostrophe & desc & apostrophe );
			 //complete sql flow control statemnt
			 ifSQL = ifSQL & arrNodes[i].jobid.xmltext & ") BEGIN ";
			 //append list into array of insert statement
			 arrayAppend(arrValues, ifSQL & InsertSql & lstValues & ") END " );
			 //reset list var for next iteration
			 lstValues ="";
			 //break;
			 
		   }
		   //loop over array of insert statamnts to create a single sql statement
		   for( x=1;x LTE ArrayLen(arrValues); x=x+1 ){
				sql = sql & arrValues[x];
			}
			///END LOOP
			//write sql to reset job partner table
			sql = "SET DATEFORMAT DMY " & deleteSql &  sql & ' EXEC sp_BuildjobPartners #arguments.partnerid#';
		  	 
		    //pass sql statement to db
		    objDAO.query(PreserveSingleQuotes(sql), variables.strConfig.strVars.dsn1);
		   
		   </cfscript>
		 
		</cffunction>

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="JoinJobs2Partners" access="private" output="false" returntype="query" hint="use qofq to join partners to partner based on conctenated id">
		<cfargument name="qryJobs" required="yes" type="query">
		  
		  <cfset var qry="">
		  <cfset var pid="">
		   <cfset var qryPartners=GetJobsPartners()>

			<!---Loop over jobs --->
			<cfloop query="arguments.qryJobs">
				<!---Get id of partner from concatenated jobid (where '-' is the delimiter) --->
				<cfset pid = Mid(JobId, Find('-', JobId) + 1, Len(JobId))>
				<cfloop query="qryPartners">
					<cfif pid eq qryPartners.partnerID>
						<!--update job qry to hold organisation --->
						<cfset QuerySetCell(arguments.qryJobs, "Organisation", Organisation, arguments.qryJobs.currentrow)>
					</cfif>
				</cfloop>
			</cfloop>
		
		<cfreturn arguments.qryJobs>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="MapPartnerSectors" returntype="string" access="public" output="false" hint="convert partners xml sectors to our sectrs before import">
		<cfargument name="sectorNode"  type="any" required="yes">
		<cfargument name="partnername" type="string" required="yes">
			
		<cfscript> 
		var i = 0;
		var x = 0;
		var lstSectors = "";
		var arrSectorsNode = arguments.sectorNode;
		for (i=1;i LTE arrayLen(arrSectorsNode);i=i+1 ){
			lstSectors =listAppend(lstSectors,  MapSectors(arrSectorsNode[i].xmlText, arguments.partnerName));
			 }
		return 	objString.ListUnique(lstSectors); 
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="MapSectors" returntype="string" access="public" output="false" hint="convert partners xml sectors to our sectors before import">
		<cfargument name="sectorName"  type="string" required="yes">
		<cfargument name="partnername" type="string" required="yes">
		
		<cfscript>
		var apostrophe=chr(39);
		var i=0;
		var x=0;
		var lstSectors="";
		var arrNodes = arrayNew(1);
		//only map sectors for certain partners
		If (arguments.partnername eq "IEMA"){
			arrNodes = getSectorsMap(arguments.partnername).xmlroot.xmlchildren; 
			for (i=1;i LTE arrayLen(arrNodes);i=i+1 ){
				if (arrNodes[i].xmlattributes.name eq arguments.sectorName){
				  //get nodes for this partner sector	
				  arrLGsectors =  arrNodes[i].xmlChildren;
				   //loop over child (localgov) sectors for this node
				   for (x=1;x LTE arrayLen(arrLGsectors);x=x+1 ){
						//set element values inot list var
						lstSectors = listAppend(lstSectors, Replace(arrLGsectors[x].xmltext, apostrophe, apostrophe & apostrophe, "all"));
				   }
				 } 
			 }
		 }
		//return unmapped sector 
		else{
			arguments.sectorName = Trim(Replace(arguments.sectorName, apostrophe, '#apostrophe##apostrophe#', "all") );
			lstSectors = listAppend(lstSectors,arguments.sectorName);
		
		}
		return 	lstSectors; 
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getJoTEndWDays" access="public" returntype="array" output="false" hint="return the days that a job of the week may appear on">
		<cfargument name="arrJoTWdays" required="yes" type="array">
		<cfscript>
		var i = 0;
		var arr  = arguments.arrJoTWdays;
		//remove position 1 so that 1st End day is one week from 1st start date
		ArrayDeleteAt(arr, 1);
		for (i=1 ;i LTE arrayLen(arr); i=i+1 ){
			//chnge date of each row to be 1 minute before current date
			arr[i]= DateAdd('n', -1, arr[i]);
		}
		//add extra row to array so that last possbibel end date is 1 week after last strta date
		arrayAppend(arr, DateAdd('ww', 1, arr[arrayLen(arr)]));
		return arr;
		</cfscript>
		</cffunction>
		
		<!--- ----------------------------------------------------------------------------------------------------->
		<!--- ----------------------------------------------------------------------------------------------------->
		<!--- ----------------------------------------------------------------------------------------------------->

</cfcomponent>