define([], () ->

  (kinds) ->
    self = {}
    self.onEvent = (e, out) ->
      console.log("LogEvent", e) if e.k in kinds
    self
)
