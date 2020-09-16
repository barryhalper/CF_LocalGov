<cfparam name="attributes.description" 	   default="LocalGov.co.uk - MYB List Rental ServicesS">
<cfparam name="attributes.Orderid" 	   	   >
<cfparam name="attributes.invoiceFileName" default="">
<cfparam name="attributes.invoiceId" 	   default="">
<cfparam name="attributes.amounttxt" 	   default="">
<cfparam name="attributes.total" 	   	   default="0">
<cfparam name="attributes.isForEmail" 	   type="boolean" default="false">
<cfparam name="attributes.xfa_viewInvoice"  default="">
<cfparam name="attributes.copy"  			default="">


<cfscript>
If (attributes.description CONTAINS "List Rental"){
	TandCtext = "Our terms and conditions:";
	TandC	 = request.strSiteConfig.strVArs.ds_TandC;
	confirmtxt	= "our list rental terms and conditions";
	}
else{
	TandCtext = "Our returns policy:" ;
	TandC	 = request.strSiteConfig.strVArs.book_returns_policy;
	confirmtxt	= Lcase(TandCtext);
	}
</cfscript>

<cfoutput>

<div class="bodytext" style="width:600px;">
<cfif attributes.isForEmail >
	<cfif StructKeyExists(session, "qryuserdetails")><cfif Len(session.qryuserdetails.forename)>
	Dear #session.qryuserdetails.forename#,</cfif></cfif><br><br>Thank you for placing an order on <a href="http://www.locagov.co.uk">www.localgov.co.uk</a><br>
	<br>
	Please find below your order summary and our #confirmtxt#<br><br>If you any questions or queries relating to this order please do not hesitate to contact us at <a href="mailto:customer@hgluk.com">customer@hgluk.com</a> or on +44 (0) 207 973 6694.<br>
	<br>Kind regards,<br><br>Customer Services Team
</cfif>

<div align="center">
	<strong class="text" style="color:##0000FF; font-size:16px"><cfif NOT attributes.isForEmail>Thank you!</cfif></strong>
	<br /><br />
	#attributes.description#
	<br /><br /><cfif len(attributes.copy)>#attributes.copy#<br />
<br />
</cfif>
</div>
<div align="center">

<table border="1" width="450" align="center" cellspacing="0" cellpadding="0" bordercolor="##184693" >
	<tr>
		<td>
			<table border="0" width="100%" align="center" class="smaller">
				<tr>
					<td align="center"  style="color:##FFFFFF; font-size:17px" bgcolor="##184693"><strong>Order Summary</strong></td>
				</tr>
			</table>
			<table class="smaller" width="100%">
				<tr>
					<td>Order Description:</td>
					<td><strong>#attributes.description#</strong></td>
					<td align="right"><div align="right" class="smtext"></div></td>
				</tr>
				<tr>
					<td>Order ID:</td>
					<td colspan="2"><strong>#attributes.Orderid#</strong></td>
				</tr>
				<tr>
					<td>#attributes.amounttxt#</td>
					<td colspan="2"><strong>&pound;#NumberFormat(attributes.total,request.mask)# (inc. VAT)</strong></td>
				</tr>
				<tr>
					<td>Invoice number:</td>
					<td><strong>#attributes.invoiceID#</strong> <cfif NOT attributes.IsForEmail and Len(attributes.invoiceFileName)> (<a href="javascript:;" onClick="window.open('#request.myself##attributes.xfa_viewInvoice#&amp;invoiceFilename=#attributes.invoiceFileName#',null,'width=850,height=950,status=no,toolbar=no'); " title="Click to view your invoice"><strong>view invoice</strong></a>)<cfelse>Please see the attached Invoice</cfif></td>
				</tr>
			</table>
		</td>
	</tr>
</table>

</div>
<br />
<br />
<div align="center">
 #TandCtext#
			<br><br>
			<div align="left" style="width:630px; height:100px; overflow:auto;background-color:##EEEEEE; padding:6px">
			<!--- #qryToCcopy.story# --->
			#TandC#
			</div></div>

<br />
<br />
<span class="medium">
If you have any questions about your order (including refunds, delivery status, wanting to cancel your order), 
please email Hemming Group Ltd at: <a href="mailto:#request.strSiteConfig.strVars.customerservices#">Customer Services</a>, with the transaction details listed above.
Thank you for shopping with Hemming Group Ltd.
</span>

</div><br />
<br />


</cfoutput>