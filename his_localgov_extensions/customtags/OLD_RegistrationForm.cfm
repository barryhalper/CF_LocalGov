<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/customtags/RegistrationForm.cfm $
	$Author: Bhalper $
	$Revision: 2 $
	$Date: 12/10/07 16:28 $

--->
<cfparam name="attributes.action">
<cfparam name="attributes.strSelects">
<cfparam name="attributes.qryUserDetails">
<cfparam name="attributes.mode" 				default="create">
<cfparam name="attributes.SubmitValue" 			default="REGISTER">
<cfparam name="attributes.subscribing" 			default="false">
<cfparam name="attributes.showLoginDetail" 		default="true">
<cfparam name="attributes.strURL.radioclicked" 	default="">
<cfparam name="attributes.strURL.subid"			default="">
<cfparam name="attributes.strForm.accesscode"	default="">
<cfparam name="attributes.strForm.loggedin"		default="">

<!--- Include appropriate javascript function... --->
<cfsavecontent variable="js">
<script type="text/javascript" language="javascript" src="<cfoutput>#request.sJSPath#</cfoutput>subscription.js" ></script>
</cfsavecontent>
<cfhtmlhead text="#js#">

<cfset strSelects = attributes.strSelects>

<cfif attributes.mode eq "create">
	<cfset disabled = "no">
<cfelse>
	<cfset disabled = "yes">
</cfif>

<!--- Note: any new form elements should be added to this list... --->
<cfset lstFields = "ADDRESS1,ADDRESS2,ADDRESS3,COMPANY,CONFIRM1,CONFIRM2,EMAIL,FAX,FORENAME,F_BUDGET_ID,F_CONTACT_SALUTATIONID,F_COUNTRY_ID,F_COUNTY_ID,F_JOBFUNCTION_ID,F_ORGTYPE_ID,F_USERSTATUS_ID,JOBTITLE,PASSWORD,POSTCODE,P_USER_ID,DATECREATED,SECTORS,SURNAME,TEL,TOWN,USERNAME,F_USERTYPE_ID,F_USERSTATUS_ID,ReceiveNewsletter">

<!--- Setup default values or vales supplied by the provided query... --->
<cfif attributes.qryUserDetails.RecordCount GT 0>
	<cfset qryDataSet = attributes.qryUserDetails>
<cfelse>
	<cfset qryDataSet = QueryNew( lstFields )>
</cfif>

<!--- Initialise form fields, defaulting to the query - if present... --->
<cfloop list="#lstFields#" index="Field">
	<cfif StructKeyExists(variables, "qryDataSet")><cfset value = Evaluate("qryDataSet.#Field#")><cfelse><cfset value = ""></cfif>
	<cfparam name="#Field#" default="#value#">
</cfloop>

<!--- Default the user id... --->
<cfif (not Len(P_USER_ID))><cfset P_USER_ID = 0></cfif>

<cfoutput>
<ul class="subsection_container" style="width:96%">	
	<li class="subsection_one" style="width:90%; margin-left:40px">
		<div class="section_box" style="width:91%;">
		<h1>Your Login Details</h1>
		
		
<table width="96%" border="0" align="center" class="text">

<cfform name="frmRegister#attributes.mode#" method="post" action="#attributes.action#" enctype="multipart/form-data" 
	<!--- onsubmit="
		return validateRegistrationForm('frmRegister#attributes.mode#');
	" --->>

<input type="hidden" 	name="subscribing" 			id="subscribing" 		value="#attributes.subscribing#" />
<input type="hidden" 	name="radio_clicked"		id="radio_clicked"		value="#attributes.strURL.radioclicked#" />
<input type="hidden" 	name="hid_subid"			id="hid_subid"			value="#attributes.strURL.subid#" />
<input type="hidden" 	name="invaliduserid"		id="invaliduserid"		value="" />
<input type="hidden"	name="accesscode"			id="accesscode"  		value="#attributes.strForm.accesscode#" />

<cfif attributes.mode eq "create">

