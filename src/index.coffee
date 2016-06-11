{EventEmitter}  = require 'events'
_            = require 'lodash'
debug           = require('debug')('meshblu-connector-arduino:index')
Kryten = require 'kryten'
kryten = new Kryten {repl: false}
prev = {}
prevSchema = {}
FORMSCHEMA = ["*"]
defaultOptions = require './default-options.json'

class Arduino extends EventEmitter
  constructor: ->
    debug 'Arduino constructed'

  isOnline: (callback) =>
    callback null, running: true

  close: (callback) =>
    debug 'on close'
    callback()

  onMessage: (message) =>
    return unless message.payload?
    kryten.onMessage message

  onConfig: (config) =>
    return unless config?
    @setOptions config

  start: (device) =>
    debug 'started', device.uuid

    @startKryten()
    @onConfig device

  setOptions: (device) =>
   @options = device.options
   return unless device.schemas?
   @schemas = device.schemas
   debug 'options', @options
   return if _.isEqual(@options, prev)
   kryten.configure @options
   debug 'configuring kryten', @options
   prev = @options

  update: (properties) =>
    @emit 'update', properties
    debug 'updating', properties

  startKryten: () =>
    kryten.on 'ready', () =>
      kryten.on 'config', (schema) =>
        return if _.isEqual(@options, prev)
        debug 'updating'
        prevSchema = schema
        @schemas.message = schema
        @update {
          schemas: @schemas
        }
      kryten.on 'data', (data) =>
        @emit 'message', {
          devices: "*"
          payload: data
        }

module.exports = Arduino
