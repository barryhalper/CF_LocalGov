<!---
	
	$Archive: /LocalGov.co.uk/his_localgov_extensions/customtags/meta.cfm $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 22/03/07 10:26 $

--->

<!---/////CUSTOM TAGE THAT GENERATES META DATA BASED ON ATTRIBUTES/////// --->

<cfparam name="attributes.fuseaction" 		 type="string">
<cfparam name="attributes.MetaContent"       type="any">

<cfscript>
TitleDelim = " &gt; ";
//call method to extract metadata based on fuseaction
strMeta = request.objApp.ObjMeta.getWebsiteMetaData(attributes.fuseaction);
//build titke based on array of meta titles
title    	= 	ArraytoList(strMeta.arrTitle); 
keywords 	=	strMeta.keywords;
description =	strMeta.description;
author 		=	strMeta.author;

//check if meta data is coming from content
if (NOT StructIsEmpty(attributes.MetaContent)){
	if (StructKeyExists(attributes.MetaContent, "title") )
		//append content title to exsiting title
		title = ListAppend(title, attributes.MetaContent.title);
	if (StructKeyExists(attributes.MetaContent, "description") )
		//overwrite meta description 
		description = attributes.MetaContent.description;
	if (StructKeyExists(attributes.MetaContent, "keyword") )
		//overwrite keywords description 
		keyword = attributes.strMetaContent.keyword;	
		
}
 
</cfscript>
<!---WRITE OUT META DATA --->
<cfoutput>
	<title>#ListChangeDelims(title, TitleDelim)#</title>
	<meta http-equiv="Content-Type" 	content="text/html; charset=iso-8859-1">
	<meta name="author" 				content="#author#">
	<meta name="description" 			content="#description#">
	<meta name="keywords" 				content="#keywords#">
	
	<cfif StructKeyExists(session.UserDetails, "UserID")>
		<meta HTTP-EQUIV=Refresh 			CONTENT="#request.strSiteConfig.strVars.session_timeout#; URL=#request.sSitePath##request.myself#users.autologout">
	</cfif>
</cfoutput>
	
