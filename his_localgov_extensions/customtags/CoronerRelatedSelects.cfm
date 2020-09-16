<!--
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/customtags/CoronerRelatedSelects.cfm $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 14/08/07 14:53 $

-->

<!---CREATE SELECTS FOR  CORONER COUNTRIES & REGIONS WHERE REGIONS ARE RELATED 2 COUNTRIES 
ARE BASED ON STATISTICS TYPE --->

<cfparam name="attributes.qryRegions"   default="">
<cfparam name="attributes.qrytypes"	 	default="">

<cfscript>
//move qry's out of attributes in local scope so they can be used in QofQ

qrytypes=request.objApp.objUtils.QueryOfQuery(attributes.qryTypes, "*", "UID IN (1,4,9)");
qryRegions=attributes.qryRegions; 
</cfscript>

<!---Join tables to join the 2 lookups --->
<cfquery name="qry"  dbtype="query">
SELECT  qryRegions.Datavalue AS Region,	
		qryTypes.Datavalue AS Type
FROM    qryRegions,
		qryTypes
WHERE	qryTypes.Uid=qryRegions.ParentUID		
</cfquery>

<!---Build query object to hold stats and the related types--->

<script language="javascript" type="text/javascript">

//array to hold country objects
var arrRegions = new Array;


<cfoutput query="qry">
//create a javascript object for each council Type
var objR =new Object;
objR.region="#JSStringFormat(qry.region)#";
objR.type="#JSStringFormat(qry.type)#";
//append object into the end of array
arrRegions[arrRegions.length]=objR;
</cfoutput>


function FillRegions(){
 

 var type =  document.getElementById('type').value;
 
 if (type == 'London')
	document.getElementById('rdiv').style.display='none';
  else
    document.getElementById('rdiv').style.display='inline';	
 
 //remove all option from the 'region' select box 
 document.getElementById('region').options.length=0;
 var objAnyOption=new Option("[Any Region]", "" ); 
 
 
 
  //loop over array
 for(var i=0; i < arrRegions.length; i++) {
 //add the option to select that hold "[any]"
 
  document.getElementById('region').options[0]=objAnyOption;
  if(arrRegions[i].type == type){
 	//create a new visual <option> to place in the 2nd select box
	var objOption=new Option(arrRegions[i].region, arrRegions[i].region);
	 //place the new option in the 2nd select box
	  with(document.getElementById('region')){
		//add the option to select that hold "[any]"
		//add options to select based on 1st select
	    options[options.length]=objOption;
		}
	}
	//open div to allow council type to be displayed 
	
  }
}; 

</script>


<cfsavecontent variable="savecont">


<!---Coroner Type Select --->
<select name="type"  width="300" class="smtext" id="type" onChange="FillRegions()">
  <cfoutput query="qryTypes">
       <option value="#datavalue#">#datavalue#</option></cfoutput>
    </select><img src="<cfoutput>#request.ssitepath#</cfoutput>view/images/pixel.gif" height="5" width="4" /><!---Region Select---><div id="rdiv" style="display:inline;">
<select name="region" id="region"   width="300" class="smtext" onchange="">
      <option value="">[Any Region]</option>
	   <cfoutput query="qryRegions">
       <option value="#datavalue#">#datavalue#</option></cfoutput>
     </select></div>
 
<script type="text/javascript" language="javascript">FillRegions();</script>
</cfsavecontent>

<!--- Return releted selects to calling page --->
<cfset caller.counilselects = savecont>