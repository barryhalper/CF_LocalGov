<!--- 
	
	$Archive: /localgov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/ApplicationObjects/config.cfc $
	$Author: Bhalper $
	$Revision: 11 $
	$Date: 31/03/10 16:51 $

--->
<cfcomponent hint="congifuration required by this application">
		
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR -------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->	
	<cffunction name="init" returntype="config" access="public" output="false" hint="constructure method">
		<cfargument name="cgiscope" required="yes" type="struct"  hint="cgi structure">
		<cfargument name="dirpath" required="yes" type="string"   hint="full directory path of application">
		<cfargument name="xmlobject" required="yes" type="any"   hint="static xml object">
		<cfargument name="basepath" required="yes" type="string"  hint="base path to core folders and files">
			
		<cfscript>
		var xmldoc="";

		variables.strConfig=StructNew();
		//pass xml object into local scope
		variables.objXML= 					arguments.xmlobject;
		//call method to get site paths
		variables.strConfig.strPaths= 		SetPaths(arguments.cgiscope, arguments.dirpath, arguments.basepath );
		//call method to get config variables
		variables.strConfig.strVars= 		GetXmlConfig(variables.strConfig.strPaths.xmlpath, "config.xml");
		//call method to get config variables
		variables.strConfig.strMetaData=	GetXmlConfig(variables.strConfig.strPaths.xmlpath, "metadata.xml");
		//get xml menu
		variables.strConfig.xmlMenu= 		variables.objXML.ReadXmlConfig(variables.strConfig.strPaths.xmlpath, "menu.xml");
		variables.strConfig.Menu=			ArrayNew(1);
		variables.strConfig.TopMenuList=	ArrayNew(1);

		//build xml menu
		variables.strConfig.Menu[1]= 			BuildXmlMenu(xmldoc=variables.strConfig.xmlMenu,  ParentStart="<div id=top_menu>", ParentEnd="<br></div>",accesstype=1);
		variables.strConfig.TopMenuList[1]= 	GetTopMenuList(xmldoc=variables.strConfig.xmlMenu,  ParentStart="<div id=top_menu>", ParentEnd="<br></div>",accesstype=1);
		
		variables.strConfig.Menu[2]= 			BuildXmlMenu(xmldoc=variables.strConfig.xmlMenu,  ParentStart="<div id=top_menu>", ParentEnd="<br></div>",accesstype=2);
		variables.strConfig.TopMenuList[2]=		GetTopMenuList(xmldoc=variables.strConfig.xmlMenu,  ParentStart="<div id=top_menu>", ParentEnd="<br></div>",accesstype=2);
		
		variables.strConfig.Menu[3]= 			BuildXmlMenu(xmldoc=variables.strConfig.xmlMenu,  ParentStart="<div id=top_menu>", ParentEnd="<br></div>",accesstype=3);
		variables.strConfig.TopMenuList[3]= 	GetTopMenuList(xmldoc=variables.strConfig.xmlMenu,  ParentStart="<div id=top_menu>", ParentEnd="<br></div>",accesstype=3);
		
		variables.strConfig.Menu[4]= 			BuildXmlMenu(xmldoc=variables.strConfig.xmlMenu,  ParentStart="<div id=top_menu>", ParentEnd="<br></div>",accesstype=4);
		variables.strConfig.TopMenuList[4]= 	GetTopMenuList(xmldoc=variables.strConfig.xmlMenu,  ParentStart="<div id=top_menu>", ParentEnd="<br></div>",accesstype=4);
		
		variables.strConfig.Menu[5]= 			BuildXmlMenu(xmldoc=variables.strConfig.xmlMenu,  ParentStart="<div id=top_menu>", ParentEnd="<br></div>",accesstype=5);
		variables.strConfig.TopMenuList[5]=		GetTopMenuList(xmldoc=variables.strConfig.xmlMenu,  ParentStart="<div id=top_menu>", ParentEnd="<br></div>",accesstype=5);
		
		return this; 
		</cfscript>
				
	</cffunction>
	
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions --------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->	
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- FUNCTION: GetVariables()... ---------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="GetVariables" access="public" returntype="struct" output="false" hint="return variables">
		<cfreturn variables>
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- FUNCTION: GetSiteConfig()... --------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="GetSiteConfig" access="public" returntype="struct" output="false" hint="return structure of site configuration">
		<cfreturn variables.strConfig>
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- PRIAVTE Functions ---------------------------------------==--------------------------------------->
	<!--- ---------------------------------------------------------=---------------------------------------->
	
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- FUNCTION: SetPaths()... ---------------------------------====------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="SetPaths" access="private" returntype="struct" hint="set physical paths to site based on position of the application.cfm">
		<cfargument name="cgiscope" required="yes" type="struct" hint="pass in cgi scope">
		<cfargument name="dirpath" required="yes" type="string"  hint="full directory path of application">
		<cfargument name="basepath" required="yes" type="string"  hint="base path to core folders and files">
		
		<cfscript>
		//set return structure
		var str = StructNew();
		var strXmlPath = "";
		
		//insert variables into return structure
		str.dirpath= 	arguments.dirpath;
		str.basepath= 	arguments.basepath;
		//call metod to get url sitepath
		str.sitepath=	GetSitePath( arguments.cgiscope );

		//set path to xml confg files
		str.xmlpath= 	str.basepath & GetXMLConfigPath( arguments.cgiscope.server_name );
		
		//call method to gey site paths held in xml config file
		strXmlPath= 	GetXmlConfig( str.xmlpath, "path.xml");
		
		//place structure keys of xml congif in reyrun structure of this method
		StructAppend( str, strXmlPath, "yes" );
		return str;
		</cfscript>
			
	</cffunction>

	<!--- -------------------------------------------------------------------------------------------------->
	<!--- FUNCTION: GetXMLConfigPath()... -------------------------------------=--------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="GetXMLConfigPath" access="public" returntype="string" output="no" hint="" >
		<cfargument name="servername" required="yes" type="string"  hint="the server name">
		
		<cfscript>
		var xmlpath = "";
		var environment = "test";
		// determine which environment we are on...
		switch (arguments.servername) {
		case "127.0.0.1" 	 : 			environment= "development"; 	break;
		case "192.168.1.61"	 : 			environment= "test"; 			break;
		case "192.168.1.149"	 : 		environment= "test"; 			break;
		case "taxonomy.localgov.co.uk/": 	environment= "test"; 			break;
		case "195.152.75.144"	 : 		environment= "test"; 			break;
		case "staging.localgov.co.uk": 
		case "admin.localgov.co.uk":   environment= "live"; 
		case "services.localgov.co.uk":   environment= "live"; 
		case "histest.com":		break;
		case "www.localgov.co.uk": 			environment= "live"; 			break;
		case "80.79.128.216": environment="live"; break;
		
		default: "live"; break;
		}
		// setup the configuration xml file path...
		return "his_localgov_config\" & environment & "\";
		</cfscript>
		
	</cffunction>		
			
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- FUNCTION: GetSitePath()... -------------------------------------=--------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="GetSitePath" access="private" returntype="string" output="no" hint="set sitepath from cgi variables" >
		<cfargument name="cgiscope" type="struct" required="yes" hint="pass cgi scope to method">

		<cfscript>
		//set local variables
		var scriptname = arguments.cgiscope.SCRIPT_NAME; 
		var servername = arguments.cgiscope.SERVER_NAME;
		var serverport = arguments.cgiscope.SERVER_PORT;
		var CurrentTemplate = ListLast(scriptname ,"/");
		
		
		
		//set sitepath from cgi variables minus the CurrentTemplate
		If (serverport EQ "81")
			sitepath = Replace("http://" & servername & ":81" & scriptname, CurrentTemplate, "") ;
			
		else
			sitepath = Replace("http://" & servername & scriptname, CurrentTemplate, "");
	
		return sitepath;
		</cfscript>
				
	</cffunction>	
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- FUNCTION: GetXmlConfig()... --------------------------------=====--------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->	
	<cffunction name="GetXmlConfig" access="private" returntype="struct" output="no" hint="Set Websites configuration string based on xml file">
		<cfargument name="xmlpath" required="yes" type="string" hint="name of xml document">
		<cfargument name="filename" required="yes" type="string" hint="name of xml document">
	
		<cfscript>
		//read xml file into var
		var xmldoc	= variables.objXML.ReadXmlConfig( arguments.xmlpath, arguments.filename );
		var str 	= variables.objXML.xml2Struct( xmldoc );
		return str;
		</cfscript>

	</cffunction>	
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- FUNCTION: BuildXmlMenu()... ---------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->	
	<cffunction name="BuildXmlMenu" access="private" returntype="any" output="false" hint="build a collapsing dhtml menu based on XML data">
		<cfargument name="xmldoc" 		required="yes" type="any" hint="xml document">
		<cfargument name="ParentStart" 	required="no" type="string" hint="html code to prefix the parent node" default="">
		<cfargument name="ParentEnd" 	required="no" type="string" hint="html code to suffix the parent node" default="<br>">
		<cfargument name="ChildStart" 	required="no" type="string" hint="html code to prefix the parent node" default="">
		<cfargument name="ChildEnd" 	required="no" type="string" hint="html code to suffix the parent node" default="<br>">
		<cfargument name="accesstype" 	required="no" type="numeric" hint="the value passed to this argument decides the type of menu to display to the user" default="1">
			
		<cfscript>
		var i1="";
		var i2="";
		var i3="";
		var Xmlmenu = arguments.xmldoc.xmlroot.xmlchildren;
		var strTopMenu="";
		var strSubMenu="";
		var menu = "";
		var width="100%";
		var mouseOverCol=	"EBE2F2";
		var mouseDownCol=	"F9EED5";
		var mouseOutCol=	"FFFFFF";
		var bgCol=			"E4EBF7";
		var delay=			70; //ms
		</cfscript>
				
		<!--- Javascript functions to open and close the menu... 
		<cfsavecontent variable="menuJS">
			<cfinclude template="/his_localgov/extends/javascripts/menu.cfm">
		</cfsavecontent>
		<cfhtmlhead text="#menuJS#">--->
		
		<cfsavecontent variable="menu">
			<cfinclude template="/his_localgov/extends/javascripts/menu.cfm">
		<cfoutput>
		<!--- <div style="height:105px; display:block"></div> --->
		<!--- loop over array of elements --->
		<cfloop from="1" to="#arraylen(Xmlmenu)#" index="i1">
			<!--- Get attributes of 1st node (a cf strcuture) --->
			<cfset strTopMenu = Xmlmenu[i1].xmlattributes>
			<!--- Only display the top-menu if the user has access to the menu item --->
			<cfif StructKeyExists(strTopMenu,"accesstype") AND ListFind(strTopMenu.accesstype,arguments.accesstype)>
				<!---display element data and create collapsing menu --->
				<div style="width:144px; background-color:##FFFFFF; padding-top:2px; padding-bottom:2px;" id="top_menu" 
						onClick="
							if (document.getElementById('m#i1#').style.display == 'block') {
								closeMenu(#i1#);
							} else {
								closeAllMenus(#i1#);
								setTimeout('openMenu(#i1#);', #delay#);
								
							}; return false;"  >					
					<table cellpadding="1" cellspacing="1" border=0 width="140px" height="23" align="center" class="menubg"   >				
					<tr	onMouseOver="this.className='menubg_over';"	onMouseOut="this.className='menubg_out';" onMouseDown="this.className='menubg_down';" valign="middle" class="menubg_out">
					<td>&nbsp;<a href="##" title="Click to view #strTopMenu.name#" class="menu" ><strong >#strTopMenu.name#</strong></a></td>
					</tr>				
					</table>
				</div>
			</cfif>
			<!---check if node has any children  --->
			<cfif ArrayLen(Xmlmenu[i1].xmlchildren)>
				<!--- lopp over nested menu item --->
				<cfloop from="1" to="#arraylen(Xmlmenu[i1].xmlchildren)#" index="i2">
					<!---output child menu items/nodes and include DHTML attributes which refer to parent menu --->
					<div id="m#i1#" style="display:none;">
					<table cellpadding="0" cellspacing="0" width="144px">
					<cfloop  from="1" to="#arraylen(Xmlmenu[i1].xmlchildren[i2].xmlchildren)#" index="i3">
						<!---Get attributes of child node (a cf strcuture) --->
						<cfset strSubMenu = Xmlmenu[i1].xmlchildren[i2].xmlchildren[i3].xmlattributes>
						<cfif StructKeyExists(strSubMenu,"accesstype") AND ListFind(strSubMenu.accesstype,arguments.accesstype)>
							<tr	onMouseOver="this.className='menubg_over';"	
								onMouseOut=	"this.className='menubg_sub_out';" 
								onMouseDown="this.className='menubg_down';" valign="middle" class="menubg_sub_out">
								<td id="m#i1#.#i3#">&nbsp;&nbsp;<img src="#variables.strConfig.strPaths.imagepath#forward_gold.gif" width="4" height="8">&nbsp;<a href="#strSubMenu.link#&amp;mid=#i1#.#i3#" class="smmenu" title="Click to view #strSubMenu.name#" onclick="this.innerHTML='#replace(strSubMenu.name,"'","")# <img src=#variables.strConfig.strPaths.imagepath#progress.gif border=0 width=12 height=12>'">#strSubMenu.name#</a>#arguments.ChildEnd#</td>
							</tr>							
						</cfif>
					</cfloop>
					</table>
					</div>				
				</cfloop>
			</cfif>
		</cfloop>
		<table cellpadding="0" cellspacing="0" width="148" height="8"><tr><td><img src="#variables.strConfig.strPaths.imagepath#pixel.gif" height="8" width="1"></td></tr></table>
		<table <!--- bgcolor="###mouseOutCol#" ---> width="90%" align="center" cellpadding="0" cellspacing="0"><tr><td align="center" valign="middle">
		<a href="##" onClick="openAllMenus();" class="menu" title="Click to open all menu items" style="color:##FFFFFF">open all</a></td><td align="center" valign="middle"  style="color:##FFFFFF">|</td><td align="center" valign="middle"><a href="##" onclick="closeAllMenus();" style="color:##FFFFFF" class="menu" title="Click to close all menu items">close all</a></td></tr></table>
		<table cellpadding="0" cellspacing="0" width="138" height="8"><tr><td><img src="#variables.strConfig.strPaths.imagepath#pixel.gif" height="8" width="1"></td></tr></table>
		
		</cfoutput>
		</cfsavecontent>

		<cfreturn menu>
	</cffunction>					
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- FUNCTION: GetMenuSections() ---------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->	
	<cffunction name="GetTopMenuList" access="private" returntype="any" output="false" hint="create a list containing all the top menu sections.">
		<cfargument name="xmldoc" 		required="yes" type="any" hint="xml document">
		<cfargument name="ParentStart" 	required="no" type="string" hint="html code to prefix the parent node" default="">
		<cfargument name="ParentEnd" 	required="no" type="string" hint="html code to suffix the parent node" default="<br>">
		<cfargument name="ChildStart" 	required="no" type="string" hint="html code to prefix the parent node" default="">
		<cfargument name="ChildEnd" 	required="no" type="string" hint="html code to suffix the parent node" default="<br>">
		<cfargument name="accesstype" 	required="no" type="numeric" hint="the value passed to this argument decides the type of menu to display to the user" default="1">
			
		<cfscript>
		var i1="";
		var Xmlmenu = arguments.xmldoc.xmlroot.xmlchildren;
		var strTopMenu="";
		var lTopMenu = "";
		</cfscript>
				
		<!--- loop over array of elements --->
		<cfloop from="1" to="#arraylen(Xmlmenu)#" index="i1">
			<!--- Get attributes of 1st node (a cf strcuture) --->
			<cfset strTopMenu = Xmlmenu[i1].xmlattributes>
			<!--- Only display the top-menu if the user has access to the menu item --->
			<cfif StructKeyExists(strTopMenu,"accesstype") AND ListFind(strTopMenu.accesstype,arguments.accesstype)>
				<cfset lTopMenu = ListAppend(lTopMenu, "#i1#:#strTopMenu.name#")>
			</cfif>
		</cfloop>

		<cfreturn lTopMenu>
	</cffunction>					
	<!--- -------------------------------------------------------------------------------------------------->	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
		
</cfcomponent>

