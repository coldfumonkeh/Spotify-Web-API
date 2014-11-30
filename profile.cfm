<!---
<cfdump var="#application.objSpotify.me(access_token=session.access.access_token)#">--->

<cfdump var="#session#">

<cfset albumResponse = application.objSpotify.search(q="Butch Walker", type="album", access_token=session.access.access_token, json=false) />
<cfdump var="#albumResponse#" />

<cfset albumResponse = application.objSpotify.getMyTracks(access_token=session.access.access_token, json=false) />

<cfdump var="#albumResponse#" />

<cfabort>
<cfdump var="#application.objSpotify.mytracks(access_token=session.access.access_token, limit='10')#">
<cfdump var="#application.objSpotify.me(access_token=session.access.access_token)#">
