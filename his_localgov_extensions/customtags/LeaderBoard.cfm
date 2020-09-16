<!--- BALLS TO FUSEBOX ---->
<!--- AD Leader Board Here ---->

<cfparam name="attributes.originalcircuit" default="">
<cfparam name="attributes.originalfuseaction" default="">
<cfparam name="attributes.link" default="">
<cfparam name="leaderBoardAdvert" default="">


<cfset qryAdsLeader =request.objBus.objAds.GetAdsforOutput(attributes.originalcircuit, attributes.originalfuseaction, 21,1)>

<cfset leaderBoardAdvert = request.objBus.objAds.outputAd(qryAds=qryAdsLeader,circuit=attributes.originalcircuit, adtypeid=21,positionID=1,AdlinkURL=attributes.link,width=732, heighth=92,strSession=session ).imagevar>

<!---<cfset leaderBoardAdvert = Replace(leaderBoardAdvert, "ord=[timestamp]", "ord=#RandRange(1000000, 9999999)#", "all")>--->

<cfif LEN(leaderBoardAdvert)>       
    <div id="leader" align="center" style="margin:10px 0 10px 0;">
      <cfoutput>#leaderBoardAdvert#</cfoutput>
    </div>
</cfif>