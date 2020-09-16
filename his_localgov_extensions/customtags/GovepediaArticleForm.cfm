<!--
	
	$Archive: /localgov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/customtags/GovepediaArticleForm.cfm $
	$Author: Ohilton $
	$Revision: 3 $
	$Date: 18/05/09 16:35 $

-->


<cfparam name="attributes.adminmode" default="0" type="boolean">
<cfparam name="attributes.xfaname">
<cfparam name="attributes.DataSet">
<cfparam name="attributes.xfaname">
<cfparam name="attributes.userid" default="0">
<cfparam name="attributes.Sections">
<cfparam name="attributes.cfcpath" default="fckeditor">
<cfparam name="attributes.formmode" default="Add">
<cfparam name="attributes.NewsStatusTypes" default="">
<cfparam name="attributes.Versions" default="">

<cfparam name="width" default="90%">
<cfparam name="userid" default="0">
<cfparam name="bgcolor" default="##EEEEEE">
<cfparam name="disabled" default="">
<cfparam name="url.error" default="0" type="boolean">
<cfparam name="fckpath" default="#request.ssitepath#" >




<cfsavecontent variable="jsA">
<script type="text/javascript" language="javascript" src="<cfoutput>#request.sJSPath#</cfoutput>Govepedia.js" ></script>
</cfsavecontent>
<cfhtmlhead text="#jsA#">

<cfloop list="#attributes.DataSet.columnlist#" index="Field">
	<cfif StructKeyExists(attributes, "DataSet")><cfset value = Evaluate("attributes.DataSet.#Field#")><cfelse><cfset value = ""></cfif>
	<cfparam name="#Field#" default="#value#">
</cfloop>


<cfparam name="url.id" default="#baseid#">

<cfscript>
if (attributes.adminmode){
 width = "95%";
 bgcolor ="";
 fckpath = request.sadminpath;
}
if (isquery (attributes.Versions))
	qryVersions = attributes.Versions;


if (NOT attributes.adminmode AND attributes.formmode eq "Edit")
	disabled = "Disabled";
if (NOT Len(status))
	status = 0;	
</cfscript>

<cfoutput>


<form name="frmGov" action="#request.myself##attributes.xfaname#" method="post" enctype="multipart/form-data" onSubmit="document.getElementById('submitgov').disabled=true; return validateArticle();">

<input type="hidden" name="isAdmin" value="#attributes.adminmode#" />
 
<input type="hidden" name="topicid" value="" />

<cfif attributes.adminmode>

<hr width="90%" align="center" />
<!--- Header... -------------------------------------------------------------------------------------------->

<table width="90%" border="0" cellspacing="0" cellpadding="1" class="smtext">
  <tr>
    <td>Article&nbsp;ID:<input name="newsid" type="text" value="#baseid#" readonly size="5" class="smtext" style="opacity: 0.5; filter:alpha(opacity=50);" >
&nbsp;
Version&nbsp;ID:<input name="version_id" type="text" value="#p_news_id#" readonly size="5" class="smtext" style="opacity: 0.5; filter:alpha(opacity=50);" >
&nbsp;

Version:
<!--- ---------------------------->
<select name="version_news_id" onchange="document.location.href='#request.myself#govepedia.edit&amp;id=#url.id#&amp;vid='+version_news_id.value" class="smtext" style="opacity: 0.5; filter:alpha(opacity=50);">
<cfloop query="qryVersions">
<option value="#qryVersions.f_news_id#" 

	<cfif url.vid neq 0>
		#iif(qryVersions.f_news_id eq url.vid, de("selected"), de(""))#
	<cfelse>
		<cfif RecordCount eq CurrentRow>selected</cfif>
	</cfif>
	
>#qryVersions.CurrentRow#</option>
</cfloop>
</select>
of #attributes.Versions.RecordCount#


&nbsp;Date&nbsp;Created:

<select name="date_posted"  onchange="document.location.href='#request.myself#govepedia.edit&amp;id=#url.id#&amp;vid='+date_posted.value" class="smtext" style="opacity: 0.5; filter:alpha(opacity=50);">
<cfloop query="qryVersions">

	<option value="#qryVersions.f_news_id#" 

	<cfif url.vid neq 0>
		#iif(qryVersions.f_news_id eq url.vid, de("selected"), de(""))#
	<cfelse>
		<cfif RecordCount eq CurrentRow>selected</cfif>
	</cfif>
	
>#DateFormat(qryVersions.DatePosted,'dd/mm/yyyy')# #TimeFormat(qryVersions.DatePosted, 'HH:mm')#</option>
</cfloop>
</select>


</td>
  </tr>
</table>

<hr align="center" width="90%" />

<cfelse>		
	<input type="hidden" name="newsid" value="#p_news_id#" id="newsid">
	<input type="hidden" name="status" value="#status#" id="status">
	
	<cfif disabled eq "Disabled">
		<input type="hidden" name="headlinebanner" value="#headlinebanner#" id="headlinebanner">
		<input type="hidden" name="sectionid" value="#sectionid#" id="sectionid">
		<input type="hidden" name="sectors" value="#sectorid#" id="sectors">
	</cfif>

