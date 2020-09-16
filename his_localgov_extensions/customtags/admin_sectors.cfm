<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/customtags/admin_sectors.cfm $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 14/08/07 14:53 $

--->

<cfparam name="request.qrysectors"  default="#QueryNew('SectorID,sector')#">
<cfparam name="attributes.sectors"  default="">
<cfparam name="attributes.formname" default="frmNews">
<cfparam name="attributes.disabled" default="">
<cfparam name="attributes.mode" 	default="admin">
<cfparam name="attributes.class" 	default="text">

<!--- Sectors... ------------------------------------------------------------------------------------------->
<cfoutput>
<table class="#attributes.class#" width="95%" align="center" border="0">
<cfif attributes.mode eq "admin"><tr><td colspan="2"><hr /><strong>Sectors:</strong><br /><span class="smtext" style="color:##999999">Select the sector(s) this article applies to</span></td></tr></cfif>
<tr>
<td valign="top">
<cfloop from="1" to="#request.qrysectors.RecordCount#" index="i">
	<span <!--- onMouseOver="this.className='hovOut';" onMouseOut="this.className='hovOver';" --->><input type="checkbox" name="Sectors" value="#request.qrysectors.SectorID[i]#" #attributes.disabled#
		onChange="
			if (this.checked) 
				document.getElementById('s#i#').style.fontWeight='bold'; 
			else  
				document.getElementById('s#i#').style.fontWeight='normal';
		" #iif(ListFind(attributes.Sectors, request.qrysectors.SectorID[i]), de('checked'), de(''))#  />
		
		<span id="s#i#" style="font-weight:#iif(ListFind(attributes.Sectors, request.qrysectors.SectorID[i]), de('bold'), de(''))#" 
			<cfif NOT Len(attributes.disabled)>onMouseDown="
				if (#attributes.formname#.Sectors[#evaluate(i-1)#].checked) {
					this.style.fontWeight='normal';
					#attributes.formname#.Sectors[#evaluate(i-1)#].checked=false;
				} else {
					this.style.fontWeight='bold';
					#attributes.formname#.Sectors[#evaluate(i-1)#].checked=true;
				}
			"</cfif>>#request.qrysectors.Sector[i]#</span>
		</span>
	<br />
	<cfif i eq round(Evaluate(request.qrysectors.RecordCount/2))></td><td valign="top"></cfif>
</cfloop>

</td></tr>
<cfif attributes.mode eq "admin"><tr><td colspan="2"><hr /></td></tr></cfif>
</table>
</cfoutput>