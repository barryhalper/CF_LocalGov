<!--
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/customtags/buildMenu.cfm $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 14/08/07 14:53 $

-->

<cfparam name="attributes.xmldoc" type="string" default="">


<cfset xmldoc = request.objApp.objXML.ReadXmlConfig( request.strSiteConfig.strPaths.xmlpath, attributes.xmldoc)>
<!--- <cfset xmlDoc = XMLParse(trim(cfhttp.filecontent))> --->
<cfset xmlMenu = xmlDoc.xmlroot.xmlchildren>


<cfsavecontent variable="savecont">
<cfoutput>
<script language="javascript" type="text/javascript">
function showHide(objID) {
	closeAllMenus(objID);
	if (document.getElementById(objID).style.display == 'none') {
		topLevelID = objID.substring(0,objID.indexOf('.'));
		document.getElementById(topLevelID).style.display='inline';
		document.getElementById(objID).style.display='inline';
	} else {
		topLevelID = objID.substring(0,objID.indexOf('.'));
		document.getElementById(topLevelID).style.display='inline';
		document.getElementById(objID).style.display='none';
	}
}
<!--- Function to close all submenus... --->
function closeAllMenus(item) {
	<cfloop from="1" to="#arraylen(Xmlmenu)#" index="i1">closeMenu(#i1#);</cfloop>
}
<!--- Function to open all submenus... --->
function openAllMenus(item) {
	<cfloop from="1" to="#arraylen(Xmlmenu)#" index="i1">x = #i1# * menuSpeed; setTimeout('openMenu(#i1#,0)',x);</cfloop>
}
// Local variable declarations...
var menuSpeed = 100;

<!--- Function to open a specific menus... --->
function openMenu(item1, item2, item3) {
	try { 
		document.getElementById('m'+item1).style.display = 'inline';
		//document.getElementById('m'+item1).style.backgroundColor='##FFFFCD'; 
		
		if (item2 != 0) {
			document.getElementById('m'+item1+'.'+item2).style.display = 'inline'; 
			//if (item3 == 0)
				//document.getElementById('m'+item1+'.'+item2).style.backgroundColor='##FFFFCD'; 
		}

		if (item3 != 0) {
			document.getElementById('m'+item1+'.'+item2+'.'+item3).style.backgroundColor='##FFFFCD'; 
		}
	} catch (err) { }
}
<!--- Function to close a specific menus... --->
function closeMenu(item) {
	try { document.getElementById('m'+item).style.display = 'none'; } catch (err) { }
}
</script>

<cfscript>
indent = 15;

for (i1=1; i1 LTE Arraylen(xmlMenu); i1=i1+1) {
	m1 = xmlMenu[i1];
	
	WriteOutput("<div  style='width:100%; padding-bottom:4px; padding-top:4px;' class='text'
		onMouseDown=""
			if (document.getElementById('m#i1#').style.display == 'inline') {
				closeMenu(#i1#);
			} else {
				closeAllMenus(#i1#);
				setTimeout('openMenu(#i1#);',menuSpeed);
			}""
		onMouseOver=""this.style.backgroundColor='##FFFFCC';this.style.cursor='pointer';""
		onMouseOut=""this.style.backgroundColor='';""
		><strong style='color:000000'>&nbsp;&nbsp;" & m1.xmlAttributes.name & "</strong></div>");

	WriteOutput("<div id=m#i1# style='display:none;width:100%;'>");
	
	if (ArrayLen(m1.xmlChildren)) {
		m2 = m1.xmlChildren[1].xmlChildren;
		
		if (ArrayLen(m2)) {
			
			for (i2=1; i2 LTE arraylen(m2); i2=i2+1) {
				
				sName = m2[i2].xmlAttributes.name;
				if ( Mid(sName, 1, 1) eq "-" ) 
					sName = "<strong>" & ucase(Mid(sName, 2, Len(sName))) & "</strong>";
				else
					sName = "MANAGE <strong>" & ucase(sName) & "</strong>";
				
				if ( ArrayLen(m2[i2].xmlChildren) ) {
					
					WriteOutput("<div style='display:inline;position:relative;left:#indent#px;' class='smtext' 
						onClick=""
							showHide('m#i1#.#i2#');""
						onMouseOver=""if ('#url.mid#' == '#i1#.#i2#') {} else  { this.style.backgroundColor='##DDDDAA'; this.style.cursor='pointer'; }""
						onMouseOut=""if ('#url.mid#' == '#i1#.#i2#') {} else  { this.style.backgroundColor=''; }""	
						onMouseDown=""this.style.backgroundColor='##FFFFCC';""						
							><img src=""#request.sImgPath#forward.gif"">
							<a href=""#m2[i2].xmlAttributes.link#&amp;mid=#i1#.#i2#"">#sName#</a>
							</div><br>");
					
					m3 = m2[i2].xmlChildren[1].xmlChildren;
					
					WriteOutput("<div id=m#i1#.#i2# style='display:none;position:relative;left:30px;'
						onMouseOver=""this.style.cursor='pointer;'""
					>");
					
					for (i3=1; i3 LTE ArrayLen(m3); i3=i3+1) {
						WriteOutput("<div id=m#i1#.#i2#.#i3# style='width:140px;'><img src=""#request.sImgPath#forward.gif""> <a href=""#m3[i3].xmlAttributes.link#&amp;mid=#i1#.#i2#.#i3#""
							onMouseOver=""if ('#url.mid#' == '#i1#.#i2#.#i3#') {} else { this.style.backgroundColor='##FFFFCC'; this.style.cursor='pointer;'}""
							onMouseOut=""if ('#url.mid#' == '#i1#.#i2#.#i3#') {} else {this.style.backgroundColor=''; }""							
						
						><strong>" & ucase(m3[i3].xmlAttributes.name) & "</strong></a></div>");
					}
					
					WriteOutput("</div>");
				} else {
					WriteOutput("<div id=m#i1#.#i2# style='display:inline;position:relative;left:#indent#px;width:140px;'
						onMouseOver=""if ('#url.mid#' == '#i1#.#i2#') {} else  { this.style.backgroundColor='##DDDDAA';this.style.cursor='pointer';}""
						onMouseOut=""if ('#url.mid#' == '#i1#.#i2#') {} else this.style.backgroundColor='';""					
						onMouseDown=""this.style.backgroundColor='##FFFFCC';""						
					><img src=""#request.sImgPath#forward.gif""> <a href=""#m2[i2].xmlAttributes.link#&amp;mid=#i1#.#i2#"">#ucase(sName)#</a></div><br>");
				} //if.
				
			} //for.
		} //if.
	} //if.
	WriteOutput("</div>");
}
</cfscript>
<br>
<cfif NOT session.IsPartner>
<div align="left">
&nbsp;&nbsp;&nbsp;<a href="##" onClick="openAllMenus();" class="smtext" title="Open all menu items">open all</a> | <a href="##" onclick="closeAllMenus();" class="smtext" title="Close all menu items">close all</a>
</div>
</cfif>
</cfoutput>

<!--- <cfdump var="#session#"><cfabort> --->

</cfsavecontent>

<!--- Return releted selects to calling page --->
<cfset caller.menu = savecont>		