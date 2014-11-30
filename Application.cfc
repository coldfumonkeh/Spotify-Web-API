component {

	this.name = "SpotiMonkeh";
	this.sessionManagement = true;
	this.sessionTimeout = CreateTimeSpan(0, 0, 30, 0);

	function onApplicationStart() {
		application.objSpotify =
		createObject('component', 'com.coldfumonkeh.spotify.Spotify')
		.init(
			clientID="0c0799e205a64c19a4e1acd319e7b368",
			clientSecret="0dfdc1fcecae4c82b3a771b94f726731",
			redirect_uri="http://127.0.0.1:8500/spotifywebapi/callback.cfm"
		);

		return this;
	}

	function onRequestStart() {
		if (structKeyExists(URL, 'reinit')) {
			onApplicationStart();
		}
	}

}
