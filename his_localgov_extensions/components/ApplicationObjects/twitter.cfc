<cfcomponent displayname="Twitter">
	
    <!--- -------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR -------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
    
    <cffunction name="formatDate" returntype="string" output="false" hint="returns date/time string based on time of tweet">
		<cfargument name="dateTime" type="date" required="yes">
       
		
        <cfscript>
			var s = "";
			var today = now();
			var numHours = 0;
			var numMins = 0;
			d = dateTime;
			if (DateDiff("d", d, today ) lt 1){
				if (DateDiff("h", d, today) lt 1)
					numMins = DateDiff("n", d, today);
				else	
				numHours = DateDiff("h", d, today ) ;	
			}
			switch(numHours){
				case 0:{
					if (numMins gt 0) 
						s= numMins & " mins ago";
					else
						s= DateFormat(d, "dd mmm");
				break;}
				case 1:
				s = numHours & " hour ago";
				break;
				default: 
				s = numHours & " hours ago";
		}
		 return s;
		</cfscript> 
        
	</cffunction>


	 <cffunction name="createLinks" returntype="string" output="false" hint="returns a string with tweet links and hastages linked ">
		<cfargument name="tweet" type="string" required="yes">
       
        <cfscript>
			var s = request.objApp.objUtils.ActivateURL(arguments.tweet, "_blank");
			return ReReplaceNoCase(s, "([^&]|^)##([a-z0-9_\-]+)", "\1<a href=""http://twitter.com/search?q=%23\2"">##\2</a>", "ALL");
		
		</cfscript> 
        
	</cffunction>
</cfcomponent>