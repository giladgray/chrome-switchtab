"use strict"

# # Globbing
# for performance reasons we're only matching one level down:
# 'test/spec/{,*/}*.js'
# use this if you want to recursively match all subfolders:
# 'test/spec/**/*.js'
module.exports = (grunt) ->
  pkg = grunt.file.readJSON('package.json')

  # load all grunt tasks
  require("matchdep").filterDev("grunt-*").forEach grunt.loadNpmTasks

  grunt.initConfig
    watch:
      files: ["src/*"]
      tasks: ["build"]

    clean:
      dist: ["dist"]

    coffee:
      dist:
        files: [
          expand: true
          cwd: "src"
          src: "*.coffee"
          dest: "dist/scripts"
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
          style: 'compressed'
        files:
          'dist/styles/style.css': 'src/style.scss'

    copy:
      dist:
        expand: true
        flatten: true
        src:  ['bower_components/jquery/jquery.min.js']
        dest: 'dist/scripts'

    imagemin:
      dist:
        expand: true
        src: ['assets/*.png']
        dest: 'dist/'

    mocha:
      all:
        options:
          run: true
          urls: ["http://localhost:<%= connect.options.port %>/index.html"]

  grunt.registerTask "template", "process template", (filepath) ->
    grunt.file.write "dist/#{filepath}",
      grunt.template.process grunt.file.read('_' + filepath), data: pkg

  grunt.registerTask "build", [
    "clean:dist",
    "sass",
    "coffee:dist",
    "copy",
    "template:manifest.json",
    "template:popup.html",
    "imagemin"
  ]
  grunt.registerTask "test", ["build", "mocha"]

  grunt.registerTask "default", ["build"]
