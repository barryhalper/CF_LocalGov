<cfcomponent  displayname="slides" hint="functions for processing .swf sildes created by Curve Corporation" extends="his_Localgov_Extends.components.ApplicationObjects.utils">
	
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="slides" hint="Pseudo-constructor">
		<cfargument name="slidexmlpath"   required="yes" type="string" hint="full dir path and name of slides.xml">
		
		<cfscript>
		var i = "";
		instance = structNew();
		instance.slidexmlpath = arguments.slidexmlpath;
		return this;
		</cfscript>
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- PUBLIC FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="GetInstance" access="public" returntype="struct" output="false" hint="return instanace data">
		<cfreturn instance>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="setXmlSlides" access="public" returntype="void" output="false" hint="return instanace data">
		<cfscript>
		If (NOT structKeyExists(instance, "xmlSlides"))
			instance.xmlSlides = XMLParse( trim( ReadFile(instance.slidexmlpath) ) );
		</cfscript>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="xmlSlideToQuery" access="public" returntype="query" hint="turn slide xml data and into query for CMS">
		
		<cfscript>
		//set array to hold xml nodes
		var arrSlides = ArrayNew(1);
		//set query to hold mxl data
		var qrySlides = "";
		var lstColumn = "";
		var i= 0;
		var j =0;
		
		setXmlSlides();
		
		arrSlides = instance.xmlSlides.xmlroot.xmlchildren;
		//set xml Attributes into query Columns;
		lstColumn  = StructKeyList(arrSlides[1].xmlAttributes);
		qrySlides  = queryNew(lstColumn);
		
		//loop over xml children array
		for (i = 1; i lte arraylen(arrSlides); i=i+1 ){
			//add row to query for each slide
			queryAddRow(qrySlides);
			//loop over column list 
			for (j = 1; j lte ListLen(lstColumn); j=j+1 ){
				//set cell for each list element
				querySetCell(qrySlides, ListGetAt(lstColumn, j),  arrSlides[i].xmlAttributes[ListGetAt(lstColumn, j)]);
				}
			}
		return 	qrySlides;
		</cfscript>
		
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="UpdateSlide" access="public" returntype="struct" hint="update xml data for a particular slide">
		<cfargument name="slideNo"    required="yes" type="numeric">
		<cfargument name="image"      required="yes" type="string">
		<cfargument name="imagePath"  required="yes" type="string" >
		<cfargument name="width"       required="yes" type="string" >
		<cfargument name="height"      required="yes" type="string" >
		<cfargument name="link"       required="yes" type="string">
		<cfargument name="text"       required="yes" type="string"> 
		<cfargument name="buttontext" required="no" type="string" default="">
		
		<cfscript>
		var strValidate = structNew();
		var strAttibutes = structNew();
		strValidate.blValid = true;
		
		setXmlSlides();
	    //set attributes for node into struct to be ammended
		strAttibutes =  instance.xmlSlides.xmlroot.xmlchildren[arguments.slideNo].xmlAttributes;
		//amend struct		 
		strAttibutes.line_1    = arguments.text;
		strAttibutes.hyperlink = arguments.link;
		if (Len(arguments.buttonText))
			strAttibutes.buttonText = arguments.buttonText;
		 
		 //save image
		 If (StructKeyExists(form, "imageFile") and Len(form.imageFile) ){
		 	strValidate = uploadSlideImage(arguments.image, arguments.imagePath, arguments.width, arguments.height );
		 }
		 
		 //dumpabort(strValidate);
		 
		  if (strValidate.blValid and structKeyExists(strValidate, "savedfile") )
			 strAttibutes.image 	= strValidate.savedfile;
		 	
			//struct pointer will have amended xml var so save xml var back to file	
	 		writeFile(instance.slidexmlpath, instance.xmlSlides) ;
			
			return strValidate;
		</cfscript>
	
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="uploadSlideImage" access="private" returntype="struct" hint="upload slide image .jgp and return validation string">
		<cfargument name="image"       required="yes" type="string">
		<cfargument name="imagePath"   required="yes" type="string" >
		<cfargument name="width"       required="yes" type="string" >
		<cfargument name="height"      required="yes" type="string" >
		
		
		  <cfscript>
		   var strValidate = StructNew();
		   var savedfile =  "";
		   strValidate.blValid = true;
		   
		   //upload file to server
		   savedfile = UploadImage(arguments.image, arguments.imagepath, 'image');
		   
		   //if no file is saved, mime type must be incorrect
		   If (NOT Len(savedfile)){
		   		strValidate.blValid = false;
		 		strValidate.validateMessage = "This image could not be uploaded as it is not an gif/jpg";
			}
			//get image dimensions of newly upaded file
		    else{
		    	strImgDim  =  GetDimensions(arguments.imagepath & "\" & savedfile);
		    	
		    	//dumpabort(strImgDim);
		    	
				//..check dimension are correct
				If (trim(strImgDim.width) neq trim(arguments.width) OR trim(strImgDim.height) neq trim(arguments.height)) {
		   			strValidate.validateMessage = "This image's imensions are not valid. The image must be #arguments.height# x #arguments.width#.<br/>This images dimensions are #strImgDim.width# x  #strImgDim.height#";
					strValidate.blValid = false;
					strValidate.savedfile = savedfile;
					// delete file
					deleteFile(arguments.imagepath & "\" & savedfile);
					}
					else{
					//place name of file into return struct
					strValidate.savedfile = savedfile;
					strValidate.blValid = true;
					}
			}
			return strValidate;
		  </cfscript>
		
	</cffunction>
	
</cfcomponent>