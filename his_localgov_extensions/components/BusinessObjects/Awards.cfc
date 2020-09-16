<!--- 
	
	$Archive: /localgov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/BusinessObjects/Awards.cfc $
	$Author: Ohilton $
	$Revision: 4 $
	$Date: 10/12/09 11:00 $

--->

<cfcomponent displayname="Awards" hint="<component description here>" extends="his_Localgov_Extends.components.BusinessObjectsManager">

	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Awards" hint="Pseudo-constructor">
	
		<cfargument name="objAppObjs" type="any" required="yes" hint="The application manager object">
		
		<cfscript>
		// Call the genric init function, placing business, app, and dao objects into a local scope...
		StructAppend( variables, Super.initChild( arguments.objAppObjs, this ) );
		
		return this;
		</cfscript>
				
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PUBLIC Functions ------------------------------------------------------------------------------------>
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="F1" access="public" output="false" returntype="string" hint="<description>">
		
		<cfargument name="A1" type="string" default="1">
		<cfargument name="A2" type="string" default="1">

		<cfscript>
		// Local variable declarations...
		var sRtnValue = "";

		// ...code...		
		
		return sRtnValue;		
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- PRIAVTE Functions ----------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="F2" access="private" output="false" returntype="string" hint="<description>">
	
		<cfargument name="A1" type="string" default="1">
		<cfargument name="A2" type="string" default="1">

		<cfscript>
		// Local variable declarations...
		var sRtnValue = "";

		// ...code...		
		
		return sRtnValue;		
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- Get the award ceremony list ---------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getAwardDetails" access="public" returntype="query">
		<cfargument name="awardID" type="numeric" required="yes">
		
		<cfset var qryAwardDetails = objDAO.getAwardDetails(arguments.awardID)>
		
		<cfreturn qryAwardDetails>
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- Get an extended version of the category struct with addition web info ---------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getWebCategory" access="public" returntype="struct">
		<cfargument name="catID" type="numeric" required="yes">
		
		<cfreturn objDAO.getWebCategory(arguments.catID)>
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- Save the nominator from the front end site ------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="saveNominator" access="public" returntype="numeric">
		<cfargument name="catid" type="numeric" required="yes">
		<cfargument name="nor_email" type="string" required="yes">
		<cfargument name="nor_name" type="string" required="yes">
		<cfargument name="nor_title" type="string" required="yes">
		<cfargument name="nor_company" type="string" required="yes">
		<cfargument name="nor_add1" type="string" required="yes">
		<cfargument name="nor_add2" type="string" required="yes">
		<cfargument name="nor_add3" type="string" required="yes">
		<cfargument name="nor_town" type="string" required="yes">
		<cfargument name="nor_county" type="string" required="yes">
		<cfargument name="nor_postcode" type="string" required="yes">
		<cfargument name="nor_country" type="string" required="yes">
		<cfargument name="nor_phone" type="string" required="yes">
		<cfargument name="nor_fax" type="string" required="yes">
		
		<cfreturn objDAO.saveNominator(
										0,
										arguments.nor_email,
										arguments.nor_name,
										arguments.nor_title,
										arguments.nor_company,
										arguments.nor_add1,
										arguments.nor_add2,
										arguments.nor_add3,
										arguments.nor_town,
										arguments.nor_county,
										arguments.nor_postcode,
										arguments.nor_country,
										arguments.nor_phone,
										arguments.nor_fax
										)>
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- Save the nomination record from the front end ---------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="saveWebNomination" access="public" returntype="numeric">
		<cfargument name="catID" type="numeric" required="yes">
		<cfargument name="norID" type="numeric" required="yes">
		<cfargument name="nom_company" type="string" required="yes">
		<cfargument name="nom_person" type="string" required="yes">
		<cfargument name="nom_file" type="string" required="yes">
		<cfargument name="nom_add1" type="string" required="yes">
		<cfargument name="nom_add2" type="string" required="yes">
		<cfargument name="nom_add3" type="string" required="yes">
		<cfargument name="nom_town" type="string" required="yes">
		<cfargument name="nom_county" type="string" required="yes">
		<cfargument name="nom_postcode" type="string" required="yes">
		<cfargument name="nom_country" type="string" required="yes">
		<cfargument name="nom_phone" type="string" required="yes">
		<cfargument name="nom_fax" type="string" required="yes">
		<cfargument name="nom_email" type="string" required="yes">
		<cfargument name="nom_description" type="string" required="yes">
		<cfargument name="awardID" type="numeric" required="yes">
		
		<cfset var thefile = ''>
		
		<!--- Use the categoryid to find the ceremony id --->
		<cfset var cerID = objDAO.getCeremonyFromCategory(arguments.catID)>
		
		<cfif arguments.nom_file neq '' and form.nom_file neq ''>
			<!--- Upload the file --->
			<cffile action="upload" destination="#request.sDirPath#view\awards\pdfs\" filefield="form.nom_file" nameconflict="makeunique" accept="application/pdf,application/word,application/msword">
			
			<cfif cffile.filewassaved>
				<cfset thefile = cffile.serverfile>
			</cfif>
		</cfif>
		
		<cfset objDAO.saveNomination(
									arguments.catID,
									0,
									now(),
									1,
									'',
									arguments.nom_company,
									arguments.nom_person,
									thefile,
									arguments.nom_add1,
									arguments.nom_add2,
									arguments.nom_add3,
									arguments.nom_town,
									arguments.nom_county,
									arguments.nom_postcode,
									arguments.nom_country,
									arguments.nom_phone,
									arguments.nom_fax,
									arguments.nom_email,
									arguments.nom_description,
									arguments.norID
									)>
		
		<cfset sendNominationEmails(arguments.norID, arguments.catID, arguments.awardID, arguments.nom_company, arguments.nom_person)>
		
		<cfreturn cerID>
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- Send emails to the nominator and admin when a new nomination is saved ---------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="sendNominationEmails" access="package" returntype="void">
		<cfargument name="norID" type="numeric" required="yes">
		<cfargument name="catID" type="numeric" required="yes">
		<cfargument name="awardID" type="numeric" required="yes">
		<cfargument name="company" type="string" required="no">
		<cfargument name="person" type="string" required="no">
		
		<cfset var qryAwardDetails = getAwardDetails(arguments.awardID)>
		<cfset var strCategoryDetails = getCategoryDetails(arguments.catID)>
		<cfset var qryNominator = objDAO.nominatorLookup(arguments.norID)>
		
		<cfoutput>
