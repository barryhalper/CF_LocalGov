<cfparam name="attributes.accountno"  type="string" default=""><!--- this is now a accepts list variable so more than one google account can be used for a single webiste --->
<cfparam name="attributes.pagetitle"  type="string" default="">

<cfscript>
delim ='/' ;
attributes.pagetitle = replace(attributes.pagetitle, ' &gt; ', delim, 'all');
attributes.pagetitle = replace(attributes.pagetitle, "LocalGov.co.uk - Your authority on UK Local Government/", "");
</cfscript>

<cfoutput>
	
<script src="http://www.google-analytics.com/urchin.js" type="text/javascript">
</script>
	
	<cfloop list="#attributes.accountno#" index="i">
		<script type="text/javascript">
		try {
			_uacct = "#i#";
			<cfif Len(attributes.pagetitle)>urchinTracker("/#attributes.pagetitle#");<cfelse>urchinTracker();</cfif>
			} 
			catch(err) {}
		</script>
	</cfloop>

</cfoutput>