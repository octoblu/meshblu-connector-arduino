Connector = require '../'

describe 'Connector', ->
  beforeEach (done) ->
    @sut = new Connector
    @sut.start {}, done

  afterEach (done) ->
    @sut.close done

  describe '->isOnline', ->
    it 'should yield running true', (done) ->
      @sut.isOnline (error, response) =>
        return done error if error?
        expect(response.running).to.be.true
        done()

  xdescribe '->onConfig', ->
    describe 'when called with a config', ->
      it 'should not throw an error', ->
        expect(=> @sut.onConfig {
          "autoDetect": true,
          "port": "",
          "interval": "500",
          "components": [{
            "name": "Led_Pin_13",
            "action": "digitalWrite",
            "pin": "13"
          }, {
            "name": "some_sensor",
            "action": "analogRead",
            "pin": "3"
          }, {
            "name": "Servo1",
            "action": "servo",
            "pin": "6"
          }]
        }).to.not.throw(Error)