<tr>
	<td></td>
	<td>Email&nbsp;address&nbsp;(Username):</td>
	<td>*</td>
	<td colspan="2" valign="middle">
		<cfif attributes.strURL.radioclicked EQ 2 OR attributes.strForm.loggedin EQ 1>
			<cfinput type="text" id="email_id" name="email_readonly" value="#email#" disabled="disabled" size="35" required="yes" validate="email" class="textfield"	
				onBlur="
					CheckUsername(this, '#request.sSitePath#extends/components/services/ajax.cfc?method=CheckUsername&email='+document.getElementById('email_id').value );
				">
			<cfinput type="hidden" id="email_id" name="email"	value="#email#">
		<cfelse>
			<cfinput type="text" id="email_id" name="email" value="#email#" size="32" required="yes" validate="email" class="textfield"	
				onBlur="
					CheckUsername(this, '#request.sSitePath#extends/components/services/ajax.cfc?method=CheckUsername&email='+document.getElementById('email_id').value );
				">
		</cfif>
		<span id="results" class="smtext" style="color:##0000FF"></span>
	</td>
</tr>
<tr>
	<td></td>
	<td>Password:</td>
	<td></td>
	<td colspan="2" class="smaller"><em>The system will generate and email a password if you are a new user. You will be able to change this when you login for the first time.</em></td>
</tr>

<cfelse>
	
	<cfif not attributes.showLoginDetail>
		<tr>
			<td></td>
			<td>Email&nbsp;address&nbsp;(Username):</td>
			<td>*</td>
			<td colspan="2" valign="middle">
				<cfinput type="text" id="email" name="email" size="32" required="yes" validate="email" value="#email#" class="textfield" >
			</td>
		</tr>
		<input type="hidden" name="remember" value="" />
	<cfelse>
	<tr>
		<td colspan="4"></td>
		<td rowspan="8" align="center">
			
			<table width="85%" border="0" cellspacing="0" class="text" ><tr><td align="center" valign="middle">
			<br /><br />
			<input type="button" name="submit" id="subUpdate" class="smtext" value="Update Username" style="height:30px; font-weight:bold;" 
				onClick=" 
					UpdateUsername( '#request.sSitePath#extends/components/services/ajax.cfc?method=UpdateUsername&email=#session.UserDetails.Username#')	
				">
			<br /><br />
			<input type="button" name="submit" id="subUpdate" class="smtext" value="Update Password" style="height:30px; font-weight:bold;" 
				onClick=" 
					UpdatePassword( '#request.sSitePath#extends/components/services/ajax.cfc?method=UpdatePassword&email=#session.UserDetails.Username#')	
				">
			<br /><br />
			</td></tr></table>

			<table width="85%" border="0" cellspacing="0" class="text" ><tr><td align="center" valign="middle">
			<tr><td id="results" align="center" valign="middle"></td></tr>
			<tr><td></td></tr></table>
			
		</td>
	</tr>
	<tr>
		<td></td>
		<td>New Username / Email</td>
		<td></td>
		<td align="left"><cfinput id="nun1" type="text" name="newun1" class="smaller" size="25"></td>
		<td></td>
	</tr>
	<tr>
		<td></td>
		<td>Confirm&nbsp;New&nbsp;Username:</td>
		<td></td>
		<td align="left"><cfinput id="nun2" type="text" name="newun2" class="smaller" size="25"></td>
		<td></td>
	</tr>
	<tr><td colspan="4"><hr /></td><td></td></tr>
	<tr>
		<td></td>
		<td>New Password: </td>
		<td></td>
		<td align="left"><cfinput id="npw1" type="password" name="newpw" class="smaller" size="25"></td>
		<td></td>
	</tr>
	<tr>
		<td></td>
		<td>Confirm&nbsp;New&nbsp;Password:</td>
		<td></td>
		<td align="left"><cfinput id="npw2" type="password" name="newpw2" class="smaller" size="25"></td>
		<td></td>
	</tr>
	<tr><td colspan="4"><hr /></td><td></td></tr>
	<tr>
		<td></td>
		<td>Remember Me?</td>
		<td></td>
		<td align="left">
			
			<input type="checkbox" name="remember" value="1" #iif( StructKeyExists(cookie, "UserID"), de("checked"), de("") )# 
				onclick="
					RememberMe( '#request.sSitePath#extends/components/services/ajax.cfc?method=', this.checked );
				">
			
		</td></tr>
		<td></td>
	</tr>
	</cfif>
</cfif>

</table>

		</div>
	</li>
</ul>


