<!--
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/customtags/RegionRelatedSelects.cfm $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 14/08/07 14:53 $

-->

<!---CREATE SELECTS FOR COUNTIES & REGIONS WHERE REGIONS ARE RELATED 2 COUNTIES --->


<cfparam name="attributes.strSelects" default="">

<!---Build query object to hold stats and the related types--->

<script language="javascript" type="text/javascript">

//array to hold country objects
var arrCounties = new Array;


<cfoutput query="attributes.strSelects.qrycounties">
//create a javascript object for each council Type
var objC =new Object;
objC.regionid=#regionid#;
objC.county="#JSStringFormat(county)#";
objC.countyid=#countyid#;
//append object into the end of array
arrCounties[arrCounties.length]=objC;
</cfoutput>


function FillCounties(){
 

 var regionid =  document.getElementById('regionid').value;
 
 //alert(regionid)
 
 if (regionid == '')
	document.getElementById('countyid').style.display='none';
  else
    document.getElementById('countyid').style.display='block';	
 
 //remove all option from the 'county' select box 
 document.getElementById('countyid').options.length=0;
 //var objAnyOption=new Option("[All Counties]", "" ); 
 
 
  //loop over array
 for(var i=0; i < arrCounties.length; i++) {
 //add the option to select that hold "[any]"
 
  //document.getElementById('countyid').options[0]=objAnyOption;
  if(arrCounties [i].regionid == regionid){
 	//create a new visual <option> to place in the 2nd select box
	var objOption=new Option(arrCounties[i].county, arrCounties[i].countyid);
	 //place the new option in the 2nd select box
	  with(document.getElementById('countyid')){
		//add the option to select that hold "[any]"
		//add options to select based on 1st select
	    options[options.length]=objOption;
		}
	}
	 //set size of select to equal no. options	 	
	 //document.getElementById('countyid').size=document.getElementById('countyid').options.lenght;
  }
}; 

/*function SelectCounties(){
	//var regionid = document.getElementById('regionid');
	var countyid = document.getElementById('countyid');
	//check if user has selected 'all'
	if (countyid.value == ""){
		//pre-select all options
		for(var i = 0; i < countyid.length; i++){
    		countyid.options[i].selected =true;
 			} 
		//unselect 1st option (all)	
		countyid.options[0].selected = false;	
	}
}*/

</script>


<cfsavecontent variable="savecont">

<table border="0" cellspacing="0" cellpadding="0" >
  <tr height="">
    <td><!---Region Select --->
<select name="regionid" class="smtext" id="regionid" onChange="FillCounties()">
  <option value="">[please select a region]</option>
  <cfoutput query="attributes.strSelects.qryRegions">
       <option value="#regionid#">#region#</option></cfoutput>
    </select></td><td width="3"></td>
    <td><select name="countyid" id="countyid" class="smtext">
    </select></td>
  </tr>
</table>




 
<script type="text/javascript" language="javascript">FillCounties();</script>
</cfsavecontent>

<!--- Return releted selects to calling page --->
<cfset caller.regionselects = savecont>