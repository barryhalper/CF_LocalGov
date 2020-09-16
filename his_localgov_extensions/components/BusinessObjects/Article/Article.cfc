<cfcomponent displayname="Article">

	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" returntype="Article">
		<cfargument name="id" type="numeric" required="no" default="0">
		
		<cfscript>
			variables.instance = structNew();
			
			variables.instance.id = arguments.id;
			variables.instance.articleTypeId = 0;
			variables.instance.articleTitle = '';
			variables.instance.copy = '';
			variables.instance.byline = '';
			variables.instance.metaDescription = '';
			variables.instance.DatePublished = '';
			variables.instance.DateEnd = '';
			variables.instance.dateCommence = '';
			variables.instance.articlePositionID = 0;
			variables.instance.teaserImage = '';
			variables.instance.oldUrl = '';
			variables.instance.author = '';
			variables.instance.numRequests = 0;
			variables.instance.statusId = 0;
			variables.instance.abstract = '';
			variables.instance.articleType = '';
			variables.instance.articlePosition = '';
			variables.instance.keywordIds = arraynew(1);
			variables.instance.strArticle = structnew();
			
			return this;
		</cfscript>		
		
	</cffunction>
		
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getInstance" access="public" output="false" returntype="struct" hint="return local scope to caller">
		<cfreturn variables.instance>
	</cffunction>	
	
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="read" access="public" returntype="void" output="false" hint="Read the data into the object from the DB">
		
		<cfif variables.instance.id eq 0>
			<cfthrow message="Cannot read an article with no id set">
		<cfelse>
			<cfscript>
				objStoredProc = createobject("component", "his_Localgov_Extends.components.ApplicationObjects.StoredProc").init('usp_GetArticleByID','Localgov2005');
				objStoredProc.setParam('ArticleID', variables.instance.id, 'numeric');
				variables.instance.strArticle = objStoredProc.execute(2);
			
				populate();
			</cfscript>
		</cfif>
		
	</cffunction>
	
	
	
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="save" access="public" returntype="void" output="false" hint="Read the data into the object from the DB">
		
		<cfscript>
			if (StructkeyExists(form, "hd_image_teaser") and Len(form.hd_image_teaser))
				variables.instance.teaserImage = arguments.strAttr.hd_image_teaser;
				
			// upload the teaser image
			if (Len(form.image_teaser))
				variables.instance.teaserImage = objUtils.uploadImage( "form.image_teaser", request.sUploadImgDir, 'image' );
				
			objStoredProc = createobject("component", "his_Localgov_Extends.components.ApplicationObjects.StoredProc").init('usp_SaveArticle','Localgov2005');
			objStoredProc.setParam('ArticleID', variables.instance.id, 'numeric');
			objStoredProc.setParam('ArticleTypeID', variables.instance.articleTypeId, 'numeric');
			objStoredProc.setParam('Title', variables.instance.articleTitle, 'string');
			objStoredProc.setParam('Byline', variables.instance.byline, 'string');
			objStoredProc.setParam('ArticlePosition', variables.instance.articlePositionID, 'numeric');
			objStoredProc.setParam('Copy', variables.instance.copy, 'text');
			objStoredProc.setParam('AuthorID', variables.instance.author, 'numeric');
			objStoredProc.setParam('DatePublished', variables.instance.dateCommence, 'date');
			objStoredProc.setParam('MetaDescripton', variables.instance.metaDescription, 'string');
			objStoredProc.setParam('Keywordid', variables.instance.keywordIds, 'string');
			objStoredProc.setParam('teaserImage', variables.instance.teaserImage, 'string');
			objStoredProc.setParam('dateEnd', variables.instance.DateEnd, 'date');
			objStoredProc.setParam('statusid', variables.instance.statusId, 'numeric');
			objStoredProc.setParam('abstract', variables.instance.abstract, 'string');
			
			variables.instance.id = objStoredProc.execute(noResults = 0, outParam = 'NewID').outParam;
		</cfscript>
		
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="populate" access="private" returntype="void" output="false" hint="I move all the data into the instance">
		
		<cfif variables.instance.strArticle.results.qry_1.recordcount neq 1>
			<cfthrow message="Cannot populate object with incorrect number of records (#variables.instance.strArticle.results.qry_1.recordcount#)">
		<cfelse>
			<cfscript>
				headQry = variables.instance.strArticle.results.qry_1;
			
				variables.instance.id = headQry.ArticleID;
				variables.instance.articleTypeId = headQry.ArticleTypeID;
				variables.instance.articleTitle = headQry.Title;
				variables.instance.copy = headQry.Copy;
				variables.instance.byline = headQry.Byline;
				variables.instance.metaDescription = headQry.MetaDescripton;
				variables.instance.DatePublished = headQry.DatePublished;
				variables.instance.DateEnd = headQry.DateEnd;
				variables.instance.dateCommence = headQry.DateCommence;
				variables.instance.articlePositionID = headQry.ArticlePositionID;
				variables.instance.teaserImage = headQry.TeaserImage;
				variables.instance.oldUrl = headQry.oldUrl;
				variables.instance.author = headQry.author;
				variables.instance.numRequests = headQry.NumRequests;
				variables.instance.statusId = headQry.statusId;
				variables.instance.abstract = headQry.abstract;
				variables.instance.articleType = headQry.ArticleType;
				variables.instance.articlePosition = headQry.ArticlePosition;
				
				keyQry = variables.instance.strArticle.results.qry_2;
				variables.instance.keywordIds = listtoarray(valuelist(keyQry.keywordid, ','));
			</cfscript>
		</cfif>
	</cffunction>
	
</cfcomponent>