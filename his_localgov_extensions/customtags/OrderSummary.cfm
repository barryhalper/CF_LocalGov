<cfparam name="attributes.SiteVars" 	type="struct" default=""><!---site config variables(strVars) --->
<cfparam name="attributes.strSession" 	type="struct" default=""><!---session scope --->
<cfparam name="attributes.ShowPrices"	type="boolean" default="true"><!--- display  order prices --->
<cfparam name="attributes.StrOrder"		type="struct" default="#structNew()#"><!--- structre that holds order summary/prices --->
<cfparam name="attributes.IsEmail"		type="boolean" default="false">

<!---set array to hold format types--->
<cfset arrFormat = listToArray(attributes.SiteVars.ds_formats)>
<cfset arrCommMethod = listToArray(attributes.SiteVars.ds_coms)>
<cfset CommMethod = "">

<cfsavecontent variable="savecont">
<cfoutput>
	
	<cfif attributes.IsEmail><span > #attributes.strSession.dataSalePurchaser.name#,<br />
	<br />Thank you for your order.<br />
	<br />Please find attached your selected data lists.<br />
	<br /></span>
	</cfif>

	<h3>Your details:</h3>
	<ul>
	<strong>
	#attributes.strSession.dataSalePurchaser.name#</strong><br>
	#attributes.strSession.dataSalePurchaser.companyname#<br>
	#attributes.strSession.dataSalePurchaser.address#<br>
	#attributes.strSession.dataSalePurchaser.postcode#<br>
	#attributes.strSession.dataSalePurchaser.tel#<br>
	#attributes.strSession.dataSalePurchaser.country#<br>
	#attributes.strSession.dataSalePurchaser.email#<br>
	</ul>
<br clear="all"/>

<table  border="0" width="625" align="center" id="tables_dir"  cellspacing="0">
	
		<tr>
			<th>Your List(s)</th>
			<th align="center">Comm&nbsp;Method</th>
			<th align="center" width="75">No of Uses</th>
		</tr>
		<cfloop from="1" to="#arrayLen(attributes.strSession.dataSalesLists)#" index="i">
		<tr>
			<td><img src="#request.sImgPath#set_list.gif" width="32" height="32" align="left">&nbsp;<strong style="font-size:14px;">#attributes.strSession.dataSalesLists[i].listname#</strong><br />
			&nbsp;Format: #arrFormat[attributes.strSession.dataSalesLists[i].format]#<cfif attributes.strSession.dataSalesLists[i].format eq 3><br />&nbsp;<span style="font-size:x-small; color:##184693">*VAT not applicable.</span></cfif>			</td>
			<cfif structKeyExists(attributes.strSession.dataSalesLists[i],'commMethods')>
				<!--- communication method --->
				<td>
				<cfloop from="1" to="#arrayLen(arrCommMethod)#" index="j">
					<cfif structKeyExists(attributes.strSession.dataSalesLists[i].commMethods,j)>
						<cfswitch expression="#arrCommMethod[j]#">
							<cfcase value="Telephone">Telephone</cfcase>
							<cfcase value="Mailing">Mailing</cfcase>
							<cfcase value="Fax">Fax</cfcase>
						</cfswitch>
						<br />
					</cfif>
				</cfloop>
				</td>
				<!--- number of uses --->
				<td align="center">
				<cfloop from="1" to="#arrayLen(arrCommMethod)#" index="k">
					<cfif structKeyExists(attributes.strSession.dataSalesLists[i].commMethods,k)>
						#attributes.strSession.dataSalesLists[i].commMethods[k]#<br />
					</cfif>
				</cfloop>				</td>
			</cfif>
		</tr>
		</cfloop>
	
	<!---ONLY DISPLAY PRICES FOR FBX PAGE NOT EMAIL --->
	<cfif attributes.ShowPrices and NOT StructIsEmpty(attributes.StrOrder)>
	<tr>
			<td colspan="2"  align="right">&nbsp;<strong>TOTAL</strong></td>
			<td align="right"  style="font-weight:bold;">&pound;#numberFormat(attributes.strSession.strdatasalestotal.totalbeforediscountandvat, request.mask)#</td>
		</tr>
		<cfif attributes.strSession.strdatasalestotal.SubDiscount gt 0>
		<tr>
		  <td colspan="2" align="right">&nbsp;<strong>DISCOUNT</strong></td>
		  <td align="right" style="font-weight:bold;">&pound;#numberFormat(attributes.strSession.strdatasalestotal.SubDiscount, request.mask)#</td>
		  </tr>
		<tr>
			<td colspan="2" align="right"><strong>TOTAL AFTER DISCOUNT </strong></td>
			<td align="right"  style="font-weight:bold;">&pound;#numberFormat(attributes.strSession.strdatasalestotal.totalaftersubdiscount, request.mask)#</td>
		</tr>
		</cfif> 
		
		<tr>
			<td colspan="2" align="right">&nbsp;<strong>VAT*&nbsp;</strong> (#request.strSiteConfig.strvars.vat_uk#%)</td>
			<td align="right"  style="font-weight:bold;"><cfif attributes.strSession.userDetails.countryid eq 1>&pound;#numberFormat(attributes.strSession.strdatasalestotal.VAT, request.mask)#<cfelse>VAT will not be added</cfif></td>
		</tr>
		  
		<tr>
			<td colspan="2" align="right" >&nbsp;<strong>GRAND TOTAL:</strong></td>
			<td align="right"  style="font-weight:bold;font-size:17px; color:##FF0000" nowrap="nowrap">
			&pound;#numberFormat(attributes.strSession.strdatasalestotal.finaltotal, request.mask)#			</td>
		</tr></cfif>
	
</table>


<cfif attributes.IsEmail>
<br />
<div class="bodytext">
If you have any questions or queries, regarding your list, please do not hesitate to contact us at <a href="mailto:customer@hgluk.com">customer@hgluk.com</a> or on +44 (0)20 7973 6694. <br />
<br />Kind regards,<br /><br />Customer Service Team
</div>
</cfif>

</cfoutput>
</cfsavecontent>

<cfset caller.orderSummary = savecont>