<ul class="subsection_container" style="width:96%">	
	<li class="subsection_one" style="width:90%; margin-left:40px">
		<div class="section_box" style="width:91%;">
		<h1>Your Contact Details</h1>
		<cfif attributes.mode eq "create">
		<p class="text"><strong>Please enter your contact details.</strong> * denotes required fields.</p>
		<cfelse>
		<p class="text">If you wish to change your contact details, please <a href="<cfoutput>#request.myself#</cfoutput>home.copy&id=40942">contact
	      us </a>and we can update our database.</p>
		</cfif>
		
		<table width="96%" border="0"  align="center" bgcolor="" class="text">
<cfinput type="hidden" name="p_user_id" required="no" value="#P_USER_ID#"></td>

<tr><td></td><td>Name:</td>				<td>*</td>
	<td>
	<cfoutput><cfselect name="f_contact_salutationID" required="no" class="dropbox">
	<cfloop from="1" to="#strSelects.qrySalutations.RecordCount#" index="i">
	<option value="#strSelects.qrySalutations.p_Salutation_id[i]#" #iif( f_contact_salutationID eq strSelects.qrySalutations.p_Salutation_id[i], de("selected"), de("") )# >#strSelects.qrySalutations.Salutation[i]#</option>
	</cfloop></cfselect></cfoutput>
	<cfinput type="text" name="forename"  style="width:60px" required="yes" class="textfield" value="#forename#"> 
	<cfinput type="text" name="surname"  style="width:100px"	required="yes" class="textfield" value="#surname#"></td></tr>  

<tr><td></td><td>Job Title:</td>		<td>*</td>	<td><cfinput type="text" name="jobtitle"  size="20"	required="yes" class="textfield" value="#jobtitle#"> </td></tr>  
<tr><td></td><td>Organisation/Company Name:</td><td>*</td><td><cfinput type="text" name="company"  size="40"	required="yes" class="textfield" value="#company#"> </td></tr>  

<tr><td></td><td>Postcode:</td>			<td>*</td><td><cfinput type="text" name="Postcode" size="10" required="yes" class="textfield" value="#postcode#"><!---  <span class="smtext" onclick="alert('QAS Functionality to be developed');" onmouseover="cursor:pointer" style="color:##999999"><strong>Find address</strong></span> ---></td></tr>  
<tr><td></td><td>Address&nbsp;1:</td>	<td>*</td><td><cfinput type="text" name="address1" size="45" required="yes" class="textfield" value="#address1#"></td></tr>
<tr><td></td><td>Address 2:</td>		<td></td><td><cfinput type="text" name="address2" size="45" required="no" class="textfield" value="#address2#"></td></tr>
<tr><td></td><td>Address&nbsp;3:</td>	<td></td><td><cfinput type="text" name="address3" size="45" required="no" class="textfield" value="#address3#"></td></tr>
<tr><td></td><td>Town:</td>				<td></td><td><cfinput type="text" name="town" 			required="no" class="textfield" value="#town#"></td></tr> 
<tr><td></td><td>County:</td>			<td></td>
	<td>
	<cfoutput><cfselect name="f_county_id" required="no" class="dropbox">
	<option value="0">Please select...</option>
	<cfloop from="1" to="#strSelects.qryCounties.RecordCount#" index="i">
	<option value="#strSelects.qryCounties.countyid[i]#" #iif( f_county_id eq strSelects.qryCounties.countyid[i], de("selected"), de("") )#>#strSelects.qryCounties.county[i]#</option>
	</cfloop></cfselect></cfoutput>	</td>
</tr>  
<tr><td></td><td>Country:</td>		<td>*</td>
	<td>
	<cfoutput><cfselect name="f_country_id" id="f_country_id" required="yes" class="dropbox">
	<option value="">Please select...</option>
	<cfloop from="1" to="#strSelects.qryCountries.RecordCount#" index="i">
	<option value="#strSelects.qryCountries.p_country_id[i]#" #iif( f_country_id eq strSelects.qryCountries.p_country_id[i], de("selected"), de(iif(strSelects.qryCountries.p_country_id[i] eq 1, de("selected"), de(""))))#>#strSelects.qryCountries.country[i]#</option>
	</cfloop></cfselect></cfoutput>	</td>
</tr>  

