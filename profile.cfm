<!---
<cfdump var="#application.objSpotify.me(access_token=session.access.access_token)#">--->

<cfdump var="#session#">

<cfset albumResponse = application.objSpotify.getNewReleases(access_token=session.access.access_token) />

<cfdump var="#albumResponse#" />

<cfabort>
<cfdump var="#application.objSpotify.mytracks(access_token=session.access.access_token, limit='10')#">
<cfdump var="#application.objSpotify.me(access_token=session.access.access_token)#">
