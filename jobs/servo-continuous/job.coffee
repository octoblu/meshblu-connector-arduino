http = require 'http'

class ServoContinuous
  constructor: ({@connector}) ->
    throw new Error 'ServoContinuous requires connector' unless @connector?

  do: ({data}, callback) =>
    return callback @_userError(422, 'data.component is required') unless data?.component?
    @connector.message data

    metadata =
      code: 200
      status: http.STATUS_CODES[200]

    callback null, {metadata}

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = ServoContinuous
