<cfparam name="attributes.directory" type="string">
<cfparam name="attributes.webpath"   type="string">

<cfdirectory directory="#attributes.directory#" action="list" name="qryDir">

<cfscript>
arrContent = ArrayNew(1);
//set content in array
for (i=1;i LTE qryDir.recordcount;i=i+1 ){
	strImage =request.objApp.objutils.GetDimensions("#attributes.directory#\#qryDir.name[i]#");
	copy  = "<img src=""#attributes.webpath##qryDir.name[i]#"" height=""#strImage.height#"" width=""#strImage.width#"" border=""0""/>";
	arrayAppend(arrContent,copy);
} 
</cfscript>
		
<!---call custom tag to fade content--->
<cf_fader content="#arrContent#">


