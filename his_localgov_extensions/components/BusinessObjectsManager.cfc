<!--- 
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/components/BusinessObjectsManager.cfc $
	$Author: Ohilton $
	$Revision: 16 $
	$Date: 10/06/10 16:50 $

--->

<cfcomponent displayname="BusinessObjectsManager" hint="Business Object Manager">

	<!--- -------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR -------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="BusinessObjectsManager" hint="Pseudo-constructor">
		<cfargument name="objAppObjs" type="any" required="yes" hint="The application manager object"> 
		
		<cfscript>
			// Component's child objects...
			this.objCommon 			= createobject("component", "his_Localgov_Extends.components.BusinessObjects.Common").init( arguments.objAppObjs );
			this.objAds 			= createobject("component", "his_Localgov_Extends.components.BusinessObjects.Ads").init( arguments.objAppObjs );
			//this.objForum 			= createobject("component", "Forum"			).init( arguments.objAppObjs );
			this.objAutoLinker		= createobject("component", "his_Localgov_Extends.components.BusinessObjects.AutoLinker").init( arguments.objAppObjs ); 
			this.objSurvey 			= createobject("component", "his_Localgov_Extends.components.BusinessObjects.Survey").init( arguments.objAppObjs ); 	
			this.objGuides 			= createobject("component", "his_Localgov_Extends.components.BusinessObjects.Guides").init( arguments.objAppObjs );
		   
			this.objArticle 		= createobject("component", "his_Localgov_Extends.components.BusinessObjects.Article").init( arguments.objAppObjs, FALSE, TRUE, arguments.objAppObjs.getSiteConfig().strVars.useProxy );
			
			this.objSearch 			= createobject("component", "his_Localgov_Extends.components.BusinessObjects.Search").init( arguments.objAppObjs, this);
			
			this.objJobs 			= createobject("component", "his_Localgov_Extends.components.BusinessObjects.Jobs").init( arguments.objAppObjs, this );
			this.objSubscriptions 	= createobject("component", "his_Localgov_Extends.components.BusinessObjects.Subscriptions").init( arguments.objAppObjs, this );
			this.objNewsletter		= createobject("component", "his_Localgov_Extends.components.BusinessObjects.Newsletter").init( arguments.objAppObjs, this );
			
			this.objEmail 			= createobject("component", "his_Localgov_Extends.components.BusinessObjects.Email").init( arguments.objAppObjs, this);
			this.objEvents 			= createobject("component", "his_Localgov_Extends.components.BusinessObjects.Events").init( arguments.objAppObjs, this );
			this.objUsers 			= createobject("component", "his_Localgov_Extends.components.BusinessObjects.Users").init( arguments.objAppObjs, this );
			
			//New User Object
			this.objUser 			= createobject("component", "his_Localgov_Extends.components.BusinessObjects.User").init( arguments.objAppObjs, this );
			
			this.objSubscriptions 	= createobject("component", "his_Localgov_Extends.components.BusinessObjects.Subscriptions").init( arguments.objAppObjs, this );
			
			this.objDirectory 		= createobject("component", "his_Localgov_Extends.components.BusinessObjects.Directory").init( arguments.objAppObjs, this );
			
			this.objDataSales 		= createobject("component", "his_Localgov_Extends.components.BusinessObjects.DataSales").init( arguments.objAppObjs, this );
			
			this.objMYBIntelli 		= createobject("component", "his_Localgov_Extends.components.BusinessObjects.MYBIntelli").init( arguments.objAppObjs, this );
			this.objPapers	 		= createobject("component", "his_Localgov_Extends.components.BusinessObjects.Papers").init( arguments.objAppObjs, this );
			
			this.objInvoice			= createobject("component", "his_Localgov_Extends.components.BusinessObjects.Invoice").init( arguments.objAppObjs, this );		
			this.objNewsletter		= createobject("component", "his_Localgov_Extends.components.BusinessObjects.Newsletter").init( arguments.objAppObjs, this );
			this.objEmail 			= createobject("component", "his_Localgov_Extends.components.BusinessObjects.Email").init( arguments.objAppObjs, this);
			this.objCareers			= createobject("component", "his_Localgov_Extends.components.BusinessObjects.Careers").init( arguments.objAppObjs, this );
			this.objComment			= createobject("component", "his_Localgov_Extends.components.BusinessObjects.Comment").init( arguments.objAppObjs, this );
			this.objGovepedia		= createobject("component", "his_Localgov_Extends.components.BusinessObjects.Govepedia").init( arguments.objAppObjs, this );
			this.objBlogs 		    = createobject("component", "his_Localgov_Extends.components.BusinessObjects.blogs").init( arguments.objAppObjs, this);
			this.objOrders 			= createobject("component", "his_Localgov_Extends.components.BusinessObjects.Orders").init( arguments.objAppObjs, this );
			this.objAwards 			= createobject("component", "his_Localgov_Extends.components.BusinessObjects.Awards").init( arguments.objAppObjs );
			//this.objCouncils 		= createobject("component", "Councils"		).init( arguments.objAppObjs );
			this.objSiteAdmin		= createobject("component", "his_Localgov_Extends.components.BusinessObjects.SiteAdmin") .init( arguments.objAppObjs, this );
			
			this.objTopics		    = createobject("component", "his_Localgov_Extends.components.BusinessObjects.topics") .init( arguments.objAppObjs, this);	
		
			this.objHome 			= createobject("component", "his_Localgov_Extends.components.BusinessObjects.Home").init( arguments.objAppObjs, this ); 
			this.objWebinar 		= createobject("component", "his_Localgov_Extends.components.BusinessObjects.Webinar").init( arguments.objAppObjs, this );
			
			this.objAccess 			= createobject("component", "his_Localgov_Extends.components.BusinessObjects.Access").init( arguments.objAppObjs, this );
			
			this.objReports			= createobject("component", "his_Localgov_Extends.components.BusinessObjects.Reports").init( arguments.objAppObjs, this );
			this.objLetter			= createobject("component", "his_Localgov_Extends.components.BusinessObjects.Letter").init( arguments.objAppObjs, this );
			this.objRenewal			= createobject("component", "his_Localgov_Extends.components.BusinessObjects.Renewal").init( arguments.objAppObjs, this );
			this.objCorrespondence	= createobject("component", "his_Localgov_Extends.components.BusinessObjects.Correspondence").init( arguments.objAppObjs, this );
			this.objFTS				= createobject("component", "his_Localgov_Extends.components.BusinessObjects.FullTextSearch").init( arguments.objAppObjs );
			this.objLRDirect			= createobject("component", "his_Localgov_Extends.components.BusinessObjects.LRDirect").init( arguments.objAppObjs, this );
			//call method to set sectors into this scope
			this.qrySectors 		= this.objSearch.getSectors();	
			this.qryNewsTypes 		= this.objArticle.getNewsTypes();	
			
			return this;
		</cfscript>
		
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- PUBLIC initChild Function ------------------------------------------------------------------------>
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="initChild" access="public" output="false" returntype="struct" hint="Universal child init function, places passed objects into a local scope.">
		
		<cfargument name="objAppObjs" type="any" 	 required="yes" hint="The application manager object">
		<cfargument name="objChild"   type="any" 	 required="yes" hint="The child object">
		<cfargument name="objBusObjs" type="any" 	 required="no"  hint="The business object" default="">
		<cfargument name="bHasDAO" 	  type="boolean" required="no"  hint="swicth to determine whether the business object has a DAO" default="true">
		
		<cfscript>
			variables.strConfig = arguments.objAppObjs.getSiteConfig();
			// Place business & app manager objects into local scope...
			if (IsStruct(arguments.objBusObjs) )
				StructAppend(variables, putObjsIntoVarScope(arguments.objBusObjs, arguments.objAppObjs) );
			else
				StructAppend(variables, putObjsIntoVarScope(arguments.objAppObjs) );
			
			if (arguments.bHasDAO) {
				//set site config
				variables.strConfig = arguments.objAppObjs.getSiteConfig();
				// Create an instance of the repsective DAO object and store it locally... 
				variables.objDAO = createObject("component", "his_Localgov_Extends.components.DataAccessObjects." & getMetaData(arguments.objChild).DisplayName & "DAO").init(variables.strConfig);
			}
			
			return variables;
		</cfscript> 
		
		
	</cffunction>	
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- PUBLIC PutObjsIntoVarScope Function -------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<cffunction name="putObjsIntoVarScope" access="public" output="false" returntype="struct" hint="Loads passed objects into the variables scope.">
		
		<cfargument name="strMain" type="any" required="yes">
		<cfargument name="strOptional" type="any" required="no" default="">

		<cfscript>
			// Loop over business manager objects and set them into local scope
			for (i in arguments.strMain)
				if ( isObject(arguments.strMain[i]) )
					StructInsert(variables, i, arguments.strMain[i]); 	// ...add object into variables scope
	
			if ( IsStruct(arguments.strOptional) )
				// Loop over application manager objects and set them into local scope
				for (i in arguments.strOptional)
					if ( isObject(arguments.strOptional[i]) )
						StructInsert(variables, i, arguments.strOptional[i]); 	// ...add object into variables scope
			
			return variables;
		</cfscript>
		
	</cffunction>
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->
	<!--- -------------------------------------------------------------------------------------------------->

</cfcomponent>