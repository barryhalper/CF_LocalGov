<cfparam name="PageContent" default="">
<cfparam name="head" default="">
<cfparam name="loginform" default="">
<cfparam name="topBanner" default="">
<cfparam name="leftBanner" default="">
<cfparam name="rightPanel" default="">
<cfparam name="bottomBanner" default="">
<cfparam name="attributes.menuDisplay" default="Home">


<cfoutput>



 <!--- ******************************************************************** 
	 	///  HEAD  /////
  ******************************************************************** --->
#head#
 <!--- ******************************************************************** 
	 	///  BODY  /////
  ******************************************************************** --->
<body onLoad="rollup();nav_ctrl('#attributes.menuDisplay#');">
	<!--Container-->
	<div id="container">
		<!--Header-->
	  	<div id="header">
   	  		<div class="logo"><a href="index.cfm"><img src="#request.strSiteConfig.strPaths.assets#/furniture/logo.gif" alt="LocalGov.co.uk" width="237" height="54" border="0" /></a></div>
	   		<div class="adverts">#topBanner#</div> 
        	<!--Header nav-->
    		<div id="header_nav">
		   	  	<ol>
		       	  <li><cfif loggedin><a href="#request.myself##xfa.logout#">Logout</a><cfelse><a href="#request.myself##xfa.register#">Register</a></cfif></li>
		           	 <cfif loggedin and (session.userDetails.userTypeID EQ 3 OR session.userDetails.userTypeID EQ 5)>
									<li><a href="#request.myself##xfa.resubscribe#" style="color:##FFFFFF">Resubscribe</a> </li>
								<cfelse>
									<li><a href="#request.myself##xfa.subscribe#" style="color:##FFFFFF">Subscribe</a> </li>
				  </cfif>
		           	  <li><a href="#request.myself##xfa.about#">About us</a></li>
		           	  <li><a href="#request.myself##xfa.contact#">Contact us</a></li>
		           	  <li><a href="#request.myself##xfa.help#">Help</a></li>
		   	    <li class="last"><a href="#request.myself##xfa.forgot#">Forgotten Password?</a></li>
			  </ol>
    		</div>
        	<!--End Header nav-->
        	<div class="clearer"></div>
      		<div id="search">
      			#search#
      		</div>
  		</div>
    	<!--End of Header-->
	
  		<div class="clearer"></div>
    	<!--Main content -->
    	<div id="content">
	 		<div id="alpha">	
	    		<!--Left  / login-->
	  	 		#login#	
				<!--Left navigation -->
				#menu#	
		
				<div class="rss"><a href="#request.myself##xfa.rss#"><img src="#request.strSiteConfig.strPaths.assets#furniture/rss.gif" alt="RSS Newsfeed" width="141" height="38" border="0" /></a></div>
		        <div class="sitemap"><a href="#request.sSitePath#sitemap.xml"><img src="#request.strSiteConfig.strPaths.assets#furniture/sitemap.gif" alt="XML Sitemap" width="141" height="38" border="0" /></a></div>
		        <div class="alpha_ad">#leftBanner#</div>
			</div>
	 
	 		<div id="beta">
	 			#pageContent#
	 
	 		</div>
	 
    		<div id="gamma">
    			#rightPanel#		
    		</div>
   	 		<div class="clearer"></div>
    	</div>
    	<!--End of Main content -->
    
      	#footer#
    	<div class="clearer"></div>
	</div>
	
</body>
<cf_google_analytics >	
<cf_google_analytics accountno="UA-5696368-1">	
</html>	
</cfoutput>