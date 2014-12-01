component extends="mxunit.framework.TestCase" {

  public any function setup() {
    variables.clientId = "0c0799e205a64c19a4e1acd319e7b368";
    variables.clientSecret = "0dfdc1fcecae4c82b3a771b94f726731";
    variables.redirect_uri = "http://127.0.0.1:8500/spotifywebapi/callback.cfm";
		variables.spotify	=	new spotifywebapi.com.coldfumonkeh.spotify.Spotify(
				clientID=variables.clientId,
        clientSecret=variables.clientSecret,
        redirect_uri=variables.redirect_uri
			);
    variables.albumId="0sNOF9WDwhWunNAHPD3Baj";
		//return this;
	}

  public any function clientIdIsCorrect() {
    var clientId = variables.spotify.getClientId();
    assertEquals(variables.clientId, clientId);
  }

  public any function clientSecretIsCorrect() {
    var clientSecret = variables.spotify.getClientSecret();
    assertEquals(variables.clientSecret, clientSecret);
  }

  public any function redirectURIIsCorrect() {
    var redirect_uri = variables.spotify.getRedirect_uri();
    assertEquals(variables.redirect_uri, redirect_uri);
  }

	public any function apiURLBaseIsCorrect() {
		var apiEndpoint = variables.spotify.getApi_base();
		assertEquals('https://api.spotify.com/v1', apiEndpoint);
	}

	public any function apiAuthBaseIsCorrect() {
    var apiEndpoint = variables.spotify.getAuth_base();
    assertEquals('https://accounts.spotify.com', apiEndpoint);
  }

  public any function authorizeURLIsCorrect() {
    var strState = '1234567890ABCDEFG';
    var strURL = variables.spotify.authorize(state=strState, scope='playlist-read-private playlist-modify-public playlist-modify-private user-library-read user-library-modify user-read-private user-read-email');
    var authURL = 'https://accounts.spotify.com/authorize/?state=1234567890ABCDEFG&redirect_uri=#variables.spotify.getredirect_uri()#&show_dialog=false&scope=playlist-read-private playlist-modify-public playlist-modify-private user-library-read user-library-modify user-read-private user-read-email&client_id=#variables.spotify.getClientId()#&response_type=code';
    assertEquals(authURL, strURL);
  }

  public any function getAlbumReturnsJSON() {
    var response = variables.spotify.getAlbum(id=variables.albumId);
    assertTrue(isJSON(response));
  }

  public any function getAlbumReturnsStruct() {
    var response = variables.spotify.getAlbum(id=variables.albumId, json=false);
    assertTrue(isStruct(response));
    assertTrue(structKeyExists(response, 'album_type'));
    assertTrue(structKeyexists(response, 'id'));
    assertEquals(response.id, variables.albumId);
  }

  public any function checkAuthBase64IsCorrect() {
    var authValue = variables.spotify.createAuthBase64(variables.spotify.getClientId(), variables.spotify.getClientSecret());
    assertEquals(authValue,"MGMwNzk5ZTIwNWE2NGMxOWE0ZTFhY2QzMTllN2IzNjg6MGRmZGMxZmNlY2FlNGM4MmIzYTc3MWI5NGY3MjY3MzE=");
  }

}
