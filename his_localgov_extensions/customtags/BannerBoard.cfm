<!--- BALLS TO FUSEBOX ---->
<!--- AD Leader Board Here ---->

<cfparam name="attributes.originalcircuit" default="">
<cfparam name="attributes.originalfuseaction" default="">
<cfparam name="attributes.link" default="">
<cfparam name="leaderBoardAdvert" default="">
<cfparam name="attributes.width" default="468">
<cfparam name="attributes.heighth" default="60">

<cfset qryAdsLeader =request.objBus.objAds.GetAdsforOutput(attributes.originalcircuit, attributes.originalfuseaction, 14,2)>

<cfset leaderBoardAdvert = request.objBus.objAds.outputAd(qryAds=qryAdsLeader,circuit=attributes.originalcircuit, adtypeid=14,positionID=2,AdlinkURL=attributes.link,width=attributes.width, heighth=attributes.heighth,strSession=session ).imagevar>

<!---<cfset leaderBoardAdvert = Replace(leaderBoardAdvert, "ord=[timestamp]", "ord=#RandRange(1000000, 9999999)#", "all")>--->


<cfif LEN(leaderBoardAdvert)>       
    <div  align="center" style="margin:10px 0 10px 0;">
      <cfoutput>#leaderBoardAdvert#</cfoutput>
    </div>
</cfif>