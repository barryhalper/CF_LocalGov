
<!--- Include appropriate javascript function... --->
<cfsavecontent variable="js">
	<script type="text/javascript" language="javascript" src="<cfoutput>#request.sJSPath#</cfoutput>users_ajax.js" ></script>
	<script type="text/javascript" language="javascript" src="<cfoutput>#request.sJSPath#</cfoutput>subscription.js" ></script>
</cfsavecontent>

<cfhtmlhead text="#js#">

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


<cfoutput>

<h1>Register</h1>
<br clear="all" />
<div id="articlemain">
	<div id="subscribe">
	
		<!--- Only show Registration form if user is registering for first time or if user is editing
			existing details --->
		<!--- <cfif (StructKeyExists(session.UserDetails, "UserID") AND NOT(attributes.loggedin))>
			<div class="subscribe">
				<div class="subpadding">
					<p>You are already registered.</p>
				</div>
			</div>
		
		<cfelse> --->
		
			<cfif NOT StructKeyExists(session.UserDetails, "UserID")>
				<p>
					Registration to LocalGov.co.uk is free and allows you to get so much more from the site, including 
					e-mail alerts, a comprehensive recruitment and careers section, details of events in the local 
					government sector plus Need 2 Know and Govepedia. <br /><br/>
			
					Fill in the form and you will be e-mailed a password to access the site. Once logged in, you can 
					change this password to something more memorable.
				</p>
			</cfif>

		
			<cfset strSelects = attributes.strSelects>
			
			<cfif attributes.mode eq "create">
				<cfset disabled = "no">
			<cfelse>
				<cfset disabled = "yes">
			</cfif>
			
			<!--- Note: any new form elements should be added to this list... --->
			<cfset lstFields = "ADDRESS1,ADDRESS2,ADDRESS3,COMPANYNAME,CONFIRM1,CONFIRM2,EMAIL,FAX,FORENAME,BUDGETID,CONTACTSALUTATIONID,COUNTRYID,COUNTYID,JOBFUNCTIONID,ORGTYPEID,JOBTITLE,PASSWORD,POSTCODE,USERID,DATECREATED,SECTORS,SURNAME,TEL,TOWN,USERNAME,USERTYPEID,ReceiveNewsletter">
			
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
			<cfif (not Len(UserID))><cfset UserID = 0></cfif>
		
			<!--- Only show Registration form if user is registering for first time or if user is editing
			existing details
			<cfif not StructKeyExists(session.UserDetails, "UserID") OR attributes.loggedin> --->
				
			
		    <h2>1. Your Login Details</h2>
		    <div class="subscribe" <cfif attributes.mode NEQ "create">style="width:582px;"</cfif>>
				<div class="subpadding">
					<table border="0" align="center">
						
					<cfform name="frmRegister#attributes.mode#" id="frmRegister#attributes.mode#" method="post" action="#attributes.action#" enctype="multipart/form-data" ><!--- onsubmit="return validateRegistrationForm('frmRegister#attributes.mode#');" --->
						<!---  --->		
						<input type="hidden" 	name="subscribing" 			id="subscribing" 		value="#attributes.subscribing#" />
						<input type="hidden" 	name="radio_clicked"		id="radio_clicked"		value="#attributes.strURL.radioclicked#" />
						<input type="hidden" 	name="hid_subid"			id="hid_subid"			value="#attributes.strURL.subid#" />
						<input type="hidden" 	name="invaliduserid"		id="invaliduserid"		value="" />
						<input type="hidden"	name="accesscode"			id="accesscode"  		value="#attributes.strForm.accesscode#" />
						<!--- <cfif StructKeyExists(session.UserDetails, "UserID")><input type="hidden" name="userid" id="userid" value="#session.UserDetails.userid#" /></cfif> --->
						
						<cfif attributes.mode eq "create">
						
							<tr>
								<td>&nbsp;</td>
								<td>Email&nbsp;address&nbsp;(Username):</td>
								<td>*</td>
								<td colspan="2" valign="middle">
									<cfif attributes.strURL.radioclicked EQ 2 OR attributes.strForm.loggedin EQ 1>
										<cfinput type="text" id="email_id" name="email_readonly" value="#email#" disabled="disabled" size="35" required="yes" validate="email" class="textfield" onBlur="CheckUsername(this, '#request.sSitePath#extends/components/services/ajax.cfc?method=CheckUsername&email='+document.getElementById('email_id').value );">
										<cfinput type="hidden" id="email_id" name="email" value="#email#">
									<cfelse>
										<cfinput type="text" id="email_id" name="email" value="#email#" size="32" required="yes" validateat="onsubmit" validate="email" class="textfield"	onBlur="CheckUsername(this, '#request.sSitePath#extends/components/services/ajax.cfc?method=CheckUsername&email='+document.getElementById('email_id').value );">
									</cfif>
									<span id="results" class="smtext" style="color:##0000FF"></span>
								</td>
							</tr>
							
							<tr>
								<td>&nbsp;</td>
								<td>Re-type email:</td>
								<td>&nbsp;</td>
								<td colspan="2">
									<cfif attributes.strURL.radioclicked EQ 2 OR attributes.strForm.loggedin EQ 1>
									<cfelse>
										<cfinput type="text" id="chkemail_id" name="chkemail" value="" size="32" required="yes" class="textfield" onBlur="CheckEMatch('chkemail_id', 'email_id');">
									</cfif>
								</td>
							</tr>
							
							<tr>
								<td>&nbsp;</td>
								<td>Password:</td>
								<td>&nbsp;</td>
								<td colspan="2"><span style="font-size:12px;font-style:italic;">The system will generate and email a password if you are a new user. You will be able to change this when you login for the first time.</span></td>
							</tr>
			
						<cfelse>
				
							<cfif not attributes.showLoginDetail>
								<tr>
									<td>&nbsp;</td>
									<td>Email&nbsp;address&nbsp;(Username):</td>
									<td>*</td>
									<td colspan="2" valign="middle">
										<cfinput type="text" id="email" name="email" size="32" required="yes" validate="email" value="#email#" class="textfield" >
									</td>
								</tr>
								<input type="hidden" name="remember" value="" />
							<cfelse>
								<tr>
									<td colspan="4">&nbsp;</td>
									<td rowspan="8" align="left">
										<table width="75%" border="0" cellspacing="0">
										<tr>
											<td align="left"><!--- style="height:30px; font-weight:bold;" --->
												
												<input type="image" src="#request.strSiteConfig.strPaths.assets#/furniture/upduser.gif" name="submit" id="subUpdate" style="position:relative;top:-10px;"
													onClick="UpdateUsername( '#request.sSitePath#extends/components/services/ajax.cfc?method=UpdateUsername&email=#session.UserDetails.Username#');return false;">
												
												<input type="image" src="#request.strSiteConfig.strPaths.assets#/furniture/updpass.gif" name="submit" id="subUpdate" style="position:relative;top:65px;"
													onClick="UpdatePassword( '#request.sSitePath#extends/components/services/ajax.cfc?method=UpdatePassword&email=#session.UserDetails.Username#');return false;">
												
											</td>
										</tr>
										</table>
							
										<table width="85%" border="0" cellspacing="0">
										<tr><td align="center" valign="middle">
										<tr><td id="results" align="center" valign="middle"></td></tr>
										<tr><td>&nbsp;</td></tr>
										</table>
									</td>
								</tr>
								<tr>
									<td>&nbsp;</td>
									<td>New Username / Email</td>
									<td>&nbsp;</td>
									<td align="left"><cfinput id="nun1" type="text" name="newun1" class="smaller" size="25"></td>
									<td>&nbsp;</td>
								</tr>
								<tr>
									<td>&nbsp;</td>
									<td>Confirm&nbsp;New&nbsp;Username:</td>
									<td>&nbsp;</td>
									<td align="left"><cfinput id="nun2" type="text" name="newun2" class="smaller" size="25"></td>
									<td>&nbsp;</td>
								</tr>
								<tr><td colspan="4"><hr /></td><td>&nbsp;</td></tr>
								<tr>
									<td>&nbsp;</td>
									<td>New Password: </td>
									<td>&nbsp;</td>
									<td align="left"><cfinput id="npw1" type="password" name="newpw" class="smaller" size="25"></td>
									<td>&nbsp;</td>
								</tr>
								<tr>
									<td>&nbsp;</td>
									<td>Confirm&nbsp;New&nbsp;Password:</td>
									<td>&nbsp;</td>
									<td align="left"><cfinput id="npw2" type="password" name="newpw2" class="smaller" size="25"></td>
									<td>&nbsp;</td>
								</tr>
								<tr>
									<td colspan="4"><hr /></td>
									<td>&nbsp;</td>
								</tr>
								<tr>
									<td>&nbsp;</td>
									<td>Remember Me?</td>
									<td>&nbsp;</td>
									<td align="left">
										
										<input type="checkbox" name="remember" value="1" #iif( StructKeyExists(cookie, "UserID"), de("checked"), de("") )# 
											onclick="
												RememberMe( '#request.sSitePath#extends/components/services/ajax.cfc?method=', this.checked );
											">
										
									</td>
									<td>&nbsp;</td>
								</tr>
							</cfif>
						</cfif>
			
					</table>
			
				</div>
			</div>
			
		    <h2>2. Your Contact Details</h2>
			<div class="subscribe" <cfif attributes.mode NEQ "create">style="width:582px;"</cfif>>
				<div class="subpadding">
					
					<cfif attributes.mode eq "create">
						<p><strong>Please enter your contact details.</strong> * denotes required fields.</p>
					<cfelse>
						<p>
							If you wish to change your details please do so using the form below.
						</p>
					</cfif>
					
					<table width="96%" border="0"  align="center" bgcolor="" class="text">
						
						<cfinput type="hidden" name="UserID" required="no" value="#UserID#"></td>
						
						<tr>
							<td>&nbsp;</td>
							<td>Name:</td>
							<td>*</td>
							<td>
								<cfselect name="ContactSalutationID" required="no">
									<cfloop from="1" to="#strSelects.qrySalutations.RecordCount#" index="i">
										<option value="#strSelects.qrySalutations.p_Salutation_id[i]#" #iif( ContactSalutationID eq strSelects.qrySalutations.p_Salutation_id[i], de("selected"), de("") )# >#strSelects.qrySalutations.Salutation[i]#</option>
									</cfloop>
								</cfselect>
								<cfinput type="text" name="forename"  style="width:60px" required="yes" class="textfield" value="#forename#"> 
								<cfinput type="text" name="surname"  style="width:100px"	required="yes" class="textfield" value="#surname#">
							</td>
						</tr>  
						
						<tr>
							<td>&nbsp;</td>
							<td>Job Title:</td>		
							<td>*</td>	
							<td><cfinput type="text" name="jobtitle"  size="20"	required="yes" class="textfield" value="#jobtitle#"></td>
						</tr>  
						
						<tr>
							<td>&nbsp;</td>
							<td>Organisation/Company Name:</td>
							<td>*</td>
							<td><cfinput type="text" name="companyName"  size="40"	required="yes" class="textfield" value="#companyName#"> </td>
						</tr>  
						
						<tr>
							<td>&nbsp;</td>
							<td>Postcode:</td>			
							<td>*</td>
							<td><cfinput type="text" name="Postcode" size="10" required="yes" class="textfield" value="#postcode#"><!---  <span class="smtext" onclick="alert('QAS Functionality to be developed');" onmouseover="cursor:pointer" style="color:##999999"><strong>Find address</strong></span> ---></td>
						</tr>  
						
						<tr>
							<td>&nbsp;</td>
							<td>Address&nbsp;1:</td>	
							<td>*</td>
							<td><cfinput type="text" name="address1" size="45" required="yes" class="textfield" value="#address1#"></td>
						</tr>
						
						<tr>
							<td>&nbsp;</td>
							<td>Address 2:</td>		
							<td>&nbsp;</td>
							<td><cfinput type="text" name="address2" size="45" required="no" class="textfield" value="#address2#"></td></tr>
							
						<tr>
							<td>&nbsp;</td>
							<td>Address&nbsp;3:</td>	
							<td>&nbsp;</td>
							<td><cfinput type="text" name="address3" size="45" required="no" class="textfield" value="#address3#"></td></tr>
							
						<tr>
							<td>&nbsp;</td>
							<td>Town:</td>				
							<td>&nbsp;</td>
							<td><cfinput type="text" name="town" required="no" class="textfield" value="#town#"></td>
						</tr>
						 
						<tr>
							<td>&nbsp;</td>
							<td>County:</td>			
							<td>&nbsp;</td>
							<td>
								<cfselect name="CountyID" id="CountyID" required="no">
									<option value="0">Please select...</option>
									<cfloop from="1" to="#strSelects.qryCounties.RecordCount#" index="i">
										<option value="#strSelects.qryCounties.countyid[i]#" #iif(CountyID eq strSelects.qryCounties.countyid[i], de("selected"), de("") )#>#strSelects.qryCounties.county[i]#</option>
									</cfloop>
								</cfselect>
							</td>
						</tr>  
						
						<tr>
							<td>&nbsp;</td>
							<td>Country:</td>		
							<td>*</td>
							<td>
								<cfselect name="CountryID" id="CountryID" required="yes">
									<option value="">Please select...</option>
									<cfloop from="1" to="#strSelects.qryCountries.RecordCount#" index="i">
										<option value="#strSelects.qryCountries.p_country_id[i]#" #iif(CountryID eq strSelects.qryCountries.p_country_id[i], de("selected"), de(iif(strSelects.qryCountries.p_country_id[i] eq 1, de("selected"), de(""))))#>#strSelects.qryCountries.country[i]#</option>
									</cfloop>
								</cfselect>
							</td>
						</tr>  
						
						<tr>
							<td>&nbsp;</td>
							<td>Tel No. <em class="smaller">(no spaces)</em>:</td>	
							<td>*</td>
							<td>
								<cfinput type="text" name="tel" size="14" message="Please enter a valid telephone number." maxlength="20" required="yes" class="textfield" value="#tel#">
							</td>
						</tr>  
						<tr>
							<td>&nbsp;</td>
							<td>Fax No. <em class="smaller">(no spaces)</em>:</td>	
							<td>&nbsp;</td>
							<td><cfinput type="text" name="fax" size="14" required="no" class="textfield" value="#fax#"></td>
						</tr>  
						
						<tr>
							<td>&nbsp;</td>
							<td>Job Function:</td>		
							<td>&nbsp;</td>	
							<td>
								<cfselect name="JobFunctionID" required="no">
									<option value="0">Please select...</option>
									<cfloop from="1" to="#strSelects.qryJobFunctions.RecordCount#" index="i">
										<option value="#strSelects.qryJobFunctions.p_jobfunction_id[i]#" #iif(JobFunctionID eq strSelects.qryJobFunctions.p_jobfunction_id[i], de("selected"), de("") )#>#strSelects.qryJobFunctions.Job_Function[i]#</option>
									</cfloop>
								</cfselect>
							</td>
						</tr>  
						
						<tr>
							<td>&nbsp;</td>
							<td>Organisation Type:</td>		
							<td>&nbsp;</td>	
							<td>
								<cfselect name="OrgTypeID" required="no">
									<option value="0">Please select...</option>
									<cfloop from="1" to="#strSelects.qryOrgTypes.RecordCount#" index="i">
										<option value="#strSelects.qryOrgTypes.p_orgtype_id[i]#" #iif(OrgTypeID eq strSelects.qryOrgTypes.p_orgtype_id[i], de("selected"), de("") )#>#strSelects.qryOrgTypes.OrganisationType[i]#</option>
									</cfloop>
								</cfselect>
							</td>
						</tr>  
						
						<tr>
							<td>&nbsp;</td>
							<td>Departmental spend or what<br />budget do you control?:</td>		
							<td>&nbsp;</td>	
							<td>
								<cfselect name="BudgetID" required="no">
									<option value="0">Please select...</option>
									<cfloop from="1" to="#strSelects.qryBudgets.RecordCount#" index="i">
										<option value="#strSelects.qryBudgets.p_budget_id[i]#" #iif(BudgetID eq strSelects.qryBudgets.p_budget_id[i], de("selected"), de("") )#>#strSelects.qryBudgets.Range[i]#</option>
									</cfloop>
								</cfselect>
							</td>
						</tr>
						
						<cfif attributes.mode NEQ "create">
							<tr>
						  		<td>&nbsp;</td>
							  	<td>Receive Newsletter </td>
							  	<td>&nbsp;</td>
							  	<td>
								  	<cfif ReceiveNewsletter>
							  			<cfinput name="ReceiveNewsletter" id="ReceiveNewsletter" type="checkbox" value="1" checked >
							  		<cfelse>
							  			<cfinput name="ReceiveNewsletter" id="ReceiveNewsletter" type="checkbox" value="1">
							  		</cfif>
								</td>
							</tr>  
						<cfelse>
							<cfinput name="ReceiveNewsletter" id="ReceiveNewsletter" type="hidden" value="1">
						</cfif>
					</table>
				</div>
			</div>
			
		    <h2>3. Your Interests</h2>
			<div class="subscribe" <cfif attributes.mode NEQ "create">style="width:582px;"</cfif>>
				<div class="subpadding">
					<p class="text"><strong>Please select all the sectors that are relevant to you.</strong></p>
					<cf_admin_sectors 
						formname=	"frmRegister#attributes.mode#"
						mode=		"normal"
						class=		"smaller"
						sectors=	"#qryDataSet.sectors#">
						
				</div>
			</div>
			
		    <h2>4. Confirmation</h2>
			<div class="subscribe" <cfif attributes.mode NEQ "create">style="width:582px;"</cfif>>
				<div class="subpadding">
			
					<table width="100%" border="0" align="center">
			 
					<cfif attributes.mode eq "create" OR attributes.SubmitValue EQ "DELETE USER" OR attributes.SubmitValue EQ "REACTIVATE USER" OR attributes.SubmitValue EQ "UPDATE DETAILS">
			
						<cfif attributes.mode eq "create" OR attributes.SubmitValue EQ "DELETE USER" OR attributes.SubmitValue EQ "REACTIVATE USER">
			
							<!---<tr>
								<td>&nbsp;</td>
								<td>
									<strong>Please tick to confirm that you wish to receive access to www.localgov.co.uk </strong>
									<cfset Confirm1Message = "Please tick the confirmation box stating that you wish to receive access to www.localgov.co.uk.">
									<cfif confirm1 eq 1 >
										<cfinput name="confirm1" type="checkbox" value="1" checked required="yes" message="#Confirm1Message#">
									<cfelse>
										<cfinput name="confirm1" type="checkbox" value="1" required="yes" message="#Confirm1Message#">
									</cfif>
									<br /><br/>
									<!--- <a href="javascript:showText('confirm1_more');">Click here for more info</a> --->
									<div align="justify">
										<span class="medium">For Audit purposes we would usually ask you to sign and date an application card to confirm that you wish to receive access to LocalGov.co.uk and validate your request. As we cannot collect signatures online, please answer the following question.
										<br /><br />
										In which month were you born? * &nbsp;</span>	
										<cfset lstMonths= "January,February,March,April,May,June,July,August,September,October,November,December">
				
										<cfselect name="countyborn" required="yes">
											<cfloop list="#lstMonths#" index="i">
												<option value="#i#">#i#</option>
											</cfloop>
										</cfselect>
										<br />	
										<span style="font-size:12px;color:gray;">*We cannot process your registation without this information</span>
									</div>
									<hr size="1" noshade="noshade" />
								</td>
							</tr> --->
                            
                            <input type="hidden" name="confirm1" id="confirm1" value="1" />
                            
                            <input type="hidden" name="countyborn" id="countyborn" value="" />
			
							<tr valign="top">
								<td>&nbsp;</td>
								<td>
									<strong><span style="font-size:12px;">If you specifically do not wish your details to be passed to third parties please tick here:</strong>
									<cfif confirm2 eq 1 >
										<cfinput name="confirm2" type="checkbox" value="1" checked>
									<cfelse>
										<cfinput name="confirm2" type="checkbox" value="1">
									</cfif>
									
									<br /><br>
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
										
										<p>
											<br /></br/>
											We will keep you informed of Hemming Information Services’ products and services, including information about LocalGov.co.uk via post, by email and/or telephone. 
											<br /><br />
											If at any point you wish to advise us of any changes to your opt out, please write to Customer Services at Hemming Information Services, 32 Vauxhall Bridge Road, London, SW1V 2SS or email customer@hgluk.com
										</p>
									</div>
								</td>
							</tr>
						</cfif>
						<tr>
							<td colspan="2" align="center">
								<br />
								<input type="hidden" name="layout" value="2">
								<!--- <cfinput type="submit" name="submitReg" id="submitReg" value="#attributes.SubmitValue#" class="button"> --->
								<cfif attributes.mode eq "create">
									<input type="image" src="#request.strSiteConfig.strPaths.assets#/furniture/register.gif" id="submitReg" name="submitReg" value="#attributes.SubmitValue#" />
								<cfelse>
									<input type="image" src="#request.strSiteConfig.strPaths.assets#/furniture/submit.gif" id="submitReg" name="submitReg" value="#attributes.SubmitValue#" />
								</cfif>
								<BR /><BR />
							</td>
						</tr>
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
					
					</table> 
				</div>
			</div>
	
	</div>
</div>

</cfoutput>

