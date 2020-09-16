<!---
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/customtags/spacer.cfm $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 14/08/07 14:53 $

--->
<cfparam name="Attributes.width">
<cfparam name="Attributes.height">

<cfoutput><img src="#request.sImgPath#pixel.gif" height="#Attributes.height#" width="#Attributes.width#"></cfoutput>