EventSource = require("eventsource")

exports.use = ->
  # Add EventSource constructor to window.
  extend = (window)->
    window.EventSource = (url, proto) ->
      # Make sure that the origin is set correctly
      loc = window.location
      opts = { origin: "#{loc.protocol}//#{loc.hostname}", protocol: proto }
      if window.location.port
        opts.origin += ":" + window.location.port
      new EventSource(url, opts)
  return extend: extend
