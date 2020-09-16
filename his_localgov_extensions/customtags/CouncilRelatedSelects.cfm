<!--
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/customtags/CouncilRelatedSelects.cfm $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 14/08/07 14:53 $

-->

<!---CREATE SELECTS FOR COUNCLS 'COUNTRY' & COUNCILS TYPES 
WHERE COUNCILS TYPES ARE BASED ON THE SELECTED COUNTRY--->

<cfparam name="attributes.qryCountries"     default="">
<cfparam name="attributes.qryCouncilTypes"	default="">
<cfparam name="attributes.formname" 		default="frm">
<cfparam name="attributes.OrgtypeID" 		default="5">
<cfparam name="counilselects" 				default="">
<cfparam name="filter" 						default="">




<cfsavecontent variable="jsCouncilSelect">
<cfscript>

//move qry's out of attributes in local scope so they can be used in QofQ
qryCountries=attributes.qryCountries;

qryCouncilTypes=attributes.qryCouncilTypes; 

If (attributes.OrgtypeID eq 4)
 qryCouncilTypes = request.objApp.objUtils.QueryOfQuery(qryCouncilTypes, '*', 'datavalue IN (#chr(39)#County#chr(39)#,#chr(39)#London#chr(39)#)');

</cfscript>


<!---Join tables to join the 2 lookups --->
<cfquery name="qry"  dbtype="query">
SELECT  qryCountries.Datavalue AS Country,	
		qryCouncilTypes.Datavalue AS CouncilType
FROM    qryCountries,
		qryCouncilTypes
WHERE	qryCountries.Uid=qryCouncilTypes.ParentUID		

</cfquery>



<script language="javascript" type="text/javascript">

var arrCouncils = new Array;

<cfoutput query="qry">
//create a javascript object for each council Type
var objCo =new Object;
objCo.country="#JSStringFormat(qry.Country)#";
objCo.counciltype="#JSStringFormat(qry.CouncilType)#";
//append object into the end of array
arrCouncils[arrCouncils.length]=objCo;
</cfoutput>


<cfoutput>

//this function fills the second select box based on the 1st box
function FillCouncilType() {

 //stop council type select from being displayed 
 document.getElementById('ctype').style.display='none';
 //remove all option from the 2nd select box
  document.getElementById("counciltype").options.length=0;
 //get currently selected country from the 1st select box
  with(document.forms.#attributes.formname#.country) {
 		 var country=options[selectedIndex].value;
   		}
  //stop here if there is no selectd rating
  if(country == "England"){
	
	
	//Create an option for "any"
	var objOption=new Option("[Any Council Type]", "" );
	//loop over array
	for(var i=0; i < arrCouncils.length; i++) {
		//if the country is the same as the currently selected value
		if(arrCouncils[i].country == country){
			//create a new visual <option> to place in the 2nd select box
			var objOption1=new Option(arrCouncils[i].counciltype, arrCouncils[i].counciltype);
			//place the new option in the 2nd select box
			with(document.#attributes.formname#.counciltype){
				//add the option to select that hold "[any]"
				options[0]=objOption;
				//add options to select based on 1st select
				options[options.length]=objOption1;
			}
 		}
		//open div to allow council type to be displayed 
		document.getElementById('ctype').style.display='inline';
 		}
     
	}
	
 };
 
</cfoutput>


</script>
</cfsavecontent>
<cfhtmlhead text="#jsCouncilSelect#">


<cfsavecontent variable="savecont">
<!---Councils Country Select--->
<select name="country" id="country"   width="300" class="dropbox" onchange="FillCouncilType()">
      <option value="">[Any Country]</option>
      <cfoutput query="qryCountries">
        <option value="#datavalue#">#datavalue#</option>
      </cfoutput>
    </select><img src="<cfoutput>#request.ssitepath#</cfoutput>view/images/pixel.gif" height="5" width="4" /><!---Councils Type Select (based on value of country)---><div id="ctype" style="display:none"><select name="counciltype"  width="300" class="dropbox" id="counciltype">
      <option value="">[Any Council Type] </option>
    </select><img src="<cfoutput>#request.ssitepath#</cfoutput>view/images/pixel.gif" height="5" width="4" /></div>
</cfsavecontent>

<!--- Return releted selects to calling page --->
<cfset caller.counilselects = savecont>