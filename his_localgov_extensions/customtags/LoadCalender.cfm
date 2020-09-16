

<!---Pass list of Input Fields and button to custom tag to generate JS--->
<cfoutput>
<cfsavecontent variable="js">
<!--- Include appropriate javascript function... --->
<!-- main calendar program -->
<script type="text/javascript" language="javascript" src="#request.sAdminPath#extends/jscalendar/calendar.js"></script>
<!-- language for the calendar -->
<script type="text/javascript" language="javascript" src="#request.sAdminPath#extends/jscalendar/lang/calendar-en.js"></script>
<!-- the following script defines the Calendar.setup helper function, which makes adding a calendar a matter of 1 or 2 lines of code. -->
<script type="text/javascript" language="javascript" src="#request.sAdminPath#extends/jscalendar/calendar-setup.js"></script>
<link rel="stylesheet" type="text/css" media="all" href="#request.sAdminPath#extends/jscalendar/calendar-system.css" title="win2k-cold-1" />
</cfsavecontent>

<cfhtmlhead text="#js#">
</cfoutput>
<cfparam name="attributes.inputField" default="">
<cfparam name="attributes.button" 	  default="">
<cfparam name="attributes.showtime" 	  type="boolean" default="true">

<cfif attributes.showtime>
	<cfset ifFormat =  "%d/%m/%Y %H:%M">
<cfelse>
	<cfset ifFormat =  "%d/%m/%Y">
</cfif>



<cfoutput>

	<cfloop list="#attributes.inputField#" index="i"> 
		<script type="text/javascript" language="javascript">
		
		Calendar.setup({
			inputField     :    "#JSStringFormat(i)#",     	// id of the input field
			ifFormat       :    "#ifFormat#",   // format of the input field
			showsTime      :    true,            	// will display a time selector
			button         :    "#JSStringFormat(ListGetAt(attributes.button, ListFindNoCase(attributes.inputField, i)))#",   	// trigger for the calendar (button ID)
			singleClick    :    true,           	// double-click mode
			step           :    1,                	// show all years in drop-down boxes (instead of every other year as default)
			
		});
		
		</script>
	</cfloop>
</cfoutput> 



