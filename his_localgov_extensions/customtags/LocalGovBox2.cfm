<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/customtags/LocalGovBox2.cfm $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 14/08/07 14:53 $

--->

<cfparam name="attributes.width"		default="100%">
<cfparam name="attributes.bgcolor"		default="##BEBEBE">
<cfparam name="attributes.headerText"	default="">
<cfparam name="attributes.textColor"	default="##FFFFFF">
<cfparam name="attributes.width"		default="">
<cfparam name="attributes.section"		default="red">

<cfif thisTag.ExecutionMode is 'start'>
	<cfoutput>
	<div class="xsnazzy" <cfif attributes.width neq ''>style='width:#attributes.width#'</cfif> >
	<b class="xtop"><b class="xb1"></b><b class="xb2 color_#attributes.section#"></b>
	<b class="xb3 color_#attributes.section#"></b><b class="xb4 color_#attributes.section#"></b></b>
	<div class="xboxcontent">
	<h1 class="color_#attributes.section#">#attributes.headerText#</h1>
	</cfoutput>
<cfelse>
	</div>
	<b class="xbottom"><b class="xb4"></b><b class="xb3"></b>
	<b class="xb2"></b><b class="xb1"></b></b>
	</div>
</cfif>