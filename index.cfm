<cfdump var="#application.objSpotify#">



<cfoutput>
	
<a href="#application.objSpotify.authorize(show_dialog=true, scope='playlist-read-private playlist-modify-public playlist-modify-private user-library-read user-library-modify user-read-private user-read-email')#">Authorize with Spotify</a>

</cfoutput>