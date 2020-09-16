<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/customtags/LocalGovBox.cfm $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 14/08/07 14:53 $

--->

<cfparam name="attributes.width"		default="100%">
<cfparam name="attributes.bgcolor"		default="##BEBEBE">
<cfparam name="attributes.headerText"	default="">
<cfparam name="attributes.textColor"	default="##FFFFFF">

<cfif thisTag.ExecutionMode is 'start'>
	<cfoutput>
	<div class="bl_#attributes.bgcolor#" style="width:100%"><div class="br_#attributes.bgcolor#"><div class="tl_#attributes.bgcolor#"><div class="tr_#attributes.bgcolor#" style="color:#attributes.textColor#">
	</cfoutput>
<cfelse>
	</div></div></div></div>
</cfif>