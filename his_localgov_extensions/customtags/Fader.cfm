<!--
	
	$Archive: /LocalGov.co.uk/wwwroot/his_localgov/private/his_localgov_extensions/customtags/Fader.cfm $
	$Author: Bhalper $
	$Revision: 2 $
	$Date: 21/08/07 17:04 $

-->

<cfparam name="attributes.Content"  default="">
<cfparam name="attributes.divclass"  default="domticker"><!---Array of HTML Content--->

<cfsavecontent variable="jsFader"> 
<script type="text/javascript" language="javascript">
var tickercontent=new Array()

<cfoutput >
/*loop over cfarray and create js array*/
<cfloop from="1" to="#ArrayLen(attributes.Content)#" index="i">
	/*js array start at 0 so index will be index of cf array -1*/
	tickercontent[#i#-1]='#JSStringFormat(attributes.Content[i])#';
</cfloop>
</cfoutput>

/***********************************************
* DHTML Ticker script- © Dynamic Drive (www.dynamicdrive.com)
* This notice MUST stay intact for legal use
* Visit http://www.dynamicdrive.com/ for this script and 100s more.
***********************************************/

function newsFader(content, divId, delay, fadeornot){
	this.content=content
	this.tickerid=divId //ID of master ticker div. Message is contained inside first child of ticker div
	this.delay=delay //Delay between msg change, in miliseconds.
	this.mouseoverBol=0 //Boolean to indicate whether mouse is currently over ticker (and pause it if it is)
	this.pointer=1
	this.opacitystring=(typeof fadeornot!="undefined")? "width: 99%; filter:progid:DXImageTransform.Microsoft.alpha(opacity=100); -moz-opacity: 1" : ""
	
	if (this.opacitystring!="") 
		this.delay+=500 //add 1/2 sec to account for fade effect, if enabled
	
	this.opacitysetting=0.2 //Opacity value when reset. Internal use.
	var instanceOfTicker=this
	
	document.write('<div id="'+divId+'"><div style="'+this.opacitystring+'">'+content[0]+'</div></div>')
	
	setTimeout(function(){instanceOfTicker.initialize()}, delay)
}

newsFader.prototype.initialize=function(){
var instanceOfTicker=this
this.contentdiv=document.getElementById(this.tickerid).firstChild //div of inner content that holds the messages
document.getElementById(this.tickerid).onmouseover=function(){instanceOfTicker.mouseoverBol=1}
document.getElementById(this.tickerid).onmouseout=function(){instanceOfTicker.mouseoverBol=0}
this.rotatemsg()
}

newsFader.prototype.rotatemsg=function(){
var instanceOfTicker=this
if (this.mouseoverBol==1) //if mouse is currently over ticker, do nothing (pause it)
setTimeout(function(){instanceOfTicker.rotatemsg()}, 100)
else{
this.fadetransition("reset") //FADE EFFECT- RESET OPACITY
this.contentdiv.innerHTML=this.content[this.pointer]
this.fadetimer1=setInterval(function(){instanceOfTicker.fadetransition('up', 'fadetimer1')}, 100) //FADE EFFECT- PLAY IT
this.pointer=(this.pointer<this.content.length-1)? this.pointer+1 : 0
setTimeout(function(){instanceOfTicker.rotatemsg()}, this.delay) //update container
}
}

// -------------------------------------------------------------------
// fadetransition()- cross browser fade method for IE5.5+ and Mozilla/Firefox
// -------------------------------------------------------------------

newsFader.prototype.fadetransition=function(fadetype, timerid){
var contentdiv=this.contentdiv
if (fadetype=="reset")
this.opacitysetting=0.2
if (contentdiv.filters && contentdiv.filters[0]){
if (typeof contentdiv.filters[0].opacity=="number") //IE6+
contentdiv.filters[0].opacity=this.opacitysetting*100
else //IE 5.5
contentdiv.style.filter="alpha(opacity="+this.opacitysetting*100+")"
}
else if (typeof contentdiv.style.MozOpacity!="undefined" && this.opacitystring!=""){
contentdiv.style.MozOpacity=this.opacitysetting
}
else
this.opacitysetting=1
if (fadetype=="up")
this.opacitysetting+=0.2
if (fadetype=="up" && this.opacitysetting>=1)
clearInterval(this[timerid])
}
</script>

</cfsavecontent>
<cfhtmlhead text="#jsFader#"><cfoutput>
<script type="text/javascript" language="javascript">
new newsFader(tickercontent, "#attributes.divclass#", #request.strsiteconfig.strVars.NewsTicker_Interval#, "fadeit");
</script></cfoutput>