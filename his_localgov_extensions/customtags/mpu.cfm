<!--- BALLS TO FUSEBOX ---->
<!--- AD MPU Here ---->

<cfparam name="attributes.originalcircuit" default="">
<cfparam name="attributes.originalfuseaction" default="">
<cfparam name="attributes.link" default="">
<cfparam name="Advert" default="">


<cfset qryAdsMpu =request.objBus.objAds.GetAdsforOutput(attributes.originalcircuit, attributes.originalfuseaction, 15,12)>

<cfset Advert = request.objBus.objAds.outputAd(qryAds=qryAdsMpu,circuit=attributes.originalcircuit, adtypeid=12,positionID=15,
													AdlinkURL=attributes.link,width=300, heighth=192,strSession=session ).imagevar>


<cfif LEN(Advert)>       
    <div class="mpu" >
      <cfoutput>#Advert#</cfoutput>
    </div>
</cfif>