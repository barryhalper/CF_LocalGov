<cfparam name="totalText" default="Total Received" > 
<cfparam name="attributes.strInvoiceData" default="">

<cfset variables.strInvoiceData = attributes.strInvoicedata>
<!--- 
<cfsetting showdebugoutput="yes"> 

<cfdump var="#strInvoiceData.qryInvoiceDetails#"><cfabort>
--->
<cfoutput>
<html><head></head><body>
<table cellpadding="0" cellspacing="0" width="100%">
	<tbody>
	<tr>
		<td colspan="3" align="center"><strong>Sales Invoice</strong></td>
	</tr>
	<tr>
		<td align="left" valign="top"><img src="#request.sImgPath#hemlogo.gif" alt="Hemming Group Ltd" border="0"></td>
		<td></td>
		<td style="font-size: 8pt;" align="right">
			
			<span style="font-size:11pt;">Hemming Group Limited</span>
			<br><br>
			32 Vauxhall Bridge Road <br>
			London SW1V 2SS<br>
			Telephone: 020 7973 6404<br>
			Accounts Fax: 020 7233 5081<br><br>
			Email: creditcontrol@hgluk.com<br>
			
		</td>
	</tr>
	</tbody>
</table>
	
<table style="font-size: 10pt;" width="100%">
	<tbody>
	<tr>
		<td width="1082">INVOICE&nbsp;DATE:&nbsp;<strong>#dateformat(strInvoiceData.qryUserDetails.DateCreated, "dd/mm/yyyy")#</strong></td>
		<td width="278"></td>
	</tr>
	<tr>
		<td>INVOICE&nbsp;NO:&nbsp;<strong>#strInvoiceData.newInvoiceNo#</strong></td>
		<td width="278"></td>
	</tr>
	<cfif Len(strInvoiceData.qryUserDetails.PurchaseOrderNumber)>
	<tr>
	  <td>PURCHASE ORDER: <strong>#strInvoiceData.qryUserDetails.PurchaseOrderNumber#</strong></td>
	  <td></td>
	  </tr>
	  </cfif>
	<tr>
		<td colspan="2"><hr></td>
	</tr>
	</tbody>
</table>

<!--- Invoice address --->

<table style="font-size: 10pt;" width="100%">
	<tbody>
	<tr>
		<td>
			<!-- | EDIT ADDRESS |-->
			<strong>#strInvoiceData.qryUserDetails.forename# #strInvoiceData.qryUserDetails.surname#</strong><br>
			#strInvoiceData.qryUserDetails.companyName#<br>
			#strInvoiceData.qryUserDetails.address1#<br>
			#strInvoiceData.qryUserDetails.address2#<br>
			#strInvoiceData.qryUserDetails.address3#<br>
			#strInvoiceData.qryUserDetails.town#<br>
			#strInvoiceData.qryUserDetails.county#<br>
			#strInvoiceData.qryUserDetails.postcode#<br>
			#strInvoiceData.qryUserDetails.Country#
			<!--| END |-->
		</td>
	</tr>
	</tbody>
</table>

<br>

