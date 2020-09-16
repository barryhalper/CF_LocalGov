
<cfcomponent displayname="Blogs" hint="component to manage blogs" extends="his_Localgov_Extends.components.BusinessObjectsManager">
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- CONSTRUCTOR ----------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="Blogs" hint="Pseudo-constructor">
		
		<cfargument name="objAppObjs" 		type="any" 	   required="yes" hint="The application manager object">
		<cfargument name="objBusObjs" type="any" required="yes" hint="The business objects">
		<cfscript>
		// Call the genric init function, placing business, app, and dao objects into a local scope...
		structAppend( variables, Super.initChild( arguments.objAppObjs, this, arguments.objBusObjs ) );
	
		variables.arrBlogs = arrayNew(1);
		variables.useProxy = arguments.objAppObjs.getSiteConfig().strVars.useproxy;
		return this;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getVariables" access="public" returntype="struct" output="false">
		<cfreturn variables>
	</cffunction>
	
	<cffunction name="doCFLog" access="private" returntype="void">
	   <cfargument name="text" type="string" required="yes">
	   <cfargument name="file" type="string" required="yes">
	   
	   <cflog text="#arguments.text#" file="#arguments.file#">
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getAllblogs" access="public" returntype="array" output="false">
		<cfset SetAllBlogs()>
		<cfreturn variables.arrBlogs>
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getblogsDetails" access="public" returntype="query" output="false">
		<cfset setBlogDetails()>
		<cfreturn variables.qryBlogDetails>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="setBlogDetails" access="public" returntype="void" output="false" hint="set qry holding blog detail into instance">
		<cfargument name="refresh" required="no" type="boolean" default="false">
		
		<!--- if the key exists in the variables structure and the refreshQuery argument is false, acess the recordset from memory --->
		<cfif NOT StructKeyExists(variables, "qryBlogDetails") OR arguments.refresh>
			<cfset variables.qryBlogDetails= objDAO.getBlogs()>
		</cfif>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="SetAllBlogs" access="public" output="false" returntype="array" hint="aggregate a list of blogs turn each into a query and set into a single array">
		<cfargument name="refresh"  required="no" type="boolean" default="false">
		
		<cfscript>
		var i =0;	
		var qryFeed = queryNew("temp");
		setBlogDetails();
		
		//request.obJapp.objUtils.dumpabort(variables.arrBlogs);
				
		If (NOT arrayLen(variables.arrBlogs) OR arguments.refresh){
			ArrayClear(variables.arrBlogs);
			
			for (i=1; i LTE variables.qryBlogDetails.recordcount; i=i+1 ) {
				
				doCFLog(text="SetAllBlogs Loop - interation #i#", file="LoopLog");
				
				qryFeed = getFeedByType(variables.qryBlogDetails.location[i], variables.useProxy);
				qryFeed = JoinBlog2Feed(qryFeed, variables.qryBlogDetails.location[i]);
				If (qryFeed.Recordcount)
					ArrayAppend(variables.arrBlogs,  qryFeed);
				}
		}
					
		return 	variables.arrBlogs;
		</cfscript>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="readxml" access="public" output="false" returntype="any" hint="">
		<cfargument name="feedUrl" required="yes" type="string" default="false">
			
			<cfset var xmlDoc ="">
			<cftry>
			<cfset xmlDoc 	 = objxml.ReadXml(arguments.feedUrl, variables.useProxy)>
				<cfcatch type="any">
					
				</cfcatch>
			</cftry>
			<cfreturn xmlDoc>
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getFeedByType" access="public" output="false" returntype="query" hint="">
		<cfargument name="feedUrl" required="no" type="string" default="false">
		
			<cfscript>
			var qryFeed  = QueryNew("content,feedurl,lastbuilddate,link,pubdate,rssdesc,rsstitle,title");
			var XmlNsURI = "";
			var xmlDoc 	 = ReadXml(arguments.feedUrl);
			
			if (Isxml(xmlDoc)){
				 XmlNsURI = XMLDoc.xmlroot.xmlchildren[1].XmlNsURI;
				If (XmlNsURI CONTAINS "atom")
						qryFeed = objRss.atom2qry(xmlDoc, arguments.feedUrl);
				else
						qryFeed = objRss.rss2qry(xmlDoc, "RSS");
				}
				return 	qryFeed;
			</cfscript>
	
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->			
	<cffunction name="JoinBlog2Feed" access="public" output="false" returntype="query" hint="join data form db to qry created from feed">
		<cfargument name="qryFeed" required="yes" type="query" default="false">
		<cfargument name="feedUrl" required="yes" type="string" default="false">
		
		<cfset var qryblog = queryNew("temp")>	
		<cfset var qryA = arguments.qryFeed>
		<cfset var qryB =  variables.qryBlogDetails>	
		
			
			<cfquery dbtype="query" name="qryblog">
				SELECT qryA.content,qryA.feedurl,qryA.lastbuilddate,qryA.link,qryA.pubdate,qryA.rssdesc,qryA.rsstitle,qryA.title, qryB.* 
				FROM   	qryA, qryB
				WHERE   Lower(qryB.location) = Lower('#arguments.feedUrl#')
			</cfquery>
			
			
		<cfreturn qryblog>
	</cffunction>		
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetTopBlogs" access="public" output="false" returntype="query" hint="merge to entry of each of blog and turn into as single qry">
		<cfargument name="useProxy" required="no" type="boolean" default="false">
		
		<cfscript>
		var qryReturn = QueryNew("uid,description,image,lastbuilddate,link,rssdesc,rsstitle,title,pubdate,bloglink,p_blog_id", "Integer,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,varchar,varchar, integer");
		var i =0;
		var q =0;
		var pubdate = "";
		
		SetAllBlogs();
		
			for (i=1; i LTE arrayLen(arrBlogs); i=i+1 ) {
				
				doCFLog(text="GetTopBlogs Loop - interation #i#", file="LoopLog");
				
				If (NOT IsDate(arrBlogs[i].pubdate[1]))
					pubdate	=objString.xmlstring2date(arrBlogs[i].pubdate[1]);
				else
					pubdate = arrBlogs[i].pubdate[1];	
				
				queryAddRow(qryReturn);
				querySetCell(qryReturn, "uid", i);
				querySetCell(qryReturn, "description", arrBlogs[i].description[1]);
				
				If (Len (arrBlogs[i].image[1]))
					querySetCell(qryReturn, "image", 	    arrBlogs[i].image[1]);
				else
					querySetCell(qryReturn, "image", 	   ListGetAt(strConfig.strVars.blogimages, i));
				
				querySetCell(qryReturn, "image", 	    arrBlogs[i].image[1]);
				querySetCell(qryReturn, "p_blog_id", arrBlogs[i].p_blog_id[1]);		
				querySetCell(qryReturn, "lastbuilddate", arrBlogs[i].lastbuilddate[1]);
				querySetCell(qryReturn, "link", arrBlogs[i].link[1]);
				querySetCell(qryReturn, "rssdesc", arrBlogs[i].rssdesc[1]);
				querySetCell(qryReturn, "rsstitle", arrBlogs[i].rsstitle[1]);
				querySetCell(qryReturn, "title", arrBlogs[i].title[1]);
				querySetCell(qryReturn, "pubdate", pubdate);
				querySetCell(qryReturn, "bloglink", arrBlogs[i].location[1]);
				}
		
		return 	qryReturn;
		</cfscript>
		
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetBlogEntry" access="public" output="false" returntype="query" hint="">
		<cfargument name="blogid" type="numeric" required="yes">
		<cfargument name="link"   type="string" required="yes"> 
			
		<cfscript>
		
		
		var qryFeed = getBlogbyFeed(arguments.blogid);	
		//objUtils.dumpabort(arguments);
		return objUtils.queryofquery(qryFeed, "*", "link ='#arguments.link#'");
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="getBlogbyFeed" access="public" output="false" returntype="query" hint="">
		<cfargument name="blogid" type="numeric" required="yes" hint="id of feed"> 
			
		<cfscript>
		var i = 0;
		var qryR = queryNew("uid,description,image,lastbuilddate,link,rssdesc,rsstitle,title,pubdate,bloglink,p_blog_id,content,author,location");
		setAllBlogs();
		
		//objUtils.dumpabort(arrBlogs);
		
		for (i=1; i LTE arrayLen(arrBlogs); i=i+1){
			
			doCFLog(text="getBlogbyFeed Loop - interation #i#", file="LoopLog");
			
			if (arrBlogs[i].p_blog_id eq arguments.blogid){
				qryR = arrBlogs[i];
				break;
			}
		}
		return qryR;
		</cfscript>
		
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetLatestBlog" access="public" output="false" returntype="query" hint="">
		
	<cfscript>
		var qryReturn = QueryNew("uid,description,image,lastbuilddate,link,rssdesc,rsstitle,title,pubdate,bloglink,p_blog_id,content,author", "Integer,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,date,varchar,integer,varchar,varchar");
		var pubdate = Now();
		var uid = 0;
		var i   = 0;
		var qryFeed = QueryNew("temp");

		SetAllBlogs(true);
		//loop over array of blogs
		for (i=1; i LTE arrayLen(variables.arrBlogs); i=i+1 ) {
			
			doCFLog(text="GetLatestBlog Outter Loop - interation #i#", file="LoopLog");
			
			//get qruery heild in array element
			qryFeed = arrBlogs[i];
			
			//loop pver query
			for (j=1; j LTE qryFeed.recordcount; j=j+1 ) {
				
				doCFLog(text="GetLatestBlog Inner Loop - interation #j#", file="LoopLog");
				
				uid = uid + 1;
				
				If (NOT IsDate(qryFeed.pubdate[j]))
							pubdate	=objString.xmlstring2date(qryFeed.pubdate[j]);
						else
							pubdate = qryFeed.pubdate[j];	
						
						queryAddRow(qryReturn);
						
						querySetCell(qryReturn, "uid", 	    	 uid);	
						querySetCell(qryReturn, "image", 	     qryFeed.image[j]);
						querySetCell(qryReturn, "p_blog_id", 	 qryFeed.p_blog_id[j]);		
						querySetCell(qryReturn, "lastbuilddate", qryFeed.lastbuilddate[j]);
						querySetCell(qryReturn, "link", 		 qryFeed.link[j]);
						querySetCell(qryReturn, "rssdesc", 		 qryFeed.rssdesc[j]);
						querySetCell(qryReturn, "rsstitle", 	 qryFeed.blogname[j]);
						querySetCell(qryReturn, "title", 		 qryFeed.title[j]);
						querySetCell(qryReturn, "pubdate", 		 pubdate);
						querySetCell(qryReturn, "bloglink",      qryFeed.location[j]);
						querySetCell(qryReturn, "content", 	     qryFeed.content[j]);
						querySetCell(qryReturn, "author", 	     qryFeed.author[j]);
			
					}
				}

		qryReturn = objUtils.queryofquery(qryReturn, "*", "0=0", "pubdate desc");
		return qryReturn;
		</cfscript>
		
	</cffunction>	
	
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="GetBlogHome" access="public" output="false" returntype="struct" hint="">
		
		<cfscript>
		var i = 0;
		var strReturn = StructNew();
		SetAllBlogs();
		
		strReturn.qryLatest = GetLatestBlog();
		strReturn.qryBlogs = getblogsDetails();
		
		return strReturn;
		</cfscript>
		
	</cffunction>
	
	<!--- <cffunction name="GetLatestBlog" access="public" output="false" returntype="query" hint="return the lastest of all the blogs">
		
		<cfscript>
		return GetBlogHome().qryLatest[1];
		</cfscript>
		
	</cffunction> --->
	
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="Blog2Collection" access="public" returntype="void" output="false" hint="tunr sql query into verity collection">
		<cfargument name="collectionName" required="yes"  type="string" >

		<!---get all local gov data --->					
		<cfset var qryCollection=GetLatestBlog()> 
	
		<cfindex 
			collection="#arguments.collectionName#" 
			action="update"
			query="qryCollection" 
			type="custom"
			key="link" 
			Title="title" 
			Body="title,content,rsstitle"  
			custom1="Blogs" 
			custom2="p_blog_id"
			custom3="pubdate" custom4="xml">
			
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="CommitBlogDetail" access="public" output="false" returntype="numeric" hint="">
	  <cfargument name="blogid" 			type="numeric" required="no" default="0">
	  <cfargument name="Name" 				type="string" required="yes">
	  <cfargument name="location" 			type="string" required="yes">
	  <cfargument name="author" 			type="string" required="yes">	  
	  <cfargument name="description" 		type="string" required="yes">
	  <cfargument name="image" 				type="string" required="yes">
	  <cfargument name="pubseq" 			type="numeric" required="no" default="0">
	  
		<cfscript>		 
		var newid =objDAO.CommitBlogDetail(argumentCollection=arguments);
		setBlogDetails();
		return newid;
		</cfscript>
		
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<cffunction name="DeleteBlogDetail" access="public" output="false" returntype="void" hint="">
		 <cfargument name="blogid" 			type="numeric" required="yes" >
		
		<cfset objDAO.DeleteBlogDetail(arguments.blogid)>
		  
	</cffunction>
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
	<!--- ----------------------------------------------------------------------------------------------------->
</cfcomponent>