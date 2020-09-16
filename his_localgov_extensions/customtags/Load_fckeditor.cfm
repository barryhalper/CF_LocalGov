<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/customtags/Load_fckeditor.cfm $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 14/08/07 14:53 $

--->

<cfparam name="attributes.instance" 	default="Story">
<cfparam name="attributes.value" 		default="">
<cfparam name="attributes.width" 		default="100%">
<cfparam name="attributes.height" 		default="200">
<cfparam name="attributes.path" 		default="#request.sAdminPath#">
<cfparam name="attributes.cfcpath" 		default="fckeditor">
<cfparam name="attributes.ToolbarSet" 	default="MyToolbar">


<cfoutput>
<cfscript>
	//call object that creates WYSIWYG Editor and pass in arguments
	fckEditor = createObject("component", attributes.cfcpath);
	fckEditor.instanceName=attributes.instance;
	fckEditor.basePath=attributes.path & "extends/fckeditor/"; 
	fckEditor.value=attributes.value;
	fckEditor.width=attributes.width;
	fckEditor.height=attributes.height;
	fckEditor.config.ToolbarStartExpanded = true;
	fckEditor.ToolbarSet = attributes.ToolbarSet ;
 	// ... additional parameters ...
	fckEditor.create(); 
	// create instance now.
</cfscript>
</cfoutput>