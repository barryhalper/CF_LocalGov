<!---
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/customtags/pagetitle.cfm $
	$Author: Bhalper $
	$Revision: 5 $
	$Date: 18/09/08 17:42 $

--->
<cfif StructKeyExists(url, "mid")>
	<cfparam name="Attributes.mid" 		default="#url.mid#">
<cfelse>
<cfparam name="Attributes.mid" 		default="">
</cfif>
<cfparam name="Attributes.Pagename" default="">
<cfparam name="metaTitle" default="">
<cfparam name="url.method" default="home.index">
<cfparam name="breadcrumbTitle" default="">


<cfif ListContains(url.method, "directory") or ListContains(url.method, "govepedia")>
<cfoutput>
 <table width="99%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td><h1 style="font-size:1.2em;">#Attributes.Pagename#</h1></td>
    <td align="right">
<cfif attributes.pageName neq "Searching..." >
<a href="#request.myself#directory.home" title="LocalGov Directory (By MYB)"><img src="http://admin.localgov.co.uk/his_localgov/view/images/uploaded/Image/LocalGovDirectorytse.jpg" alt="LocalGov Directory (By MYB)" width="200" height="54" border="0" /></a></cfif></td>
  </tr>
</table> 
</cfoutput>

<cfelse>
<cfscript>
//get title from meta data
ArrTitle 		=  request.objApp.objMeta.GetWebsiteMetaData(url.method, request.strMetaContent).arrTitle;
//check if title is present in array
if (ArrayLen(ArrTitle) gte 3 )
	metaTitle = ArrTitle[3];

if (Len(metaTitle))
  Attributes.Pagename = metaTitle;
else
if (Len(breadcrumbTitle))
  Attributes.Pagename = breadcrumbTitle;
  	
    
if (Len(Attributes.Pagename)) {
	writeoutput( '<h1 style="font-size:1.2em;">' & Attributes.Pagename & '</h1>' );
}
</cfscript>
</cfif>

