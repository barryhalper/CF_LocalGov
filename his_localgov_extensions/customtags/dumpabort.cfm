<!--
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/customtags/dumpabort.cfm $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 14/08/07 14:53 $

-->

<cfparam name="attributes.var"   type="string" default="">

<cfdump var="#evaluate(attributes.var)#">
<cfabort>