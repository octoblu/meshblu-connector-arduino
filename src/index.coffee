{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-arduino:index')
Kryten = require 'kryten'
kryten = new Kryten {repl: false}
_ = require 'lodash'
prev = {}

class Connector extends EventEmitter
  constructor: ->

  isOnline: (callback) =>
    callback null, running: true

  close: (callback) =>
    debug 'on close'
    callback()

  onConfig: (device={}) =>
    { @options } = device
    debug 'on config', @options
    @setOptions device

  start: (device, callback) =>
    debug 'started'
    @startKryten()
    @onConfig device
    callback()

  message: (command) =>
    return unless command.component?
    kryten.onMessage command

  setOptions: (device) =>
   @options = device.options
   debug 'options', @options
   return if _.isEqual(@options, prev)
   kryten.configure @options
   debug 'configuring kryten', @options
   prev = @options

  startKryten: () =>
    kryten.on 'ready', () =>
      kryten.on 'config', (schema) =>
        console.log schema

      kryten.on 'data', (data) =>
        @emit 'message', {
          devices: "*"
          payload: data
        }

module.exports = Connector
