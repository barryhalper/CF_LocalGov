<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/ApplicationObjects/breadcrumb.cfc $
	$Author: Bhalper $
	$Revision: 2 $
	$Date: 26/01/10 17:09 $

--->

<cfcomponent hint="Breacrumb-related functions.">

	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<cffunction name="getBreadcrumb" access="public" hint="..." returntype="struct" output="true">
		
		<cfargument name="mid" 		type="string" required="yes" hint="the menu id, dot delimited">
		<cfargument name="xmlMenu" 	type="xml" required="yes" hint="the menu in it's xml state">
		<cfargument name="strAttr" 	type="struct" required="yes" hint="">
		
		
		
		<!--- <cfscript>
		// Local variable initialisation...
		var sStart = 		"You are here: ";
		var sBreadcrumb = 	sStart;
		var sLevel1 = 		"";
		var sLevel2 = 		"";		
		var sSpc = 			" > ";
		var sMethod = 		"";
		var strLevel1 = 	StructNew();
		var strRtnData = 	StructNew();
		var c = 			0;
		strRtnData.PageTitle ="";

		// Determine number of levels...
		for (i=1; i lte Len(arguments.strAttr.mid); i=i+1)
			if (Mid(arguments.strAttr.mid, i, 1) eq '.')
				c=c+1;

		selectedElements1 = XMLSearch(arguments.xmlMenu, "/menu/item");
		
		try{
		strLevel1 = selectedElements1[ListGetAt(arguments.mid, 1, ".")].xmlAttributes;
		if (strLevel1.link neq "") 
			sLevel1 = "<a href=""" & strLevel1.link & """>" & strLevel1.name & "</a>";
		else
			sLevel1 = strLevel1.name;
		
		 {
			strLevel2 = selectedElements1[ListGetAt(arguments.mid, 1, ".")].XMLChildren[1].XmlChildren[ ListGetAt(arguments.mid, 2, ".") ].XmlAttributes;
			sLevel2 = "<a href=""" & strLevel2.link & "&amp;mid=#arguments.mid#"">" & strLevel2.name & "</a>";
		}
		}
		catch(any exception){
		
		}
			
		if (StructKeyExists(arguments.strAttr,"method") )
			sMethod = lcase(arguments.strAttr.method);  
			
		/* Construct level 1 and 2 breadcrumbs...*/
		switch (sMethod) {
			case "news.detail" : { 
				//sLevel1 = "News"; 
				if (StructKeyExists(arguments.strAttr, "id"))
					sLevel2 = request.objBus.objArticle.getFull(1, arguments.strAttr.id).HeadlineBanner; 
				break; 
			}
		}
	
		// Append any level 1's...
		if (sLevel1 NEQ "") {
			sBreadcrumb = sBreadcrumb & sLevel1;
			strRtnData.PageTitle = sLevel1;
			
			// Append any level 2's...
			if (sLevel2 NEQ "") {
				sBreadcrumb = sBreadcrumb & sSpc & sLevel2;
				strRtnData.PageTitle = sLevel2;
			}
		}

		strRtnData.Breadcrumb = sBreadcrumb;
		strRtnData.PageTitle = REReplace(strRtnData.PageTitle, "<[^>]*>", "", "All");
		
		return strRtnData;
		</cfscript> --->
					
	</cffunction>
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	
</cfcomponent>