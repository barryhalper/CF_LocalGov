<!--
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/customtags/ParishRelatedSelects.cfm $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 14/08/07 14:53 $

-->
<cfparam name="attributes.formname" default="frm">

<cfset qryRegions = request.objApp.objUtils.QueryOfQuery(request.objBUs.ObjDirectory.GetLookUps(), "*", "LookUpID =9")>
<cfset qryCountry = request.objApp.objUtils.QueryOfQuery(request.objBUs.ObjDirectory.GetLookUps(), "*", "LookUpID =14 AND datavalue IN ('England', 'Scotland', 'Wales')")>

<cfquery name="qry"  dbtype="query">
SELECT  qryCountry.Datavalue AS Country,	
		qryRegions.Datavalue AS Region
FROM    qryCountry,
		qryRegions
WHERE	qryCountry.Uid=qryRegions.ParentUID		
</cfquery>

<!--- <cfdump var="#qryRegions#">
<cfdump var="#qryCountry#">
<cfdump var="#qry#"><cfabort> --->

<script language="javascript" type="text/javascript">

var arrRegions = new Array;

<cfoutput query="qry">
//create a javascript object for each council Type
var objR =new Object;
objR.Country="#JSStringFormat(qry.Country)#";
objR.region="#JSStringFormat(qry.Region)#";
//append object into the end of array
arrRegions[arrRegions.length]=objR;
</cfoutput> 

<cfoutput>
//this function fills the second select box based on the 1st box
function FillParishRegions() {
 //get currently selected country from the 1st select box
 with(document.forms.#attributes.formname#.Country) {
  var Country=options[selectedIndex].value;
  }
  	//alert(Region);
  //stop here if there is no selectd rating
  if(Country == ""){
	return;
	} 
	//remove all option from the 2nd select box
	document.#attributes.formname#.region.options.length=0;
	//Create an option for "any"
	var objOptionAny=new Option("[Any Region]", "" );
	//add options to select based 
	
	//loop over array
	for(var i=0; i < arrRegions.length; i++) {
	//if the country is the same as the currently selected value
	if(arrRegions[i].Country == Country){
		
		//create a new visual <option> to place in the 2nd select box
		var objOption=new Option(arrRegions[i].region, arrRegions[i].region);
		//place the new option in the 2nd select box
		with(document.#attributes.formname#.region){
			//add the option to select that hold "[any]"
			options[0]=objOptionAny;
			//add options to select based on 1st select
			options[options.length]=objOption;
			}
 		}
	
 	}
 };
</cfoutput>
</script>

<cfsavecontent variable="savecont">
<!---Parish Areas Select--->
<select name="Country" id="Country"   width="300" class="smtext" onchange="FillParishRegions()">
      <option value="">[Any Country]</option>
      <cfoutput query="qryCountry">
		<option value="#datavalue#">#datavalue#</option>
		
      </cfoutput>
    </select><img src="<cfoutput>#request.ssitepath#</cfoutput>view/images/pixel.gif" height="5" width="4" /><!--Parish Districts (based on value of Area)---><select name="region"  width="300" class="smtext" id="region">
      <option value="">[Any Region] </option>
    </select><img src="<cfoutput>#request.ssitepath#</cfoutput>view/images/pixel.gif" height="5" width="4" />
</cfsavecontent>

<!--- Return releted selects to calling page --->
<cfset caller.parsishselects = savecont>