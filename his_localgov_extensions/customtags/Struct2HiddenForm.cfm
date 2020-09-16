<!--
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/customtags/Struct2HiddenForm.cfm $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 14/08/07 14:53 $

-->

<!--- Turn all keys in structure into hidden form fields--->
<cfparam name="attributes.str" 	  default="#structNew()#">

<cfscript>
///HIDDEN FORM FIELDS
for (i in attributes.str){
	if (Len(attributes.str[i])){;
		if (i neq "startrow")
			writeoutput("<input id=""#Lcase(i)#"" type=""hidden"" name=""#Lcase(i)#"" value=""#attributes.str[i]#"">");
			//writeoutput(i & "<br>");
	}
}
</cfscript>

<!--- <cfabort>	 --->	
