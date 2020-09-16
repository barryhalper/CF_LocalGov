<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/COMPONENTS/BusinessObjects/AutoLinker.cfc $
	$Author: Bhalper $
	$Revision: 1 $
	$Date: 8/08/07 10:06 $

--->

<cfcomponent displayname="AutoLinker" hint="Directory-linking -related functions, inheriting any common business-related functions." extends="his_Localgov_Extends.components.BusinessObjectsManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- FUNCTION: init()... --------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="AutoLinker" hint="Pseudo-constructor">
	
		<cfargument name="objAppObjs" type="any" required="yes" hint="The application manager object">
		
		<cfscript>
		// Call the genric init function, placing business, app, and dao objects into a local scope...
		StructAppend( variables, Super.initChild( objAppObjs=arguments.objAppObjs, objChild=this, bHasDAO=false ) );
		
		return this;
		</cfscript>
				
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions ------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="convertToMagFriendly" access="public" output="false" returntype="string" hint="returns a tring containing a magazine-friendly version of the passed name">

		<cfargument name="sOrg" required="yes" type="string" hint="string holding the organisation name, specifically central government names">
		
		<cfscript>
		/* NB: This regular expression attempt to do two things:

				1) Reformat Departments of/for...		
					e.g.	before: International Development, Department for 
							after:	Department for International Development
					
				2) Reformat The...
					e.g. 	before:	Isle of Man, The
							after:	The Isle of Man  
		*/

		// Construct the in and out regular expressions...
		var sRegEx_MYB = "([[:alnum:]*|,| ]*)((, Department [for|or]*)|, The)"; 
		var sRegEx_Mag = "\2 \1";
		
		// Parse the organisation name...
		var sOrg_Mag = REReplaceNoCase(	
							arguments.sOrg, 
							sRegEx_MYB, 
							sRegEx_Mag 
						);
		
		// Check whether we need to trim the ", " from the start...
		if (sOrg_Mag neq arguments.sOrg)
			sOrg_Mag = Mid( sOrg_Mag, 3, Len(sOrg_Mag)-2 );
		
		// Return the converted, magazine-friendly, organisation name...
		return sOrg_Mag;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="cleanFullname" access="public" output="false" returntype="string" hint="">

		<cfargument name="sName" required="yes" type="string" hint="">

		<cfreturn trim( REReplace( trim( arguments.sName ), "Rt Hon|, MP|The|\+|\(|\)", "", "all" ) )>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PRIAVTE Functions ----------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->

</cfcomponent>