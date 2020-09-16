<!---
Author: Barry Halper
Date Created: 21/07/06
Description: Custom Tag to rotate images
--->


	<cfparam name="attributes.images" 		default="">
	<cfparam name="attributes.links" 		default="">
	<cfparam name="attributes.path" 		default="">
	<cfparam name="attributes.banner" 		default="1">
	<cfparam name="attributes.interval" 	default="1">
	<cfparam name="attributes.align" 		default="center">
	<cfparam name="attributes.width" 		default="0">
	<cfparam name="attributes.height" 		default="0">
	<cfparam name="Attributes.resultName" 	default="">
        
    <cfparam name="jsoutput" default=""> 
    
    
 
    <!--- BASED ON cf_rotate_banners 
    syntaxis:
     <cf_rotate_banners  images   = "comma separated list for images"
     links    = "comma separated list for links on images"
     path     = "the path of the images"
     interval = "delay time (sec)"
     align    = "alignment of the banners"  // default = center;
     width    = "width of the banners"      // default="468";
     height   = "height of the banners"    //  default="60">
     
     Note: The count of the image values has to be the same as the count of the links values,
        If you have a banner without a link value, define it in the list of the links as a 'none' value.
        reason: it won't work in Netscape and on MAC if you don't do this.
        refr.: example.
 
     example:
     <cf_rotate_banners  images   = "00794_006_Boom_468_60_01_c.gif,00794_009_career468.gif,00797_001_BeLuxbanner.gif"
          links    = "www.myownemail.com,none,astalavista.box.sk"
          path     = "images"
          interval = "5"
          align    ="left"> --->

	<cfif listlen(attributes.images) eq listlen(attributes.links)>
     
           
          <cfoutput>
		  <a href="" name="image_target_#attributes.images#" id="image_target_#attributes.images#" border="0" target="_blank"><img src="#attributes.path##ListGetAt(attributes.images,1,",")#" name="banner_#attributes.banner#image" id="banner_#attributes.banner#image" border="1" style="border-color:##000000" width="#attributes.width#" height="#attributes.height#"></a>
		  
          <script type="text/javascript" language="javascript">
          <cfset loop_count = 1>
          var banner_#attributes.banner#count = 1;
          /*set the objects you need for the banner rotations.*/
          <cfloop index="image_item" list="#attributes.images#" delimiters=",">
           
		   <cfif image_item CONTAINS "http://">
		   	<cfset image_path =image_item>
		  <cfelse>
		   <cfset image_path = "#attributes.path##image_item#">
          
		  </cfif>
		   var banner_#attributes.banner#image_#loop_count# = new Image();
            banner_#attributes.banner#image_#loop_count#.src = '#image_path#';
           var banner_#attributes.banner#image_#loop_count#_loc = '#ListGetAt(attributes.links,loop_count,",")#';
           <cfset loop_count = loop_count + 1>
          </cfloop>
         
          function banner_#attributes.banner#start(){
           document.getElementById('banner_#attributes.banner#image').src = eval('banner_#attributes.banner#image_' + banner_#attributes.banner#count + '.src');
           document.getElementById('image_target_#attributes.images#').href = eval('banner_#attributes.banner#image_' + banner_#attributes.banner#count + '_loc');
           window.setTimeout("banner_#attributes.banner#rotate();",eval(#attributes.interval#*20000));
           banner_#attributes.banner#count = banner_#attributes.banner#count + 1;
           if(banner_#attributes.banner#count == #loop_count#){banner_#attributes.banner#count = 1;};
          };
          

          function banner_#attributes.banner#rotate(){
		   document.getElementById('banner_#attributes.banner#image').src = eval('banner_#attributes.banner#image_' + banner_#attributes.banner#count + '.src');
           document.getElementById('image_target_#attributes.images#').href = eval('banner_#attributes.banner#image_' + banner_#attributes.banner#count + '_loc');
           window.setTimeout("banner_#attributes.banner#start();",eval(#attributes.interval#*20000));
           banner_#attributes.banner#count = banner_#attributes.banner#count + 1;
           if(banner_#attributes.banner#count == #loop_count#){banner_#attributes.banner#count = 1;};
          };
          
          banner_#attributes.banner#start();
          </script>
		  </cfoutput>
       <cfelse>
       
        <script type="text/javascript" language="javascript">
         alert("Error in rotate_banners custom tag");
        </script>
   
     </cfif>
