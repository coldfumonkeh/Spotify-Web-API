module.exports = function(grunt) {
  grunt.initConfig({
    http: {
      your_service: {
        options: {
          url: 'http://127.0.0.1:8500/spotifywebapi/?reinit',
        }
      }
    },
    watch: {
      source: {
        files: 'com/coldfumonkeh/spotify/Spotify.cfc',
        tasks: ['http'],
        options: {
          reload: true
        }
      }
    }
  })

  grunt.loadNpmTasks('grunt-http');
  grunt.loadNpmTasks('grunt-contrib-watch');

  grunt.registerTask('default', ['watch']);

};
