{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-arduino:index')
Kryten = require 'kryten'
kryten = new Kryten {repl: false}
_ = require 'lodash'

UpdateSchema = require './update-components.coffee'
updateSchema = new UpdateSchema
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
    callback()

    debug 'started'
    @startKryten()
    @onConfig device

  message: (command) =>
    return unless command.component?
    kryten.onMessage command

  setOptions: (device) =>
   @options = device.options
   { components } = @options
   debug 'options', @options
   return if _.isEqual(@options, prev)

   @emit 'update', schemas: updateSchema.generate(components, device.schemas)
   debug 'configuring kryten', @options
   kryten.configure @options
   prev = @options

  startKryten: () =>
    kryten.on 'ready', () =>
      kryten.on 'data', (data) =>
        @emit 'message', {
          devices: "*"
          payload: data
        }

module.exports = Connector
