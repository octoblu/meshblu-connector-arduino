_ = require 'lodash'

class UpdateSchema

  componentList: (components) =>
    comp = {}
    components.forEach (component) ->
      action = "DigitalWrite" if component.action == "digitalWrite"
      action = "AnalogWrite" if component.action == "analogWrite"
      action = "Servo" if component.action == "servo"
      action = "ServoContinuous" if component.action == "servo-continuous"
      action = "Lcd" if component.action == "LCD-PCF8574A"
      action = "Lcd" if component.action == "LCD-JHD1313M1"
      action = "Oled" if component.action == "oled-i2c"
      action = "Esc" if component.action == "esc"

      return unless action?
      comp[action] = [] if !comp[action]?
      comp[action].push component.name
    return comp

  generate: (components, schemas) =>
    components = @componentList components
    _.forEach components, (value, key) =>
      return unless value?
      if !schemas.message[key].properties.data.properties.component.enum?
        schemas.message[key].properties.data.properties.component.enum = []
      schemas.message[key].properties.data.properties.component.enum = value
    return schemas

module.exports = UpdateSchema
