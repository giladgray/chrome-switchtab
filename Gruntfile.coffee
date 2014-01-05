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
      sass:
        files: ["src/**/*.scss"]
        tasks: ["sass"]
      coffee:
        files: ["src/**/*.coffee"]
        tasks: ["coffee"]
      manifest:
        files: ["_manifest.json"]
        tasks: ["template:manifest.json"]
      popup:
        files: ["_popup.html"]
        tasks: ["template:popup.html"]

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
        src:  'bower_components/jquery/jquery.min.js'
        dest: 'dist/scripts/'

    imagemin:
      dist:
        expand: true
        src: ['assets/*icon*.png']
        dest: 'dist/'

  # run file through grunt template engine in context of package.json
  # assumes input file starts with _ and maps to output
  grunt.registerTask "template", "process template", (filepath) ->
    grunt.file.write "dist/#{filepath}",
      grunt.template.process grunt.file.read('_' + filepath), data: pkg

  grunt.registerTask "build", [
    "clean",
    "sass",
    "coffee",
    "copy",
    "template:manifest.json",
    "template:popup.html",
    "imagemin"
  ]

  grunt.registerTask "default", ["build"]
