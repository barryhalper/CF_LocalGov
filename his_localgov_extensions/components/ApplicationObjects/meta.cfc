<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/COMPONENTS/ApplicationObjects/meta.cfc $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 8/08/07 10:06 $

--->

<cfcomponent displayname="Meta" hint="process meta tags for this website">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="meta" hint="Pseudo-constructor">
		<cfargument name="strConfig" type="struct" required="yes">
		
		<cfscript>
		// Component's constant declarations...	
		variables.strConfig = arguments.strConfig;
		variables.dirMetaPath=variables.strConfig.strPaths.xmlpath & "meta.xml";
		LoadMetaData();
		
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
	<cffunction name="LoadMetaData" access="public" output="false" returntype="void" hint="read contents of meta.xml into var">
		<cfset var sXML ="">
		<cffile action="read" file="#variables.dirMetaPath#" variable="sXML">
		<cfset variables.XmlMeta= XMLParse(sXML)>
	</cffunction>	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="SaveMetaData" access="public" output="false" returntype="boolean" hint="save xml string to file and reaload into mememory">
		<cfargument name="sXml" type="string" required="yes">
		
		<cfscript>
		var bl = false; 
		var xmlDoc = Trim(arguments.sXml);
		//remove char from  string
		xmlDoc = replace (xmlDoc, "&", "&amp;", "all");
		//parse xml doc and see if it is valid
		if ( IsXml(xmlDoc) )
			bl = true;
		</cfscript>
		
		<cfif bl> 
			<cffile action="write" file="#variables.dirMetaPath#" output="#trim(xmlDoc)#" addNewLine="no">
		 	<cfset LoadMetaData()>
		</cfif>
		
		<cfreturn bl>
	</cffunction>	

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------- --->
	<cffunction name="GetStringMeta" access="public" output="false" returntype="string" hint="get meta data as string for admin">
			<cfreturn ToString(variables.XmlMeta)>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------- --->
	<cffunction name="GetWebsiteMetaData" access="public" output="false" returntype="struct" hint="return meta data based on webiste">
			<cfargument name="fuseaction" 		type="string" required="yes" hint="fbx fuseaction">
			<cfargument name="MetaContent"   	type="struct" required="yes" hint="struct that may contain meta data set from a peice of content ">
			
	  	    <cfscript>
			var TitleDelim = " &gt; ";
			//call method to extract metadata based on fuseaction
			var strMeta = BuildWebsiteMetaData(arguments.fuseaction);
			//build title based on array of meta titles
			strMeta.title    	= 	ArraytoList(strMeta.arrTitle); 
			
			//check if meta data is coming from content
			if (NOT StructIsEmpty(arguments.MetaContent)){
				if (StructKeyExists(arguments.MetaContent, "title") )
					//append content title to exsiting title
					strMeta.title =  arguments.MetaContent.title & "," & "LocalGov.co.uk";
				if (StructKeyExists(arguments.MetaContent, "description") )
					//overwrite meta description 
					strMeta.description = arguments.MetaContent.description;
				if (StructKeyExists(arguments.MetaContent, "keyword") )
					//overwrite keywords description 
					strMeta.keyword = arguments.strMetaContent.keyword;	
					
			}
			strMeta.title = ListChangeDelims(strMeta.title, TitleDelim);
			return strMeta;
			</cfscript>
	</cffunction>
	
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PRIVATE FUNCTIONS ----------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="BuildWebsiteMetaData" access="public" output="false" returntype="struct" hint="get meta description and keywords for this fuseaction ">
		<cfargument name="fuseaction" type="string" required="yes">
			
		<cfscript>
		//declare local vars
		var i = 0;
		var x = 0;
		var t = 0;
		var strReturn = StructNew();
		//get directory from fuseaction
		var directory = listGetAt(arguments.fuseaction, 1, ".");
		//get circuit from fuseaction
		//var page      =	listGetAt(arguments.fuseaction, 2, "."); 
		//get array of xml nodes
		var arrMeta = Arraynew(1);
		//position of node in xml of this directory
		var CircuitPosition = 0; 
		var arrPages  = ArrayNew(1);
		//array to hold a title for each node
		var arrTitle = ArrayNew(1);
		
		try{
		arrMeta	  = variables.xmlMeta.xmlRoot.xmlChildren;
		
			// 1.) set default meta data values based on 1st XML node
			if (structkeyExists(arrMeta[1].XmlAttributes, "title"))
				ArrayAppend(arrTitle, arrMeta[1].XmlAttributes.title);
			if (StructkeyExists(arrMeta[1].XmlAttributes, "description"))	
				strReturn.description =arrMeta[1].XmlAttributes.description;
			if (StructkeyExists(arrMeta[1].XmlAttributes, "keywords"))	
				strReturn.keywords	  =arrMeta[1].XmlAttributes.keywords;
			if (StructkeyExists(arrMeta[1].XmlAttributes, "author"))
					strReturn.author	  =arrMeta[1].XmlAttributes.author;
			
			// 2.)overwrite default metadata with that which is held in the directory node
			for (i=1;i LTE ArrayLen(arrMeta);i=i+1 ){
				//check if current node is the directory set in fuction
				If (arrMeta[i].XmlName eq "directory" and arrMeta[i].XmlAttributes.circuit eq directory){
					CircuitPosition = i;
					//only overwrite metadate if it is present
					If (structkeyExists(arrMeta[i].XmlAttributes, "title") and Len(arrMeta[i].XmlAttributes.title)){
						//remove strap line from title 
						//prepend extising title with directy node title
						ArrayPrepend(arrTitle, arrMeta[i].XmlAttributes.title);
						}
					If (structkeyExists(arrMeta[i].XmlAttributes, "description") and Len(arrMeta[i].XmlAttributes.description))
						strReturn.description	=arrMeta[i].XmlAttributes.description;
					If (structkeyExists(arrMeta[i].XmlAttributes, "keywords") and Len(arrMeta[i].XmlAttributes.keywords))
						strReturn.keywords		=arrMeta[i].XmlAttributes.keywords;
				break;
				}
			}
			if (CircuitPosition){
				// 3.) overwrite directory metadata with that which is held in the page node
				arrPages = arrMeta[CircuitPosition].xmlChildren; //get array of nodes for each page/fuseaction in this directory
				for (x=1;x LTE ArrayLen(arrPages);x=x+1 ){
					if (structKeyExists(arrPages[x].XmlAttributes, "fuseaction") ){
							if (arrPages[x].XmlAttributes.fuseaction eq arguments.fuseaction){
								//only overwrite metadate if it is present
								If (structKeyExists(arrPages[x].XmlAttributes, "title") and Len(arrPages[x].XmlAttributes.title))
									ArrayAppend(arrTitle, arrPages[x].XmlAttributes.title);
								If (structKeyExists(arrPages[x].XmlAttributes, "description") and Len(arrPages[x].XmlAttributes.description))
									strReturn.description	=arrPages[x].XmlAttributes.description;
								If (structKeyExists(arrPages[x].XmlAttributes, "keywords") and Len(arrPages[x].XmlAttributes.keywords))
									strReturn.keywords		=arrPages[x].XmlAttributes.keywords;
							}
					  }
				}
			}
			
		//**CATCH **//	
		}
		catch(Any Exception){
			strReturn.arrTitle = ArrayAppend(arrTitle,"LocalGov.co.uk - Your authority on UK Local Government");
			strReturn.keywords = "";
			strReturn.description = "";
			strReturn.author="Hemming Group IT Development Team - Barry Halper";
		}	
		//remove strap line from title if not at the beginning
		if (ArrayLen(arrTitle) gt 1){
			for (t=2;t LTE ArrayLen(arrTitle);t=t+1) 
				arrTitle[t] = Replace(arrTitle[t], "- Your authority on UK Local Government", "");
		}
		//place array of title into return structure
		strReturn.arrTitle = arrTitle;
		return 	strReturn;	
		</cfscript>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- <cffunction name="UploadMeta" access="public" output="false" returntype="struct" hint="Upload xml meta data and save to file">
	 <cfargument name="FileName" type="string" required="true" hint="Name of file form field">
		
		<cfset var str=StructNew()>
		<cfset var sXML="">
		<cfset str.IsSuccess=True>
		
			<cftry>
				<!--- upload image file --->
				<cffile action="upload" destination="#Trim(variables.strConfig.strPaths.xmlpath)#" filefield="#arguments.filename#" nameconflict="makeunique" accept="text/xml"> 
				
				<cfif File.FileWasSaved >
					<!--read contents of file 
					<cffile action="read" file="#variables.strConfig.strPaths.xmlpath##File.ServerFile#" variable="sXML"> 
					<!---check if file is well formatted xml--->
					<cfif isXml(sXML)> 
						<cfset str.IsSuccess=false>
					</cfif>
				</cfif>
				
				
				<cfcatch><cfset str.IsSuccess=false></cfcatch>
			</cftry>	
		<cfreturn str>
	</cffunction> ---></cfcomponent>
