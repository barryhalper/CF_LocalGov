<cfparam name="attributes.header" 		default="">
<cfparam name="attributes.title" 		default="">
<cfparam name="attributes.image" 		default="">
<cfparam name="attributes.imagecaption" default="">
<cfparam name="attributes.teaser" 		default="">
<cfparam name="attributes.link" 		default="">
<cfparam name="attributes.imagealign"	default="left">
<cfparam name="attributes.imagesizefixed"	default="true">

<cfoutput>
<cfif attributes.header neq ""><h2 style="margin:0px;">#attributes.header#</h2></cfif>
<hr noshade="noshade" size="1" />
<div onMouseOver="this.className='hovOver';" onMouseOut="this.className='hovOut';">
	<p style="font-size:1.2em"><strong><a href="#attributes.link#" title="#attributes.title#">#attributes.title#</a></strong></p>
	<p class="text">
	<cfif fileExists("#request.sUploadImgDir##attributes.image#")><img src="#request.sUploadImgPath##attributes.image#" border="1" <cfif attributes.imagesizefixed>width="64" height="64"</cfif> align="#attributes.imagealign#" hspace="4px" alt="#attributes.title#" /></cfif>
	#attributes.teaser#</p>
	<div align="right"><a href="#attributes.link#" title="#attributes.title#" class="medium">more...</a></div>
</div>
</cfoutput>