<cfmail to="#qryNominator.email#" from="awards@hgluk.com" subject="Nomination Entered">
Thank you for submitting a nomination for The MJ Achievement Awards 2010.
 
If your nomination has been successful we will be in touch in March 2010.
 
For any other enquiries please contact either Mandy Murray or Polly Sabin.
 
We wish you the best of luck.
 
HIS Events
020 7973 6668/020 7973 6689
</cfmail>
			
			<cfmail to="#qryAwardDetails.adminEmail[1]#" from="awardsweb@hgluk.com" subject="New Nomination Made">
			A new nomination has been entered for #arguments.person# #arguments.company# in the category of #strCategoryDetails.main.name# - #qryAwardDetails.name#
			</cfmail>
		</cfoutput>
		
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- Load a page copy record for editing -------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getPageCopy" access="public" returntype="query">
		<cfargument name="type" type="numeric" required="yes">
		<cfargument name="relID" type="numeric" required="yes">
		<cfargument name="awardID" type="numeric" required="yes">
				
		<cfreturn objDAO.getPageCopy(arguments.type, arguments.relID, arguments.awardID)>
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- Get the details of an individual ceremony -------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getCeremonyDetails" access="public" returntype="struct">
		<cfargument name="ceremonyID" type="numeric" required="yes">
		
		<cfset var strCeremonyDetails = objDAO.getCeremonyDetails(arguments.ceremonyID)>
		
		<cfreturn strCeremonyDetails>
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- Get a list of categories for a given ceremony ---------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getCategoryList" access="public" returntype="query">
		<cfargument name="cerID" type="numeric" required="yes">
		
		<cfset var qryCategoryList = objDAO.getCategoryList(arguments.cerID)>
		
		<cfreturn qryCategoryList>		
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- Look to see if a nominator has been entered before and retrieve their details -------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="nominatorLookup" access="public" returntype="query">
		<cfargument name="em" type="string" required="yes">
		
		<cfreturn objDAO.nominatorLookup(arguments.em)>
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- Load the details of a given category ------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getCategoryDetails" access="public" returntype="struct">
		<cfargument name="catID" type="numeric" required="yes">		
		
		<cfreturn objDAO.getCategoryDetails(arguments.catID)>
	</cffunction>
	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- Load the details of a given sponsor -------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="getSponsorDetails" access="public" returntype="query">
		<cfargument name="sponID" type="numeric" required="yes">		
		
		<cfreturn objDAO.getSponsorDetails(arguments.sponID)>
	</cffunction>
</cfcomponent>