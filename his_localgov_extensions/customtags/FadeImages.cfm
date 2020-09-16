<cfparam name="attributes.directory" type="string">
<cfparam name="attributes.webpath"   type="string">

<cfparam name="attributes.height" default="">
<cfparam name="attributes.width"  default="">

<cfdirectory directory="#attributes.directory#" action="list" name="qryDir">

<cfscript>
	arrContent = ArrayNew(1);
	
	//set content in array
	for (i=1;i LTE qryDir.recordcount;i=i+1 )
	{
		strImage =request.objApp.objutils.GetDimensions("#attributes.directory#\#qryDir.name[i]#");
		
		//Set height of image
		if(Len(attributes.height))
		{
			imageHeight = attributes.height;
		}
		else
		{
			imageHeight = strImage.height;
		}
		
		//Set width of image
		if(Len(attributes.width))
		{
			imageWidth = attributes.width;
		}
		else
		{
			imageWidth = strImage.width;
		}
		
		copy  = "<img src=""#attributes.webpath##qryDir.name[i]#"" height=""#imageHeight#"" width=""#imageWidth#"" border=""0""/>";
		arrayAppend(arrContent,copy);
	} 
</cfscript>
		
<!---call custom tag to fade content--->
<cf_fader content="#arrContent#">