<tr><td></td><td>Tel No. <em class="smaller">(no spaces)</em>:</td>	<td>*</td><td><cfinput type="text" name="tel" 	 size="14" message="Please enter a valid telephone number." maxlength="20" required="yes" class="textfield" value="#tel#"></td></tr>  
<tr><td></td><td>Fax No. <em class="smaller">(no spaces)</em>:</td>	<td></td><td><cfinput type="text" name="fax" 	 size="14"		required="no" class="textfield" value="#fax#"></td></tr>  

<tr><td></td><td>Job Function:</td>		<td></td>	
	<td>
	<cfoutput><cfselect name="f_jobfunction_id" required="no" class="dropbox">
	<option value="0">Please select...</option>
	<cfloop from="1" to="#strSelects.qryJobFunctions.RecordCount#" index="i">
	<option value="#strSelects.qryJobFunctions.p_jobfunction_id[i]#" #iif( f_jobfunction_id eq strSelects.qryJobFunctions.p_jobfunction_id[i], de("selected"), de("") )#>#strSelects.qryJobFunctions.Job_Function[i]#</option>
	</cfloop></cfselect></cfoutput>	</td>
</tr>  

<tr><td></td><td>Organisation Type:</td>		<td></td>	
	<td>
	<cfoutput><cfselect name="f_orgtype_id" required="no" class="dropbox">
	<option value="0">Please select...</option>
	<cfloop from="1" to="#strSelects.qryOrgTypes.RecordCount#" index="i">
	<option value="#strSelects.qryOrgTypes.p_orgtype_id[i]#" #iif( f_orgtype_id eq strSelects.qryOrgTypes.p_orgtype_id[i], de("selected"), de("") )#>#strSelects.qryOrgTypes.OrganisationType[i]#</option>
	</cfloop></cfselect></cfoutput>	</td>
</tr>  

<tr><td></td><td>Departmental spend or what<br />budget do you control?:</td>		<td></td>	
	<td>
	<cfoutput><cfselect name="f_budget_id" required="no" class="dropbox">
	<option value="0">Please select...</option>
	<cfloop from="1" to="#strSelects.qryBudgets.RecordCount#" index="i">
	<option value="#strSelects.qryBudgets.p_budget_id[i]#" #iif( f_budget_id eq strSelects.qryBudgets.p_budget_id[i], de("selected"), de("") )#>#strSelects.qryBudgets.Range[i]#</option>
	</cfloop></cfselect></cfoutput>	</td>
</tr>
<cfif attributes.mode NEQ "create">
<tr>
  <td></td>
  <td>Receive Newsletter </td>
  <td></td>
  <td><cfif ReceiveNewsletter>
  <cfinput name="ReceiveNewsletter" id="ReceiveNewsletter" type="checkbox" value="1" checked >
  <cfelse>
  <cfinput name="ReceiveNewsletter" id="ReceiveNewsletter" type="checkbox" value="1">
  </cfif></td>
</tr>  
<cfelse>
	<cfinput name="ReceiveNewsletter" id="ReceiveNewsletter" type="hidden" value="1">
</cfif>
</table>
		</div>
	</li>
</ul>

<ul class="subsection_container" style="width:96%">	
	<li class="subsection_one" style="width:90%; margin-left:40px">
		<div class="section_box" style="width:91%;">
		<h1>Your Interests</h1>
		<p class="text"><strong>Please select all the sectors that are relevant to you.</strong></p>
		<cf_admin_sectors 
			formname=	"frmRegister#attributes.mode#"
			mode=		"normal"
			class=		"smaller"
			sectors=	"#qryDataSet.sectors#">
			
		</div>
	</li>
</ul>

<ul class="subsection_container" style="width:96%">	
	<li class="subsection_one" style="width:90%; margin-left:40px">
		<div class="section_box" style="width:91%">
		<h1><a name="confirm">Confirmation</h1>

<table width="100%" border="0" class="text" align="center">
 
<cfif attributes.mode eq "create" OR attributes.SubmitValue EQ "DELETE USER" OR attributes.SubmitValue EQ "REACTIVATE USER" OR attributes.SubmitValue EQ "UPDATE DETAILS">

<cfif attributes.mode eq "create" OR attributes.SubmitValue EQ "DELETE USER" OR attributes.SubmitValue EQ "REACTIVATE USER">

