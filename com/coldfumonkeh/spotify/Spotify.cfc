/**
* Name: Spotify.cfc
* Author: Matt Gifford (http://www.monkehworks.com)
* Date: 1st December 2014
* Copyright 2019 Matt Gifford.
*
* All rights reserved.
* Product and company names mentioned herein may be trademarks or trade names of their respective owners.
* Subject to the conditions below, you may, without charge:
* Use, copy, modify and/or merge copies of this software and associated documentation files (the 'Software')
* Any person dealing with the Software shall not misrepresent the source of the Software.
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
* INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
* PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
* HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
* OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
*
* Got a lot out of this package? Saved you time and money?
* Share the love and donate some money to a good cause: https://www.alzheimers.org.uk/get-involved/make-donation
**/

component accessors="true" {

	property name="clientID" type="string";
	property name="clientSecret" type="string";
	property name="redirect_uri" type="string";
	property name="api_base" type="string";
	property name="auth_base" type="string";

	/**
	* @clientID string Required. The client ID provided to you by Spotify when you register your application..
	* @clientSecret string Required. The Spotify API Client Secret.
	* @redirect_uri string Required. The redirect_uri (or one of if multiple) stored against the app.
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

	/**
	* @client_id string Required. The client ID provided to you by Spotify when you register your application.
	* @response_type string Required. Set it to code.
	* @redirect_uri string Required. The URI to redirect to after the user grants/denies permission. This URI needs to have been entered in the Redirect URI whitelist that you specified when you registered your application. The value of redirect_uri here must exactly match one of the values you entered when you registered your application, including upper/lowercase, terminating slashes, etc.
	* @state string Required. The state can be useful for correlating requests and responses. Because your redirect_uri can be guessed, using a state value can increase your assurance that an incoming connection is the result of an authentication request. If you generate a random string or encode the hash of some client state (e.g., a cookie) in this state variable, you can validate the response to additionally ensure that the request and response originated in the same browser. This provides protection against attacks such as cross-site request forgery
	* @scope string Optional. A space-separated list of scopes: see Using Scopes. If no scopes are specified, authorization will be granted only to access publicly available information: that is, only information normally visible in the Spotify desktop, web and mobile players.
	* @show_dialog boolean Optional. Whether or not to force the user to approve the app again if they’ve already done so. If false (default), a user who has already approved the application may be automatically redirected to the URI specified by redirect_uri. If true, the user will not be automatically redirected and will have to approve the app again.
	**/
	public string function authorize(
			required 	string client_id    = getClientID(),
			required 	string response_type = "code",
			required 	string redirect_uri = getRedirect_uri(),
			required 	string state        = hash(CreateUUID()),
			string scope                  = "",
			boolean 	show_dialog          = false
		)
	{
		var strURL = getAuth_base() & "/authorize/?" & buildParamString( arguments );
		return strURL;
	}

	public struct function requestToken(
			required string grant_type,
			required string scope = "",
			required string code = "",
			required string redirect_uri = getRedirect_uri(),
			required string refresh_token = ""
		)
	{
		var stuResponse = {};
		var requestData = {};
		var httpService = new http(url=getAuth_base() & "/api/token", method="POST");
			httpService.addParam(type="header",name="Authorization", value="Basic #createAuthBase64(getClientID(), getClientSecret())#");
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
			stuResponse = httpService.send().getPrefix();
		requestData = deserializeJSON( stuResponse.FileContent );
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

	/**
	* hint - matching official endpoint /v1/albums/{id}
	* @id The Spotify ID for this album
	* @json If set to false ColdFusion will return a struct of data. If true (default) the 'natural' JSON response will be returned.
	**/
	public any function getAlbum(
			required string id,
			boolean json = true
		)
	{
		return makeRequest(url=getApi_base() & "/albums/" & arguments.id, json=arguments.json);
	}

	/**
	* @json If set to false ColdFusion will return a struct of data. If true (default) the 'natural' JSON response will be returned.
	**/
	public any function getAlbums(
			required string ids,
			boolean json = true
		)
	{
		return makeRequest(url=getApi_base() & "/albums?ids=" & arguments.ids, json=arguments.json);
	}

	/**
	* @id The Spotify ID for this album
	* @limit Optional. The maximum number of items to return. Default: 20. Minimum: 1. Maximum: 50.
	* @offset Optional. The index of the first item to return. Default: 0 (the first object). Use with limit to get the next set of items.
	* @json If set to false ColdFusion will return a struct of data. If true (default) the 'natural' JSON response will be returned.
	**/
	public any function getAlbumTracks(
			required string id,
			string limit = "20",
			string offset ="0",
			boolean json = true
		)
	{
		var args = structcopy(arguments);
		structDelete(args,"id");
		return makeRequest(url=getApi_base() & "/albums/" & arguments.id & "/tracks?" & buildParamString(args), json=arguments.json);
	}

	/* Artist Data */

	/**
	* @id The Spotify ID for this artist.
	* @json If set to false ColdFusion will return a struct of data. If true (default) the 'natural' JSON response will be returned.
	**/
	public any function getArtist(
			required string id,
			boolean json = true
		)
	{
		return makeRequest(url=getApi_base() & "/artists/" & arguments.id, json=arguments.json);
	}

	/**
	* @json If set to false ColdFusion will return a struct of data. If true (default) the 'natural' JSON response will be returned.
	**/
	public any function getArtists(
				required string ids,
				boolean json = true
			)
	{
		return makeRequest(url=getApi_base() & "/artists?ids=" & arguments.ids, json=arguments.json);
	}

	/**
	* @album_type Optional. A comma-separated list of keywords that will be used to filter the response. If not supplied, all album types will be returned. Valid values are: album, single, appears_on, compilation. For example: album_type=album,single
	* @market Optional. An ISO 3166-1 alpha-2 country code. Supply this parameter to limit the response to one particular geographical market. For example, for albums available in Sweden: market=SE. If not given, results will be returned for all markets and you are likely to get duplicate results per album, one for each market in which the album is available!
	* @limit Optional. The maximum number of items to return. Default: 20. Minimum: 1. Maximum: 50.
	* @offset Optional. The index of the first item to return. Default: 0 (the first object). Use with limit to get the next set of items.
	* @json If set to false ColdFusion will return a struct of data. If true (default) the 'natural' JSON response will be returned.
	**/
	public any function getArtistAlbums(
			required string id,
			string album_type,
			string market,
			string limit = "20",
			string offset ="0",
			boolean json = true
		)
	{
		var args = structcopy(arguments);
		structDelete(args,"id");
		return makeRequest(url=getApi_base() & "/artists/" & arguments.id & "/albums?" & buildParamString(args), json=arguments.json);
	}

	/**
	* @country The country: an ISO 3166-1 alpha-2 country code.
	* @json If set to false ColdFusion will return a struct of data. If true (default) the 'natural' JSON response will be returned.
	**/
	public any function getArtistTopTracks(
			required string ids,
			required string country,
			boolean json = true
		)
	{
		return makeRequest(url=getApi_base() & "/artists/" & arguments.id & "/top-tracks?country=" & arguments.country, json=arguments.json);
	}

	/**
	* @json If set to false ColdFusion will return a struct of data. If true (default) the 'natural' JSON response will be returned.
	**/
	public any function getRelatedArtists(
			required string ids,
			boolean json = true
		)
	{
		return makeRequest(url=getApi_base() & "/artists/" & arguments.id & "/related-artists", json=arguments.json);
	}


	/* Playlist Methods */

	/**
	* @access_token Required. A valid access token  from the Spotify Accounts service: see the Web API Authorization Guide for details. The access token must have been issued on behalf of the current user. Reading the user's email address requires the user-read-email scope; reading country, display name, profile images, and product subscription level requires the user-read-private scope. See Using Scopes.
	* @locale Optional. The desired language, consisting of a lowercase ISO 639 language code and an uppercase ISO 3166-1 alpha-2 country code, joined by an underscore. For example: es_MX, meaning "Spanish (Mexico)". Provide this parameter if you want the results returned in a particular language (where available). Note that, if locale is not supplied, or if the specified language is not available, all strings will be returned in the Spotify default language (American English). The locale parameter, combined with the country parameter, may give odd results if not carefully matched. For example country=SE&locale=de_DE will return a list of categories relevant to Sweden but as German language strings.
	* @country Optional. A country: an ISO 3166-1 alpha-2 country code. Provide this parameter if you want the list of returned items to be relevant to a particular country. If omitted, the returned items will be relevant to all countries.
	* @timestamp Optional. A timestamp in ISO 8601 format: yyyy-MM-ddTHH:mm:ss. Use this parameter to specify the user's local time to get results tailored for that specific date and time in the day. If not provided, the response defaults to the current UTC time. Example: "2014-10-23T09:00:00" for a user whose local time is 9AM.
	* @limit Optional. The maximum number of items to return. Default: 20. Minimum: 1. Maximum: 50.
	* @offset Optional. The index of the first item to return. Default: 0 (the first object). Use with limit to get the next set of items.
	* @json If set to false ColdFusion will return a struct of data. If true (default) the 'natural' JSON response will be returned.
	**/
	public any function getFeaturedPlaylists(
			required string access_token,
			string locale,
			string country,
			string timestamp,
			string limit = "20",
			string offset ="0",
			boolean json = true
		)
	{
		var args = structcopy(arguments);
		structDelete(args,"access_token");
		return makeRequest(url=getApi_base() & "/browse/featured-playlists?" & buildParamString(args), access_token=arguments.access_token, json=arguments.json);
	}

	/**
	* @access_token Required. A valid access token  from the Spotify Accounts service: see the Web API Authorization Guide for details. The access token must have been issued on behalf of the current user. Reading the user's email address requires the user-read-email scope; reading country, display name, profile images, and product subscription level requires the user-read-private scope. See Using Scopes.
	* @country Optional. A country: an ISO 3166-1 alpha-2 country code. Provide this parameter if you want the list of returned items to be relevant to a particular country. If omitted, the returned items will be relevant to all countries.
	* @limit Optional. The maximum number of items to return. Default: 20. Minimum: 1. Maximum: 50.
	* @offset Optional. The index of the first item to return. Default: 0 (the first object). Use with limit to get the next set of items.
	* @json If set to false ColdFusion will return a struct of data. If true (default) the 'natural' JSON response will be returned.
	**/
	public any function getNewReleases(
			required string access_token,
			string country,
			string limit = "20",
			string offset ="0",
			boolean json = true
		)
	{
		var args = structcopy(arguments);
		structDelete(args,"access_token");
		return makeRequest(url=getApi_base() & "/browse/new-releases?" & buildParamString(args), access_token=arguments.access_token, json=arguments.json);
	}

	/* Profile Data */

	/**
	* @access_token Required. A valid access token  from the Spotify Accounts service: see the Web API Authorization Guide for details. The access token must have been issued on behalf of the current user. Reading the user's email address requires the user-read-email scope; reading country, display name, profile images, and product subscription level requires the user-read-private scope. See Using Scopes.
	* @json If set to false ColdFusion will return a struct of data. If true (default) the 'natural' JSON response will be returned.
	**/
	public any function getMe(
			required string access_token,
			boolean json = true
		)
	{
		return makeRequest(url=getApi_base() & "/me", access_token=arguments.access_token, json=arguments.json);
	}

	/**
	* @access_token Required. A valid access token  from the Spotify Accounts service: see the Web API Authorization Guide for details. The access token must have been issued on behalf of the current user. Reading the user's email address requires the user-read-email scope; reading country, display name, profile images, and product subscription level requires the user-read-private scope. See Using Scopes.
	* @limit Optional. The maximum number of items to return. Default: 20. Minimum: 1. Maximum: 50.
	* @offset Optional. The index of the first item to return. Default: 0 (the first object). Use with limit to get the next set of items.
	* @json If set to false ColdFusion will return a struct of data. If true (default) the 'natural' JSON response will be returned.
	**/
	public any function getMyTracks(
			required string access_token,
			string limit = "20",
			string offset ="0",
			boolean json = true
		)
	{
		var args = structcopy(arguments);
		structDelete(args,"access_token");
		return makeRequest(url=getApi_base() & "/me/tracks?" & buildParamString(args), access_token=arguments.access_token, json=arguments.json);
	}


	/**
	* hint Save one or more tracks to the current user’s “Your Music” library.
	* @access_token Required. A valid access token from the Spotify Accounts service: see the Web API Authorization Guide for details. Modification of the current user's "Your Music" collection requires authorization of the user-library-modify scope.
	* @ids Required. A comma-separated list of the Spotify IDs. For example: ids=4iV5W9uYEdYUVa79Axb7Rh,1301WleyT98MSxVHPZCA6M. Maximum: 50 IDs.
	* @json If set to false ColdFusion will return a struct of data. If true (default) the 'natural' JSON response will be returned.
	**/
	public any function saveTracksForUser(
			required string access_token,
			required string ids,
			boolean json = true
		)
	{
		return makeRequest(url=getApi_base() & "/me/tracks?ids=" & arguments.ids, access_token=arguments.access_token, method="PUT", json=arguments.json);
	}

	/**
	* hint Remove one or more tracks from the current user’s “Your Music” library.
	* @access_token Required. A valid access token from the Spotify Accounts service: see the Web API Authorization Guide for details. Modification of the current user's "Your Music" collection requires authorization of the user-library-modify scope.
	* @ids Required. A comma-separated list of the Spotify IDs. For example: ids=4iV5W9uYEdYUVa79Axb7Rh,1301WleyT98MSxVHPZCA6M. Maximum: 50 IDs.
	* @json If set to false ColdFusion will return a struct of data. If true (default) the 'natural' JSON response will be returned.
	**/
	public any function removeUserSavedTracks(
			required string access_token,
			required string ids,
			boolean json = true
		)
	{
		return makeRequest(url=getApi_base() & "/me/tracks?ids=" & arguments.ids, access_token=arguments.access_token, method="DELETE", json=arguments.json);
	}

	/**
	* hint Check if one or more tracks is already saved in the current Spotify user’s “Your Music” library.
	* @access_token Required. A valid access token from the Spotify Accounts service: see the Web API Authorization Guide for details. Modification of the current user's "Your Music" collection requires authorization of the user-library-modify scope.
	* @ids Required. A comma-separated list of the Spotify IDs for the tracks. Maximum: 50 IDs.
	* @json If set to false ColdFusion will return a struct of data. If true (default) the 'natural' JSON response will be returned.
	**/
	public any function checkUserSavedTracks(
			required string access_token,
			required string ids,
			boolean json = true
		)
	{
		return makeRequest(url=getApi_base() & "/me/tracks/contains?ids=" & arguments.ids, access_token=arguments.access_token, method="GET", json=arguments.json);
	}


	/**
	* hint Get Spotify catalog information about artists, albums, tracks or playlists that match a keyword string.
	* @access_token Required. A valid access token from the Spotify Accounts service: see the Web API Authorization Guide for details. Modification of the current user's "Your Music" collection requires authorization of the user-library-modify scope.
	* @q Required. The search query's keywords (and optional field filters and operators), for example q=roadhouse+blues. Encode spaces with the hex code %20, %2B or +. Matching of search keywords is not case-sensitive. (Operators, however, should be specified in uppercase.) Keywords will be matched in any order unless surrounded by double quotation marks: q=roadhouse&20blues will match both "Blues Roadhouse" and "Roadhouse of the Blues" while q="roadhouse&20blues" will match "My Roadhouse Blues" but not "Roadhouse of the Blues". Searching for playlists will return results where the query keyword(s) match any part of the playlist's name or description. Only popular public playlists are returned. The operator NOT can be used to exclude results. For example q=roadhouse+NOT+blues returns items that match "roadhouse" but excludes those that also contain the keyword "blues". Similarly, the OR operator can be used to broaden the search: q=roadhouse+OR+blues returns all results that include either of the terms. Only one OR operator can be used in a query. Note that operators must be specified in uppercase otherwise they will be treated as normal keywords to be matched. The asterisk (*) character can, with some limitations, be used as a wildcard (maximum: 2 per query). It will match a variable number of non-white-space characters. It cannot be used in a quoted phrase, in a field filter, or as the first character of the keyword string. By default, results are returned when a match is found in any field of the target object type. Searches can be made more specific by specifying an album, artist or track field filter. For example, the query q=album:gold+artist:abba&type=album will only return albums with the text "gold" in the album name and the text "abba" in the artist's name. The field filter year can be used with album, artist and track searches to limit the results to a particular year (for example, q=bob+year:2014) or date range (for example, q=bob+year:1980-2020). The field filter tag:new can be used in album searches to retrieve only albums released in the last two weeks. The field filter tag:hipster can be used in album searches to retrieve only albums with the lowest 10% popularity. Other possible field filters, depending on object types being searched, include genre, upc, and isrc. For example, q=damian+genre:reggae-pop&type=artist.
	* @type Required. A comma-separated list of item types to search across. Valid types are: album, artist, playlist, and track. Search results will include hits from all the specified item types; for example q=name:abacab&type=album,track will return both albums and tracks with "abacab" in their name.
	* @market Optional. An ISO 3166-1 alpha-2 country code or the string from_token. If a country code is given, only artists, albums, and tracks with content playable in that market will be returned. (Playlist results are not affected by the market parameter.) If from_token is given and a valid access token is supplied in the request header, only items with content playable in the country associated with the user's account will be returned. (The country associated with the user's account can be viewed by the user in their account settings at https://www.spotify.com/se/account/overview/). Note that the user must have granted access to the user-read-private scope when the access token was issued.
	* @limit Optional. The maximum number of items to return. Default: 20. Minimum: 1. Maximum: 50.
	* @offset Optional. The index of the first item to return. Default: 0 (the first object). Use with limit to get the next set of items.
	* @json If set to false ColdFusion will return a struct of data. If true (default) the 'natural' JSON response will be returned.
	**/
	public any function search(
		required string access_token,
		required string q,
		required string type,
		string market,
		string limit  = "20",
		string offset = "0",
		boolean json  = true
	){
		var args = structcopy( arguments );
		structDelete( args, "access_token" );
		return makeRequest(
			url          = getApi_base() & "/search?" & buildParamString( args ),
			access_token = arguments.access_token,
			method       = "GET",
			json         = arguments.json
		);
	}


	/* Track Data */



	/****************/
	/* UTILS        */
	/****************/


	private any function makeRequest(
		required string url,
		string access_token = "",
		string method = "GET",
		boolean json = true
	){
		var httpService = new http(url=arguments.url, method=arguments.method);
			if ( len(arguments.access_token) ) {
					httpService.addParam(type="header",name="Authorization", value="Bearer #arguments.access_token#");
			}
		var stuResponse = httpService.send().getPrefix();
		if( json ){
			return stuResponse.FileContent.toString();
		} else {
			if( len( stuResponse.FileContent.toString() ) ) {
				return deserializeJSON( stuResponse.FileContent );
			} else {
				return stuResponse.FileContent.toString();
			}
		}
	}


	/**
	* hint I loop through a struct to convert to query params for the URL
	*/
	private function buildParamString(
		required struct argScope
	){
		var strURLParam = "";
		for( key in arguments.argScope ){
			if( len( arguments.argScope[ key ] ) ){
				if( listLen( strURLParam ) ){
					strURLParam = strURLParam & '&';
				}
				strURLParam = strURLParam & lcase( key ) & '=' & arguments.argScope[ key ];
			}
		}
		return strURLParam;
	}


	public function createAuthBase64(
		required string clientId,
		required string clientSecret
	){
		return toBase64( arguments.clientId & ':' & arguments.clientSecret );
	}

}
