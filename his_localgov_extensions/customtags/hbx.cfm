<!--- 
	
	$Archive: /localgov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/customtags/hbx.cfm $
	$Author: Bhalper $
	$Revision: 2 $
	$Date: 18/05/09 16:35 $

--->

<cfparam name="attributes.pn" default="PUT+PAGE+NAME+HERE">


<cfparam name="attributes.title" 	default="title">
<cfparam name="attributes.content"  default="CONTENT">
<cfparam name="attributes.category" default="CATEGORY">
<cfparam name="attributes.pagetitle" default="">
<cfparam name="attributes.id"  		default="0">

<cfset pn = Replace(attributes.pn, ".", "+")>
<cfset mlc = Replace(attributes.pn, ".", "/")>

<cfset jspath = server.LocalGov.objAppManager.getSiteConfig().strPaths.sitePath  & server.LocalGov.objAppManager.getSiteConfig().strPaths.JSPath>

<cfscript>
delim ='|' ;
attributes.pagetitle = replace(attributes.pagetitle, '&gt;', delim, 'all');

//if page title has been passed
if (listLen(attributes.pagetitle,delim)){
	//get final element in list
	attributes.pagetitle = ListGetAt(attributes.pagetitle, ListLen(attributes.pagetitle, '|'), '|');
	//apend value to mlc
	mlc = listAppend(mlc, trim(attributes.pagetitle), "/");
	mlc = replace(mlc, "&", "", "all");
	mlc = replace(mlc, "'", "", "all");
	mlc = replace(mlc, ":", "", "all");
	mlc = replace(mlc, "‘", "", "all");
	mlc = replace(mlc, "’", "", "all");
	}

//check id is present in url and append to pn var
if (structKeyExists(url, "id"))
 pn = listAppend(pn, url.id, "+");
else 
if (structKeyExists(url, "jobid"))
 pn = listAppend(pn, url.jobid, "+");	
	
</cfscript>


<!--WEBSIDESTORY CODE HBX2.0 (Universal)-->
<!--COPYRIGHT 1997-2005 WEBSIDESTORY,INC. ALL RIGHTS RESERVED. U.S.PATENT No. 6,393,479B1. MORE INFO:http://websidestory.com/privacy-->


<cfif NOT ListFind("127.0.0.1,localhost,192.168.1.61", cgi.SERVER_NAME)>

<script language="javascript" type="text/javascript">
var _hbEC=0,_hbE=new Array;

function _hbEvent(a,b){b=_hbE[_hbEC++]=new Object();b._N=a;b._C=0;return b;}

var hbx=_hbEvent("pv");
hbx.vpc="HBX0200u";

hbx.gn="ehg-hemminginformation.hitbox.com";

//BEGIN EDITABLE SECTION
//CONFIGURATION VARIABLES
<cfoutput>
hbx.acct="DM5611101HMA71EN3";//ACCOUNT NUMBER(S)
hbx.pn="#JSStringFormat(pn)#";//PAGE NAME(S)
hbx.mlc="#JSStringFormat(mlc)#";//MULTI-LEVEL CONTENT CATEGORY
hbx.pndef="#JSStringFormat(attributes.title)#";//DEFAULT PAGE NAME
hbx.ctdef="full";//DEFAULT CONTENT CATEGORY
hbx.lt ="auto";//LINK TRACKER


//CUSTOM VARIABLES
<cfif StructKeyExists(session, "Userdetials") and server.LocalGov.objBusinessObjects.objUser.loggedIn(session)>

hbx.ci="#session.userdetails.userid#";//CUSTOMER ID
hbx.hc1="#session.userdetails.jobtitle#";//CUSTOM 1
hbx.hc2="#session.userdetails.county#";//CUSTOM 2
</cfif>
</cfoutput>
//INSERT CUSTOM EVENTS

//END EDITABLE SECTION

//REQUIRED SECTION. CHANGE "YOURSERVER" TO VALID LOCATION ON YOUR WEB SERVER (HTTPS IF FROM SECURE SERVER)
</script>

<script language="javascript" type="text/javascript"  src="<cfoutput>#jspath#</cfoutput>hbx.js"></script>
<!--END WEBSIDESTORY CODE-->
</cfif>