<table cellpadding="0" cellspacing="0" width="98%" border="0" align="center">
<tr>
	<td><!---INSERT BODY OF INVOICE --->	
  		<table style="font-size: 10pt; font-family:'Courier New', Courier, monospace; border:thin; border-color:##EEEEEE; border-collapse:collapse" width="100%" cellspacing="0" cellpadding="8"  border="1" bordercolor="##EEEEEE">
    		<tbody>
      		<tr bgcolor="##aeb0b2" style="font-family:'Times New Roman', Times, serif; font-weight:bold">
        		<td align="center">QUANTITY</td>
        		<td>DETAILS</td>
        		<td align="center">UNIT&nbsp;COST</td>
        		<td align="right">VAT RATE </td>
        		<td align="right">COST <strong>(GBP)<strong></strong></strong></td>
      		</tr>
      		<cfloop query="strInvoiceData.qryInvoiceDetails">
        	<tr>
          		<td align="center"><strong>#strInvoiceData.qryInvoiceDetails.Quantity#</strong></td>
          		<td><strong>#strInvoiceData.qryInvoiceDetails.Component#</strong></td>
          		<td align="center"><strong>#NumberFormat(strInvoiceData.qryInvoiceDetails.AbsolutePrice, request.strSiteConfig.strvars.mask)#</strong></td>
          		<td align="right"><strong><cfif strInvoiceData.qryInvoiceDetails.isSubjectToFullVAT>S<cfelse>0</cfif></strong></td>
          		<td align="right"><strong>#NumberFormat(strInvoiceData.qryInvoiceDetails.AbsolutePrice, request.strSiteConfig.strvars.mask)#</strong></td>
        	</tr>
      		</cfloop>
      		<tr>
        		<td></td>
        		<td></td>
        		<td align="right" colspan="3">
					<table style="font-size: 10pt; font-family:'Courier New', Courier, monospace" cellpadding="0" cellspacing="0">
          			<tr>
            			<td colspan="3" height="50">&nbsp;</td>
          			</tr>
          			<tr>
            			<td></td>
            			<td colspan="2"><hr width="90%" align="right"></td>
          			</tr>
         
            		<!--- <tr>
              			<td>TOTAL</td>
              			<td><strong>&nbsp;&pound;&nbsp;</strong></td>
              			<td align="right"><strong></strong></td>
            		</tr> --->
            
           			
         
              		<tr>
                		<td>PRE VAT TOTAL </td>
                		<td>&nbsp;&pound;&nbsp;</td>
                		<td align="right"><strong>#NumberFormat(strInvoiceData.qryUserDetails.AbsoluteOrderPrice, request.strSiteConfig.strvars.mask)#</strong></td>
              		</tr>
					
					<tr>
              			<td></td>
              			<td colspan="2"><hr width="90%" align="right"></td>
            		</tr>
			
              		<tr>
                		<td>VAT</td>
                		<td><strong>&nbsp;&pound;&nbsp;</strong></td>
                		<td align="right"><strong>#NumberFormat(strInvoiceData.qryInvoiceDetails.StandardRatedVAT, request.strSiteConfig.strvars.mask)#</strong></td>
              		</tr>
           
            		<tr>
              			<td></td>
              			<td colspan="2"><hr width="90%" align="right"></td>
            		</tr>
         
          			<tr>
            			<td style="font-weight:bolder"><cfif strInvoiceData.qryUserDetails.PaymentMethodID eq 3>TOTAL DUE<cfelse>TOTAL RECEIVED</cfif></td>
            			<td style="font-weight:bolder"><strong>&nbsp;&pound;&nbsp;</strong></td>
            			<td style="font-weight:bolder" align="right">
							<strong>#NumberFormat(strInvoiceData.qryUserDetails.AbsoluteOrderPrice + strInvoiceData.qryInvoiceDetails.StandardRatedVAT, request.strSiteConfig.strvars.mask)#</strong>
						</td>
          			</tr>
          			<tr>
            			<td></td>
            			<td colspan="2"><hr width="90%" align="right"></td>
          			</tr>
        			</table>
				</td>
      		</tr>
    		</tbody>
  		</table>
		<br>
		<br>
		<table width="400" style="font-size: 10pt; font-family:'Courier New', Courier, monospace; color:##666666">
      	<tr>
        	<td width="180"><strong>VAT Analysis</strong></td>
        	<td width="50" align="right"><strong>Rate</strong></td>
        	<td width="75" align="right"><strong>Value</strong></td>
        	<td width="75" align="right"><strong>VAT</strong></td>
      	</tr>
      	<tr>
        	<td colspan="4"><br></td>
      	</tr>
      	<tr>
        	<td>S Standard rated</td>
        	<td align="right">#request.strSiteConfig.strVars.vat_uk# </td>
        	<td align="right">#NumberFormat(strInvoiceData.qryInvoiceDetails.StandardRatedTotal,request.strSiteConfig.strvars.mask)#</td>
        	<td align="right">#NumberFormat(strInvoiceData.qryInvoiceDetails.StandardRatedVAT,request.strSiteConfig.strvars.mask)#</td>
      	</tr>
      	<tr>
        	<td>0 Zero rated</td>
        	<td align="right">0%</td>
        	<td align="right">#NumberFormat(strInvoiceData.qryInvoiceDetails.ZeroRatedTotal, request.strSiteConfig.strvars.mask)#</td>
        	<td align="right">0.00</td>
      	</tr>
      	<tr>
        	<td colspan="4"><hr></td>
      	</tr>
      	<tr>
        	<td>Total</td>
        	<td></td>
        	<td align="right"><strong>#NumberFormat(strInvoiceData.qryUserDetails.AbsoluteOrderPrice, request.strSiteConfig.strvars.mask)#</strong></td>
        	<td align="right"><strong>#NumberFormat(strInvoiceData.qryInvoiceDetails.StandardRatedVAT, request.strSiteConfig.strvars.mask)#</strong></td>
      	</tr>
    	</table>
	  	<br>
	</td>
</tr>
</table>
	
<table style="font-size: 10pt;" cellspacing="0" width="100%">
	<tbody>
	<tr>
		<td colspan="4"><br></td>
	</tr>
	<tr>
		<td width="9%">Bank&nbsp;Transfers&nbsp;to:&nbsp;</td>
		<td colspan="3"><strong>HSBC Bank plc, 117 Great Portland Street, London, W1A 4UY</strong></td>
	</tr>
	<tr>
		<td width="80">Sort&nbsp;Code:&nbsp;</td>
		<td width="260"><strong>40-03-15</strong></td>
		<td width="60">IBAN:</td>
		<td ><strong>GB85 MIDL 4003 1581 2142 25</strong></td>
	</tr>
	<tr>
		<td>Account&nbsp;Number:&nbsp;</td>
		<td><strong>81214225</strong></td>
		<td>BIC:</td>
		<td><strong>MIDLGB2106M</strong></td>
	</tr>
	<tr>
		<td colspan="4" height="5"></td>
	</tr>
	<tr>
		<td colspan="4">&nbsp;</td>
	</tr>
	<cfif strInvoiceData.qryUserDetails.paymentMethodID EQ 3>
		<tr>
			<td colspan="4">Settlement due by return.</td>
		</tr>
		<tr>
			<td colspan="4">Please quote invoice number with your remittance.</td>
		</tr>
	<cfelse>
		<tr>
			<td colspan="4">Payment received with thanks.</td>
		</tr>
	</cfif>		
	</tbody>
</table>
<hr>
<table width="100%" cellpadding="0" cellspacing="0" border="0">
<tr>
	<td><img src="#request.sImgPath#hemlogo_mini.gif" alt="Hemming Group Ltd" border="0"></td>
	<td align="center" style="font-size:6pt">Hemming Group Limited Registered in England No. 490200 - Registered Offices as above - VAT Number GB 342 0234 08</td>
	<td><img src="#request.sImgPath#iip_logo.gif" alt="Investors in People" border="0"></td>
</tr>
</table>
	
</body>
</html>
</cfoutput>