<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/ApplicationObjects/string.cfc $
	$Author: Bhalper $
	$Revision: 17 $
	$Date: 5/11/09 16:13 $

--->

<cfcomponent hint="String-related functions.">

	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<cffunction name="createRandomString" access="public" hint="Creates a string of random alphanumerics of a specified size" output="false" returntype="string">
		<cfargument name="size" required="no" default="8" type="numeric" hint="size of string to create">
		<cfscript>
		var i = 0;
		var j = 0;
		var string = "";
		var char = "";
		
		for (i=1; i lte arguments.size * 100; i=i+1) {
			char = chr(randRange(48,90));
			if (not reFind("\:|\;|\<|\=|\>|\?|\@", char)) {
				string = string & char;
				j=j+1;
			}
			if (j gte arguments.size) break;
		}
		return string;
		
		</cfscript>
	</cffunction>
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<cffunction name="IsValidEmail" access="public" hint="Checks an email address is valid" output="false">
		<cfargument name="email" required="yes" hint="email address to check" type="string">
		<cfif (findnocase('@',arguments.email) is 0)
				or (right(arguments.email,1) is "@")
				or (left(arguments.email,1) is "@")
				or (findnocase('@',arguments.email,(findnocase('@',arguments.email) + 1)) is not 0)
				or (findnocase('.',arguments.email) is 0)
				or (right(arguments.email,1) is ".")
				or (left(arguments.email,1) is ".")
				or (REFind("[, *()><:;""]",arguments.email))>
			<cfreturn false>
		<cfelse>
			<cfreturn true>
		</cfif>
	</cffunction>
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<cffunction name="StripASCII" returntype="string" access="public" hint="" output="false">
		<cfargument name="String" type="string" required="yes">
		
		<cfscript>
		var thisChar = "";
		var thisCode = "";
		var newString = "";
		
		for (i=1; i LTE Len(Arguments.String); i=i+1) {
			thisChar = Mid(Arguments.String, i, 1);
			switch (ASC(thisChar)) {
				case 198: {
					thisChar = CHR(39);	break;
				}
				case 244: {
					thisChar = CHR(34);	break;
				}
				case 246: {
					thisChar = CHR(34);	break;
				}
				case 96: {
					thisChar = CHR(39);	break;
				}
				default: {
					thisCode = ASC(thisChar);
					if (thisCode EQ 124 OR thisCode GTE 127) {
						thisChar = IIf(Strip, DE(""), DE("&####" & thisCode & ";"));
					}
					break;
				}
			}
			newString = newString & thisChar;
		}
		return newString;
		</cfscript>
	
	</cffunction>
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<cffunction access="public" name="CleanJSString" returntype="string" hint="removes characters that make the browser think a JS string is terminated" output="false">
		<!--- arguments --->
		<cfargument name="text" required="yes" type="string">
		<!--- Clean the string. TODO: fancy regex? --->
		<cfset arguments.text = Replace(arguments.text,"'","&##39;","ALL")>
		<cfset arguments.text = Replace(arguments.text,chr(13)," ","ALL")>
		<cfset arguments.text = Replace(arguments.text,chr(10)," ","ALL")>
		<cfreturn arguments.text>
	</cffunction>
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<cffunction name="StripHTML" access="public" returntype="string" output="false">
		<cfargument name="text" required="yes" type="string">
		<cfreturn REReplace(arguments.text, "<[^>]*>", "", "All")>
	</cffunction>
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<cffunction name="StripImageHTML" access="public" returntype="string" output="false">
		<cfargument name="text" required="yes" type="string">
		<cfreturn REreplacenocase(arguments.text,"<(img|/?object|param|embed)[^<]*>","","all")>
	</cffunction>
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<cffunction name="StripUnclosedTags" access="public" returntype="string" output="false" hint="Strip unclosed html tags ">
		<cfargument name="text" required="yes" type="string">
			<cfscript>
			var strippedcontext 	= rereplace(arguments.text, "<.*?>", "", "all");
			strippedcontext 		= rereplace(strippedcontext, "<.*?$", "", "all");
			strippedcontext 		= rereplace(strippedcontext, "^.*?>", "", "all");
			return strippedcontext;
			</cfscript>
		
	</cffunction>
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<cffunction name="StripImg" access="public" returntype="string" output="false">
		<cfargument name="text" required="yes" type="string">
		<cfreturn REReplace(arguments.text, "<img [^>]*>|</img>", "", "All")>
	</cffunction>
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<cffunction name="StripFont" access="public" returntype="string">
		<cfargument name="text" required="yes" type="string">
		<cfreturn REReplaceNoCase(arguments.text, "<font [^>]*>|</font>", "", "All")>
	</cffunction>
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<cffunction name="StripBR" access="public" returntype="string" output="false">
		<cfargument name="text" required="yes" type="string">
		<cfargument name="extent" required="no" type="string" default="all">
		<cfreturn ReplaceNoCase(arguments.text, "<br>", " ", arguments.extent)>
	</cffunction>
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<cffunction name="StripNBSP" access="public" returntype="string" output="false">
		<cfargument name="text" required="yes" type="string">
		<cfreturn ReplaceNoCase(arguments.text, "&nbsp;", "", "All")>
	</cffunction>
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<cffunction name="ReplaceNewLines" access="public" returntype="string" output="false">
		<cfargument name="text" required="yes" type="string">
		<cfreturn REReplace(arguments.text, "#Chr(10)#|#Chr(13)#", "<br>", "All")>
	</cffunction>
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!---Begin ListUnique() Function --->
	 <cffunction name="ListUnique" access="public" returntype="string" output="false" hint="rewrite lst var to only contain unique elements">
	 	<cfargument name="list" required="yes" type="string">
		<cfargument name="delimiter" required="yes" type="string" default=",">
	 		
			<cfset var lstReturn ="">
			<cfloop list="#arguments.list#" index="i" delimiters="#arguments.delimiter#">
				<cfscript>
				if (NOT ListFindNoCase(lstReturn, i,arguments.delimiter))
					//only set those values not already present in list var
		 			lstReturn = ListAppend(lstReturn, i, arguments.delimiter);
			 	</cfscript>
			</cfloop>
	 
	 	<cfreturn lstReturn>
	 </cffunction>
	<!---  ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<cffunction name="HighLight" access="public" hint="Highlights keywords within a string" output="false">
		<cfargument name="source" required="yes" type="string">		
		<cfargument name="lookfor" required="yes" type="string">
		

		<cfscript>
		/**
		* Applies a simple highlight to a word in a string.
		* Original version by Raymond Camden.
		* 
		* @param string 	 The string to format. (Required)
		* @param word 	 The word to highlight. (Required)
		* @param front 	 This is the HTML that will be placed in front of the highlighted match. It defaults to <span style= (Optional)
		* @param back 	 This is the HTML that will be placed at the end of the highlighted match. Defaults to </span> (Optional)
		* @param matchCase 	 If true, the highlight will only match when the case is the same. Defaults to false. (Optional)
		* @return Returns a string. 
		* @author Dave Forrest (dmf67@yahoo.com) 
		* @version 2, June 12, 2003 
		*/
		
		var tmpOn       = "[;;^";
		var tmpOff      = "^;;]";
		var hilightitem	= "<SPAN STYLE=""background-color:yellow;"">";
		var endhilight  = "</SPAN>";
		var matchCase   = false;
		var obracket    = "";
		var tmps		= "";
		var stripperRE  = "";
		var badTag		= "";
		var nextStart	= "";
		
		if(ArrayLen(arguments) GTE 3) hilightitem = arguments[3];
		if(ArrayLen(arguments) GTE 4) endhilight  = arguments[4];
		if(ArrayLen(arguments) GTE 5) matchCase   = arguments[5];
		if(NOT matchCase) 	source = REReplaceNoCase(source,"(#lookfor#)","#tmpOn#\1#tmpOff#","ALL");
		else 				source = REReplace(source,"(#lookfor#)","#tmpOn#\1#tmpOff#","ALL");
		obracket   = find("<",source);
		stripperRE = "<.[^>]*>";	
		while(obracket){
			badTag = REFindNoCase(stripperRE,source,obracket,1);
			if(badTag.pos[1]){
				tmps 	  = Replace(Mid(source,badtag.pos[1],badtag.len[1]),"#tmpOn#","","ALL");
				source 	  = Replace(source,Mid(source,badtag.pos[1],badtag.len[1]),tmps,"ALL");
				tmps 	  = Replace(Mid(source,badtag.pos[1],badtag.len[1]),"#tmpOff#","","ALL");
				source 	  = Replace(source,Mid(source,badtag.pos[1],badtag.len[1]),tmps,"ALL");
				nextStart = badTag.pos[1] + badTag.len[1];
			}
			else nextStart = obracket + 1;
			obracket = find("<",source,nextStart);
		}
		source = Replace(source,tmpOn,hilightitem,"ALL");
		source = Replace(source,tmpOff,endhilight,"ALL");
		return source;
		
	</cfscript>
	</cffunction>
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<cffunction name="SQLFriendlyList" access="public" returntype="string" output="false" hint="prepare list to be used in SQL 'IN' Operator">
		<cfargument name="list" required="yes" type="string">
		<cfset var i = "">
		<cfset var lst = "">
		<cfset var item = "">
		<cfloop list="#arguments.list#" index="i">
			<cfset item = chr(39) & i & chr(39)>
			<cfset lst = ListAppend(lst, item)>
		</cfloop>
		<cfreturn lst>
		
	</cffunction>
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<cffunction name="SentenceCase" access="public" returntype="string" output="false" hint="takes a string and returns it in sentence case format.">
		<cfargument name="string" required="yes" type="string">

		<cfscript>
		var i = "";
		var rtnString = ucase(mid(arguments.string, 1, 1));
				
		for (i=2; i LTE Len(arguments.string); i=i+1)
			rtnString = rtnString & lcase(mid(arguments.string, i, 1));
		
		return rtnString;
		</cfscript>
	
	</cffunction>
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<!--- ---------------------------------------------------------------------------------------------------------------->
	<cffunction name="CapFirst" access="public" returntype="string" output="false" hint="Returns the string with the first character of each word capitalized.">
		<cfargument name="str" required="yes" type="string">
		
		<cfscript>
		var newstr = "";
		var word = "";
		var i = 1;
		var strlen = listlen(str," ");
		for(i=1;i lte strlen;i=i+1) {
			word = ListGetAt(str,i," ");
			newstr = newstr & UCase(Left(word,1));
			if(len(word) gt 1) newstr = newstr & Right(word,Len(word)-1);
			if(i lt strlen) newstr = newstr & " ";
		}
		return newstr;
		</cfscript>
		</cffunction>
	<!------------------------------------------------------------------------------------------------------------>
	<!--- -------------------------------------------------------------------------------------------------------->
	<!--- --------------------------------------------------------------------------------------------------------->
	<cffunction name="Struct2QueryString" access="public" output="false" returntype="string" hint="turn structure		key/value pairs into url query string">
		<cfargument name="str" 			required="yes" type="struct">
		<cfargument name="ignorelist" required="yes"   type="string" default="fieldnames,startrownext" hint="list of keys not to be included">
		
		<cfscript>
		var querystring = "";
		var key ="";
		var i ="";
		
		for (i in arguments.str){
			try{
			if (NOT listFindNocase(arguments.ignorelist, i)){
				key = replace(replace(lcase(i),'mc_','MC_'),'m_','M_') & "=" & UrlEncodedFormat(arguments.str[i]);
				querystring = ListAppend(querystring, key, "&amp;");
			}}
			catch(Any e){}
			
		 }	
		return 	querystring;
		</cfscript>

	</cffunction>
	<!------------------------------------------------------------------------------------------------------------>
	<!--- -------------------------------------------------------------------------------------------------------->
	<!--- --------------------------------------------------------------------------------------------------------->
	<cffunction name="spiltOptionString" access="public" output="false" returntype="string" hint="return list of either the integrs or the values paased in a concatentaed list - often useed in piple delimeted option value">
		<cfargument name="string" required="yes" type="string">
		<cfargument name="element" required="yes" type="string" default="before" hint="pass either 'before' or 'before' to return  list elements types ">
		<cfargument name="delim" required="no" type="string" default="|">
		
		<cfscript>
		var lst = "";
		var i 	= 0;
		var pos = "";
		//convert list to array
		var arr =  listToArray(arguments.string);
		//loop over array
		for (i=1;i LTE arrayLen(arr);i=i+1 ){
		 //get a position	
		 pos = Find(arguments.delim, arr[i]);
			//get list of elemnets  before the delim (being the integers)
			if (arguments.element eq 'before')
				lst = ListAppend(lst, left(arr[i], pos - 1));
					
			else	
				//get list of elemnets after the delim (being the integers)
				lst = ListAppend(lst, mid(arr[i], pos + 1, Len(arr[i])));
			}
		return 	lst;
		</cfscript>

	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------------->
	<!--- --------------------------------------------------------------------------------------------------------->
	<cffunction name="SQLSafe" access="public" returntype="string" output="false" hint="Cleans string of potential sql injection">
	<cfargument name="string" required="yes" type="string">
		<cfscript>		
		  var sqlList = "-- ,',*,%,(,),";
		  //var replacementList = "#chr(38)##chr(35)##chr(52)##chr(53)##chr(59)##chr(38)##chr(35)##chr(52)##chr(53)##chr(59)# , #chr(38)##chr(35)##chr(51)##chr(57)##chr(59)##chr(40)##chr(41)#";
		  
		  return trim(replaceList( arguments.string , sqlList , '' ));
		
		</cfscript>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------>
	<!--- ------------------------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="RemoveNoiseWords" access="public" returntype="string" output="false" hint="takes a string and removes all noise words">
		<cfargument name="noisewords"  required="yes" type="string">
		<cfargument name="string" required="yes" type="string">

		<cfreturn REReplaceNoCase(arguments.string, ListChangeDelims(arguments.noisewords,'|'), "","ALL")>
	
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------>
	<!--- ------------------------------------------------------------------------------------------------------>
	<!--- ------------------------------------------------------------------------------------------------------>
	<cffunction name="stringtodate" access="public" returntype="date" output="false" hint="takes an 8 charachter string and returns a date">
		<cfargument name="string" required="yes" type="string">
		
		<cfscript>
		var syear  = left(arguments.string, 4);
		var sday =   right(arguments.string, 2);
		var smonth = mid(arguments.string,5,2);
		return  CreateDate(syear,smonth, sday);
		</cfscript>
	</cffunction>
	<!-- ------------------------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="xmlstring2date" access="public" returntype="string" hint="takes a zml date string and turns it into cf date">
		<cfargument name="string" required="yes" type="string">
		
		<cfscript>
		var date 		= arguments.string;
		var time	    = "00:00:00";
		
		If (listContains(date, "T"))
			date 		= ListgetAt(arguments.string, 1, "T");
		
		If (ListLen(arguments.string, "T") GT 1)
		  time 		= ListgetAt( ListgetAt(arguments.string, 2, "T"), 1, "-");
		
		try{
			date & ' ' & LSTimeFormat(time, 'HH:mm:ss');
			}
			catch(any expception){
				date & ' ' & time;
			}
		
		
		return 	date;
		</cfscript>
	</cffunction> 
	<!--- ------------------------------------------------------------------------------------------------------>
	<!--- ------------------------------------------------------------------------------------------------------>
	<!--- ------------------------------------------------------------------------------------------------------>
	<cffunction name="findInSES" access="public" returntype="string" output="false" hint="find url variables in SES converted query sting">
		<cfargument name="queryString" required="yes" type="string">
		<cfargument name="string" 	   required="yes" type="string">
		
		<cfscript>
		var arrQueryString =ListToArray(arguments.queryString,"/");
		var i =0;
		var sReturn ="";
		for (i=1; i lte ArrayLen(arrQueryString);i=i+1){
			if (arrQueryString[i] contains arguments.string ){
				sReturn = ListGetAt(arrQueryString[i], 2, "=");
				break;}
		}
		return 	sReturn;	
		</cfscript>
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------>
	<!--- ------------------------------------------------------------------------------------------------------>
	<!--- ------------------------------------------------------------------------------------------------------>
	<cffunction name="regxMatch" output="FALSE" access="public">
		<cfargument name="regEx" type="string" required="TRUE" />
		<cfargument name="string" type="string" required="TRUE" />
		<cfargument name="start" type="numeric" required="FALSE" default="1" />
		<cfargument name="scope" type="string" required="FALSE" default="ONE" />
		<cfargument name="returnLenPos" type="boolean" required="FALSE" default="FALSE" />
		<cfargument name="caseSensitive" type="boolean" required="FALSE" default="TRUE" />
		<cfset var thisMatch = "" />
		<cfset var matchInfo = structNew() />
		<cfset var matches = arrayNew(1) />
		<!--- Set the time before entering the loop --->
		<cfset var timeout = now() />
		
		<!--- Build the matches array. Continue looping until additional instances of regEx are not found. If scope is "ONE", the loop will end after the first iteration --->
		<cfloop condition="TRUE">
			<!--- By using returnSubExpressions (the fourth reFind argument), the position and length of the first match is captured in arrays named len and pos --->
			<cfif caseSensitive>
				<cfset thisMatch = reFind(regEx, string, start, TRUE) />
			<cfelse>
				<cfset thisMatch = reFindNoCase(regEx, string, start, TRUE) />
			</cfif>
			
			<!--- If a match was not found, end the loop --->
			<cfif thisMatch.pos[1] EQ 0>
				<cfbreak />
			<!--- If a match was found, and extended info was requested, append a struct containing the value, length, and position of the match to the matches array --->
			<cfelseif returnLenPos>
				<cfset matchInfo.value = mid(string, thisMatch.pos[1], thisMatch.len[1]) />
				<cfset matchInfo.len = thisMatch.len[1] />
				<cfset matchInfo.pos = thisMatch.pos[1] />
				<cfset arrayAppend(matches, matchInfo) />
			<!--- Otherwise, just append the match value to the matches array --->
			<cfelse>
				<cfset arrayAppend(matches, mid(string, thisMatch.pos[1], thisMatch.len[1])) />
			</cfif>
			
			<!--- If only the first match was requested, end the loop --->
			<cfif scope IS "ONE">
				<cfbreak />
			<!--- If the match length was greater than zero --->
			<cfelseif thisMatch.pos[1] + thisMatch.len[1] GT start>
				<!--- Set the start position for the next iteration of the loop to the end position of the match --->
				<cfset start = thisMatch.pos[1] + thisMatch.len[1] />
			<!--- If the match was zero length --->
			<cfelse>
				<!--- Advance the start position for the next iteration of the loop by one, to avoid infinite iteration --->
				<cfset start = start + 1 />
			</cfif>
			
			<!--- If the loop has run for 20 seconds, throw an error, to mitigate against overlong processing. However, note that even one pass using a poorly-written regex which triggers catastrophic backtracking could take longer than 20 seconds --->
			<cfif dateDiff("s", timeout, now()) GTE 20>
				<cfthrow message="Processing too long. Optimize regular expression for better performance" />
			</cfif>
		</cfloop>
		
		<cfif scope IS "ONE">
			<cfparam name="matches[1]" default="" />
			<cfreturn matches[1] />
		<cfelse>
			<cfreturn matches />
		</cfif>
