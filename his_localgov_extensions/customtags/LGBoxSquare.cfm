<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/customtags/LGBoxSquare.cfm $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 14/08/07 14:53 $

--->

<cfparam name="attributes.width"		default="100%">
<cfparam name="attributes.bgcolor"		default="6D369B">
<cfparam name="attributes.headerText"	default="">
<cfparam name="attributes.headerTextAlign"	default="center">
<cfparam name="attributes.textColor"	default="FFFFFF">
<cfparam name="attributes.width"		default="">
<cfparam name="attributes.section"		default="red">
<cfparam name="attributes.border"		default="1">
<cfparam name="url.method"		default="1">

<!--- todo: replace with class style when ready? --->
<cfswitch expression="#listgetat(url.method,1,".")#">
	<cfcase value="news,business">					<cfset attributes.bgcolor="6D369B">	</cfcase>
	<cfcase value="directory,govepedia,need2know">	<cfset attributes.bgcolor="6D369B">	</cfcase>
	<cfcase value="home,subscribe">					<cfset attributes.bgcolor="6D369B">	</cfcase>
	<cfcase value="events">							<cfset attributes.bgcolor="6D369B">	</cfcase>
	<cfcase value="jobs">							<cfset attributes.bgcolor="6D369B">	</cfcase>
	<cfdefaultcase>									<cfset attributes.bgcolor="6D369B">	</cfdefaultcase>
</cfswitch>

<cfif thisTag.ExecutionMode is 'start'>
	<cfoutput>
	<cfif attributes.border><table   bgcolor="###attributes.bgcolor#"  cellpadding="1" cellspacing="0" <cfif attributes.width neq ''>width="#attributes.width#"</cfif>><tr><td valign="middle" align="center"></cfif>
	<table class="text" bgcolor="##FFFFFF"<cfif attributes.width neq ''>width="100%"</cfif> >
	<tr bgcolor="###attributes.bgcolor#" style="color:###attributes.textColor#" align="#attributes.headerTextAlign#"><td><strong>#attributes.headerText#</strong></td></tr>
	<tr><td>
	</cfoutput>
<cfelse>
	</td></tr></table>
	<cfif attributes.border></td></tr></table></cfif>
</cfif>