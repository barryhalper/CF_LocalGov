<!--
	
	$Archive: /localgov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/customtags/StatsRelatedSelects.cfm $
	$Author: Ohilton $
	$Revision: 3 $
	$Date: 13/05/09 16:31 $

-->

<!---CREATE SELECTS FOR STAT TYPES, COUNCIL 'COUNTRY' & COUNCILS TYPES 
WHERE COUNCILS TYPES ARE BASED ON THE SELECTED COUNTRY AND COUNTRIES 
ARE BASED ON STATISTICS TYPE --->



<!--- --->


<cfscript>
//move qry's out of request str in local scope so they can be used in QofQ
qryCountries=request.str.strFormselects.qryCountries;
qryCouncilTypes=request.str.strFormselects.qryCouncilTypes;
qryCoStats=request.str.qryCoStats;
//extract stat from qryCoStats
qryStats = request.str.qryStats;
</cfscript>




<!---Join tables to join the 2 lookups --->
<cfquery name="qry"  dbtype="query">
SELECT  qryCountries.Datavalue AS Country,	
		qryCouncilTypes.Datavalue AS CouncilType
FROM    qryCountries,
		qryCouncilTypes
WHERE	qryCountries.Uid=qryCouncilTypes.ParentUID		
AND 	qryCouncilTypes.datavalue <> 'Isles'
</cfquery>

<!---Build query object to hold stats and the related types--->

<cfsavecontent variable="jsSelects">
<script language="javascript" type="text/javascript">

//array to hold country objects
var arrCountries = new Array;
//array that hold council types
var arrCouncils = new Array;


<cfoutput>
<cfloop query="qryCoStats">
//create a javascript object for each council Type
var objCountry =new Object;
objCountry.Country="#JSStringFormat(qryCoStats.Country)#";
objCountry.stattype="#JSStringFormat(qryCoStats.stattype)#";
//append object into the end of array
arrCountries[arrCountries.length]=objCountry;
</cfloop>


function FillCountry(){
 var stattype =  document.getElementById('stattype').value;
 
   
 //remove all option from the 'stattype' select box 
 document.getElementById('Country').options.length=0;
 var objOption=new Option("[Any Country]", "" ); 
  //loop over array
 for(var i=0; i < arrCountries.length; i++) {
  if(arrCountries[i].stattype == stattype){
 	//create a new visual <option> to place in the 2nd select box
	var objOption1=new Option(arrCountries[i].Country, arrCountries[i].Country);
	 //place the new option in the 2nd select box
	  with(document.getElementById('Country')){
		//add the option to select that hold "[any]"
		options[0]=objOption;
		//add options to select based on 1st select
	    options[options.length]=objOption1;
		}
	}
  }
}; 

<cfloop query="qry">

//create a javascript object for each council Type
var objCo =new Object;
objCo.Country="#JSStringFormat(qry.Country)#";
objCo.CouncilType="#JSStringFormat(qry.CouncilType)#";
//append object into the end of array
arrCouncils[arrCouncils.length]=objCo;

</cfloop>
</cfoutput>


//this function fills the second select box based on the 1st box
function FillCouncilType() {
 
 //stop council type select from being displayed 
  document.getElementById('CouncilType').style.display='none';
  //remove all option from the council type select box
  document.getElementById('CouncilType').options.length=0;
 //get currently selected country from the 1st select box
  var Country  = document.getElementById('Country').value;
  var stattype = document.getElementById('stattype').value;
 
  //stop here if there is no selectd rating
  if(Country == "England"){
	
	//Create an option for "any"
	var objOption=new Option("[Any Council Type]", "" );
	//loop over array
	for(var i=0; i < arrCouncils.length; i++) {
	   //add the option to select that hold "[any]"
	    document.getElementById('CouncilType').options[0]=objOption;

		
		//if the country is the same as the currently selected value
		if(arrCouncils[i].Country == Country){
		    
			//only place options in select if they comply with usniess rules
			if (stattype == 'Education' && arrCouncils[i].CouncilType != 'District' || stattype == 'Leisure' && arrCouncils[i].CouncilType != 'County' || stattype == 'Recycling' && arrCouncils[i].CouncilType != 'County' || stattype == 'Transport' && arrCouncils[i].CouncilType != 'London' )
			 //create a new visual <option> to place in the council type select box
			 var objOption1=new Option(arrCouncils[i].CouncilType, arrCouncils[i].CouncilType);
			else
			   //create a new visual <option> to place in the council type select box
			  var objOption1=new Option(arrCouncils[i].CouncilType, arrCouncils[i].CouncilType);
	
			 //loop over council type select box
			 with(document.getElementById('CouncilType')){
				//add options to select based on 1st select
				options[options.length]=objOption1;
			
			}
 		}
		//open select element to allow council type to be displayed 
		document.getElementById('CouncilType').style.display="block";
 		}
     
	}
	
 };
 
</script>
</cfsavecontent>
<cfhtmlhead text="#jsSelects#">

<cfsavecontent variable="savecont">
<table  border="0" cellspacing="0">
  <tr>
    <td><!---stat type select--->
<select name="stattype" class="dropbox" id="stattype" onchange="FillCountry()">
   	<cfoutput query="qryStats">
			<option value="#datavalue#">#datavalue#</option>
      </cfoutput>
    </select></td>
    <td ></td>
    <td><!---Councils Country Select--->
<select name="Country" id="Country"   class="dropbox" onchange="FillCouncilType()">
      <option value="">[Any Country]</option>
      <cfoutput query="qryCountries">
	    <cfif datavalue eq "England" OR datavalue eq "Wales">
        <option value="#datavalue#">#datavalue#</option>
		</cfif>
      </cfoutput></select></td>
    <td ></td>
    <td> <!---Councils Type Select (based on value of country)--->
	<select name="CouncilType"   class="dropbox" id="CouncilType">
      <option value="">[Any Council Type] </option>
    </select></td>
    <td></td>
    <td><cfoutput><input type="image" src="#request.strSiteConfig.strPaths.assets#/furniture/go.gif" id="submitstats" name="sumbit" 
			onclick="this.disabled=true;GetCouncilStats('',1);"
			value="go" 
			class=""/></cfoutput><!--- this.disabled=true;"  Re - enable form in js (once ajax call has been rendered)---></td>
  </tr>
</table>
</cfsavecontent>

<!--- Return releted selects to calling page --->
<cfset caller.counilselects = savecont>