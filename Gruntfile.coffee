"use strict"

# # Globbing
# for performance reasons we're only matching one level down:
# 'test/spec/{,*/}*.js'
# use this if you want to recursively match all subfolders:
# 'test/spec/**/*.js'
module.exports = (grunt) ->

  # load all grunt tasks
  require("matchdep").filterDev("grunt-*").forEach grunt.loadNpmTasks

  grunt.initConfig
    watch:
      coffee:
        files: ["src/*"]
        tasks: ["build"]
      # css:
      #   files: ["src/*.scss"]
      #   tasks: ['sass']


    clean:
      dist: [".tmp", "dist/*", "!dist/.git*"]

    coffee:
      dist:
        files: [
          expand: true
          cwd: "src"
          src: "*.coffee"
          dest: ".tmp"
          ext: ".js"
        ]

      test:
        files: [
          expand: true
          cwd: "test/spec"
          src: "*.coffee"
          dest: ".tmp/spec"
          ext: ".js"
        ]

    sass:
      dist:
        options:
          # sassDir: 'src',
          # cssDir: 'dist',
          # environment: 'production'
          style: 'compressed'
        files:
          'dist/style.css': 'src/style.scss'

    concat:
      dist:
        src:  ['bower_components/jquery/jquery.js', '.tmp/*.js']
        dest: 'dist/switchtab.js'

    requirejs:
      dist:

        # Options: https://github.com/jrburke/r.js/blob/master/build/example.build.js
        options:
          name: 'switchtab'
          out: 'dist/switchtab.js'
          optimize: "none"

          # because of coffee-script, we'll have requirejs compile from .tmp folder
          baseUrl: ".tmp"

          # paths for our own files (not bower_components)
          paths:
            jquery: 'node_modules/jquery'
          # TODO: Figure out how to make sourcemaps work with grunt-usemin
          # https://github.com/yeoman/grunt-usemin/issues/30
          #generateSourceMaps: true,
          # required to support SourceMaps
          # http://requirejs.org/docs/errors.html#sourcemapcomments
          preserveLicenseComments: false
          useStrict: true
          wrap: false

    mocha:
      all:
        options:
          run: true
          urls: ["http://localhost:<%= connect.options.port %>/index.html"]

  grunt.registerTask "build", ["clean:dist", "sass", "coffee:dist", "concat"]
  grunt.registerTask "test", ["build", "mocha"]

  grunt.registerTask "default", ["build"]