</cffunction>
	
	
	
	<!--- ------------------------------------------------------------------------------------------------------>
	<!--- ------------------------------------------------------------------------------------------------------>
	<!--- ------------------------------------------------------------------------------------------------------>
	<cffunction name="FormatTeaser" output="FALSE" access="public" returntype="string">
		<cfargument name="string" type="string" required="TRUE" />
		<cfargument name="number" type="numeric" required="TRUE" />
			<cfscript>
			/**
			* Displays n number of characters from a string without cutting off in the middle of a word
			* Code used from FullLeft
			*
			* @param string      String to be modified. (Required)
			* @param number      Number of characters to include in teaser. (Required)
			* @param urlArgument      URL to use for 'more' link. (Optional)
			* @return Returns a string.
			* @author Bryan LaPlante (blaplante@netwebapps.com)
			* @version 3, July 31, 2003
			*/
			
				var urlArgument = "";
				var shortString = "";
				
				//return quickly if string is short or no spaces at all
				if(len(string) lte number or not refind("[[:space:]]",string)) return string;
				
				if(arrayLen(arguments) gt 2) urlArgument = "... <a href=""" & arguments[3] & """>[more]</a>";
			
				//Full Left code (http://www.cflib.org/udf.cfm?ID=329)
				if(reFind("[[:space:]]",mid(string,number+1,1))) {
					 shortString = left(string,number);
				} else {
					if(number-refind("[[:space:]]", reverse(mid(string,1,number)))) shortString = Left(string, (number-refind("[[:space:]]", reverse(mid(string,1,number)))));
					else shortString = left(str,1);
				}
				
				return shortString & urlArgument;
			
			</cfscript>
		</cffunction>	
	<!--- ------------------------------------------------------------------------------------------------------>
	<!--- ------------------------------------------------------------------------------------------------------>
	<!--- ------------------------------------------------------------------------------------------------------>	
	<cffunction name="filterFilename" access="public" returntype="string" output="false" hint="I remove any special characters from a filename and replace any spaces with underscores.">
		<cfargument name="filename" type="string" required="true" />
		<cfset var filenameRE = "[" & "'" & '"' & "##" & "/\\%&`@~!,:;=<>\+\*\?\[\]\^\$\(\)\{\}\|]" />
		<cfset var newfilename = reReplace(arguments.filename,filenameRE,"","all") />
		<cfset newfilename = replace(newfilename," ","_","all") />
		
    <cfreturn newfilename />
	</cffunction>
	<!--- ------------------------------------------------------------------------------------------------------>
	<!--- ------------------------------------------------------------------------------------------------------>
	<!--- ------------------------------------------------------------------------------------------------------>	
	<cffunction name="DeMoronize" access="public" output="no" returntype="string" hint="Fixes text using Microsoft Latin-1 Extensions, namely ASCII characters 128-160 and UniCode characters">
		 <cfargument name="inputString" type="string" required="yes" hint="String to DeMoronize">
		 <cfscript>
		  var i = 0;
		  var rt = trim(arguments.inputString);
		  
		  // map incompatible non-ISO characters into plausible
		  // substitutes
		  rt = Replace(rt, Chr(128), "&euro;", "All");
		  rt = Replace(rt, Chr(8364), "&euro;", "All");
		 
		  rt = Replace(rt, Chr(130), ",", "All");
		  rt = Replace(rt, Chr(8218), ",", "All");
		
		  rt = Replace(rt, Chr(131), "<em>f</em>", "All");
		  rt = Replace(rt, Chr(402), "<em>f</em>", "All");
		
		  rt = Replace(rt, Chr(132), ",,", "All");
		  rt = Replace(rt, Chr(8222), ",,", "All");
		
		  rt = Replace(rt, Chr(133), "...", "All");
		  rt = Replace(rt, Chr(8230), "...", "All");
		   
		  rt = Replace(rt, Chr(136), "^", "All");
		  rt = Replace(rt, Chr(710), "^", "All");
		 
		  rt = Replace(rt, Chr(139), ")", "All");
		  rt = Replace(rt, Chr(8249), ")", "All");
		
		  rt = Replace(rt, Chr(140), "Oe", "All");
		  rt = Replace(rt, Chr(338), "Oe", "All");
		 
		  rt = Replace(rt, Chr(145), "`", "All");
		  rt = Replace(rt, Chr(8216), "`", "All");
		
		  rt = Replace(rt, Chr(146), "'", "All");
		  rt = Replace(rt, Chr(8217), "'", "All");
		
		  rt = Replace(rt, Chr(147), """", "All");
		  rt = Replace(rt, Chr(8220), """", "All");
		
		  rt = Replace(rt, Chr(148), """", "All");
		  rt = Replace(rt, Chr(8221), """", "All");
		
		  rt = Replace(rt, Chr(149), "*", "All");
		  rt = Replace(rt, Chr(8226), "*", "All");
		
		  rt = Replace(rt, Chr(150), "-", "All");
		  rt = Replace(rt, Chr(8211), "-", "All");
		
		  rt = Replace(rt, Chr(151), "--", "All");
		  rt = Replace(rt, Chr(8212), "--", "All");
		
		  rt = Replace(rt, Chr(152), "~", "All");
		  rt = Replace(rt, Chr(732), "~", "All");
		
		  rt = Replace(rt, Chr(153), "&trade;", "All");
		  rt = Replace(rt, Chr(8482), "&trade;", "All");
		 
		  rt = Replace(rt, Chr(155), ")", "All");
		  rt = Replace(rt, Chr(8250), ")", "All");
		
		  rt = Replace(rt, Chr(156), "oe", "All");
		  rt = Replace(rt, Chr(339), "oe", "All");
		 
		  // remove any remaining ASCII 128-159 characters
		  for (i = 128; i LTE 159; i = i + 1)
		   rt = Replace(rt, Chr(i), "", "All");
		 
		  // map Latin-1 supplemental characters into
		  // their &name; encoded substitutes
		  rt = Replace(rt, Chr(160), "&nbsp;", "All");
		 
		  rt = Replace(rt, Chr(163), "&pound;", "All");
		 
		  rt = Replace(rt, Chr(169), "&copy;", "All");
		 
		  rt = Replace(rt, Chr(176), "&deg;", "All");
		 
		  // encode ASCII 160-255 using 'square' format
		  for (i = 160; i LTE 255; i = i + 1)
		   rt = REReplace(rt, "(#Chr(i)#)", "&###i#;", "All");
		  
		  // supply missing semicolon at end of numeric entities
		  rt = ReReplace(rt, "&##([0-2][[:digit:]]{2})([^;])", "&##\1;\2", "All");
		  
		  // fix obscure numeric rendering of &lt; &gt; &amp;
		  rt = ReReplace(rt, "&##038;", "&amp;", "All");
		  rt = ReReplace(rt, "&##060;", "&lt;", "All");
		  rt = ReReplace(rt, "&##062;", "&gt;", "All");
		 
		  // supply missing semicolon at the end of &amp; &quot;
		  rt = ReReplace(rt, "&amp(^;)", "&amp;\1", "All");
		  rt = ReReplace(rt, "&quot(^;)", "&quot;\1", "All");
		 
		 </cfscript>
		 <cfreturn rt />
		</cffunction>	
	
	</cfcomponent>