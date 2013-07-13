fs = require 'fs'

{print} = require 'sys'
{spawn} = require 'child_process'

binPath = './node_modules/.bin/'

# Returns a string with the current time to print out.
timeNow = ->
  today = new Date()
  today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds()

# Spawns an application with `options` and calls `onExit`
# when it finishes.
run = (bin, options, onExit) ->
  bin = binPath + bin
  console.log timeNow() + ' - running: ' + bin + ' ' + (if options? then options.join(' ') else "")
  cmd = spawn bin, options
  cmd.stdout.on 'data', (data) -> print data.toString()
  cmd.stderr.on 'data', (data) -> print data.toString()
  cmd.on 'exit', (code) ->
    console.log 'done.'
    onExit?(code, options)

build = (callback) ->
  options = ['-c', '-o', 'lib', 'src']
  run('coffee', options)

task 'build', 'Build lib/ from src/', ->
  build()

task 'watch', 'Watch src/ for changes', ->
  options = ['-w', '-c', '-o', 'lib', 'src']
  run('coffee', options)
