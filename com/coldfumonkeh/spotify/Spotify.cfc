component accessors="true" {

	property name="clientID" 			type="string";
	property name="clientSecret" 	type="string";
	property name="redirect_uri"	type="string";
	property name="api_base"			type="string";
	property name="auth_base"			type="string";

	/**
	* @hint "Constructor method"
	*/
	public function init (
			required string clientID,
			required string clientSecret,
			required string redirect_uri
		)
	{
		setclientID(arguments.clientID);
		setclientSecret(arguments.clientSecret);
		setRedirect_uri(arguments.redirect_uri);
		setApi_base('https://api.spotify.com/v1');
		setAuth_base('https://accounts.spotify.com');
		return this;
	}

	public function authorize(
			required 	string client_id = getClientID() 				hint="The client ID provided to you by Spotify when you register your application.",
			required 	string response_type = "code",
			required 	string redirect_uri = getRedirect_uri() hint="The URI to redirect to after the user grants/denies permission. This URI needs to have been entered in the Redirect URI whitelist that you specified when you registered your application. The value of redirect_uri here must exactly match one of the values you entered when you registered your application, including upper/lowercase, terminating slashes, etc.",
			required 	string state = hash(CreateUUID()) 			hint=" The state can be useful for correlating requests and responses. Because your redirect_uri can be guessed, using a state value can increase your assurance that an incoming connection is the result of an authentication request. If you generate a random string or encode the hash of some client state (e.g., a cookie) in this state variable, you can validate the response to additionally ensure that the request and response originated in the same browser. This provides protection against attacks such as cross-site request forgery",
								string scope ="" 												hint="A space-separated list of scopes: see Using Scopes. If no scopes are specified, authorization will be granted only to access publicly available information: that is, only information normally visible in the Spotify desktop, web and mobile players.",
			boolean 	show_dialog =false 											hint="Whether or not to force the user to approve the app again if they’ve already done so. If false (default), a user who has already approved the application may be automatically redirected to the URI specified by redirect_uri. If true, the user will not be automatically redirected and will have to approve the app again."
		)
	{
		var strURL=getAuth_base() & "/authorize/?" & buildParamString(arguments);
		return strURL;
	}

	public struct function requestToken(
			required string grant_type,
			required string scope ="",
			required string code = "",
			required string redirect_uri = getRedirect_uri(),
			required string refresh_token = ""
		)
	{
		var request = {};
		var requestData = {};
		var httpService = new http(url=getAuth_base() & "/api/token", method="POST");
			httpService.addParam(type="header",name="Authorization", value="Basic #toBase64(getClientID() & ':' & getClientSecret())#");
			httpService.addParam(type="formfield",name="grant_type",value=arguments.grant_type);
			if ( len(arguments.scope) ) {
				httpService.addParam(type="formfield",name="scope",value=arguments.scope);
			}
			if ( len(arguments.code) ) {
				httpService.addParam(type="formfield",name="code",value=arguments.code);
			}
			if ( len(arguments.redirect_uri) ) {
				httpService.addParam(type="formfield",name="redirect_uri",value=arguments.redirect_uri);
			}
			if ( len(arguments.refresh_token) ) {
				httpService.addParam(type="formfield",name="refresh_token",value=arguments.refresh_token);
			}
		request = httpService.send().getPrefix();
		requestData = deserializeJSON(request.FileContent);
		return requestData;
	}


	public struct function refreshToken(
			required string grant_type,
			required string refresh_token
		)
	{
		return requestToken(grant_type=arguments.grant_type, refresh_token=arguments.refresh_token);
	}


	/****************/
	/* METHODS      */
	/****************/


	/* Album Data */

	public struct function album(required string id)
	{
		return makeRequest(url=getApi_base() & "/albums/" & arguments.id);
	}

	public struct function albums(required string ids)
	{
		return makeRequest(url=getApi_base() & "/albums?ids=" & arguments.ids);
	}

	public struct function albumTracks(
			required string id,
			string limit = "20",
			string offset ="0"
		)
	{
		var args = structcopy(arguments);
		structDelete(args,"id");
		return makeRequest(url=getApi_base() & "/albums/" & arguments.id & "/tracks?" & buildParamString(args));
	}

	/* Artist Data */

	public struct function artist(required string id)
	{
		return makeRequest(url=getApi_base() & "/artists/" & arguments.id);
	}

	public struct function artists(required string ids)
	{
		return makeRequest(url=getApi_base() & "/artists?ids=" & arguments.ids);
	}

	/**
	* @album_type Optional. A comma-separated list of keywords that will be used to filter the response. If not supplied, all album types will be returned. Valid values are: album, single, appears_on, compilation. For example: album_type=album,single
	* @market Optional. An ISO 3166-1 alpha-2 country code. Supply this parameter to limit the response to one particular geographical market. For example, for albums available in Sweden: market=SE. If not given, results will be returned for all markets and you are likely to get duplicate results per album, one for each market in which the album is available!
	**/
	public struct function artistAlbums(
			required string id,
			string album_type,
			string market,
			string limit = "20",
			string offset ="0"
		)
	{
		var args = structcopy(arguments);
		structDelete(args,"id");
		return makeRequest(url=getApi_base() & "/artists/" & arguments.id & "/albums?" & buildParamString(args));
	}

	/**
	* @country The country: an ISO 3166-1 alpha-2 country code.
	**/
	public struct function artistTopTracks(
			required string ids,
			required string country
		)
	{
		return makeRequest(url=getApi_base() & "/artists/" & arguments.id & "/top-tracks?country=" & arguments.country);
	}

	public struct function relatedArtists(required string ids)
	{
		return makeRequest(url=getApi_base() & "/artists/" & arguments.id & "/related-artists");
	}


	/* Playlist Methods */

	/**
	* @locale Optional. The desired language, consisting of a lowercase ISO 639 language code and an uppercase ISO 3166-1 alpha-2 country code, joined by an underscore. For example: es_MX, meaning "Spanish (Mexico)". Provide this parameter if you want the results returned in a particular language (where available). Note that, if locale is not supplied, or if the specified language is not available, all strings will be returned in the Spotify default language (American English). The locale parameter, combined with the country parameter, may give odd results if not carefully matched. For example country=SE&locale=de_DE will return a list of categories relevant to Sweden but as German language strings.
	* @country Optional. A country: an ISO 3166-1 alpha-2 country code. Provide this parameter if you want the list of returned items to be relevant to a particular country. If omitted, the returned items will be relevant to all countries.
	* @timestamp Optional. A timestamp in ISO 8601 format: yyyy-MM-ddTHH:mm:ss. Use this parameter to specify the user's local time to get results tailored for that specific date and time in the day. If not provided, the response defaults to the current UTC time. Example: "2014-10-23T09:00:00" for a user whose local time is 9AM.
	* @limit Optional. The maximum number of items to return. Default: 20. Minimum: 1. Maximum: 50.
	* @offset Optional. The index of the first item to return. Default: 0 (the first object). Use with limit to get the next set of items.
	**/
	public struct function getFeaturedPlaylists(
			required string access_token,
			string locale,
			string country,
			string timestamp,
			string limit = "20",
			string offset ="0"
		)
	{
		var args = structcopy(arguments);
		structDelete(args,"access_token");
		return makeRequest(url=getApi_base() & "/browse/featured-playlists?" & buildParamString(args), access_token=arguments.access_token);
	}

	/**
	* @country Optional. A country: an ISO 3166-1 alpha-2 country code. Provide this parameter if you want the list of returned items to be relevant to a particular country. If omitted, the returned items will be relevant to all countries.
	* @limit Optional. The maximum number of items to return. Default: 20. Minimum: 1. Maximum: 50.
	* @offset Optional. The index of the first item to return. Default: 0 (the first object). Use with limit to get the next set of items.
	**/
	public struct function getNewReleases(
			required string access_token,
			string country,
			string limit = "20",
			string offset ="0"
		)
	{
		var args = structcopy(arguments);
		structDelete(args,"access_token");
		return makeRequest(url=getApi_base() & "/browse/new-releases?" & buildParamString(args), access_token=arguments.access_token);
	}

	/* Profile Data */

	public struct function me(required string access_token)
	{
		return makeRequest(url=getApi_base() & "/me", access_token=arguments.access_token);
	}


	public struct function mytracks(
			required string access_token,
			string limit = "20",
			string offset ="0"
		)
	{
		var args = structcopy(arguments);
		structDelete(args,"access_token");
		return makeRequest(url=getApi_base() & "/me/tracks?" & buildParamString(args), access_token=arguments.access_token);
	}


	/****************/
	/* UTILS        */
	/****************/


	private struct function makeRequest(
			required string url,
			string access_token = "",
			string method = "GET"
		)
	{
		var httpService = new http(url=arguments.url, method=arguments.method);
			if ( len(arguments.access_token) ) {
					httpService.addParam(type="header",name="Authorization", value="Bearer #arguments.access_token#");
			}
		var request = httpService.send().getPrefix();
		return deserializeJSON(request.FileContent);
	}


	/**
	* hint I loop through a struct to convert to query params for the URL
	*/
	private function buildParamString(argScope)
	{
		var strURLParam = "";
		for (key in arguments.argScope) {
			if (len(arguments.argScope[key])) {
				if (listLen(strURLParam)) {
					strURLParam = strURLParam & '&';
				}
				strURLParam = strURLParam & lcase(key) & '=' & arguments.argScope[key];
			}
		}
		return strURLParam;
	}

}
