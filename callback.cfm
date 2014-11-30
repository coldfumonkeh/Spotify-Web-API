<cfdump var="#url#">

<cfif structKeyExists(URL, 'code')>
	<cfset accessData = application.objSpotify.requestToken(grant_type="authorization_code", code=URL.code, redirect_uri=application.objSpotify.getRedirect_uri()) />
	<cfset session.access = accessData />
	<cfdump var="#application.objSpotify.me(access_token=accessData.access_token)#">

	<cfdump var="#application.objSpotify.mytracks(access_token=accessData.access_token)#">

	<cflocation url="profile.cfm" addtoken="false" />
</cfif>
