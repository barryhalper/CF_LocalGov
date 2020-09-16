<!---
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/customtags/paginate.cfm $
	$Author: Bhalper $
	$Revision: 3 $
	$Date: 26/01/10 17:09 $

--->

<!---////////CREATE 'NEXT' & 'BACK' LINKS//////////--->

<cfparam name="attributes.strPagination" type="struct">
<cfparam name="attributes.querystring"   type="string" default="">
<cfparam name="attributes.isJS"          type="boolean" default="0">
<cfparam name="nextQuerystring"          type="string" default="">
<cfparam name="PreviousQuerystring"      type="string" default="">

<cfparam name="attributes.numrows" type="numeric" default="20">
<cfparam name="attributes.table_width" type="numeric" default="0">

<cfscript>
table_width=300;

if ( attributes.strPagination.startrowback gt 0 and attributes.strPagination.startrownext lte attributes.strPagination.totalrows)
	table_width=600;
</cfscript>

<cfif attributes.table_width neq 0>
	<cfset table_width=attributes.table_width>
</cfif>

<cfoutput>

<cfif NOT attributes.isJS>
		<table width="#table_width#" border="0" cellspacing="0" cellpadding="1" >
	  <tr align="left">
	  <!---PREVIOUS--->
	  <cfif attributes.strPagination.startrowback gt 0 >
		<td width="150"><a href="#attributes.querystring#&amp;startrow=#attributes.strPagination.startrowback#" >
		 <img src="#request.simgpath#previous_arrow_anim.gif" border="0" width="11" height="13" alt="next" /><img src="#request.simgpath#previous_arrow_anim.gif" border="0" width="11" height="13" alt="next" /></a> </td>
		<td width="150" align="left"><a href="#attributes.querystring#&amp;startrow=#attributes.strPagination.startrowback#" ><span class="smaller"> previous #attributes.numrows# </span></a>
		</td>
		</cfif>
		<!---NEXT --->
		<cfif attributes.strPagination.startrownext lte attributes.strPagination.totalrows >
		<td width="150" ><a href="#attributes.querystring#&amp;startrow=#attributes.strPagination.startrownext#"><span class="smaller">next #attributes.numrows#</span></a></td>
		<td width="150" align="left">
		<a href="#attributes.querystring#&amp;startrow=#attributes.strPagination.startrownext#"><img src="#request.simgpath#next_arrow_anim.gif" border="0" width="11" height="13" alt="next" /><img src="#request.simgpath#next_arrow_anim.gif" border="0" width="11" height="13" alt="next" /></a></td>
		</cfif>
	  </tr>
	</table>

<cfelse>
	
	<table width="#table_width#" border="0" cellspacing="0" cellpadding="1"  >
	  <tr>
	  
	  	<!---PREVIOUS--->
	  	<cfif attributes.strPagination.startrowback gt 0 >
			<cfset previousQuerystring = attributes.querystring &  attributes.strPagination.startrowback & ')'>
			<td width="150" align="right"><a href="javascript:#PreviousQuerystring#">
			 <img src="#request.simgpath#previous_arrow_anim.gif" border="0" width="11" height="13" alt="next" /><img src="#request.simgpath#previous_arrow_anim.gif" border="0" width="11" height="13" alt="next" /></a> </td>
			<td width="150" align="left"><a href="javascript:#PreviousQuerystring#"><span class="smaller">&nbsp;previous&nbsp;#attributes.numrows#&nbsp;</span></a></td>
		<cfelse>
			<td></td>
			<td></td>
		</cfif>
		
		<!---NEXT --->
		<cfif attributes.strPagination.startrownext lte attributes.strPagination.totalrows >
			<cfset nextQuerystring = attributes.querystring & attributes.strPagination.startrownext & ')'>
			<td width="100%" align="right"><a href="javascript:#nextQuerystring#"><span class="smaller">next #attributes.numrows#</span></a></td>
			<td align="left">
			<a href="javascript:#nextQuerystring#"><img src="#request.simgpath#next_arrow_anim.gif" border="0" width="11" height="13" alt="next" /><img src="#request.simgpath#next_arrow_anim.gif" border="0" width="11" height="13" alt="next" /></a></td>
		</cfif>
	  </tr>
	</table>

</cfif>

</cfoutput>

 <!------> 
