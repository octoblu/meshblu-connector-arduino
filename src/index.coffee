{EventEmitter}  = require 'events'
_            = require 'lodash'
debug           = require('debug')('meshblu-connector-arduino:index')
Kryten = require 'kryten'
kryten = new Kryten {}
defaultSchema = require './schemas.json'
prev = {}
prevSchema = {}
FORMSCHEMA = ["*"]
testOptions = defaultSchema.testOptions

class Arduino extends EventEmitter
  constructor: ->
    debug 'Arduino constructed'
    @options = testOptions
    @messageSchema = defaultSchema.MESSAGE_SCHEMA
    @optionsSchema = defaultSchema.OPTIONS_SCHEMA

    @starterDevice =
      options: @options
      messageSchema: @messageSchema
      optionsSchema: @optionsSchema

  isOnline: (callback) =>
    callback null, running: true

  close: (callback) =>
    debug 'on close'
    callback()

  onMessage: (message) =>
    return unless message?
    { topic, devices, fromUuid } = message
    return if '*' in devices
    return if fromUuid == @uuid

    kryten.onMessage message
    debug 'onMessage', { topic }

  onConfig: (config) =>
    return unless config?
    @setOptions config
    debug 'on config', @uuid

  start: (device) =>
    { @uuid } = device
    debug 'started', @uuid
    @startKryten()
    @setOptions device

  setOptions: (device) =>
   self = @
   @update(@starterDevice) unless device.optionsSchema?
   self.options = device.options || testOptions
   debug 'options', self.options
   if !_.isEqual device.options, prev
     debug 'options not equal'
     kryten.configure self.options
     prev = self.options

  update: (properties) =>
    @emit 'update', properties
    debug 'updating', properties

  startKryten: () =>
    self = @
    kryten.on 'ready', () =>
      kryten.on 'schema', (schema) =>
        if !_.isEqual(self.options, prev) || !_.isEqual(schema, prevSchema)
          debug 'updating'
          prevSchema = schema
          self.update {
            messageSchema: schema.MESSAGE_SCHEMA
            messageFormSchema: schema.FORMSCHEMA
            optionsSchema: defaultSchema.OPTIONS_SCHEMA
            optionsForm: defaultSchema.OPTIONS_FORM
          }
      kryten.on 'data', (data) =>
        @emit 'message', {
          devices: "*"
          payload: data
        }

module.exports = Arduino
