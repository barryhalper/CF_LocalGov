<cfparam name="fullname"   default="">
<cfparam name="accesscode" default="">
<cfparam name="sitepath"  default=""> 

<cfsavecontent variable="savecont">
<span class="bodytext">
<cfoutput><p>Dear #attributes.fullname# </p>
<p>Thank you for purchasing a corporate subscription to <a href="http://www.localgov.co.uk">www.localgov.co.uk</a>,&nbsp;, I hope you find the information featured on our website of value.  Further to the confirmation of your personal access details please find below your company’s corporate access code along with the link to our corporate welcome page.
</p>
<p>Corporate Access Code:&nbsp; <strong> #attributes.accesscode# </strong></p>
<p>Corporate user registration page:&nbsp;<a href="http://www.localgov.co.uk/Corporate/Join">http://www.localgov.co.uk/Corporate/Join</a></p>
<p>Please forward the code and link to any individuals within your organisation that want to become part of the corporate subscription. Upon receipt of these details each individual will need to click on the link, which will direct them to the screen below:</p>

<p><img src="#attributes.sitepath#view/images/corpjoin.jpg" width="484" height="324"></p><br />

<p>The joining process will only take a few minutes to complete and as the administrator you will receive an email notification each time a new user is added.  To assist you in the management of the subscription you can use the '<a href="http://www.localgov.co.uk/index.cfm?method=corporate.registrations&amp;mid=2.3">View Registrations</a>' link that appears in 'My Corporate Home'.  This will show you the details of all corporate users and allow you to edit or delete user information in the event of any staff changes.

<p>If at any point you require any additional assistance with your corporate subscription please contact our Customer Service team on 020 7973 6694 or email <a href="mailto:custmomer@localgov.co.uk">customer@localgov.co.uk</a>. </p>

<p>Regards,
<br />
Localgov Customer Services Team
</p>

<p>&nbsp;</p>
<p>&nbsp;</p>
</span>
</cfoutput>
</cfsavecontent>

<cfset caller.Emailcopy = savecont>