</cfif>
	
		<input type="hidden" name="userid" value="#attributes.userid#" id="id">
	<table width="#width#" border="0" class="text" align="center" bgcolor="#bgcolor#">
  <tr>
    <td><table width="100%" border="0" cellspacing="0" cellpadding="1" class="text">
  <tr>
    <td width="15%">Article Title:</td>
    <td width="85%" height="25"><input name="headlinebanner" type="text" id="headlinebanner" size="75"  class="text" value="#headlinebanner#" #disabled#> <cfif url.error and structkeyexists(url, "headlinebanner")> 
      <span class="error">Please supply a title</span> 
    </cfif></td>
  </tr>
  <tr>
    <td>Type:</td>
    <td height="25">
			<select name="sectionid" id="sectionid" class="text" #disabled#>
					<cfloop query="attributes.Sections">
						<option value="#attributes.Sections.sectionid#" <cfif attributes.Sections.sectionid eq variables.sectionid>selected="selected"</cfif>>#attributes.Sections.govepedia_section#</option>
					</cfloop>
   				</select>    </td>
  </tr>
  <cfif attributes.adminmode>
    <cfif isquery(attributes.NewsStatusTypes)>
    <tr>
    <td>Status</td>
    <td height="25">
	<select name="status" id="status" class="text" #disabled#>
					<cfloop query="attributes.NewsStatusTypes">
						<option value="#attributes.NewsStatusTypes.id#" #iif(variables.Status eq attributes.NewsStatusTypes.id,de('selected'),de(""))#>#attributes.NewsStatusTypes.status#</option>
					</cfloop>
   				</select></td>
  </tr>
  </cfif>
  
  <cfif attributes.formmode eq "edit" and userid>
  <tr>
      <td>Author:</td>
      <td height="25"><a href="mailto:#username#">#Username#:</a> <cfif NOT Find("hgluk.com",username)><a href="#request.myself#user.edit&amp;id=#userid#" class="smtext"><em>view details</em></a></cfif></td>
    </tr>
	</cfif>
	 <tr>
      <td>Modified By:</td>
      <td height="25"><input name="Modified" type="text" value="#session.UserDetails.Fullname#" readonly size="25 " class="smtext" style="opacity: 0.5; filter:alpha(opacity=50);" />
	  <input type="hidden" name="ModifiedBy" value="#session.UserDetails.userid#" />	  </td>
	 </tr>
	 <tr>
	   <td>Teaser:</td>
	   <td height="25"><textarea name="teaser" maxlength="850" rows="4" cols="68" style="font-family:Arial; font-size:13px"><cfoutput>#teaser#</cfoutput></textarea></td>
	   </tr>
	 <tr>
	   <td>Teaser Image: </td>
	   <td height="25"><cfoutput><cfif fileExists("#request.sUploadImgDir##imagefile#")><img src="#request.sUploadImgPath##imagefile#" border="1" width="20" height="20" align="left" hspace="4px" alt="#imagecaption#" onmouseover="this.width='96'; this.height='96';" onmouseout="this.width='18'; this.height='18';" /></cfif><input name="image_teaser" id="image_teaser" type="file" value="" ></cfoutput></td>
	   </tr>
	 <cfelse>
	 <input type="hidden" name="image_teaser" id="image_teaser"  value=""/>
  </cfif>	
  
</table>
    <table width="100%" border="0" cellspacing="0" cellpadding="1">
  <tr>
    <td height="25" class="text"><hr /></td>
  </tr>
  <tr>
    <td height="25" class="text">Copy:</td>
  </tr>
  <tr>
    <td height="25" align="center">
	<cf_Load_fckeditor instance="Story" value="#Story#" height="400" width="95%" path="#fckpath#" cfcpath="#attributes.cfcpath#"> <br />
<cfif url.error and structkeyexists(url, "story")> 
      <span class="error">Please supply copy for this article</span> 
    </cfif></td>
  </tr>
  <tr>
    <td height="25"><!---Output sectors --->
	<cf_admin_sectors Sectors="#sectorid#" FormName="frmGov" disabled="#disabled#">
	<br />
<cfif url.error and structkeyexists(url, "sectors")> 
      <span class="error">Please supply sectors for this article</span> 
    </cfif>	</td>
  </tr>
  

  <tr>
    <td height="25" align="center">
	<cfif attributes.adminmode AND attributes.formmode eq "edit">
	<input name="submit" type="button" class="text" id="submitgov" style="height:30px; font-weight:bold;" value="Preview Article" onclick="document.location.href='#request.ssitepath#index.cfm?method=govepedia.detail&amp;id=#p_news_id#'">
	</cfif>
	
	<input name="submit" type="submit" class="text" id="submitgov" style="height:30px; font-weight:bold;" value="#attributes.formmode# Article">
	</td>
  </tr>
</table>

</td>
  </tr>
</table>

</form> 
</cfoutput>




