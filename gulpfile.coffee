# core
{exec} = require 'child_process'

# gulp
gulp   = require 'gulp'
mocha  = require 'gulp-mocha'
gutil  = require 'gulp-util'
concat = require 'gulp-concat'
coffee = require 'gulp-coffee'

path =
  scripts: ['src/**/*.coffee']
  tests: ['test/**/*.coffee']

# Coffee scripts
gulp.task 'scripts', ->
    gulp.src(path.scripts)
        .pipe(coffee {bare: true})

        # gulp will stop when it error has occurred
        .on('error', gutil.log)
        .pipe(gulp.dest 'dist/src')

# Tests
gulp.task 'test', ->
  util = require 'gulp-util'
  exec 'npm test', (error, stdin, stdout)->
    console.log stdin, error
  
gulp.task 'build', ->

  # build nodejs file
  exec './node_modules/.bin/browserify dist/src/index.js -s UriTemplate -o ./dist/uri-template.js', (error, stdin, stdout)->
    console.log stdin, error

# The default task
gulp.task 'default', ->
  gulp.watch path.scripts, ['scripts', 'test']
  gulp.watch path.tests, ['test']