<tr><td></td><td colspan="3">
	<strong>Please tick to confirm that you wish to receive access to www.localgov.co.uk </strong>
	<cfset Confirm1Message = "Please tick the confirmation box stating that you wish to receive access to www.localgov.co.uk.">
	<cfif confirm1 eq 1 >
		<cfinput name="confirm1" type="checkbox" value="1" checked required="yes" message="#Confirm1Message#">
	<cfelse>
		<cfinput name="confirm1" type="checkbox" value="1" required="yes" message="#Confirm1Message#">
	</cfif>
	<br />
	<!--- <a href="javascript:showText('confirm1_more');">Click here for more info</a> --->
	<div id="confirm1_more" style="display:inline"  align="justify">
	<span class="medium">For Audit purposes we would usually ask you to sign and date an application card to confirm that you wish to receive access to LocalGov.co.uk and validate your request. As we cannot collect signatures online, please answer the following question.
	<br />
	In which month were you born? * &nbsp;</span>
	<!--- <cfinput name="countyborn" type="text" value="" size="10" required="yes" message="Please enter the Personal Identifier question"> --->	
	<cfset lstMonths= "January,February,March,April,May,June,July,August,September,October,November,December">
	
	<cfselect name="countyborn" required="yes" class="dropbox">
		<cfloop list="#lstMonths#" index="i">
		<option value="#i#">#i#</option>
		</cfloop>
	</cfselect>
	
	<br />	
	<em class="medium">*We cannot process your registation without this information</em>
	</p></div>
	<hr size="1" noshade="noshade" />
	</td>
</tr>  

<tr valign="top"><td></td><td colspan="3" class="medium">
<strong>If you specifically do not wish your details to be passed to third parties please tick here:</strong>
<cfif confirm2 eq 1 >
	<cfinput name="confirm2" type="checkbox" value="1" checked>
<cfelse>
	<cfinput name="confirm2" type="checkbox" value="1">
</cfif>

<br />
<cfsavecontent variable="js2">
<script type="text/javascript" language="javascript">
function showText(objName)  {
	setTimeout("document.getElementById('"+objName+"').style.display='inline';",1);
}
</script>
</cfsavecontent>
<cfhtmlhead text="#js2#">

<a href="javascript:showText('confirm2_more');">Click here for more info</a>
<div id="confirm2_more" style="display:none"  align="justify">
<br />
<p>
	We will keep you informed of Hemming Information Services’ products and services, including information about LocalGov.co.uk via post, by email and/or telephone. 
	<br /><br />
	If at any point you wish to advise us of any changes to your opt out, please write to Customer Services at Hemming Information Services, 32 Vauxhall Bridge Road, London, SW1V 2SS or email customer@hgluk.com
</p>
</div>

</td></tr>
</cfif>
<tr><td colspan="4" align="center"><br /><cfinput type="submit" name="submitReg" id="submitReg" value="#attributes.SubmitValue#" style="width:190; height:50; font-weight:bold; font-size:16px"><BR /><BR /></td></tr>

</cfif>

<cfloop list="#lstFields#" index="Field">
	<cfif StructKeyExists(variables, "qryDataSet")>
		<cfset hidvalue = Evaluate("qryDataSet.#Field#")>
	<cfelse>
		<cfset hidvalue = "">
	</cfif>
	<cfinput type="hidden" name="hid_#Field#" value="#hidvalue#">
</cfloop>

</cfform>

</td></tr></table> 
		</div>
	</li>
</ul>

<!--- If we are in edit mode, ensure certain fields are disabled... --->
<cfif attributes.mode neq "create">
	<script type="text/javascript" language="javascript">
	var objElems = frmRegister#attributes.mode#.elements;
	// Loop through all form elements and disable...
	for(i=0;i<objElems.length;i++) {
		if (objElems[i].name != 'newpw' && objElems[i].name != 'newpw2' 
			&& objElems[i].name != 'submit' && objElems[i].name != 'remember' 
			&& objElems[i].value != 'DELETE USER' && objElems[i].value != 'REACTIVATE USER' 
			&& objElems[i].value != 'UPDATE DETAILS'
			&& objElems[i].name != 'p_user_id' 
			&& objElems[i].name != 'ReceiveNewsletter' 
			&& objElems[i].name != 'Sectors' 
			&& objElems[i].name != 'newun1' && objElems[i].name != 'newun2')
			objElems[i].disabled = true;
	}
	frmRegister#attributes.mode#.remember.disabled=false;
	</script>
</cfif>

</cfoutput>